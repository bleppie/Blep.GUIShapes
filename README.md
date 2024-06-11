Blep.GUIShapes
===============

**Blep.GUIShapes** is a package that adds simple shapes with outlines to Unity's
GUI. It uses Shader Graph, and hence requires Unity 6 and above. The outlines
are nicely antialiased. Shapes are a subclass of Image, and so support all
operations that Images do.

To create a shape, simply add the corresponding Component to your GameObject.
Eg, for a circle, add the Circle component. Each one of these Components will
have its own Material.

If you want multiple shapes to share the same material, you can use the generic
Shape Component: Create a Material using one of the included Shaders (Circle,
Ellipse, Rectangle), set its parameters, create a generic Shape Component, add
it to your GameObject, and set its Material to the material you just created.

If you add a sprite to your shape, it will affect only the fill, not the outline.

Installation Instructions
-------------------------

[Install from Git](https://docs.unity3d.com/Manual/upm-ui-giturl.html) or copy
to your Assets folder


Supported Shapes
--------------------

* Circle
* Ellipse
* Rectangle with plain, rounded, chamfered, and custom corners

License
-------

See LICENSE.md
