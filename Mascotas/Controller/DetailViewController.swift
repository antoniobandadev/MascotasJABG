//
//  ViewController.swift
//  Mascotas
//
//  Created by Ángel González on 26/04/25.
//, UIPickerViewDataSource, UIPickerViewDelegate

import UIKit


class DetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var laMascota : Mascota!
    var detalle: DetailView!
    var responsables = [Responsable]()
    var responsableSeleccionado: Responsable?
    var cerrarPorDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        detalle = DetailView(frame:view.bounds.insetBy(dx: 40, dy: 40))
        view.addSubview(detalle)
        detalle.pickerView.delegate = self
        detalle.pickerView.dataSource = self
        detalle.txtPicker.delegate = self
        responsables = DataManager.shared.todosLosResponsables()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: - Obtener y presentar la información de la mascota
        initUI()
    }
    
    
    func initUI() {
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        detalle.txtNombre.text = laMascota.nombre ?? ""
        detalle.txtGenero.text = laMascota.genero ?? ""
        detalle.txtTipo.text = laMascota.tipo ?? ""
        detalle.txtEdad.text = "\(laMascota.edad)"
        detalle.btnDelete.addTarget(self, action:#selector(borrar), for:.touchUpInside)
        detalle.btnAdopt.addTarget(self, action: #selector(abrirPicker), for: .touchUpInside)
        
        detalle.toolbar.setItems([flexible, doneButton], animated: false)
        
        //detalle.txtPicker.inputView = detalle.pickerView.view
        
        // TODO: - Si la mascota ya tiene un responsable, ocultar el botón
        if laMascota.responsable != nil {
            detalle.btnAdopt.isHidden = true
            detalle.txtPicker.isHidden = true
            let ownerInfo = ((laMascota.responsable?.nombre) ?? "") + " " + ((laMascota.responsable?.apellido_paterno) ?? "")
            detalle.lblResponsable.isHidden = false
            detalle.lblResponsable.frame.size.height = 50
            detalle.lblResponsable.text = "Dueño: \(ownerInfo)"
            detalle.lblResponsable.sizeToFit()
        }
        else {
            detalle.btnAdopt.isHidden = false
            detalle.txtPicker.isHidden = true
            detalle.lblResponsable.isHidden = true
            detalle.lblResponsable.frame.size.height = 0
        }
        
        
    }
    
    // Acción del botón Done
    @objc func doneTapped() {
        detalle.txtPicker.resignFirstResponder() // Cierra el picker o el teclado
        if let responsableSeleccionado {
            DataManager.shared.asignarResponsableAMascota(responsableSeleccionado, laMascota.id)
        }
        initUI()
    }
    
    
    @objc
    func abrirPicker(_ sender: UIButton) {
        detalle.txtPicker.becomeFirstResponder()
    }
    
    @objc
    func borrar () {
        let ac = UIAlertController(title: "CONFIRME", message:"Desea borrar este registro?", preferredStyle: .alert)
        let action = UIAlertAction(title: "SI", style: .destructive) {
            alertaction in
            DataManager.shared.borrar(objeto:self.laMascota)
            // si se implementa con navigation controller:
            self.navigationController?.popViewController(animated: true)
            // self.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "NO", style:.cancel)
        ac.addAction(action)
        ac.addAction(action2)
        self.present(ac, animated: true)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return responsables.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let nombreCompleto = "\(responsables[row].nombre ?? "") \(responsables[row].apellido_paterno ?? "") \(responsables[row].apellido_materno ?? "")"
        return nombreCompleto
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        responsableSeleccionado = responsables[row]
    }
    
}

