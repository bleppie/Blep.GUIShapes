Blep.GUIShapes
===============

**Blep.GUIShapes** adds simple shapes with outlines to Unity's GUI. The shapes
are created in shaders procedurally and are nicely antialiased. Shapes are a
subclass of Image, and so support all operations that Images do.

![Image](SampleImage.png)

To create a shape, simply create it from the GameObject menu or add the
corresponding Component to your GameObject: Circle, Pill, Ellipse, or Rectangle.
Rectangles can be plain (right angled), rounded, chamfered, or custom (each
corner has a different radius/chamfer). Use a negative radius to create a
chamfered corner in a custom rectangle. Each one of these Components will have
its own Material.

If you want multiple shapes to share the same Material, use the generic Shape
Component: Create a Material using one of the included Shaders (Circle, Ellipse,
Rectangle), set its parameters, create a generic Shape Component, add it to your
GameObject, and set its Material to the material you just created.

If you add a sprite to your shape, it will affect only the fill, not the outline.

Installation Instructions
-------------------------

[Install from Git](https://docs.unity3d.com/Manual/upm-ui-giturl.html) or copy
to your Assets folder


Supported Shapes
--------------------

* Circle
* Pill
* Ellipse
* Rectangle with plain, rounded, chamfered, and custom corners

License
-------

See LICENSE.md
