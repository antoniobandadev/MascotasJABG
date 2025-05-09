//
//  DataManager.swift
//  Mascotas
//
//  Created by Ángel González on 26/04/25.
//

import Foundation
import CoreData

class DataManager : NSObject {
    static let shared = DataManager()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Mascotas")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Custom methods
    func llenaBD () {
        // validar si la BD ya se sincronizo
        let ud = UserDefaults.standard
        if ud.integer(forKey: "BD-OK") != 1 {
            if let url = URL (string:"http://janzelaznog.com/DDAM/iOS/mascotas.json") {
                let sesion = URLSession(configuration:.default)
                let task = sesion.dataTask(with: URLRequest(url: url)) {
                    datos, respuesta, err in
                    if err != nil && datos == nil {
                        print ("no se pudo descargar el feed de mascotas")
                        return
                    }
                    // parece que todo bien
                    do {
                        // si no se quieren utilizar estructuras que implementen Codable:
                        //let tmp = try JSONSerialization.jsonObject(with: datos!) as! [[String:Any]]
                        let arreglo = try JSONDecoder().decode([MascotaVO].self, from: datos!)
                        self.guardaMascotas (arreglo)
                        
                    }
                    catch {
                        print ("algo falló \(error.localizedDescription)")
                    }
                }
                task.resume()
            }
            
             if let url = URL(string: "http://janzelaznog.com/DDAM/iOS/responsables.json"){
                 let session = URLSession(configuration: .default)
                 let task = session.dataTask(with: URLRequest(url: url)){
                     data, response, error in
                     
                     if error != nil && data == nil {
                         print("No se pudo descargar el feed de mascotas")
                         return
                     }
                     
                     do{
                        
                         let arrayResponsables = try JSONDecoder().decode([ResponsableVO].self, from: data!)
                         //print(arrayResponsables)
                         
                         self.guardaResponsables(arrayResponsables, self.persistentContainer.viewContext)
                         
                     }
                     catch{
                         print("Error : \(error.localizedDescription)")
                     }
                     
                 }
                 task.resume()
             }
            ud.setValue(1, forKey: "BD-OK")
        }
        // La BD ya fue sincronizada anteriormente
    }
    
    func guardaMascotas (_ mascotas:[MascotaVO]) {
        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Mascota", in: persistentContainer.viewContext) else { return }
        mascotas.forEach { mascotaVO in   // for m in mascotas { ... }
            let mascota = NSManagedObject(entity: entidadDesc, insertInto:persistentContainer.viewContext) as! Mascota
            mascota.inicializa(mascotaVO)
        }
        saveContext()
    }
    
    func guardaResponsables(_ responsables:[ResponsableVO], _ context: NSManagedObjectContext) {
        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Responsable", in: context) else { return }

        responsables.forEach { responsableVO in
            let responsable = NSManagedObject(entity: entidadDesc, insertInto: context) as! Responsable
            responsable.inicializa(responsableVO)

            let fetchRequest: NSFetchRequest<Mascota> = Mascota.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", responsable.duenio_de)

            if let mascota = try? context.fetch(fetchRequest).first {
                responsable.addToMascotas(mascota)
                mascota.responsable = responsable
            } else {
                print("No se encontró la mascota con ID \(responsable.duenio_de)")
            }
        }

        do {
            try context.save()
        } catch {
            print("Error al guardar el contexto: \(error)")
        }
    }
    
   
    
