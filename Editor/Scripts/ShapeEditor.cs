using UnityEditor;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.UI;
using Blep.GUIShapes;

[CustomEditor(typeof(Shape), true)]
public class ShapeEditor : ImageEditor {
    private SerializedProperty fillColorProp;
    private SerializedProperty outlineColorProp;
    private SerializedProperty outlineWidthProp;

    protected Shape shape => (Shape) serializedObject.targetObject;

    protected override void OnEnable() {
        base.OnEnable();

        fillColorProp = serializedObject.FindProperty("_fillColor");
        outlineColorProp = serializedObject.FindProperty("_outlineColor");
        outlineWidthProp = serializedObject.FindProperty("_outlineWidth");
    }

    protected void ShapeFields() {
        serializedObject.Update();
        if (! shape.hasUserMaterial) {
            EditorGUILayout.PropertyField(fillColorProp);
            EditorGUILayout.PropertyField(outlineWidthProp);
            EditorGUILayout.PropertyField(outlineColorProp);
        }
        serializedObject.ApplyModifiedProperties();
    }

    protected void ImageFields() {
        EditorGUILayout.Space();
        base.OnInspectorGUI();
    }

    public override void OnInspectorGUI() {
        ShapeFields();
        ImageFields();
    }
}
