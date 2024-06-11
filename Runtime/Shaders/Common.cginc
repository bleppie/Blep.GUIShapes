#include "UnityCG.cginc"
#include "UnityUI.cginc"
#include "ShapeFuncs.hlsl"

#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
#pragma multi_compile_local _ UNITY_UI_ALPHACLIP

struct appdata_t {
  float4 vertex   : POSITION;
  float4 color    : COLOR;
  float4 texcoord : TEXCOORD0;
  UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f {
  float4 vertex   : SV_POSITION;
  fixed4 color    : COLOR;
  float4 texcoord : TEXCOORD0;
  float4 worldPosition : TEXCOORD1;
  float4 mask : TEXCOORD2;
  UNITY_VERTEX_OUTPUT_STEREO
};

sampler2D _MainTex;
float4 _OutlineColor;
float4 _FillColor;
float _OutlineWidth;
float2 _Size;
fixed4 _Color;
fixed4 _TextureSampleAdd;
float4 _ClipRect;
float4 _MainTex_ST;
float _UIMaskSoftnessX;
float _UIMaskSoftnessY;
int _UIVertexColorAlwaysGammaSpace;

v2f vert(appdata_t v) {
  v2f OUT;
  UNITY_SETUP_INSTANCE_ID(v);
  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
  float4 vPosition = UnityObjectToClipPos(v.vertex);
  OUT.worldPosition = v.vertex;
  OUT.vertex = vPosition;

  float2 pixelSize = vPosition.w;
  pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

  float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
  float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
  OUT.texcoord.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
  OUT.texcoord.zw = v.texcoord.zw;
  OUT.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw,
                    0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));


  if (_UIVertexColorAlwaysGammaSpace) {
      if(!IsGammaSpace()) {
          v.color.rgb = UIGammaToLinear(v.color.rgb);
      }
  }

  OUT.color = v.color * _FillColor;
  return OUT;
}


fixed4 fragSdf(v2f IN, float sdf) {
  //Round up the alpha color coming from the interpolator (to 1.0/256.0 steps)
  //The incoming alpha could have numerical instability, which makes it very sensible to
  //HDR color transparency blend, when it blends with the world's texture.
  const half alphaPrecision = half(0xff);
  const half invAlphaPrecision = half(1.0/alphaPrecision);
  IN.color.a = round(IN.color.a * alphaPrecision)*invAlphaPrecision;

  float4 fillColor = IN.color * (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);

  float4 color;
  ColorFromSdf_float(sdf, fillColor, _OutlineColor, _OutlineWidth, color);
  
#ifdef UNITY_UI_CLIP_RECT
  half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
  color.a *= m.x * m.y;
#endif

#ifdef UNITY_UI_ALPHACLIP
  clip (color.a - 0.001);
#endif

  color.rgb *= color.a;
  return color;
}
