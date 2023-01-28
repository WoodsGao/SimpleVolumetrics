#ifndef WOODS_NOISE3D
#define WOODS_NOISE3D

static const float3 dirs[26] = 
{
    float3(0.57735, 0.57735, -0.57735),                                                                                                                                                                                                                 
    float3(0.57735, 0.57735, 0.57735),                                                                                                                                                                                                                  
    float3(0.70711, 0.70711, 0),                                                                                                                                                                                                                        
    float3(0.70711, 0, -0.70711),                                                                                                                                                                                                                       
    float3(0.70711, 0, 0.70711),                                                                                                                                                                                                                        
    float3(1, 0, 0),                                                                                                                                                                                                                                    
    float3(0.57735, -0.57735, -0.57735),                                                                                                                                                                                                                
    float3(0.57735, -0.57735, 0.57735),                                                                                                                                                                                                                 
    float3(0.70711, -0.70711, 0),                                                                                                                                                                                                                       
    float3(0, 0.70711, -0.70711),                                                                                                                                                                                                                       
    float3(0, 0.70711, 0.70711),                                                                                                                                                                                                                        
    float3(0, 1, 0),                                                                                                                                                                                                                                    
    float3(0, 0, -1),                                                                                                                                                                                                                                   
    float3(0, 0, 1),                                                                                                                                                                                                                                    
    //float3(0,0,0),                                                                                                                                                                                                                           
    float3(0, -0.70711, -0.70711),                                                                                                                                                                                                                      
    float3(0, -0.70711, 0.70711),                                                                                                                                                                                                                       
    float3(0, -1, 0),                                                                                                                                                                                                                                   
    float3(-0.57735, 0.57735, -0.57735),                                                                                                                                                                                                                
    float3(-0.57735, 0.57735, 0.57735),                                                                                                                                                                                                                 
    float3(-0.70711, 0.70711, 0),                                                                                                                                                                                                                       
    float3(-0.70711, 0, -0.70711),                                                                                                                                                                                                                      
    float3(-0.70711, 0, 0.70711),                                                                                                                                                                                                                       
    float3(-1, 0, 0),                                                                                                                                                                                                                                   
    float3(-0.57735, -0.57735, -0.57735),                                                                                                                                                                                                               
    float3(-0.57735, -0.57735, 0.57735),                                                                                                                                                                                                                
    float3(-0.70711, -0.70711, 0)         
};

static const int tableSize = 512;
static const int permutationMask = 512/2 - 1;
static const int permutationTable[512] = 
{                                                                                                                                                                                                                                         
    180, 3, 121, 17, 22, 7, 69, 202, 72, 172,                                                                                                                                                                                                         
    56, 94, 92, 254, 122, 139, 118, 127, 76, 2,                                                                                                                                                                                                       
    46, 74, 169, 147, 228, 196, 47, 110, 138, 217,                                                                                                                                                                                                    
    155, 39, 91, 61, 45, 238, 242, 229, 251, 207,                                                                                                                                                                                                     
    192, 198, 175, 222, 176, 75, 234, 10, 25, 63,                                                                                                                                                                                                     
    250, 135, 159, 183, 253, 96, 68, 153, 87, 50,                                                                                                                                                                                                     
    226, 241, 114, 188, 13, 112, 21, 66, 249, 144,                                                                                                                                                                                                    
    126, 1, 233, 124, 148, 43, 199, 156, 208, 223,                                                                                                                                                                                                    
    164, 213, 18, 219, 59, 209, 108, 134, 27, 100,                                                                                                                                                                                                    
    197, 90, 53, 140, 168, 29, 165, 19, 65, 161,                                                                                                                                                                                                      
    141, 52, 195, 128, 151, 37, 117, 150, 36, 105,                                                                                                                                                                                                    
    49, 6, 187, 116, 235, 216, 201, 119, 182, 204,                                                                                                                                                                                                    
    221, 136, 0, 113, 24, 111, 158, 131, 212, 58,                                                                                                                                                                                                     
    41, 85, 102, 166, 77, 157, 64, 103, 184, 83,                                                                                                                                                                                                      
    237, 220, 23, 149, 84, 171, 99, 230, 152, 178,                                                                                                                                                                                                    
    190, 215, 38, 34, 163, 93, 14, 244, 79, 31,                                                                                                                                                                                                       
    9, 142, 240, 132, 145, 231, 95, 236, 8, 167,                                                                                                                                                                                                      
    82, 80, 133, 137, 252, 211, 57, 248, 89, 20,                                                                                                                                                                                                      
    30, 154, 32, 174, 205, 42, 98, 11, 15, 243,                                                                                                                                                                                                       
    78, 203, 146, 185, 107, 51, 224, 54, 70, 106,                                                                                                                                                                                                     
    194, 35, 177, 160, 255, 16, 104, 189, 12, 67,                                                                                                                                                                                                     
    125, 33, 123, 55, 120, 186, 40, 143, 181, 239,                                                                                                                                                                                                    
    193, 214, 115, 81, 4, 44, 200, 101, 206, 71,                                                                                                                                                                                                      
    73, 28, 86, 130, 48, 225, 210, 227, 245, 109,                                                                                                                                                                                                     
    232, 162, 129, 179, 218, 88, 247, 173, 191, 97,                                                                                                                                                                                                   
    62, 60, 246, 5, 26, 170,
    180, 3, 121, 17, 22, 7, 69, 202, 72, 172,                                                                                                                                                                                                         
    56, 94, 92, 254, 122, 139, 118, 127, 76, 2,                                                                                                                                                                                                       
    46, 74, 169, 147, 228, 196, 47, 110, 138, 217,                                                                                                                                                                                                    
    155, 39, 91, 61, 45, 238, 242, 229, 251, 207,                                                                                                                                                                                                     
    192, 198, 175, 222, 176, 75, 234, 10, 25, 63,                                                                                                                                                                                                     
    250, 135, 159, 183, 253, 96, 68, 153, 87, 50,                                                                                                                                                                                                     
    226, 241, 114, 188, 13, 112, 21, 66, 249, 144,                                                                                                                                                                                                    
    126, 1, 233, 124, 148, 43, 199, 156, 208, 223,                                                                                                                                                                                                    
    164, 213, 18, 219, 59, 209, 108, 134, 27, 100,                                                                                                                                                                                                    
    197, 90, 53, 140, 168, 29, 165, 19, 65, 161,                                                                                                                                                                                                      
    141, 52, 195, 128, 151, 37, 117, 150, 36, 105,                                                                                                                                                                                                    
    49, 6, 187, 116, 235, 216, 201, 119, 182, 204,                                                                                                                                                                                                    
    221, 136, 0, 113, 24, 111, 158, 131, 212, 58,                                                                                                                                                                                                     
    41, 85, 102, 166, 77, 157, 64, 103, 184, 83,                                                                                                                                                                                                      
    237, 220, 23, 149, 84, 171, 99, 230, 152, 178,                                                                                                                                                                                                    
    190, 215, 38, 34, 163, 93, 14, 244, 79, 31,                                                                                                                                                                                                       
    9, 142, 240, 132, 145, 231, 95, 236, 8, 167,                                                                                                                                                                                                      
    82, 80, 133, 137, 252, 211, 57, 248, 89, 20,                                                                                                                                                                                                      
    30, 154, 32, 174, 205, 42, 98, 11, 15, 243,                                                                                                                                                                                                       
    78, 203, 146, 185, 107, 51, 224, 54, 70, 106,                                                                                                                                                                                                     
    194, 35, 177, 160, 255, 16, 104, 189, 12, 67,                                                                                                                                                                                                     
    125, 33, 123, 55, 120, 186, 40, 143, 181, 239,                                                                                                                                                                                                    
    193, 214, 115, 81, 4, 44, 200, 101, 206, 71,                                                                                                                                                                                                      
    73, 28, 86, 130, 48, 225, 210, 227, 245, 109,                                                                                                                                                                                                     
    232, 162, 129, 179, 218, 88, 247, 173, 191, 97,                                                                                                                                                                                                   
    62, 60, 246, 5, 26, 170
};

