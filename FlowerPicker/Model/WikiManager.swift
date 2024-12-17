//
//  WikiManager.swift
//  FlowerPicker
//
//  Created by Jessica Parsons on 12/13/24.
//

import Foundation

protocol WikiManagerDelegate {
    func didUpdateWiki(data: ParsedData)
}

struct WikiManager {
    
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&indexpageids"
    
    var delegate: WikiManagerDelegate?
    
    func fetchResults(flowerName: String) {
        let urlString = "\(wikipediaURl)&titles=\(flowerName)"
        
        //pass the URL to our performRequest function
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        //1. Create a URL, by using the URL initializer, passing it in
        if let url = URL(string: urlString) {
            
            //2. Create a URL Session object (with default configuration), which is basically like your browser.
            
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task and //5. create the completionHandler function as a trailing closure
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    if let wiki = parseJSON(wikiData: safeData) {
                        self.delegate?.didUpdateWiki(data: wiki)
                    }
                    // get the data back to the app
                    
                }
            }
            
            
            //4. Start the task
            
            task.resume()
            
        }
    }
    
    func parseJSON(wikiData: Data) -> ParsedData? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WikiData.self, from: wikiData)
            
            //get the dictionary page ID
            if let pageID = decodedData.query.pageids.first {
                
                //use the page ID to get our exact page, and then get properties
                if let page = decodedData.query.pages[pageID] {
                    
                    //Encode our data back in to our app
                    let description = page.extract
                    let title = page.title
                    
                    //create an object from the struct we made, return it
                    let parsedData = ParsedData(description: description, title: title)
                    return parsedData
                    
                }
            } else {
                print("Could not find page ID")
            }
            
        } catch {
            print(error)
            return nil
        }
        //if all conditions fail
        return nil
        
    }
    
}
