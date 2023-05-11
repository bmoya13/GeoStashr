# GeoStashr (CS 4750)

Final project for CS 4750 Mobile App Development.

## Description

This geocaching application allows user to create and manage stashes as well as view other user-created stashes. These come with information presented in the form of map markers, as well as a virtual logbook which users may visit and mark what they took and left from the geocache. There is also a notification system for stashes in order to report missing/damaged stashes.

## Notes

This app utlilizes the Mapbox Static Tiles API for map customization and tile loading, which has a free tier of 200,000 free tile requests per month, with a pay as you go model if it goes over that limit. Some restrictions were put in place of zooming and map traversal in order to minimize the number of requests. Additionally, Firebase was used to authenticate users and Firestore to store cache and user information.

## Future Updates

In the future, I would like to get user profile statistics up and running for the user to see stats such as miles walked, caches found, and logbook entries made. I would also like to implement profile pictures as well as cache pictures for more customization.
