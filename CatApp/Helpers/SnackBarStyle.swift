//
//  SnackBarStyle.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import Foundation
import SnackBar_swift

class SnackBarWarning: SnackBar {
    
    override var style: SnackBarStyle {
        var style = SnackBarStyle()
        style.background = .red
        style.textColor = .white
        return style
    }
}
class SnackBarSuccess: SnackBar {
    
    override var style: SnackBarStyle {
        var style = SnackBarStyle()
        style.background = .green
        style.textColor = .white
        return style
    }
}
