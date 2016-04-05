//
//  TimeTableViewController.swift
//  Pakua
//
//  Created by Leonardo Iacovini on 12/03/15.
//  Copyright (c) 2015 Leonardo Iacovini. All rights reserved.
//

import UIKit

var fastCacheJson: NSData? // Simple and 'poor' in memory cache, but does the job

class TimeTableViewController: UITableViewController {

    // MARK: - Class properties
    
    var aulasList: [Aula]!
    var diaSegment: UISegmentedControl!
    var jsonData: NSData! 
    var recinto: String!
    var backView: UIView!
    var label: UILabel!
    let timetableURL = NSURL(string: "https://dl.dropboxusercontent.com/u/24418684/horarios.json")!
    
    // MARK: - Load and Unload Methods (View LifeCycle)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aulasList = []
        self.navigationController?.setToolbarHidden(false, animated: true)
        diaSegment = UISegmentedControl(items: ["Seg", "Ter", "Qua", "Qui", "Sex", "Sab"])
        
        let height = self.navigationController!.toolbar.frame.height - 10
        let width = self.navigationController!.toolbar.frame.width - 10
        
        diaSegment.frame = CGRectMake(5, 5, width, height)
        self.navigationController?.toolbar.addSubview(diaSegment)
        diaSegment.selectedSegmentIndex = 0
        diaSegment.addTarget(self, action: #selector(TimeTableViewController.diaMudou(_:)), forControlEvents: UIControlEvents.ValueChanged)
        backView = UIView(frame: self.tableView.frame)
        self.label = UILabel(frame: self.tableView.frame)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.grayColor()
        label.font = UIFont(name: "Avenir", size: 22)
        label.text = "Carregando"
        backView.addSubview(label)
        self.tableView.backgroundView = backView
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        fetchDataFromWhereverPossible("segunda")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "Sem Internet", message: "Você não está conectado à internet, alguns serviços não estarão disponivéis", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        diaSegment.selectedSegmentIndex = 0
        diaSegment.removeFromSuperview()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: - IBActions
    
    @IBAction func refreshDataFromNetwork() {
        fetchDataFromWhereverPossible(getDiaSelecionado(), fromCache: false)
    }
    
    func parseJsonData(dia: String, data: NSData? = nil, reload: Bool = false) {
        if data != nil {
            aulasList = Aula.parseFromJsonData(data!, recinto: recinto ,diaDaSemana: dia)
            if reload { self.tableView.reloadData() }
        } else {
            print("Json Invalido ou Inexistente")
        }
    }
    
    // MARK: - View Actions
    
    func fetchDataFromWhereverPossible(diaDaSemana: String, fromCache: Bool = true) {
        if  fastCacheJson != nil && fromCache {
            self.jsonData = fastCacheJson
            self.parseJsonData(getDiaSelecionado(), data: self.jsonData)
            self.label.text = "Nenhuma Aula"
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        else {
            NetworkManager.getDataFromURL(timetableURL, block: { (data) -> () in
                if data != nil {
                    self.jsonData = data
                    CacheManager.saveDataToCache("horarios", data: self.jsonData)
                    self.parseJsonData(self.getDiaSelecionado(), data: self.jsonData)
                    fastCacheJson = data
                    self.tableView.reloadData()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.label.text = "Nenhuma Aula"
                    if !fromCache {
                        let alert = UIAlertController(title: "Atualizado Com Sucesso", message: "Novos dados foram atualizados", preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else if fromCache {
                    if CacheManager.checkIfExists("horarios") {
                        print("Disk Cache")
                        self.jsonData = CacheManager.retriveCache("horarios") as! NSData
                        fastCacheJson = self.jsonData
                        print(self.jsonData)
                        self.parseJsonData(self.getDiaSelecionado(), data: self.jsonData, reload: true)
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.label.text = "Nenhuma Aula"
                        self.showInternetAlert("Não foi possível obter a versão mais recente a partir dos nossos servidores, você está usando a versão disponível no cache do seu dispositivo")
                    } else {
                        self.showInternetAlert("Não foi possível obter dados a partir do nosso servidor, infelizmente não encontramos dados salvos no seu dispositivo :(")
                        print("Dai Fedeu")
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.label.text = "Erro ao obter horários"
                    }
                }
            })
        }
    }
    
    func showInternetAlert(message: String) {
        let alert = UIAlertController(title: "Sem Conexão", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    func diaMudou(sender: UISegmentedControl!) {
        let diaDaSemana = Weekdays(abreviacao: diaSegment.titleForSegmentAtIndex(diaSegment.selectedSegmentIndex)!).rawValue
        self.navigationItem.title = diaDaSemana.capitalizedString + " " + "Feira"
        print(diaDaSemana)
        parseJsonData(diaDaSemana, data: jsonData)
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func getDiaSelecionado() -> String {
        return Weekdays(abreviacao: diaSegment.titleForSegmentAtIndex(diaSegment.selectedSegmentIndex)!).rawValue
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        backView.hidden = aulasList.count == 0 ? false : true
        return aulasList.count
    }
    
    var tipoCell1 = true
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: AulaTableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("timeTableCell", forIndexPath: indexPath) as! AulaTableViewCell
        cell.praticaLabel.text = aulasList[indexPath.row].nome!
        cell.inicioLabel.text = aulasList[indexPath.row].inicio!
        cell.inicioLabel.text! += " - " + aulasList[indexPath.row].termino!
        cell.drawMark()
        return cell
    }
    
}

// MARK: - AulaTableViewCell

class AulaTableViewCell: UITableViewCell {
    @IBOutlet weak var praticaLabel: UILabel!
    @IBOutlet weak var inicioLabel: UILabel!
    @IBOutlet weak var centralMark: UIView!
    
    func drawMark() {
        centralMark.layer.cornerRadius = 7.5
        centralMark.backgroundColor = UIColor.whiteColor()
        centralMark.layer.borderColor = UIColor(red: 0.839, green: 0.847, blue: 0.851, alpha: 1).CGColor
        centralMark.layer.borderWidth = 2
    }
}



