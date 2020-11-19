#define PI 3.1415

float3 lambertFunc(float3 albedo) 
{
    return albedo / PI;
}

float3 fresnel(float fr, float ndl)
{
    return fr + (1-fr) * pow(1-ndl, 5);
}

