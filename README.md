# godot-stepmania-parser

This is a Godot add-on that parses the contents of .sm or .ssc files (used by Stepmania). The ability to use a Stepmania file for rhythm games should make rhythm game development much easier, since there are many robust tools to create Stepmania stepcharts like ArrowVortex.

## What it can do (right now)

* Load song metadata into a `StepSong` object
* Parse the note data into a list of what notes happen where on which lane in a `StepChart` object

## What it can't do (yet)

* Make timing the chart easy, even with BPM changes, using a `StepTiming` object
* Automatically find the .sm or .ssc file within a folder

## Contribution

Since this is a side project for me, and I have not created a rhythm game on Godot yet, I am more than eager to receive tips, feature requests, and pull requests for this add-on.
