# InstaBetter

The best Instagram tweak yet, packed with features ranging from media saving to muting annoying users from your feed.

The most comprehensive tweak for Instagram yet. With over 10 new features and tweaks, you'll have more control over your Instagram experience. 

## Features
* Save hi-res images and videos
* Hold down on images to zoom
* Hold down on profile pictures to zoom
* Mute Users from main feed
* Hide Sponsored Ads
* Custom Locations for Media - /u/stevep88
* Show follow status on user profile (Similar to Twitter) - /u/evansjailbreak
* Show like counts as percentages - /u/rnumur
* Share sheet for text and images
* Open links in Instagram
* Fake follower and following counts
* View DMs without notifying the sender
* All features can be toggled on or off
* Enable grid view on main feed
* Alerts for liking media with a double tap
* Show the full time for feed items by clicking on the timestamp button
* Add setting to enable or disable auto-playing video sound
* Hold down on direct message images and videos for sharing and save options

### Release 1.1.0
* [FEATURE] Add zooming to feed images
* [FEATURE] Add zooming to profile images
* [BUG FIX] Correct "eachother" to "each other"
* [TWEAK] Disable app rating messages
* [FEATURE] Grid view on main feed
* [FEATURE] Add alert to double-tap likes
* [FEATURE] Add full timestamps to feed items
* [FEATURE] Add option to auto play video sound
* [BUG FIX] Fix DM read timestamps still being sent
* [FEATURE] Add saving and sharing options to DMs
* [BUG FIX] Prevent Mute button from showing on own profile

### Release 1.1.1
* [BUG FIX] Fix crash related to short captions

### Release 1.1.2
* [BUG FIX] Fix crash related to no captions

### Release 1.1.3
* [BUG FIX] Fix invalid ringer state on load
* [BUG FIX] Fix crash on Instagram 7.6
* [CHANGE] Replace "Save Media" and "Share" with new buttons under images and videos
* [CHANGE] New preferences icons - by @AOkhtenberg 

### Release 1.1.4
* [CHANGE] Add minor change to possibly lower memory usage
* [BUG FIX] Fix very thick share/download icons
* [BUG FIX] Fix crash when viewing profile image in activity tab
* [BUG FIX] Fix share/save images not showing on 6+ - s/o to ThisBeChrisSas for testing

### Release 1.2.0
* [CHANGE] Revert to old style of Saving/Sharing. Now more consistent
* [BUG FIX] Fix both Twitter buttons opening to the same page
* [FEATURE] Enable Instagram's hidden account switcher
* [FEATURE] Add preferences view to Instagram's settings
* [FEATURE] Add ability to customize whether or not to auto play videos
* [BUG FIX] Fix zoom/share attempting to display several times

### Release 1.3.0
* [BUG FIX] Fix muting not working for some users
* [CHANGE] Revamp custom locations. Now select a location from a map, add a name and address.
* [FEATURE] Add a toggle for displaying buttons or action sheet for saving/sharing
* [FEATURE] Add confirmation to saving content with save button
* [FEATURE] Remove activity from muted users from the activity feed. Only removes items where just a single user is involved.
* [FEATURE] Add action list to DM photos rather than immediately zooming. Includes zoom and save.

### Release 1.3.1
* Submit the correct version to BigBoss

### Release 1.3.2
* Codebase cleanup
* Make it possible to access native Instagram share sheet on own posts
* Change save and share buttons to activate on inside touch events
* Redo settings as a popup to fix black screen on iOS 9
* Add done button to web view
* Potentially fix freezing on app start

### Release 1.3.3
* Fix 7.9 crash when zooming on profile pics
* Fix 7.9 crash when using account switcher

### Release 1.3.3-6
* Potentially fix iPhone 6(+) crashes

### Release 1.3.4
* Add Restart Instagram button to settings
* Add custom notification sounds
* Add option to disable like confirmation for save button

### Release 1.4.0
* Add done button to Instagram web view
* Rewrite preference loading to reduce preference file size and hopefully resolve crashes
* Add return key to captions and comments to create multiline posts and comments (use two blank lines between each)
* Add localization support:
- Russian: Mik Ovchinnikov (Instagram only)
- Thai: @kn3w (Instagram only)
- Khmer: /u/fidele007 (not supported by iOS)
- Italian: Alessandro Grandi
- Arabic: @MiRO92 (not supported in Instagram..yet)
- Swedish: /u/andreashenriksson
- Hebrew: Aran Shavit (@Aranshavit)

### Release 1.4.1
- Fix Russian translation not displaying correctly
- Fix potential crash in activity tab
* Compatible with Instagram 7.11 and older.

### Release 1.4.2
- Codebase cleanup
- Fix Instagram 7.13 crash
- New follow status label

### Release 1.4.4
- Support Instagram 7.14
- Fix crash when opening action menus
- Remove like percentages. They caused too many issues, including the No Internet Connection bug. They also display terribly with the latest updates.

### Release 1.4.5
- Further support Instagram 7.14
- Fix mute/save/share buttons not appearing in menus
- Rewrite muting to support future versions
- Add fake verified symbol, similar to spoofing followers
- Make spoofed followers/following/verified only appear for your profile
- Support return key in future versions


### Release 1.4.6
- Support Instagram 7.15
- Fix DM image saving displaying wrong text
- Fix crash when double clicking to like photos

## Building
* Setup [theos](http://iphonedevwiki.net/index.php/Theos/Setup) on your system.
* Adjust the ```theos``` symlink to match the path to your installation.
* Run ```make clean package```
* The package will be available in the ```debs``` directory.

## License
All Rights Reserved - InstaBetter may not be redistributed without permission from the developer.

InstaBetter is not affiliated with Instagram or Facebook.

## Depiction Description

The most comprehensive tweak for Instagram yet, with over 15 new features.

* Save high resolution media (Images & Videos) 
* Hold down on images and profile pictures to zoom
* Mute users from home and activity feeds
* Hide Sponsored Ads
* Select and name custom locations for media
* Show follow status on user profile (Similar to Twitter) 
* Show like counts as percentages
* Share actions for text and images
* Open links in Instagram
* View DMs without notifying the sender
* Toggle grid layout with the press of a button
* Confirm double-tap likes with an alert
* Press times to display timestamps
* Enable or disable auto playing of video and sound
* Save and zoom DM content
* Manage multiple accounts with a native switcher
* Set custom notification sounds for Instagram alerts
* Available in English, Russian, Italian, Arabic, Hebrew, and more.

InstaBetter will always be free, and does not add any ads to the Instagram app.

InstaBetter is not affiliated with Instagram or Facebook.

Compatible with iOS 8 and 9. See changelog for supported Instagram versions.