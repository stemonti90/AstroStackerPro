#include <metal_stdlib>
using namespace metal;

kernel void maxStack(
    texture2d<float, access::read>  inTex0 [[ texture(0) ]],
    texture2d<float, access::read>  inTex1 [[ texture(1) ]],
    texture2d<float, access::write> outTex [[ texture(2) ]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;
    float4 a = inTex0.read(gid);
    float4 b = inTex1.read(gid);
    outTex.write(max(a, b), gid);
}