    func todasLasMascotas() -> [Mascota] {
        var arreglo = [Mascota]()
        let elQuery = Mascota.fetchRequest()
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
        }
        catch {
            print ("no se puede ejecutar el query SELECT * FROM Mascota")
        }
        let sortedA = arreglo.sorted {m1, m2  in
            return m1.nombre ?? "" < m2.nombre ?? ""  // Descendente
        }
        return sortedA
    }
    
    func todosLosResponsables() -> [Responsable] {
        var arreglo = [Responsable]()
        let elQuery = Responsable.fetchRequest()
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
        }
        catch {
            print ("no se puede ejecutar el query SELECT * FROM Responsable")
        }
        let sortedA = arreglo.sorted {m1, m2  in
            return m1.nombre ?? "" < m2.nombre ?? ""
        }
            
        return sortedA
    }
    
    func buscaMascotaId(_ idMascota:Int16) -> Mascota? {
        let elQuery = Mascota.fetchRequest()
        let elFiltro = NSPredicate(format:"id == %d", idMascota)
        elQuery.predicate = elFiltro
        do {
            let tmp = try persistentContainer.viewContext.fetch(elQuery)
            return tmp.first
        }
        catch {
            print ("no se puede ejecutar el query SELECT * FROM Mascota WHERE id = [n]")
        }
        return nil
    }
    
    func asignarResponsableAMascota(_ responsable: Responsable, _ idMascota: Int16) {
        if let miMascota = buscaMascotaId(idMascota) {
            
            miMascota.responsable = responsable
            
            responsable.addToMascotas(miMascota)
            
            saveContext()
        }
    }
    
    
    
    func todasLasMascotas(tipo:[String]) -> [Mascota] {
        var arreglo = [Mascota]()
        let elQuery = Mascota.fetchRequest()
        // [c] significa "case insensitive"
        let condiciones = tipo.map { _ in "tipo =[c] %@" }.joined(separator: " OR ")
        elQuery.predicate = NSPredicate(format: condiciones, argumentArray: tipo)
       
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
        }
        catch {
            print ("no se puede ejecutar el query SELECT * FROM Mascota WHERE tipo='%'")
        }
        let sortedA = arreglo.sorted {m1, m2  in
            return m1.nombre ?? "" < m2.nombre ?? ""  // Descendente
        }
        return sortedA
    }
    
    func todasLasMascotasMenos(tipo:[String]) -> [Mascota] {
        var arreglo = [Mascota]()
        let elQuery = Mascota.fetchRequest()
        // [c] significa "case insensitive"
        let condiciones = tipo.map { _ in "tipo !=[c] %@" }.joined(separator: " AND ")
        elQuery.predicate = NSPredicate(format: condiciones, argumentArray: tipo)
       
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
        }
        catch {
            print ("no se puede ejecutar el query SELECT * FROM Mascota WHERE tipo='%'")
        }
        let sortedA = arreglo.sorted {m1, m2  in
            return m1.nombre ?? "" < m2.nombre ?? ""  // Descendente
        }
        return sortedA
    }
    
    func resumenMascotas() -> String {
        var resumen = ""
        let queryM = Mascota.fetchRequest()
        let queryR = Responsable.fetchRequest()
        do {
            let cuenta = try persistentContainer.viewContext.count(for:queryR)
            resumen = "Hay \(cuenta) responsables\n"
            let cuenta2 = try persistentContainer.viewContext.count(for:queryM)
            resumen += "Hay \(cuenta2) mascotas\n"
            // SELECT tipo, count(id) as cuantos FROM Mascota GROUP BY tipo
            // gato, 34
            // perro, 45
            let keypathExp = NSExpression(forKeyPath: "id")
            let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
            let countDesc = NSExpressionDescription()
            countDesc.expression = expression
            countDesc.name = "cuantos"
            countDesc.expressionResultType = .integer64AttributeType
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Mascota")
            //request.resultType = .countResultType
            request.returnsObjectsAsFaults = false
            request.propertiesToFetch = ["tipo", countDesc]
            request.propertiesToGroupBy = ["tipo"]
            request.resultType = .dictionaryResultType
            let dict = try persistentContainer.viewContext.fetch(request)
            for dictTipo in dict {
                let d = dictTipo as! Dictionary<String, Any>
                let t = d["tipo"] ?? ""
                let c = d["cuantos"] ?? 0
                resumen += "      \(c) \(t)\n"
            }
        }
        catch {
            
        }
        return resumen
    }
    
    func borrar(objeto:NSManagedObject){
        persistentContainer.viewContext.delete(objeto)
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("DELETED_OBJECT"), object:nil)
    }
}


