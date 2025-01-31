using UnityEngine;

namespace Blep.GUIShapes {

[AddComponentMenu("UI/Blep/Rectangle")]
public class Rectangle : Shape {

    protected static int RadiiID = Shader.PropertyToID("_Radii");

    protected override string shaderName => "Blep.GUIShapes/Rectangle";

    public enum CornerType { Plain, Rounded, Chamfered, Custom };

    [SerializeField]
    private CornerType _cornerType;
    public CornerType cornerType {
        get => _cornerType;
        set {
            _cornerType = value;
            SetMaterialDirty();
        }
    }

    [SerializeField]
    [Tooltip("Radii > 0 will be rounded, Radii < 0 will be chamfered")]
    public Vector4 _radii;
    public Vector4 radii {
        get => _radii;
        set {
            _radii = value;
            SetMaterialDirty();
        }
    }
    public float radius {
        get => radii.x;
        set => radii = Vector4.one * value;
    }

    public override Material GetModifiedMaterial(Material baseMaterial) {
        var mat = base.GetModifiedMaterial(baseMaterial);

        var curRadii = cornerType switch {
            CornerType.Plain => Vector4.zero,
            CornerType.Rounded => Vector4.one * Mathf.Max(0, radius),
            CornerType.Chamfered => Vector4.one * -Mathf.Max(0, radius),
            _ => radii
        };

        mat.SetColor(RadiiID, curRadii);
        return mat;
    }

}

} // Namespace
