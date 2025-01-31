using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Sprites;

namespace Blep.GUIShapes {

[AddComponentMenu("UI/Blep/Shape")]
public class Shape : Image {

    protected static int FillColorID = Shader.PropertyToID("_FillColor");
    protected static int OutlineColorID = Shader.PropertyToID("_OutlineColor");
    protected static int OutlineWidthID = Shader.PropertyToID("_OutlineWidth");
    protected static int SizeID = Shader.PropertyToID("_Size");

    protected virtual string shaderName { get; } = null;

    [SerializeField]
    private Color _fillColor = Color.white;
    public Color fillColor {
        get => _fillColor;
        set {
            _fillColor = value;
            SetMaterialDirty();
        }
    }

    [SerializeField]
    private Color _outlineColor = Color.black;
    public Color outlineColor {
        get => _outlineColor;
        set {
            _outlineColor = value;
            SetMaterialDirty();
        }
    }

    [SerializeField]
    private float _outlineWidth;
    public float outlineWidth {
        get => _outlineWidth;
        set {
            _outlineWidth = value;
            SetMaterialDirty();
        }
    }

    [SerializeField][HideInInspector]
    private Material _localMaterial;
    public override Material material {
        get {
            if (shaderName == null || hasUserMaterial) {
                return base.material;
            }
            if (! _localMaterial) {
                var shader = Shader.Find(shaderName);
                // In some cases, Shader.Find returns a shader with no name when it can't find the shader
                if (string.IsNullOrEmpty(shader?.name)) {
                    Debug.LogError($"Can't find shader {shaderName}");
                    return base.material;
                }
                _localMaterial = new Material(shader);
            }
            return _localMaterial;
        }
        set => base.material = value;
    }
    public bool hasUserMaterial => m_Material != null;

#if UNITY_EDITOR
    protected override void OnValidate() {
        base.OnValidate();
        SetMaterialDirty();

        // Have to make sure the shader is referenced in the scene, otherwise
        // Shader.Find won't find it (even though it's in a Resource folder!)
        var mat = material;
    }
#endif

    public override Material GetModifiedMaterial(Material baseMaterial) {
        var mat = base.GetModifiedMaterial(baseMaterial);
        if (hasUserMaterial) {
            _fillColor = mat.GetColor(FillColorID);
            _outlineColor = mat.GetColor(OutlineColorID);
            _outlineWidth = mat.GetFloat(OutlineWidthID);
        }
        else {
            mat.SetColor(FillColorID, fillColor);
            mat.SetColor(OutlineColorID, outlineColor);
            mat.SetFloat(OutlineWidthID, outlineWidth);
        }
        return mat;
    }

    // Rewritten from Image.cs because it's private there
    private Vector4 _GetDrawingDimensions(bool shouldPreserveAspect) {
        var padding = overrideSprite == null
            ? Vector4.zero : DataUtility.GetPadding(overrideSprite);
        var size = overrideSprite == null
            ? Vector2.zero : new Vector2(overrideSprite.rect.width, overrideSprite.rect.height);
        Rect r = GetPixelAdjustedRect();
        //Debug.Log(string.Format("r:{2}, size:{0}, padding:{1}", size, padding, r));

        // BK: Added Max
        int spriteW = Mathf.Max(1, Mathf.RoundToInt(size.x));
        int spriteH = Mathf.Max(1, Mathf.RoundToInt(size.y));

        var v = new Vector4(
            padding.x / spriteW,
            padding.y / spriteH,
            (spriteW - padding.z) / spriteW,
            (spriteH - padding.w) / spriteH);

        if (shouldPreserveAspect && size.sqrMagnitude > 0.0f) {
            _PreserveSpriteAspectRatio(ref r, size);
        }

        v = new Vector4(
            r.x + r.width * v.x,
            r.y + r.height * v.y,
            r.x + r.width * v.z,
            r.y + r.height * v.w
        );

        return v;
    }

    // Copied from Image.cs because it's private there
    private void _PreserveSpriteAspectRatio(ref Rect rect, Vector2 spriteSize) {
        var spriteRatio = spriteSize.x / spriteSize.y;
        var rectRatio = rect.width / rect.height;

        if (spriteRatio > rectRatio) {
            var oldHeight = rect.height;
            rect.height = rect.width * (1.0f / spriteRatio);
            rect.y += (oldHeight - rect.height) * rectTransform.pivot.y;
        }
        else {
            var oldWidth = rect.width;
            rect.width = rect.height * spriteRatio;
            rect.x += (oldWidth - rect.width) * rectTransform.pivot.x;
        }
    }

    protected override void OnPopulateMesh(VertexHelper toFill) {
        base.OnPopulateMesh(toFill);

        // Texture uv is in uv.xy. Store shape uv in uv.zw

        var dims = _GetDrawingDimensions(preserveAspect);
        // Constants for inverse lerp
        var xOffset = dims.x;
        var yOffset = dims.y;
        var xSize = (dims.z - dims.x);
        var ySize = (dims.w - dims.y);
        var xScale = 1.0f / xSize;
        var yScale = 1.0f / ySize;

        UIVertex v = new();
        for (int i = toFill.currentVertCount; --i >= 0; ) {
            toFill.PopulateUIVertex(ref v, i);

            v.uv0.z = (v.position.x - xOffset) * xScale;
            v.uv0.w = (v.position.y - yOffset) * yScale;

            toFill.SetUIVertex(v, i);
        }

        // Need to reset Size when mesh changes
        // TODO: will this work with override materials? Is that an issue?
        material.SetVector(SizeID, new Vector2(xSize, ySize));

    }

}

} // Namespace
