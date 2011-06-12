BUGS
---
- PSZoomView needs some work with orientation and zoom levels
- Finish coding 'write a comment' feature
- Logging out on another client causes oauth failure which causes crash
- Searching/Filtering scroll performance is bad, find a way to unload the tableview underneath it
- LOGOUT crashes

DONE
- Logout needs some love (DONE)
- Logging in / Serializing Progress Indicator (DONE)
- Memory scrub (DONE)
- Cyclical memcache/buffer for imageCache (DONE)
- Launch album since call failing causes a logout in bad state (DONE)
- If an album image is cached, since call will not trigger cache reset on album img (DONE)
- convert defaultCenter singletons into local static variables (DONE)
- search keyword delimmiters (DONE)
- in photo view, allow searching for tagged friends (DONE)
- add tagged people parsing in json (DONE)

FEATURES
---
- Global AlertCenter
- More view controller, move logout here
- Search view controller (DEPRECATED)
- On login, need to fetch and compare to find new friends, and get their albums

TODO
---
