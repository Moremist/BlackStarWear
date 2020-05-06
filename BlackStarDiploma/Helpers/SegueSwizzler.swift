import UIKit

class Box {
    let value: Any
    init(_ value: Any) {
        self.value = value
    }
}

extension UIViewController {
    struct AssociatedKey {
        static var ClosurePrepareForSegueKey = "ClosurePrepareForSegueKey"
    }
    
    typealias ConfiguratePerformSegue = (UIStoryboardSegue) -> ()
    func performSegueWithIdentifier(identifier: String, sender: AnyObject?, configurate: ConfiguratePerformSegue?) {
        print(UIViewController.swizzlingPrepareForSegue)
        configuratePerformSegue = configurate
        performSegue(withIdentifier: identifier, sender: sender)
    }
    
    static let swizzlingPrepareForSegue : Bool = {
         
        let originalSelector = #selector(UIViewController.prepare)
        let swizzledSelector = #selector(UIViewController.closurePrepareForSegue(segue:sender:))
        
        let instanceClass = UIViewController.self
        let originalMethod = class_getInstanceMethod(instanceClass, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(instanceClass, swizzledSelector)!
        
        let didAddMethod = class_addMethod(instanceClass, originalSelector,
                                           method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(instanceClass, swizzledSelector,
                                method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        return true
    }()
    
    @objc func closurePrepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        configuratePerformSegue?(segue)
        closurePrepareForSegue(segue: segue, sender: sender)
        configuratePerformSegue = nil
    }
    
    var configuratePerformSegue: ConfiguratePerformSegue? {
        get {
            let box = objc_getAssociatedObject(self, &AssociatedKey.ClosurePrepareForSegueKey) as? Box
            return box?.value as? ConfiguratePerformSegue
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.ClosurePrepareForSegueKey, Box(newValue as Any), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
