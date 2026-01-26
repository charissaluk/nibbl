#  README

# Final Project: Food Social Media App

## Project Description
This project will create a restaurant discovery and personal restaurant tracking app with a social component. Users will be able to save restaurants they have visited or want to try, rate them, and organize them into custom lists. The app will also support searching and filtering saved restaurants by name, rating, tags, and location.

To help with the common “Where should we eat?” problem, the app will recommend restaurants based on the user’s taste profile and past ratings. Compared to existing rating and reservation platforms such as Yelp, OpenTable, and Resy, this app emphasizes personalized recommendations and adds features for planning group outings.

The goal of this project is to build a meaningful iOS app that demonstrates core Swift and SwiftUI skills learned throughout the semester, including persistence, async tasks, and common mobile UI patterns.

## Figma Prototype
**Figma Link:**  https://www.figma.com/design/En3MUVfUPkIMemuADXNSZ2/Food-App--HCI-?node-id=0-1&p=f&t=QI0D5ssmSHZPm6c4-0

## Core Features (Planned)
- Save restaurants/places with name, location, notes, and tags
- Rate restaurants using a simple rating scale or relative to other restaurants you've tried (similar to Beli app)
- View restaurant details and edit saved entries
- Create custom lists (ex: “Favorites”, “Want to Try”, “Date Night”, “Best Matcha”)
- Search and filter restaurants by rating, tags, and list
- Map view to display saved restaurants geographically (stretch goal depending on time)

## Planned iOS Technologies
This app is intended to include at least 3 iOS technologies covered in the course:
- **Persistence (SwiftData)**  
  Store restaurants, lists, and ratings locally on device.
- **CoreLocation/MapKit**  
  Display restaurant locations and optionally allow adding locations using a map.
- **Networking with async/await**  
  Support searching for restaurants from an external API and importing results (time permitting).
- **Gestures and Animations**  
  Swipe actions (delete/favorite), liking heart animations, and smooth UI feedback.

## Data Models (Planned)
The database/models for this project will include:
- **User** (basic profile info)
- **Place/Restaurant**
- **Rating**
- **Tag**
- **List/Collection**

## Requirements Tracking
All requirements and development tasks for this project will be tracked using GitHub Issues with the following labels:
- Base Requirements
- UI Requirements
- Data Flow Diagrams
- Final Issues

## Status
This project is in progress. Requirements will be defined and refined during Development Logs, and implementation will be completed throughout the semester.
