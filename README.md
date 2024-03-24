# bullet
simple game to learn about lua and love2d

## Level syntax
Level files are expected of the following format.

One or more lines that are composed of the following (mandatory unless mentionned) elements : 
1. a `xx:xx` time stamp (`x` is any digit)
2. a comma
3. one or more "enemies", i.e. `(s,t,r,d)` constructs where 
    1. `s` : side we want the enemy to spawn : starting from 1 for right side and counting clockwise
    2. `t` : type of enemy. Anything aside from 1 or 2 results in a crash
    3. `r` : remaining bullets. Enemy's clip size.
    4. `d` : shooting delay, i.e. time in second between enemy shots

Example

```
00:01,(1,1,2,1)(2,2,3,1)
00:02,(1,1,2,1)
```
