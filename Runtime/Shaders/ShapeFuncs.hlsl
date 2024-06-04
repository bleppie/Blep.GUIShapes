#ifndef _BLEP_GUISHAPES_FUNCS
#define _BLEP_GUISHAPES_FUNCS

// UNUSED Calclate size by looking at how uv changes from pixel to pixel. This
// works, but outlineWidth remains pixel constant even when scaling. It also
// doesn't work in world-space UIs that are not orthogonal to the screen.
float2 SizeFromUV(float2 uv) {
    float4 dxy = abs(float4(ddx(uv), ddy(uv)));
    return rcp(float2(length(dxy.xz), length(dxy.yw)));
}

void CircleSdf_float(float2 uv, float2 size, out float sdf) {
    float2 xy = uv * size;
    float2 center = size * 0.5f;
    float radius = min(size.x, size.y) * 0.5f;

    sdf = distance(xy, center) - radius;
}

void CircleSdf_half(half2 uv, half2 size, out half sdf) {
    half2 xy = uv * size;
    half2 center = size * 0.5f;
    half radius = min(size.x, size.y) * 0.5f;

    sdf = distance(xy, center) - radius;
}

void EllipseSdf_float(float2 uv, float2 size, out float sdf) {
    float2 xy = uv * size;
    float2 center = size * 0.5f;
    float2 radius = center;

    // See https://github.com/0xfaded/ellipse_demo/issues/1
    float2 p = abs(xy - center);

    float rdiff = radius.x * radius.x - radius.y * radius.y;

    // Initial guess
    float2 t = float2(0.70710678118f, 0.70710678118f); // Normalized
    float2 q = radius * t; // Closest point on ellipse

    for (int i = 0; i < 3; ++i) {
        float2 e = float2(rdiff, -rdiff) * t * t * t / radius;

        float2 qe = q - e;
        float2 pe = p - e;

        t = saturate((normalize(pe) * length(qe) + e) / radius);
        t = normalize(t);
        q = radius * t;
    }

    float df = distance(p, q); // unsigned distance function
    sdf = sign(dot(p, p) - dot(q, q)) * df;
}

void EllipseSdf_half(half2 uv, half2 size, out half sdf) {
    half2 xy = uv * size;
    half2 center = size * 0.5f;
    half2 radius = center;

    // See https://github.com/0xfaded/ellipse_demo/issues/1
    half2 p = abs(xy - center);

    half rdiff = radius.x * radius.x - radius.y * radius.y;

    // Initial guess
    half2 t = half2(0.70710678118f, 0.70710678118f); // Normalized
    half2 q = radius * t; // Closest point on ellipse

    for (int i = 0; i < 3; ++i) {
        half2 e = half2(rdiff, -rdiff) * t * t * t / radius;

        half2 qe = q - e;
        half2 pe = p - e;

        t = saturate((normalize(pe) * length(qe) + e) / radius);
        t = normalize(t);
        q = radius * t;
    }

    half df = distance(p, q); // unsigned distance function
    sdf = sign(dot(p, p) - dot(q, q)) * df;
}

void CustomRectangleSdf_float(float2 uv, float2 size, float4 radii, out float sdf) {
    float2 xy = uv * size;
    float2 center = size * 0.5f;
    float2 xyCentered = xy - center;

    // Delta from edge
    float2 delta = abs(xyCentered) - center;

    // Sdf from edge
    float sdfEdge = max(delta.x, delta.y);

    // Selected radius corresponding to quadrant
    float2 idx2 = step(0, xyCentered) * float2(1, 2);
    int idx = (int) (idx2.x + idx2.y);
    float radius = radii.zwxy[idx];

    // Move to corner center
    delta += abs(radius);

    // Sdf to rounded corner
    float sdfRoundedCorner = length(delta) - radius;
    // Sdf to chamfered corner
    float sdfChamferedCorner = (delta.x + delta.y + radius);
    // Sdf to corner
    float sdfCorner = min(sdfChamferedCorner, sdfRoundedCorner);

    // Sdf, delta is < 0 if in the corner
    sdf = any(delta < 0) ? sdfEdge : sdfCorner;
}

