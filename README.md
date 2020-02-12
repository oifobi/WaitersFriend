# Application Type
UIKit

# Application Name
Waiter's Friend

# Objective
The aim of this app is to find how to make any cocktail. The app connects to a paid tier (patreon) 3rd party cocktail database, and utilizes JSON-API calls to ftech data on demand to populate the respective screens of the app.
The also caches data to save on API calls, and saves data (as JSON data) to the app bundle (userDefaults) when a user saves cocktails to their favorites.
The app utilizes APIs to:
- Fetch and display a default list of cocktails (default / Top Rated drinks screen)
- Fetch a random drink (Featured drink sceeen)
- Search for a Drink name (Search screen)
- Review Saved drinks (Favorites screen)

# App Functionality highlights
- Combines use of horintals UICollectionView + Vertical scroll UITableView on the same ViewController / screen (Search screen)
- Alphabatized index of Drinks, to jump to drink by first letter (Featured and Favorites screens)
- Shared UIViewControllers (Featured and Favorites screens) since both screens layout the data the same
- Dymanimc Search controller that seraches for matching drinks as you type
- Uses a shared Network controller file for manaing the fetching and parsing of JSON Data
- Utilizes methods that trigger other methods when executed
- Asyncrhonous display of data. Eg. Drink informaton / text data will display, while image is still downloading. 
- Screens and images utilize UIActivityIndicators
- Each fetched drink can be tapped to reveal a details screen, detailing an enlarged image, and information on ingredients, how to make and click on the image to enlarger

# Demo
![Demo](Demo_06122019.gif)

# Technologies

- UIKit

- MVC

- CGAffineTransform

- Network Controller (file for manaing the fetching and parsing of JSON Data)

- UIActivityIndicator

- UICollectionView

- UICollectionViewCompositionalLayout

- UITableView

- GestureRecognizer

- SegmentController

- .xib files

- JSON-APIs

- JSON Encoder / Decoder

- URLComponents

- @escaping functions

- queryItems

- appendingPathComponents

- UserDefaults

- Enum

- extensions (UIView)

- Custom UITableViewCell

- UIActivityIndicator

- UISearchController (UISearchResultsUpdating, UISearchBarDelegate)

- UIAlertController

- Git / Github


# Completed
- October, 2019

# Deployment information

- <strong>Deployment Target (iOS version):</strong> 12 (Functions broken by iOS 13+, Xcode 11+)
- <strong>Supported Devices: </strong>iPhone
