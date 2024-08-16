//
//  ViewController.swift
//  Assignment3-IOS
//
//  Created by Priyanka Thomas on 2024-07-07.
//

import UIKit

class MovieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource 
{
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [Movie] = []
    
 override func viewDidLoad()
    {
        super.viewDidLoad()

        fetchMovies { [weak self] movies, error in
        DispatchQueue.main.async
        {
        if let movies = movies
        {
        if movies.isEmpty
        {
        // Display a message for no data
        self?.displayErrorMessage("No movies available.")
        } else {
        self?.movies = movies
        self?.tableView.reloadData()
        }
        } else if let error = error {
        if let urlError = error as? URLError, urlError.code == .timedOut
        {
        // Handle timeout error
        self?.displayErrorMessage("Request timed out.")
        } else {
        // Handle other errors
        self?.displayErrorMessage(error.localizedDescription)
        }
        }
        }
        }
    }
    func fetchMovies(completion: @escaping ([Movie]?, Error?) -> Void)
    {
    guard let url = URL(string: "https://mdev-api.onrender.com/api/movie/list") else
    {
    print("URL Error")
    completion(nil, nil) // Handle URL error
    return
    }
    URLSession.shared.dataTask(with: url) { data, _, error in
    if let error = error
    {
    print("Network Error")
    completion(nil, error) // Handle network error
    return
    }
    guard let data = data else {
    print("Empty Response")
    completion(nil, nil) // Handle empty response
    return
    }
        
    //Response
    do {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        if let success = json?["success"] as? Bool, success == true
        {
            if let moviesData = json?["data"] as? [[String: Any]]
            {
                let movies = try JSONSerialization.data(withJSONObject: moviesData, options: [])
                let decodedMovies = try JSONDecoder().decode([Movie].self, from: movies)
                completion(decodedMovies, nil) //success
            }
            else
            {
                print("Missing 'data' field in Json response")
                completion(nil,nil)
            }}
        else
        {
            print("API Request Unsuccessful")
            let errorMessage = json?["msg"] as? String ?? "Unknown Error"
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            completion(nil,error)
        }
    let movies = try JSONDecoder().decode([Movie].self, from: data)
    completion(movies, nil) // Success
    } catch {
    completion(nil, error) // Handle JSON decoding error
    }
    }.resume()
    }
    func displayErrorMessage(_ message: String)
        {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        }
        //Must override functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
     return movies.count; 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        
        let movie = movies[indexPath.row]
        
        cell.titlelabel?.text = movie.title
        cell.studiolabel?.text = movie.studio
        cell.ratinglabel?.text = "\(movie.criticsRating ?? 0.0)"
        
        let rating = movie.criticsRating
        
        if let rating = rating {
            if rating > 7 {
                cell.ratinglabel.backgroundColor = UIColor.green
                cell.ratinglabel.textColor = UIColor.black
            }
            else if rating > 5 {
                cell.ratinglabel.backgroundColor = UIColor.yellow
                cell.ratinglabel.textColor = UIColor.black
            }
            else
            {
                cell.ratinglabel.backgroundColor = UIColor.red
                cell.ratinglabel.textColor = UIColor.white
            }
        }
            else
            {
                cell.ratinglabel.backgroundColor = UIColor.gray
                cell.ratinglabel.textColor = UIColor.white
                cell.ratinglabel.text = "N/A"
            }
       
            return cell
    }
    

    
    }