int Hash(float3 x)
{
    // using ampersand to calculate modulus because-
    // mod() for negative integers gives "wrong" results, for instance mod(-3, 4) = 1 and not 3
    // the ampersand trick works only if the divisor is a power of two minus 1
    // less operatons compared to x - y * floor(x/y)
    return permutationTable[permutationTable[permutationTable[int(x.x) % tableSize] + int(x.z) % tableSize] + int(x.y) % tableSize];
}

float SmoothCurve(float t)
{
    return t * t * (3.0 - 2.0 * t);
}

float GetIntegerNoise(float2 p)  // replace this by something better, p is essentially ifloat2
{
    p  = 53.7 * frac( (p*0.3183099) + float2(0.71,0.113));
    return frac( p.x*p.y*(p.x+p.y) );
}

float3 GetGradient(float3 x)
{
    // using % instead of & operator, below, because the divisor is not a power of two minus 1, and the divisor will never be negative here.
    int i = Hash(x) % 26;
    return dirs[i];
}

float GetNoise3D(float3 uvw)
{
    float noise = 0.0;
    
    float3 p = floor(uvw);
    float3 f = frac(uvw);
    
    float3 p1 = p + float3(0.0, 0.0, 0.0);
    float3 p2 = p + float3(1.0, 0.0, 0.0);
    float3 p3 = p + float3(0.0, 1.0, 0.0);
    float3 p4 = p + float3(1.0, 1.0, 0.0);
    float3 p5 = p + float3(0.0, 0.0, 1.0);
    float3 p6 = p + float3(1.0, 0.0, 1.0);
    float3 p7 = p + float3(0.0, 1.0, 1.0);
    float3 p8 = p + float3(1.0, 1.0, 1.0);
    
    float3 g1 = GetGradient(p1);
    float3 g2 = GetGradient(p2);
    float3 g3 = GetGradient(p3);
    float3 g4 = GetGradient(p4);
    float3 g5 = GetGradient(p5);
    float3 g6 = GetGradient(p6);
    float3 g7 = GetGradient(p7);
    float3 g8 = GetGradient(p8);
    
    float dot1 = dot(g1, uvw - p1);
    float dot2 = dot(g2, uvw - p2);
    float dot3 = dot(g3, uvw - p3);
    float dot4 = dot(g4, uvw - p4);
    float dot5 = dot(g5, uvw - p5);
    float dot6 = dot(g6, uvw - p6);
    float dot7 = dot(g7, uvw - p7);
    float dot8 = dot(g8, uvw - p8);
    
    float wX = SmoothCurve(f.x);
    float noiseY1 = lerp(dot1, dot2, wX);
    float noiseY2 = lerp(dot3, dot4, wX);
    float noiseY3 = lerp(dot5, dot6, wX);
    float noiseY4 = lerp(dot7, dot8, wX);
    
    float wY = SmoothCurve(f.y);
    float noiseZ1 = lerp(noiseY1, noiseY2, wY);
    float noiseZ2 = lerp(noiseY3, noiseY4, wY);
    
    float wZ = SmoothCurve(f.z);
    noise = lerp(noiseZ1, noiseZ2, wZ);
    
    return noise;
}


#endif