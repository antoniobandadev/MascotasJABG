//
//  DetailView.swift
//  Pets
//
//  Created by Ángel González on 19/10/24.
//

import UIKit

class DetailView: UIView{
    
    let btnDelete = UIButton(type: .system)
    let txtNombre = UITextField()
    let txtTipo = UITextField()
    let txtGenero = UITextField()
    let txtEdad = UITextField()
    let btnAdopt = UIButton(type: .custom)
    let lblResponsable = UILabel()
    let pickerView = UIPickerView()
    let txtPicker = UITextField()
    
    
    override func draw(_ rect: CGRect) {
        // Crear el stack view
        let stackView = UIStackView()
        
        // Configurar propiedades del stack view
        stackView.axis = .vertical // Disposición vertical
        stackView.spacing = 15 // Espaciado entre los elementos
        stackView.alignment = .fill // Alinear a llenar el espacio
        stackView.translatesAutoresizingMaskIntoConstraints = false // Utilizar Auto Layout
        
        // Agregamos los elementos:
        txtNombre.borderStyle = .roundedRect // Estilo del borde
        txtNombre.placeholder = "Nombre" // Texto de marcador
        stackView.addArrangedSubview(txtNombre) // Agregar al stack view
        
        txtGenero.borderStyle = .roundedRect // Estilo del borde
        txtGenero.placeholder = "Género" // Texto de marcador
        stackView.addArrangedSubview(txtGenero) // Agregar al stack view
        
        txtTipo.borderStyle = .roundedRect // Estilo del borde
        txtTipo.placeholder = "Tipo" // Texto de marcador
        stackView.addArrangedSubview(txtTipo) // Agregar al stack view
        
        txtEdad.borderStyle = .roundedRect // Estilo del borde
        txtEdad.placeholder = "Edad" // Texto de marcador
        stackView.addArrangedSubview(txtEdad) // Agregar al stack view
        
        txtPicker.borderStyle = .roundedRect
        txtPicker.placeholder = "Seleccione un responsable"
        //pickerView.center = stackView.center
        txtPicker.inputView = pickerView
        stackView.addArrangedSubview(txtPicker)
        
        btnAdopt.backgroundColor = .red
        btnAdopt.setTitle("Adoptar", for: .normal)
        stackView.addArrangedSubview(btnAdopt)
        
        lblResponsable.backgroundColor = .red.withAlphaComponent(0.5)
        lblResponsable.textColor = .white
        stackView.addArrangedSubview(lblResponsable)
        
        btnDelete.setImage(UIImage(systemName: "pip.remove"), for: .normal)
        stackView.addArrangedSubview(btnDelete)
        
        
        
        
        
        // Agregar el stack view a la vista principal
        self.addSubview(stackView)
        
        
        // Configurar las restricciones del stack view
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor), // Centrar horizontalmente
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor), // Centrar verticalmente
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8), // Ancho del stack view
        ])
    }

}
