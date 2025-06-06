## GTween for Haxe

GTween is a small but extremely robust Haxe library for programmatic tweening, animation, and transitions, based on the AS3 library for Adobe Flash built by Grant Skinner of [gskinner.com](http://www.gskinner.com/). It is currently comprised of 3 key classes:

* **GTween**. A robust tweening engine, packed full of innovative features.
* **GTweenTimeline**. A powerful virtual timeline that extends GTween to enable you to sequence tweens and actions.
* **GTweener**. A static interface to GTween.

It also comes with a variety of plug-ins and easing classes. 

GTween is licensed under the **MIT license**, so it can be used and modified with **almost no restrictions in commercial projects** beyond maintaining the header in the source files.

## Features

### Size & Performance

Despite it's broad feature set, GTween is very small. GTweenTimeline, GTweener, and plugins optionally add a bit more.

GTween also demonstrates high performance, able to create and run 5000 tweens per second at up to 20fps on a 2.5ghz Macbook Pro.

### Developer Oriented

GTween was originally built for ActionScript 3 developers from the ground up, and it fits into the Haxe and OpenFL ecosystems equally well. It uses a more conventional instance-oriented model, rather than a static interface (though one is supported through GTweener).

It also supports both callbacks and OpenFL events. The former are faster, while the latter provide more control and consistency with OpenFL standards.

### Flexible

GTween works with **any numeric property of any object**.
You can use it to tween the volume of a sound, the size of a window, 3D properties, or the value of "foo" on a custom object type, as easily as you would tween the x and y properties of a sprite.

You can set up a tween in a **single line of code**, or stick to using strictly typed properties. You can maintain references to your tweens, or create them and forget them - GTween intelligently manages tweens to prevent them from being garbage collected while they are active.

```haxe
// unreferenced tween, in one line:
new GTween(myTarget, 2, {x:50, alpha:1}, {ease:Sine.easeInOut});

// referenced tween, typed properties:
var myTween:GTween = new GTween(myTarget, 2);
myTween.setValue("x",50);
myTween.setValue("alpha",1);
myTween.ease = Sine.easeInOut;

// you can also do referenced tweens in one line.
```

### Proxy

The proxy property does not exist in the Haxe version of GTween.

### Sequencing

GTweenTimeline lets you set up complex animations or transitions on a **virtual timeline**.
In addition to tweens, you can add actions and labels at specified positions.
Pause, reverse, and jump to the start or end of the full timeline as easily as you would with a single tween.
You can even **nest timelines** in each other, just like you can do in the Flash or OpenFL.

GTween even lets you **synchronize frame based animations** to time based programmatic tweens.
Even if you pause the tween, or change the framerate, your awesome animated effects will stay perfectly timed.

```haxe
var myTween:GTween = new GTween(myTarget, 2, {x:50, alpha:1}, {ease:Sine.easeInOut});
myTimeline.addTween(1, myTween);
myTimeline.addCallback(3, myCallback, [param1, param2]);
```

### Interrupt

Modify your tween while it is playing, and it will attempt to accommodate those changes.

### Control

GTween offers an unprecedented level of control over your tweens.
You can **pause one or all tweens**.
You can specify how many times a tween repeats, and whether it should reflect on each repeat (play backwards).
You can **jump to any position** in your tween at any time.

### Timing

GTween supports both frame and time based tweens on a per tween basis. You can specify positions and durations in either frames or seconds.

### Extensibility

The code base for GTween is straightforward and easy to read, extend, and modify. It also supports an easy to use, robust plug-in model which makes it easy to add and share custom functionality without having to modify or extend the core classes.

### Etcetera

Here's a quick list of a few more features you might find interesting:

* plug-ins for common tasks like synchronizing timeline animations, calculated motion blur, adjusting color, snapping values, and more.
* simple sequencing with nextTween.
* delay the start of your tween with the delay property.
* slow down or speed up (even reverse) one tween or all tweens with time scaling.
* associate arbitrary data with your tween (handy for storing temporary transition related values).
* swap start and end values easily.
* calculate the optimal duration for a timeline based on the tweens and callbacks in it.
* change, init, and complete callbacks.

The best place to learn about these and other features is by checking out the included demos, and flipping through the API documentation.

## Demos

All source code for these demos is included with the download.

## Download

[Download latest build of GTween](#) (Not yet available for download)

## Feedback

Found a bug? Report an [issue](https://github.com/joshtynjala/gtween-haxe/issues).

Want to extend the library? Submit a [pull request](https://github.com/joshtynjala/gtween-haxe/pulls).

