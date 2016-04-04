//
//  Aula.swift
//  PakuaSP
//
//  Created by Leonardo Iacovini on 4/3/16.
//  Copyright © 2016 Leonardo Iacovini. All rights reserved.
//

import Foundation

struct Aula {
    
    var nome: String!
    var inicio: String!
    var termino: String!
    
    init(nome: String, inicio: String, termino: String) {
        self.nome = nome
        self.inicio = inicio
        self.termino = termino
    }
    
    init() {
        self.nome = ""
        self.inicio = ""
        self.termino = ""
    }
    
    static func parseFromJsonData(jsonData: NSData, recinto: String ,diaDaSemana: String) -> [Aula] {
        var aulasList: [Aula] = []
        let json = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions()) as! NSDictionary
        
        let aulasRecinto = json[recinto] as! NSDictionary
        let aulasJsonArr = aulasRecinto[diaDaSemana] as! NSArray
        
        for aula in aulasJsonArr {
            let aulaDic = aula as! NSDictionary
            let nomeAula = aulaDic["pratica"] as! String
            let inicioAula = aulaDic["horarioInicio"] as! String
            let terminoAula = aulaDic["horarioTermino"] as! String
            aulasList.append(Aula(nome: nomeAula, inicio: inicioAula, termino: terminoAula))
        }
        return aulasList
    }
}