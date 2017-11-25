# FlickerImages
iOS app to load and display Flicker images using Flickr Search API

## Application Main Modules
---

### Model

* FlickrImage: Contains all the required information to identify and download an image with Flickr API
* ImagesStash: Singelton class that is used as a unified interface to retrieve and store Flickr images by passing FlickrImage objects. It provides three levels of caching:
 1. Memory Caching: Dictionary that maps image's unique id to FlickrImage objects
 2. Disk Caching: Spilling images to the documents directory if the images stored in the memory exceeds some parameter threshold. Applied if the image is not found in the memory
 3. Network Protocol Caching: Using the standard http protocol caching. Applied if the image is found neither in memory nor on disk
* ImagesIndex: The index that retrieves and stores the FlickrImage objects. Its main functionality is, given a search key, retrieves a paginated index of Flickr's API search results. The downloading and actul image storing is handled by the ImagesStash module. This module is the one that deals with the CollectionView (UI)

### Network Operations Module

* NetworkOperation: Basic module whose functionality is to take a URL and retrieve a stream of data contained at this URL no matter what kind of data it is. The advantage of this abstraction is that many other modules in the app can use the same module to retrieve different kinds of data such as images, json ... etc
* ImageNetworkOperation: uses the NetworkOperation class to download an image from Flickr API given a FlickrImage object
* JSONNetworkOperation: uses the NetworkOperation class to retrieve search pages and returns it as a dictionary

### User Interface

A single view that contains a UICollectionView to display the retrieved images in a three-column layout. It supports endless scrolling and automatically loads next pages when the user approaches the end of the current page. The search bar supports searching for multi-word phrases not only a single keyword. The view supports all orientations and uses that autolayout to arrange items inside the collection view.

### UnitTests

The most important functionalities of the main modules are two XCTTest classes. The first one tests the network interactions and the second one tests the main image storage, caching and retrieval. UI testing is not done due to time constraints

## Potential improvements
---

* Image disk storage cleanup. Currently, all the images stored to disk are never removes. There should be a periodic cleanup procedure to remove images stored before some time parameter such as a week or a month ago
* Better UI design. The current interface is basic just to show the working functions of the app. For example, pressing, or press and hold, an image displays it in actual size
* Navigation buttons to enable navigation through search history
* UI Testing
* Better error handling epecially for network failures and disk operations
* Asynchronous behavior (Network and Disk access) is not tested thouroughly to find race conditions and provide synchronized access to shared objects

![Screenshot 1](screenshot1.png)