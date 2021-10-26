//
//  ViewController.swift
//  atom-sdk-ios-swift
//
//  Created by Arsalan Wahid Asghar on 10/25/21.
//

import UIKit
import AtomSDK
import AtomCore

class ViewController: UIViewController {
 
    
    @IBOutlet weak var tableview: UITableView!
    
    var allCitiesList = Array<AtomCity>()
    var allProtocols = Array<AtomProtocol>()
    var allCountries = Array<AtomCountry>()
    var vpnStatus: [String] = [];
    
//    add table view property
//    make a status handler function and add values to status change
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusDidChangedHandler()
        
        AtomManager.sharedInstance()?.delegate = self
        
        getAtomData()
        
        let state = AtomManager.sharedInstance()?.getCurrentVPNStatus()
        switch state {
        case .CONNECTED:
            print("CONNECTED")
        case .DISCONNECTED:
            print("DISCONNECTED")
        case .none, .some(_):
            print("hmm")
        }
        
    }
    
    @IBAction func connect(_ sender: UIButton) {
        connectWithParams()
    }
    
    
    func connectWithParams() {
        // setup user credentials
//        for (index, object) in allCitiesList.enumerated() {
//            print("\(index)- \(object)")
//        }
//
//        for (index, object) in allProtocols.enumerated() {
//            print("\(index)- \(object.protocol)")
//        }
//
        print(allCountries[1].recommendedProtocol?.protocol)
//        print(allCitiesList[14])
//        print(allProtocols[1].protocol)
        
        var properties: AtomProperties
        let atomCredentials = AtomCredential(username: Constants.credentials.username, password: Constants.credentials.password)
        AtomManager.sharedInstance()?.atomCredential = atomCredentials
        
//        properties = AtomProperties(city: allCitiesList[14], protocol: allProtocols[1])
        
        let atomCountry = AtomCountry()
        atomCountry.country = "us"
        
        let atomProtocol = AtomProtocol()
        atomProtocol.protocol = "ipsec"
        
        properties = AtomProperties.init(country: atomCountry, protocol: atomProtocol)
//        properties.useSmartDialing = false;
        
        let configuration = AtomOnDemandConfiguration()
        configuration.onDemandRulesEnabled = true
        AtomManager.sharedInstance()?.onDemandConfiguration = configuration
        
        AtomManager.sharedInstance()?.connect(with: properties, completion: {(success) in print("connected")}, errorBlock: {(error) in print("configuration is not correct")})
    }

    func getAtomData() {
        AtomManager.sharedInstance()?.getCountriesWithSuccess({ [self] countryList in
            allCountries = countryList!
        }, errorBlock: {
            error in
            //NSLog(@"%@",error.description);
        })
        
        // Do any additional setup after loading the view.
        AtomManager.sharedInstance()?.getCitiesWithSuccess({ [self] citiesList in
            allCitiesList = citiesList!
        }) { error in
            //NSLog(@"%@",error.description);
        }
        
        AtomManager.sharedInstance()?.getProtocolsWithSuccess({[self] protocols in
            allProtocols = protocols!
        }, errorBlock: {
            (error) in
            //
        })
    }
}

extension ViewController: AtomManagerDelegate {
    func atomManagerDidInitialized(_ sharedInstance: AtomManager) {
        print("VPN initialized")
    }
    
    func atomManagerDidConnecting(_ atomConnectionDetails: AtomConnectionDetails?) {
        print("VPN connecting")
    }
    
    func atomManagerDidConnect(_ atomConnectionDetails: AtomConnectionDetails?) {
        print("VPN connected")
    }
    
    func atomManagerDidDisconnect(_ atomConnectionDetails: AtomConnectionDetails?) {
        print("VPN disconnecting")
    }
    
    func atomManager(onRedialing atomConnectionDetails: AtomConnectionDetails?, withError error: Error?) {
        print("VPN error redialing \(error.debugDescription)")
    }
    
    func atomManagerDialErrorReceived(_ error: Error?, with atomConnectionDetails: AtomConnectionDetails?) {
        print("VPN error \(error.debugDescription)")
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vpnStatus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = vpnStatus[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell.textLabel?.textColor = UIColor.black
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20.0
    }
    
    func statusDidChangedHandler() {
        AtomManager.sharedInstance()?.stateDidChangedHandler = { status in
            switch status {
            case .statusInvalid:
                self.vpnStatus.append("Invalid")
                break;
            case .statusDisconnected:
                self.vpnStatus.append("Disconnected")
                break;
            case .statusConnecting:
                self.vpnStatus.append("Connecting")
                break;
            case .statusConnected:
                self.vpnStatus.append("Connected")
                break;
            case .statusReasserting:
                self.vpnStatus.append("Reasserting")
                break;
            case .statusDisconnecting:
                self.vpnStatus.append("Disconnecting")
                break;
            case .statusValidating:
                self.vpnStatus.append("Validating")
                break;
            case .statusGeneratingCredentials:
                self.vpnStatus.append("GeneratingCredentials")
                break;
            case .statusGettingFastestServer:
                self.vpnStatus.append("GettingFastestServer")
                break;
            case .statusOptimizingConnection:
                self.vpnStatus.append("OptimizingConnection")
                break;
            case .statusVerifyingHostName:
                self.vpnStatus.append("Verifying Hostname")
                break;
            case .statusAuthenticating:
                self.vpnStatus.append("Authenticating")
                break;
            case .statusInternetChecking:
                self.vpnStatus.append("InternetChecking")
                break;
            @unknown default:
                break
            }
            self.tableview.reloadData()
        }
    }
    
}
