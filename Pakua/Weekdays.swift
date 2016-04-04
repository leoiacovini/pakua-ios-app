//
//  Weekdays.swift
//  PakuaSP
//
//  Created by Leonardo Iacovini on 4/3/16.
//  Copyright © 2016 Leonardo Iacovini. All rights reserved.
//

import Foundation

enum Weekdays: String {
    case Segunda = "segunda"
    case Terca = "terca"
    case Quarta = "quarta"
    case Quinta = "quinta"
    case Sexta = "sexta"
    case Sabado = "sabado"
    case Domingo = "domingo"
    
    init(abreviacao: String) {
        switch abreviacao {
        case "Seg":
            self = .Segunda
        case "Ter":
            self = .Terca
        case "Qua":
            self = .Quarta
        case "Qui":
            self = .Quinta
        case "Sex":
            self = .Sexta
        case "Sab":
            self = .Sabado
        default:
            self = .Domingo
        }
    }
}