/* func obtenResponsables() {
     if let laURL = URL(string: "http://janzelaznog.com/DDAM/iOS/responsables.json") {
         let sesion = URLSession(configuration: .default)
         let tarea = sesion.dataTask(with:URLRequest(url:laURL)) { data, response, error in
             if error != nil {
                 print ("no se pudo descargar el feed de responsables \(error?.localizedDescription ?? "")")
                 return
             }
             do {
                 let tmp = try JSONDecoder().decode([ResponsableVO].self, from:data!)
                 self.guardaResponsables (tmp,  self.persistentContainer.viewContext)
             }
             catch { print ("no se obtuvo un JSON en la respuesta") }
         }
         tarea.resume()
     }
 }*/
 
 
 
 /*func guardaResponsables (_ responsables:[ResponsableVO]) {
     guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Responsable", in: persistentContainer.viewContext) else { return }
     responsables.forEach { responsableVO in
         let responsable = NSManagedObject(entity: entidadDesc, insertInto:persistentContainer.viewContext) as! Responsable
         responsable.inicializa(responsableVO)
         try? persistentContainer.viewContext.save()
         if let idMascota = responsableVO.duenoDe, idMascota != 0 {
             if let miMascota = buscaMascotaConId(idMascota) {
                 //print(miMascota)
                 responsable.addToMascotas(miMascota)
                 miMascota.responsable = responsable
             }
         }
     }
     saveContext()
 }*/
 
 /* Mi funcion
 func guardaResponsables (_ responsables:[ResponsableVO], _ context:NSManagedObjectContext) {
         guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Responsable", in: persistentContainer.viewContext) else { return }
         responsables.forEach { responsableVO in   // for m in mascotas { ... }
             let responsable = NSManagedObject(entity: entidadDesc, insertInto:persistentContainer.viewContext) as! Responsable
             responsable.inicializa(responsableVO)
             
             let fetchRequest: NSFetchRequest<Mascota> = Mascota.fetchRequest()// se crea la solicitud para obtener objetos Mascota des BD
             fetchRequest.predicate = NSPredicate(format: "id == %d", responsable.duenio_de) // Filtro %d Int16 %@ String

             if let mascota = try? context.fetch(fetchRequest).first {
                 responsable.addToMascotas(mascota) // Relacionar mascota con responsable
                 mascota.responsable = responsable  // Relacionar responsable con mascota
             } else {
                 print(" No se encontró la mascota con ID \(responsable.duenio_de)")
             }
         }
         saveContext()
 }*/
 
 /*func buscaMascotaConId(_ idMascota:Int) -> Mascota? {
     let elQuery = Mascota.fetchRequest()
     let elFiltro = NSPredicate(format:"id == %d", idMascota)
     elQuery.predicate = elFiltro
     do {
         let tmp = try persistentContainer.viewContext.fetch(elQuery)
         return tmp.first
     }
     catch {
         print ("no se puede ejecutar el query SELECT * FROM Mascota WHERE id = [n]")
     }
     return nil
 }*/


/*func todasLasMascotas(tipo: [String]) -> [Mascota] {
    guard !tipo.isEmpty else { return [] }
    
    let elQuery: NSFetchRequest<Mascota> = Mascota.fetchRequest()
    let condiciones = tipo.map { _ in "tipo =[c] %@" }.joined(separator: " OR ")
    elQuery.predicate = NSPredicate(format: condiciones, argumentArray: tipo)
    
    do {
        let resultado = try persistentContainer.viewContext.fetch(elQuery)
        let ordenado = resultado.sorted { ($0.nombre ?? "") < ($1.nombre ?? "") }
        return ordenado
    } catch {
        print("Error al ejecutar fetch: \(error.localizedDescription)")
        return []
    }
}*/
