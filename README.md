# Album iOS App

## Screenshot
![home](screenshot/home.png "Home Screen")
![add](screenshot/add.png "Add Feature")
![delete](screenshot/delete.png "Delete Feature")

## Requirement : 
- [x] Use the latest version of Swift
- [x]  Home Screen 
    - [x] list all images/videos with grid style view
    - [x] add delete function if user hold on image/video in few seconds.
    - [x] If User click on the floating button will showing 2 sub buttons for taking image/ video from camera and device gallery. After image/video selected will appear immediately in Home Screen. 
    - [x] Show full image preview if user tap on one of images from Home Screen and the image are able pinch to zoom.
    - [x] Play the video if user tap on one of videos from Home Screen.
    

## Solution : 
- Use in memory database (Array) for now, expected data will not persistence. 
- Use bar button and alert action to replace floating button (HIG instead of Material Design)

## What else could be done with more time:
- Using Persistence Database like CoreData
- Unit Testing & Good Code Coverage
- Refactor to MVVM / VIPER Architecture

## How to install :
- Make sure you have Xcode 13.2.1
- Open Album.xcodeproj
- Run project to simulator or real device using `cmd + R` (Need Developer Account for Real Device)
