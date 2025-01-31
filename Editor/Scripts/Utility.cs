using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

namespace Blep.GUIShapes.Editor {

public static class Utility {

    // Creating a new ui object correctly is quite complicated (see
    // com.unity.ugui/Editor/UGUI/UI/MenuOptions.cs), so instead create an
    // Image, then replace the Image with the appropriate subclass.

    private static void _Add<T>() where T : Component{
        // Create Image
        EditorApplication.ExecuteMenuItem("GameObject/UI/Image");
        var go = Selection.activeGameObject;

        // Replace with T
        Object.DestroyImmediate(go.GetComponent<Image>());
        go.AddComponent<T>();

        // Change names 
        go.name = typeof(T).Name;
        Undo.SetCurrentGroupName($"Create {go.name}");
    }

    [MenuItem("GameObject/UI/Circle - Blep")]
    public static void AddCircle() => _Add<Blep.GUIShapes.Circle>();

    [MenuItem("GameObject/UI/Pill - Blep")]
    public static void AddPill() => _Add<Blep.GUIShapes.Pill>();

    [MenuItem("GameObject/UI/Rectangle - Blep")]
    public static void AddRectangle() => _Add<Blep.GUIShapes.Rectangle>();
}

}