void CustomRectangleSdf_half(half2 uv, half2 size, half4 radii, out half sdf) {
    half2 xy = uv * size;
    half2 center = size * 0.5f;
    half2 xyCentered = xy - center;

    // Delta from edge
    half2 delta = abs(xyCentered) - center;

    // Sdf from edge
    half sdfEdge = max(delta.x, delta.y);

    // Selected radius corresponding to quadrant
    half2 idx2 = step(0, xyCentered) * half2(1, 2);
    int idx = (int) (idx2.x + idx2.y);
    half radius = radii.zwxy[idx];

    // Move to corner center
    delta += abs(radius);

    // Sdf to rounded corner
    half sdfRoundedCorner = length(delta) - radius;
    // Sdf to chamfered corner
    half sdfChamferedCorner = (delta.x + delta.y + radius);
    // Sdf to corner
    half sdfCorner = min(sdfChamferedCorner, sdfRoundedCorner);

    // Sdf, delta is < 0 if in the corner
    sdf = any(delta < 0) ? sdfEdge : sdfCorner;
}

void ColorFromSdf_float(float sdf, float4 fillColor,
                        float4 outlineColor, float outlineWidth,
                        out float4 color) {

    // Magic that does antialiasing
    // distOuter = dist
    // distInner = dist + OutlineWidth
    //   distInner < 0  -->  FillColor
    //   distInner < 1  -->  lerp between FillColor and OutlineColor
    //   distOuter < 0  -->  OutlineColor
    //   distOuter < 1  -->  OutlineColor with alpha between 1 and 0
    //   distOuter > 1  -->  OutlineColor with alpha 0
    color = lerp(fillColor, outlineColor, saturate(sdf + outlineWidth));
    color.a *= 1 - saturate(sdf);
}

void ColorFromSdf_half(half sdf, half4 fillColor,
                        half4 outlineColor, half outlineWidth,
                        out half4 color) {

    // Magic that does antialiasing
    // distOuter = dist
    // distInner = dist + OutlineWidth
    //   distInner < 0  -->  FillColor
    //   distInner < 1  -->  lerp between FillColor and OutlineColor
    //   distOuter < 0  -->  OutlineColor
    //   distOuter < 1  -->  OutlineColor with alpha between 1 and 0
    //   distOuter > 1  -->  OutlineColor with alpha 0
    color = lerp(fillColor, outlineColor, saturate(sdf + outlineWidth));
    color.a *= 1 - saturate(sdf);
}

// void RectangleSdf_float(float2 uv, out float sdf) {
//     float2 size = SizeFromUV(uv);
//     float2 xy = uv * size;
//     float2 center = size * 0.5f;
//     float2 xyCentered = xy - center;

//     float2 delta = abs(xyCentered) - center;
//     sdf = max(delta.x, delta.y);
// }

// void RoundedRectangleSdf_float(float2 uv, float radius, out float sdf) {
//     float2 size = SizeFromUV(uv);
//     float2 xy = uv * size;
//     float2 center = size * 0.5f;
//     float2 xyCentered = xy - center;

//     float2 delta = abs(xyCentered) - center;
//     float sdfEdge = max(delta.x, delta.y);

//     // Move to corner center
//     delta += radius;
//     float sdfCorner = length(delta) - radius;

//     sdf = any(delta < 0) ? sdfEdge : sdfCorner;
// }

// void ChamferedRectangleSdf_float(float2 uv, float radius, out float sdf) {
//     float2 size = SizeFromUV(uv);
//     float2 xy = uv * size;
//     float2 center = size * 0.5f;
//     float2 xyCentered = xy - center;

//     float2 delta = abs(xyCentered) - center;
//     float sdfEdge = max(delta.x, delta.y);

//     // Move to corner center
//     delta += radius;
//     float sdfCorner = delta.x + delta.y - radius;

//     sdf = any(delta < 0) ? sdfEdge : sdfCorner;
// }

#endif
