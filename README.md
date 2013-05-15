iTunesStoreClone
================

An iTunes App Store Clone that implements the following features:
<ul>
<li> Utilizes a UISearchBar to receive a search string that is used to query the iTunes 
search API
<li> The results of the search are presented in a UICollectionView.
<li> The collection view cells display the app icon, name, developer name, 
stars and price.
<li> The results are sorted by star rating and organized into sections (i.e. the 
first section 5 stars, the second 4 starts, etc.).
<li> Tapping on a collection view cell presents a modal view controller that 
contains the app details, including the app description. There's also 
“Buy” button that redirects users to the app store, and a “Favorite” button that allows the user to save the app to a favorites list.
<li> Uses NSCache to store previous queries results and tests before hitting the 
iTunes server. Also uses NSCache to cache thumbnail images.
<li> The favorites list uses Core Data. 
<li> GTMHTTPFetcher used for Networking.
<li> The app is Universal.
</ul>
