// Based on Unity built-in shader source.

Shader "Blep.GUIShapes/Rectangle" {
  Properties {
    [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
    _FillColor("FillColor", Color) = (1, 1, 1, 1)
    _OutlineColor("OutlineColor", Color) = (0, 0, 0, 1)
    _OutlineWidth("OutlineWidth", Float) = 0
    _Radii("Radii", Vector) = (0, 0, 0, 0)
    [HideInInspector]_Size("Size", Vector) = (0, 0, 0, 0)
    [HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
    [HideInInspector]_Stencil("Stencil ID", Float) = 0
    [HideInInspector]_StencilOp("Stencil Operation", Float) = 0
    [HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
    [HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
    [HideInInspector]_ColorMask("ColorMask", Float) = 15
    [HideInInspector]_ClipRect("ClipRect", Vector) = (0, 0, 0, 0)
    [HideInInspector]_UIMaskSoftnessX("UIMaskSoftnessX", Float) = 1
    [HideInInspector]_UIMaskSoftnessY("UIMaskSoftnessY", Float) = 1
  }

  SubShader {
    Tags {
      "Queue"="Transparent"
      "IgnoreProjector"="True"
      "RenderType"="Transparent"
      "PreviewType"="Plane"
      "CanUseSpriteAtlas"="True"
    }
    Stencil {
      Ref [_Stencil]
      Comp [_StencilComp]
      Pass [_StencilOp]
      ReadMask [_StencilReadMask]
      WriteMask [_StencilWriteMask]
    }
    Cull Off
    Lighting Off
    ZWrite Off
    ZTest [unity_GUIZTestMode]
    Blend One OneMinusSrcAlpha
    ColorMask [_ColorMask]

    Pass {
      Name "Default"

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma target 2.0

      #include "Common.cginc"
      float4 _Radii;

      fixed4 frag(v2f IN) : SV_Target {
          float sdf;
          RectangleSdf_float(IN.texcoord.zw, _Size, _Radii, sdf);
          return fragSdf(IN, sdf);
      }
      ENDCG
    }
  }
}



