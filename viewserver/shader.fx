//--------------------------------------------------------------------------------------
// File: Tutorial022.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------
Texture2D tex : register(t0);
Texture2D psheightmap : register(t1);
//Texture2D psheightmap2 : register(t2);
SamplerState samLinear : register(s0);

cbuffer VS_CONSTANT_BUFFER : register(b0)
	{
	float offset1x;
	float offset1y;
	float offset2x;
	float offset2y;
	float div_tex_x;	//dividing of the texture coordinates in x
	float div_tex_y;	//dividing of the texture coordinates in x
	float slice_x;		//which if the 4x4 images
	float slice_y;		//which if the 4x4 images
	matrix world;
	matrix view;
	matrix projection;
	float4 campos;
	};

//struct float4
//	{
//	float r, g, b, a;//same
//	float x, y, z, w;
//	}
struct SimpleVertex
	{
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
	float4 Norm : NORMAL;
	};

//struct planeVertex
//{
//	float4 Pos : POSITION;
//	float2 Tex : TEXCOORD0;
//	float4 norm : Normal;
//};

struct PS_INPUT
	{
	float4 Pos : SV_POSITION;
	float3 ViewPos : POSITION1;
	float2 Tex : TEXCOORD0;
	float3 Norm : NORMAL;
	};
//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VShader(SimpleVertex input)
	{
	PS_INPUT output;
	float4 pos = input.Pos;

	pos = mul(world, pos);
	pos = mul(view, pos);
	pos = mul(projection, pos);

	output.Pos = pos;
	output.Tex = input.Tex;
	return output;
	}



//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
//normal pixel shader
float4 PS(PS_INPUT input) : SV_Target
{
	//return float4(1,0,1,1);
	//return float4(input.Tex.x,input.Tex.y,0,1);
	float4 color = tex.Sample(samLinear, input.Tex);
	//color.a = offset1x;
	return color;
}
	//Special effects
	//mixing 2 textures <-
	//passing more information from the vertex shader to the pixel shader
	//linear interpolation. <-
	// C = A * (1 - f) + B * f;

//-------------------------------------terain shaders -----------------------------------------------//
	PS_INPUT VShaderHeight(SimpleVertex input)
{
	PS_INPUT output;
	float4 pos = input.Pos;

	pos = mul(world, pos);

	float4 color = tex.SampleLevel(samLinear, input.Tex, 0);
	pos.y += (color.r * 60) - 10; // heightmapping!!!!

	pos = mul(view, pos);

	output.ViewPos = pos.xyz;

	pos = mul(projection, pos);

	output.Pos = pos;
	output.Tex = input.Tex;
	return output;
}
float4 PSterrain(PS_INPUT input) : SV_Target
	{
	//return float4(input.Tex.y,input.Tex.y,0,1);
	float4 color = tex.Sample(samLinear, input.Tex * 100);
	float4 colorheight = psheightmap.Sample(samLinear, input.Tex);

	float3 vpos = input.ViewPos;
	vpos.y = 0;
	float dist = length(vpos);
	dist /= 200.0;
	if (dist > 1) dist = 1;
	float4 farcolor = float4(0.9, 0.93, 0.94, 1);
	farcolor.r *= dist;
	farcolor.g *= dist;
	farcolor.b *= dist;

	//return float4(dist, dist, dist, 1);


	color.r *= colorheight.r + 0.2;
	color.g *= colorheight.r + 0.2;
	color.b *= colorheight.r + 0.2;
	color.a = 1;

	//linear interpolation:
	// 2 states: color and farcolor

	float4 resultcolor = color*(1 - dist) + farcolor*dist;
	resultcolor.a = 1;
	return resultcolor;
}


//-------------------------------------- wave Shaders ------------------------------------------------//



PS_INPUT VShaderWave(SimpleVertex input)
{
	PS_INPUT output;
	float4 pos = input.Pos;

	pos = mul(world, pos);

	float4 height1 = tex.SampleLevel(samLinear, input.Tex + float2(offset1x, offset1y), 0);
	float4 height2 = psheightmap.SampleLevel(samLinear , input.Tex + float2(offset2x, offset2y), 0);
	pos.y += (height1.r * 5) - 5; // heightmapping!!!!
	pos.y += (height2.r * 5) - 5;

	pos = mul(view, pos);

	output.ViewPos = pos.xyz;

	pos = mul(projection, pos);

	output.Pos = pos;
	output.Tex = input.Tex;
	return output;
}

float4 PSWave(PS_INPUT input) : SV_Target
{
	//return float4(input.Tex.y,input.Tex.y,0,1);
	float4 color = float4( 0.1,0.05,0.8,1 );
	float4 colorheight2 = tex.Sample(samLinear, input.Tex+ float2(offset1x, offset1y));
	float4 colorheight = psheightmap.Sample(samLinear, input.Tex + float2(offset2x, offset2y));
	colorheight = (colorheight + colorheight2) / 2;


	float3 vpos = input.ViewPos;
	vpos.y = 0;
	float dist = length(vpos);
	dist /= 200.0;
	if (dist > 1) dist = 1;
	float4 farcolor = float4(0.9, 0.93, 0.94, 1);
	farcolor.r *= dist;
	farcolor.g *= dist;
	farcolor.b *= dist;

	//return float4(dist, dist, dist, 1);


	color.r *= colorheight.r + 0.2;
	color.g *= colorheight.r + 0.2;
	color.b *= colorheight.r + 0.2;
	color.a = 1;

	//linear interpolation:
	// 2 states: color and farcolor

	float4 resultcolor = color*(1 - dist) + farcolor*dist;
	resultcolor.a = 1;
	return resultcolor;
}

//----------------------------------- plane shaders ---------------------------------------------//
PS_INPUT VShaderPlane(SimpleVertex input)
{
	PS_INPUT output;
	float4 pos = input.Pos;

	pos = mul(world, pos);
	output.ViewPos = pos.xyz;
	pos = mul(view, pos);
	pos = mul(projection, pos);

	matrix w = world;
	//w._14 = 0;
	//w._24 = 0;
	//w._34 = 0;

	float4 norm;
	norm.xyz = input.Norm;
	norm.w = 1;
	norm = mul(norm, w);
	output.Norm = normalize(norm.xyz);

	output.Pos = pos;
	output.Tex = input.Tex;
	return output;
}

float4 PSPlane(PS_INPUT input) : SV_Target
{
	float3 lightposition = float3(20, 10, 90);
	float3 normal = normalize(input.Norm);
	//return float4(normal, 1);
	//diffuse lighting:
	float specular = 0;
	float3 lightdirection = lightposition - input.ViewPos;
	lightdirection = normalize(lightdirection);
	float diffuselight = dot(normal, lightdirection);
	diffuselight = saturate(diffuselight);//saturate(x) ... if(x<0)x=0;else if(x>1) x=1;
	if (diffuselight > 0.1) {
		//specular light:
		float3 r = reflect(normal, lightdirection);
		r = normalize(r);
		float3 camdir = campos - input.ViewPos;
		camdir = -normalize(camdir);
		//return float4(camdir, 1);
		specular = dot(camdir, r);
		//specular = saturate(specular);
		specular = pow(specular, 20);
	}
	//lighting calc:
	//diffuselight = diffuselight + specular * 20;

	float4 colorA = tex.Sample(samLinear, input.Tex);
	float4 SpecLightColor = float4(1, 1, 1, 1);//light color

	float4 ambiant = float4(0.09, 0.09, 0.09, 1);

	float4 color = ambiant+ colorA * diffuselight +SpecLightColor*specular;
	color.a = 1;
	return color;
}