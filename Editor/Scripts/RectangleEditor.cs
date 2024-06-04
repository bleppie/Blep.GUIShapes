using UnityEditor;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.UI;
using Blep.GUIShapes;

[CustomEditor(typeof(Rectangle), true)]
public class RectangleEditor : ShapeEditor {
    private SerializedProperty cornerTypeProp;
    private SerializedProperty radiiProp;

    protected override void OnEnable() {
        base.OnEnable();

        cornerTypeProp = serializedObject.FindProperty("_cornerType");
        radiiProp = serializedObject.FindProperty("_radii");
    }

    public override void OnInspectorGUI() {
        ShapeFields();
        serializedObject.Update();

        EditorGUILayout.PropertyField(cornerTypeProp);
        switch ((Rectangle.CornerType) cornerTypeProp.enumValueIndex) {
            case Rectangle.CornerType.Plain:
                break;
            case Rectangle.CornerType.Rounded:
                var radius = EditorGUILayout.FloatField("Radius", radiiProp.vector4Value.x);
                radiiProp.vector4Value = Vector4.one * Mathf.Max(0, radius);
                break;
            case Rectangle.CornerType.Chamfered:
                var chamfer = EditorGUILayout.FloatField("Chamfer", radiiProp.vector4Value.x);
                radiiProp.vector4Value = Vector4.one * Mathf.Max(0, chamfer);
                break;
            default:
                EditorGUILayout.PropertyField(radiiProp);
                break;
        };

        serializedObject.ApplyModifiedProperties();
        ImageFields();
    }
}
