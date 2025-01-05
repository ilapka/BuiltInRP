// Rotate around custom axis.
// The axis vector has to be normalized.
float3x3 rotMtxCustomAxis (float angleRad, float3 axis)
{
    float angSin, angCos;
    sincos(angleRad, /* inout */ angSin, /* inout */ angCos);
	
    float invCos = 1.0 - angCos;
	
    // intermediate:
    // float intXY = invCos * axis.x * axis.y;
    // float intXZ = invCos * axis.x * axis.z;
    // float intYZ = invCos * axis.y * axis.z;
	
    float3 invCos_XY_XZ_YZ = invCos * axis.xxy * axis.yzz; //0
	
    float3 sinVec = axis * angSin; //up
    float3 negSinVec = -sinVec; //down
    float3 invCos_axisSq = invCos * axis * axis; //up
	
    // return float3x3 (
    // 	angCos + invCos * axis.x * axis.x,   invCos_XY_XZ_YZ.x - sinVec.z,   invCos_XY_XZ_YZ.y + sinVec.y,
    // 	invCos_XY_XZ_YZ.x + sinVec.z,   angCos + invCos * axis.y * axis.y,   invCos_XY_XZ_YZ.z - sinVec.x,
    // 	invCos_XY_XZ_YZ.y - sinVec.y,   invCos_XY_XZ_YZ.z + sinVec.x,   angCos + invCos * axis.z * axis.z
    // );
	
    return
        float3x3(
            angCos,              invCos_XY_XZ_YZ.x,   invCos_XY_XZ_YZ.y,
            invCos_XY_XZ_YZ.x,   angCos,              invCos_XY_XZ_YZ.z,
            invCos_XY_XZ_YZ.y,   invCos_XY_XZ_YZ.z,   angCos
        )
        +
        float3x3(
            invCos_axisSq.x,   negSinVec.z,       sinVec.y,
            sinVec.z,          invCos_axisSq.y,   negSinVec.x,
            negSinVec.y,       sinVec.x,          invCos_axisSq.z
        )
    ;
}