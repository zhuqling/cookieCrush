
import UIKit
import CloudKit

class menuViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        CloudManager.sharedInstance.getData()
    }
    
    @IBAction func startButton(sender: UIButton) {
        
        
    }
    
    @IBAction func leaderBoardButton(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("leaderNav") as! UINavigationController
        
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var instructionsButton: UIButton!
    

}
