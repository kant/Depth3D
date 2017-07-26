 ////----------------//
 ///**SuperDepth3D**///
 //----------------////

 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //* Depth Map Based 3D post-process shader v1.9.7  																																*//
 //* For Reshade 3.0																																								*//
 //* --------------------------																																						*//
 //* This work is licensed under a Creative Commons Attribution 3.0 Unported License.																								*//
 //* So you are free to share, modify and adapt it for your needs, and even use it for commercial use.																				*//
 //* I would also love to hear about a project you are using it with.																												*//
 //* https://creativecommons.org/licenses/by/3.0/us/																																*//
 //*																																												*//
 //* Have fun,																																										*//
 //* Jose Negrete AKA BlueSkyDefender																																				*//
 //*																																												*//
 //* http://reshade.me/forum/shader-presentation/2128-sidebyside-3d-depth-map-based-stereoscopic-shader																				*//	
 //* ---------------------------------																																				*//
 //*																																												*//
 //* Original work was based on the shader code of a CryTech 3 Dev http://www.slideshare.net/TiagoAlexSousa/secrets-of-cryengine-3-graphics-technology								*//
 //* 																																												*//
 //* AO Work was based on the shader code of a Devmaster Dev																														*//
 //* code was take from http://forum.devmaster.net/t/disk-to-disk-ssao/17414																										*//
 //* arkano22 Disk to Disk AO GLSL code adapted to be used to add more detail to the Depth Map.																						*//
 //* http://forum.devmaster.net/users/arkano22/																																		*//
 //*																																												*//
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Determines The resolution of the Depth Map. For 4k Use 1.75 or 1.5. For 1440p Use 1.5 or 1.25. For 1080p use 1. Too low of a resolution will remove too much.
#define Depth_Map_Division 1.0

// Determines The Max Depth amount.
#define Depth_Max 55

uniform int Depth_Map <
	ui_type = "combo";
	ui_items = " 0 Normal\0 1 Normal Reverse\0 2 Raw\0 3 Raw Reverse\0 4 Mix\0 5 Mix Reverse\0 6 Special\0";
	ui_label = "Custom Depth Map";
	ui_tooltip = "Pick your Depth Map.";
> = 0;

uniform float Depth_Map_Adjust <
	ui_type = "drag";
	ui_min = 1.0; ui_max = 50.0;
	ui_label = "Depth Map Adjustment";
	ui_tooltip = "Adjust the depth map for your games.";
> = 7.5;

uniform float Mix <
	ui_type = "drag";
	ui_min = 0.125; ui_max = 0.500;
	ui_label = "Mix Adjustment";
	ui_tooltip = "Mix is used to adjust between Normal & Raw.\n"
				"This is for Depth Map 4 & 5\n"
				"Default is 0.5";
> = 0.5;

uniform float Offset <
	ui_type = "drag";
	ui_min = 0; ui_max = 1.0;
	ui_label = "Offset";
	ui_tooltip = "Offset is for the Special Depth Map Only.";
> = 0.5;

uniform int Divergence <
	ui_type = "drag";
	ui_min = 1; ui_max = Depth_Max;
	ui_label = "Divergence Slider";
	ui_tooltip = "Determines the amount of Image Warping and Separation.\n" 
				 "You can override this value.";
> = 15;

uniform float ZPD <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.25;
	ui_label = "Zero Parallax Distance";
	ui_tooltip = "ZPD controls the focus distance for the screen Pop-out effect.\n"
				"FPS Games should be around 0.025-0.100 Max.";
> = 0.050;

uniform float Weapon_Depth <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Weapon Depth Adjustment";
	ui_tooltip = "Pushes or Pulls the FPS Hand in or out of the screen.\n" 
				 "Default is 0";
> = 0;

uniform int Dis_Occlusion <
	ui_type = "drag";
	ui_min = 0; ui_max = 5;
	ui_label = "Disocclusion Power";
	ui_tooltip = "Occlusion masking power adjustment.\n"
				"Disocclusion starts at One.\n"
				"Default is 1";
> = 1;

uniform float Perspective <
	ui_type = "drag";
	ui_min = -100; ui_max = 100;
	ui_label = "Perspective Slider";
	ui_tooltip = "Determines the perspective point.\n" 
				 "Default is 0";
> = 0;

uniform bool Depth_Map_View <
	ui_label = "Depth Map View";
	ui_tooltip = "Display the Depth Map.";
> = false;

uniform bool Depth_Map_Flip <
	ui_label = "Depth Map Flip";
	ui_tooltip = "Flip the depth map if it is upside down.";
> = false;

uniform int WDM <
	ui_type = "combo";
	ui_items = "Weapon DM Off\0Custom WDM One\0Custom WDM Two\0Weapon DM 0\0Weapon DM 1\0Weapon DM 2\0Weapon DM 3\0Weapon DM 4\0Weapon DM 5\0Weapon DM 6\0Weapon DM 7\0Weapon DM 8\0Weapon DM 9\0Weapon DM 10\0Weapon DM 11\0Weapon DM 12\0Weapon DM 13\0Weapon DM 14\0Weapon DM 15\0Weapon DM 16\0Weapon DM 17\0Weapon DM 18\0Weapon DM 19\0Weapon DM 20\0Weapon DM 21\0Weapon DM 22\0Weapon DM 23\0Weapon DM 24\0Weapon DM 25\0";
	ui_label = "Weapon Depth Map";
	ui_tooltip = "Pick your weapon depth map for games.";
> = 0;

uniform float3 Weapon_Adjust <
	ui_type = "drag";
	ui_min = -10.0; ui_max = 10.0;
	ui_label = "Weapon Adjust Depth Map";
	ui_tooltip = "Adjust weapon depth map.\n" 
				 "Default is (X 0.010, Y 5.0, Z 1.0)";
> = float3(0.010,5.00,1.00);

uniform float Weapon_Cutoff <
	ui_type = "drag";
	ui_min = 0; ui_max = 1;
	ui_label = "Weapon Cutoff Point";
	ui_tooltip = "For adjusting the cutoff point of the weapon Depth Map.\n" 
				 "Zero is Auto.";
> = 0;

uniform int Custom_Sidebars <
	ui_type = "combo";
	ui_items = "Mirrored Edges\0Black Edges\0Stretched Edges\0";
	ui_label = "Edge Selection";
	ui_tooltip = "Edges selection for your screen output.";
> = 1;

uniform int Stereoscopic_Mode <
	ui_type = "combo";
	ui_items = "Side by Side\0Top and Bottom\0Line Interlaced\0Column Interlaced\0Checkerboard 3D\0Anaglyph\0";
	ui_label = "3D Display Mode";
	ui_tooltip = "Stereoscopic 3D display output selection.";
> = 0;

uniform int Scaling_Support <
	ui_type = "combo";
	ui_items = " 2160p\0 Native\0 1080p A\0 1080p B\0 1050p A\0 1050p B\0 720p A\0 720p B\0";
	ui_label = "Scaling Support";
	ui_tooltip = "Dynamic Super Resolution , Virtual Super Resolution, downscaling, or Upscaling support for Line Interlaced, Column Interlaced, & Checkerboard 3D displays.";
> = 1;

uniform int Anaglyph_Colors <
	ui_type = "combo";
	ui_items = "Red/Cyan\0Dubois Red/Cyan\0Green/Magenta\0Dubois Green/Magenta\0";
	ui_label = "Anaglyph Color Mode";
	ui_tooltip = "Select colors for your 3D anaglyph glasses.";
> = 0;

uniform float Anaglyph_Desaturation <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "Anaglyph Desaturation";
	ui_tooltip = "Adjust anaglyph desaturation, Zero is Black & White, One is full color.";
> = 1.0;

uniform bool AO <
	ui_label = "3D AO Mode";
	ui_tooltip = "3D ambient occlusion mode switch.\n" 
				 "Default is On.";
> = 1;

uniform float AO_Shift <
	ui_type = "drag";
	ui_min = 0; ui_max = 0.500;
	ui_label = "AO Shift";
	ui_tooltip = "Determines the Shift from White to Black.\n" 
				 "Default is 0";
> = 0.0;

uniform int Mode <
	ui_type = "combo";
	ui_items = "Normal\0Over Sample\0Tight\0";
	ui_label = "Sample Mode Selection";
	ui_tooltip = "Use this to hide artifacts.";
> = 0;

uniform bool Eye_Swap <
	ui_label = "Swap Eyes";
	ui_tooltip = "L/R to R/L.";
> = false;

uniform float Cross_Cursor_Size <
	ui_type = "drag";
	ui_min = 1; ui_max = 100;
	ui_label = "Cross Cursor Size";
	ui_tooltip = "Pick your size of the cross cursor.\n" 
				 "Default is 25";
> = 25.0;

uniform float3 Cross_Cursor_Color <
	ui_type = "color";
	ui_label = "Cross Cursor Color";
	ui_tooltip = "Pick your own cross cursor color.\n" 
				 "Default is (R 255, G 255, B 255)";
> = float3(1.0, 1.0, 1.0);

uniform bool InvertY <
	ui_label = "Invert Y-Axis";
	ui_tooltip = "Invert Y-Axis for the cross cursor.";
> = false;

/////////////////////////////////////////////D3D Starts Here/////////////////////////////////////////////////////////////////

#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)

texture DepthBufferTex : DEPTH;

sampler DepthBuffer 
	{ 
		Texture = DepthBufferTex; 
	};

texture BackBufferTex : COLOR;

sampler BackBuffer 
	{ 
		Texture = BackBufferTex;
	};

sampler BackBufferMIRROR 
	{ 
		Texture = BackBufferTex;
		AddressU = MIRROR;
		AddressV = MIRROR;
		AddressW = MIRROR;
	};

sampler BackBufferBORDER
	{ 
		Texture = BackBufferTex;
		AddressU = BORDER;
		AddressV = BORDER;
		AddressW = BORDER;
	};

sampler BackBufferCLAMP
	{ 
		Texture = BackBufferTex;
		AddressU = CLAMP;
		AddressV = CLAMP;
		AddressW = CLAMP;
	};
	
texture texDM  { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F; MipLevels = 3;}; 

sampler SamplerDM
	{
		Texture = texDM;
	};
	
texture texDis  { Width = BUFFER_WIDTH/Depth_Map_Division; Height = BUFFER_HEIGHT/Depth_Map_Division; Format = RGBA32F; MipLevels = 3;}; 

sampler SamplerDis
	{
		Texture = texDis;
	};
	
texture texAO  { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RGBA32F; MipLevels = 3;}; 

sampler SamplerAO
	{
		Texture = texAO;
	};

uniform float2 Mousecoords < source = "mousepoint"; > ;	
////////////////////////////////////////////////////////////////////////////////////Cross Cursor////////////////////////////////////////////////////////////////////////////////////	
float4 MouseCursor(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 Mpointer; 
	 
	if (!InvertY)
	{
		Mpointer = all(abs(Mousecoords - position.xy) < Cross_Cursor_Size) * (1 - all(abs(Mousecoords - position.xy) > Cross_Cursor_Size/(Cross_Cursor_Size/2))) ? float4(Cross_Cursor_Color, 1.0) : tex2D(BackBuffer, texcoord);//cross
	}
	else
	{
		Mpointer = all(abs(float2(Mousecoords.x,BUFFER_HEIGHT-Mousecoords.y) - position.xy) < Cross_Cursor_Size) * (1 - all(abs(float2(Mousecoords.x,BUFFER_HEIGHT-Mousecoords.y) - position.xy) > Cross_Cursor_Size/(Cross_Cursor_Size/2))) ? float4(Cross_Cursor_Color, 1.0) : tex2D(BackBuffer, texcoord);//cross
	}
	
	return Mpointer;
}

/////////////////////////////////////////////////////////////////////////////////Adapted Luminance/////////////////////////////////////////////////////////////////////////////////
texture texLum  {Width = 256/2; Height = 256/2; Format = RGBA8; MipLevels = 8;}; //Sample at 256x256/2 and a mip bias of 8 should be 1x1 
																				
sampler SamplerLum																
	{
		Texture = texLum;
		MipLODBias = 8.0f; //Luminance adapted luminance value from 1x1 Texture Mip lvl of 8
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = LINEAR;
	};
	
float AL(in float2 texcoord : TEXCOORD0)
{
	float Luminance = tex2Dlod(SamplerLum,float4(texcoord,0,0)).r; //Average Luminance Texture Sample 
    return smoothstep(0,1,Luminance);
}
/////////////////////////////////////////////////////////////////////////////////Depth Map Information/////////////////////////////////////////////////////////////////////////////////

float4 Depth(in float2 texcoord : TEXCOORD0)
{
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBuffer = tex2D(DepthBuffer, texcoord).r; //Depth Buffer

		//Conversions to linear space.....
		//Near & Far Adjustment
		float DDA = 0.125/Depth_Map_Adjust; //Division Depth Map Adjust - Near
		float DA = Depth_Map_Adjust*2; //Depth Map Adjust - Near
		//All 1.0f are Far Adjustment
		
		//0. Normal
		float Normal = 1.0f * DDA / (1.0f + zBuffer * (DDA - 1.0f));
		
		//1. Reverse
		float NormalReverse = 1.0f * DDA / (DDA + zBuffer * (1.0f - DDA));
		
		//2. Raw Buffer
		float Raw = pow(abs(zBuffer),DA);
		
		//3. Raw Buffer Reverse
		float RawReverse = pow(abs(zBuffer - 1.0),DA);
		
		//4. Special Depth Map
		float Special = pow(abs(exp(zBuffer)*Offset),(DA*25));
		
		if (Depth_Map == 0)
		{
		zBuffer = Normal;
		}
		
		else if (Depth_Map == 1)
		{
		zBuffer = NormalReverse;
		}

		else if (Depth_Map == 2)
		{
		zBuffer = Raw;
		}
		
		else if (Depth_Map == 3)
		{
		zBuffer = RawReverse;
		}
		
		else if (Depth_Map == 4)
		{
		zBuffer = lerp(Normal,Raw,Mix);
		}
		
		else if (Depth_Map == 5)
		{
		zBuffer = lerp(NormalReverse,RawReverse,Mix);
		}

		else if (Depth_Map == 6)
		{
		zBuffer = Special;
		}
	
	return float4(zBuffer.rrr,1);	
}

float4 WeaponDepth(in float2 texcoord : TEXCOORD0)
{
		if (Depth_Map_Flip)
			texcoord.y =  1 - texcoord.y;
			
		float zBufferWH = tex2D(DepthBuffer, texcoord).r; //Weapon Hand Depth Buffer
		//Weapon Depth Map
		//FPS Hand Depth Maps require more precision at smaller scales to work
		if(WDM == 1 || WDM == 3 || WDM == 4 || WDM == 6 || WDM == 7 || WDM == 8 || WDM == 9 || WDM == 10 || WDM == 11 || WDM == 12 || WDM == 13 || WDM == 14 || WDM == 16 || WDM == 17 || WDM == 19 || WDM == 20 || WDM == 21 || WDM == 22 || WDM == 23 || WDM == 24 || WDM == 25 || WDM == 26 || WDM == 27 )
		{
		float constantF = 1.0;	
		float constantN = 0.01;
		zBufferWH = 2.0 * constantN * constantF / (constantF + constantN - (2.0 * zBufferWH - 1.0) * (constantF - constantN));
		}
		else if(WDM == 2 || WDM == 5 || WDM == 15 || WDM == 18)
		{
		zBufferWH = pow(abs(zBufferWH - 1.0),10);
 		}
 		
		//Set Weapon Depth Map settings for the section below.//
		float cWF;
		float cWN;
		float cWP;
		float CoP;
		
		if (WDM == 1)
		{
		cWF = Weapon_Adjust.x;
		cWN = Weapon_Adjust.y;
		cWP = Weapon_Adjust.z;
		}
		
		if (WDM == 2)
		{
		cWF = Weapon_Adjust.x;
		cWN = Weapon_Adjust.y;
		cWP = Weapon_Adjust.z;
		}
		
		//Game: Unreal Gold with v227 DX9
		//Weapon Depth Map Zero
		if (WDM == 3)
		{
		cWF = 0.010;
		cWN = -2.5;
		cWP = 0.873;
		CoP = 0.390;
		}
		
		//Game: Borderlands 2 
		//Weapon Depth Map One
		if (WDM == 4)
		{
		cWF = 0.010;
		cWN = -7.500;
		cWP = 0.875;
		CoP = 0.600;
		}
		
		//Game: Call of Duty: Black Ops 
		//Weapon Depth Map Two
		if (WDM == 5)
		{
		cWF = 0.853;
		cWN = 1.500;
		cWP = 1.0003;
		CoP = 0.507;
		}
		
		//Game: Call of Duty: Games 
		//Weapon Depth Map Three
		if (WDM == 6)
		{
		cWF = 0.390;
		cWN = 5;
		cWP = 0.999;
		CoP = 0.254;
		}
		
		//Game: Fallout 4
		//Weapon Depth Map Four
		if (WDM == 7)
		{
		cWF = 0.010;
		cWN = -0.500;
		cWP = 0.9895;
		CoP = 0.252;
		}
		
		//Game: Cryostasis
		//Weapon Depth Map Five		
		if (WDM == 8)
		{
		cWF = 0.015;
		cWN = -87.500;
		cWP = 0.750;
		CoP = 0.666;
		}
		
		//Game: Doom 2016
		//Weapon Depth Map Six
		if (WDM == 9)
		{
		cWF = 0.010;
		cWN = -15.0;
		cWP = 0.890;
		CoP = 0.4127;
		}
		
		//Game: Metro Games
		//Weapon Depth Map Seven
		if (WDM == 10)
		{
		cWF = 0.010;
		cWN = -5.0;
		cWP = 0.956;
		CoP = 0.260;
		}
		
		//Game: NecroVision
		//Weapon Depth Map Eight
		if (WDM == 11)
		{
		cWF = 0.010;
		cWN = -20.0;
		cWP = 0.4825;
		CoP = 0.733;
		}
		
		//Game: Quake XP
		//Weapon Depth Map Nine
		if (WDM == 12)
		{
		cWF = 0.010;
		cWN = -25.0;
		cWP = 0.695;
		CoP = 0.341;
		}
		
		//Game: Quake 4
		//Weapon Depth Map Ten
		if (WDM == 13)
		{
		cWF = 0.010;
		cWN = -20.0;
		cWP = 0.500;
		CoP = 0.476;
		}
		
		//Game: Rage
		//Weapon Depth Map Eleven
		if (WDM == 14)
		{
		cWF = 0.010;
		cWN = -7.5;
		cWP = 0.4505;
		CoP = 0.816;
		}
		
		//Game: Return to Castle Wolfensitne
		//Weapon Depth Map Twelve
		if (WDM == 15)
		{
		cWF = 0.010;
		cWN = 100.0;
		cWP = 0.4375;
		CoP = 0.522;
		}

		//Game: S.T.A.L.K.E.R: Games
		//Weapon Depth Map Thirteen
		if (WDM == 16)
		{
		cWF = 0.010;
		cWN = -5.0;
		cWP = 0.976;
		CoP = 0.508;
		}

		//Game: Skyrim Special Edition
		//Weapon Depth Map Fourteen
		if (WDM == 17)
		{
		cWF = 0.010;
		cWN = -5.0;
		cWP = 0.90375;
		CoP = 0.275;
		}
		
		//Game: Turok Dinosaur Hunter
		//Weapon Depth Map Fifteen
		if (WDM == 18)
		{
		cWF = 0.010;
		cWN = -0.450;
		cWP = 0.01225;
		CoP = 0.473;
		}
		
		//Game: Wolfenstine: New Order ; Old Blood
		//Weapon Depth Map Sixteen
		if (WDM == 19)
		{
		cWF = 0.010;
		cWN = -10.0;
		cWP = 0.4455;
		CoP = 0.548;
		}
		
		//Game: Prey 2017 Object Detail Veary High
		//Weapon Depth Map Seventeen
		if (WDM == 20)
		{
		cWF = 0.010;
		cWN = 3.75;
		cWP = 0.0914;
		CoP = 0.275;
		}
		
		//Game: Prey 2017
		//Weapon Depth Map Eighteen
		if (WDM == 21)
		{
		cWF = 0.010;
		cWN = 5.0;
		cWP = 0.131;
		CoP = 0.285;
		}
		
		//Game: Deus Ex Mankind Divided may not be needed.
		//Weapon Depth Map Nineteen
		if (WDM == 22)
		{
		cWF = 0.010;
		cWN = 150.0;
		cWP = 1.100;
		}

		//Game: Dying Light
		//Weapon Depth Map Twenty
		if (WDM == 23)
		{
		cWF = 0.010;
		cWN = 150.0;
		cWP = 1.045;
		}

		//Game: Kingpin
		//Weapon Depth Map Twenty One
		if (WDM == 24)
		{
		cWF = 0.010;
		cWN = 150.0;
		cWP = 1.100;
		CoP = 0.338;
		}
		
		//Game: SOMA
		//Weapon Depth Map Twenty Two
		if (WDM == 25)
		{
		cWF = 0.010;
		cWN = -150.0;
		cWP = 0.125;
		CoP = 0.900;
		}
		
		//Game: Turok 2: Seeds of Evil
		//Weapon Depth Map Twenty Three
		if (WDM == 26)
		{
		cWF = 0.010;
		cWN = -100.0;
		cWP = -0.050;
		CoP = 3.750;
		}
		
		//Game: Amnesia: Machine for Pigs
		//Weapon Depth Map Twenty Four
		if (WDM == 27)
		{
		cWF = 0.010;
		cWN = -37.5;
		cWP = -0.0075;
		CoP = 7.0;
		}
		
		//Game:
		//Weapon Depth Map Twenty Five
		if (WDM == 28)
		{
		cWF = Weapon_Adjust.x;
		cWN = Weapon_Adjust.y;
		cWP = Weapon_Adjust.z;
		}
		
		//SWDMS Done//
 		
		//Scaled Section z-Buffer
		
		if (WDM >= 1)
		{
		cWN /= 1000;
		zBufferWH = (cWN * zBufferWH) / ((cWP*zBufferWH)-(cWF));
		}
		
		if (WDM == 18 || WDM == 24) //Turok Dinosaur Hunter ; KingPin
		zBufferWH = 1-zBufferWH;
		
		float Adj = Weapon_Depth/375; //Push & pull weapon in or out of screen.
		zBufferWH = smoothstep(Adj,1,zBufferWH) ;//Weapon Adjust smoothstep range from Adj-1
		
		//Auto Anti Weapon Depth Map Z-Fighting is always on.
		zBufferWH = zBufferWH*clamp(AL(texcoord).r*2,0.125,1); 
		
		if (WDM == 18)
		{
		zBufferWH = smoothstep(0,1,zBufferWH);
		}
		else
		{
		zBufferWH = smoothstep(0,1.250,zBufferWH);
		}
		if (Weapon_Cutoff == 0) //Zero Is auto
		{
		CoP = CoP;
		}
		else	
		{
		CoP = Weapon_Cutoff;
		}
		
		return float4(saturate(zBufferWH.rrr),CoP);
}

void DepthMap(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 Color : SV_Target0)
{
		float N,R,G,B,A = 1;
		
		float DM = Depth(texcoord).r;
		float AverageLuminance = Depth(texcoord).r;	

		float WD = WeaponDepth(texcoord).r;
		
		float CoP = WeaponDepth(texcoord).w; //Weapon Cutoff Point
				
		float CutOFFCal = (CoP/Depth_Map_Adjust)/2; //Weapon Cutoff Calculation
					
		float NearDepth = step(WD.r,1.0); //Base Cutoff
		
		float D, Done;
		
		float Cutoff = step(DM.r,CutOFFCal);
				
		if (WDM == 0)
		{
		Done = DM;
		}
		else
		{
		D = lerp(DM,WD,NearDepth);
		Done = lerp(DM,D,Cutoff);
		}
		
		R = Done;
		G = AverageLuminance;
		B = Done;
		
	// Dither for DepthBuffer adapted from gedosato ramdom dither https://github.com/PeterTh/gedosato/blob/master/pack/assets/dx9/deband.fx
	// I noticed in some games the depth buffer started to have banding so this is used to remove that.
			
	float dither_bit  = 7.0;
	float noise = frac(sin(dot(texcoord, float2(12.9898, 78.233))) * 43758.5453 * 1);
	float dither_shift = (1.0 / (pow(2,dither_bit) - 1.0));
	float dither_shift_half = (dither_shift * 0.5);
	dither_shift = dither_shift * noise - dither_shift_half;
	B += -dither_shift;
	B += dither_shift;
	B += -dither_shift;
	
	// Dither End	
	
	Color = float4(R,G,B,A);
}

/////////////////////////////////////////////////////AO/////////////////////////////////////////////////////////////

float3 GetPosition(float2 coords)
{
	return float3(coords.xy*2.5-1.0,10.0)*tex2Dlod(SamplerDM,float4(coords.xy,0,0)).rrr;
}

float2 GetRandom(float2 co)
{
	float random = frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453 * 1);
	return float2(random,random);
}

float3 normal_from_depth(float2 texcoords) 
{
	float depth;
	const float2 offset1 = float2(-10,10);
	const float2 offset2 = float2(10,10);
	  
	float depth1 = tex2Dlod(SamplerDM, float4(texcoords + offset1,0,0)).r;
	float depth2 = tex2Dlod(SamplerDM, float4(texcoords + offset2,0,0)).r;
	  
	float3 p1 = float3(offset1, depth1 - depth);
	float3 p2 = float3(offset2, depth2 - depth);
	  
	float3 normal = cross(p1, p2);
	normal.z = -normal.z;
	  
	return normalize(normal);
}

//Ambient Occlusion form factor
float aoFF(in float3 ddiff,in float3 cnorm, in float c1, in float c2)
{
	float S = 1-AO_Shift;
	float3 vv = normalize(ddiff);
	float rd = length(ddiff);
	return (S-clamp(dot(normal_from_depth(float2(c1,c2)),-vv),-1,1.0)) * (1.0 - 1.0/sqrt(-0.001/(rd*rd) + 1000));
}

float4 GetAO( float2 texcoord )
{ 
    //current normal , position and random static texture.
    float3 normal = normal_from_depth(texcoord);
    float3 position = GetPosition(texcoord);
	float2 random = GetRandom(texcoord).xy;
    
    //initialize variables:
    float F = 1.5;//Falloff
	float iter = 2.5*pix.x;
    float aout, num = 8;
    float incx = F*pix.x;
    float incy = F*pix.y;
    float width = incx;
    float height = incy;
    
    //Depth Map
    float depthM = tex2Dlod(SamplerDM,float4(texcoord ,0,0)).b;
    
		
	//Depth Map linearization
	float constantF = 1.0;	
	float constantN = 0.250;
	depthM = saturate(2.0 * constantN * constantF / (constantF + constantN - (2.0 * depthM - 1.0) * (constantF - constantN)));
    
	//2 iterations
	[loop]
    for(int i = 0; i<2; ++i) 
    {
       float npw = (width+iter*random.x)/depthM;
       float nph = (height+iter*random.y)/depthM;
       
		if(AO == 1)
		{
			float3 ddiff = GetPosition(texcoord.xy+float2(npw,nph))-position;
			float3 ddiff2 = GetPosition(texcoord.xy+float2(npw,-nph))-position;
			float3 ddiff3 = GetPosition(texcoord.xy+float2(-npw,nph))-position;
			float3 ddiff4 = GetPosition(texcoord.xy+float2(-npw,-nph))-position;

			aout += aoFF(ddiff,normal,npw,nph);
			aout += aoFF(ddiff2,normal,npw,-nph);
			aout += aoFF(ddiff3,normal,-npw,nph);
			aout += aoFF(ddiff4,normal,-npw,-nph);
		}
		
		//increase sampling area
		   width += incx;  
		   height += incy;	    
    } 
    aout/=num;

	//Luminance adjust used for overbright correction.
	float4 Done = min(1.0,aout);
	float OBC =  dot(Done.rgb,float3(0.2627, 0.6780, 0.0593));
	return smoothstep(0,1,float4(OBC,OBC,OBC,1));
}

void AO_in(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 )
{
	color = GetAO(texcoord);
}

void Average_Luminance(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0 )
{
	color = tex2D(SamplerDM,texcoord).gggg;
}

void  Disocclusion(in float4 position : SV_Position, in float2 texcoord : TEXCOORD0, out float4 color : SV_Target0)
{
//bilateral blur\/
float4 Done, sum, DM;
float B, DP =  Divergence,Disocclusion_Power;

float blursize = 2.0*pix.x;

if(AO == 1)
	{
		sum += tex2D(SamplerAO, float2(texcoord.x - 4.0*blursize, texcoord.y)) * 0.05;
		sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y - 3.0*blursize)) * 0.09;
		sum += tex2D(SamplerAO, float2(texcoord.x - 2.0*blursize, texcoord.y)) * 0.12;
		sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y - blursize)) * 0.15;
		sum += tex2D(SamplerAO, float2(texcoord.x + blursize, texcoord.y)) * 0.15;
		sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y + 2.0*blursize)) * 0.12;
		sum += tex2D(SamplerAO, float2(texcoord.x + 3.0*blursize, texcoord.y)) * 0.09;
		sum += tex2D(SamplerAO, float2(texcoord.x, texcoord.y + 4.0*blursize)) * 0.05;
	}
	
Done = 1-sum;
//bilateral blur/\

	if(Dis_Occlusion == 1)     
		{
		Disocclusion_Power = DP/350;
		}
else if(Dis_Occlusion == 2)     
		{
		Disocclusion_Power = DP/306.25;
		}
else if(Dis_Occlusion == 3)     
		{
		Disocclusion_Power = DP/262.5;
		}
else if(Dis_Occlusion == 4)   
		{
		Disocclusion_Power = DP/175;
		}
else if(Dis_Occlusion == 5)   
		{
		Disocclusion_Power = DP/min(-250,1-tex2Dlod(SamplerDM,float4(texcoord,0,0)).b/0.002);
		}
		
 float2 dir;
 const int Con = 10;
	
	if(Dis_Occlusion >= 1) 
	{
		const float weight[Con] = {0.01,-0.01,0.02,-0.02,0.03,-0.03,0.04,-0.04,0.05,-0.05};
		
		if(Dis_Occlusion >= 1)
		{
			dir = float2(0.5,0.0);
			B = Disocclusion_Power;
		}
		
		[loop]
		for (int i = 0; i < Con; i++)
		{	
			if(Dis_Occlusion >= 1) 
			{	
				DM += tex2Dlod(SamplerDM,float4(texcoord + dir * weight[i] * B ,0,0)).bbbb/Con;
			}
		}
	
	}
	else
	{
		DM = tex2Dlod(SamplerDM,float4(texcoord,0,0)).bbbb;
	}	                          
		
		DM = lerp(DM,float4(1,1,1,1),0.04375);                         	
		
		float4 AODM;
		
		if(AO == 1)
		{
			AODM =lerp(DM,Done,0.04375);
		}
		else
		{
			AODM = DM;
		}
		
	color = float4(DM.r,0,AODM.r,1); //AO Depth Map is on the Blue Channel Normal DM on the Red Channel.
}

////////////////////////////////////////////////Left/Right Eye////////////////////////////////////////////////////////

float4 PS_renderLR(in float2 texcoord : TEXCOORD0)
{
	float4 color,Samp;
	float DepthL = 1, DepthR = 1, DepthZL = 1, DepthZR = 1, MS, P, S, Z;
	
	if(Mode == 1)
	{
	Samp = float4(0.60, 0.58, 0.75, 1.5);
	}
	else if(Mode == 2)
	{
	Samp = float4(0.60, 0.58, 0.66, 1);
	}
	else
	{
	Samp = float4(0.50, 0.58, 0.66, 1);
	}
	
	float samples[4] = {Samp.x, Samp.y, Samp.z,Samp.w};
	float2 TCL, TCR;
	
	if(!Eye_Swap) //MS is Max Separation P is Perspective Adjustment
		{	
			P = Perspective * pix.x;
			MS = Divergence * pix.x;
		}
		else
		{
			P = -Perspective * pix.x;
			MS = -Divergence * pix.x;
		}
	
	if (Stereoscopic_Mode == 0)
		{
			TCR.x = (texcoord.x*2-1) - P;
			TCL.x = (texcoord.x*2) + P;
			TCR.y = texcoord.y;
			TCL.y = texcoord.y;
		}
	else if(Stereoscopic_Mode == 1)
		{
			TCR.x = texcoord.x - P;
			TCL.x = texcoord.x + P;
			TCR.y = texcoord.y*2-1;
			TCL.y = texcoord.y*2;
		}
	else
		{
			TCR.x = texcoord.x - P;
			TCL.x = texcoord.x + P;
			TCR.y = texcoord.y;
			TCL.y = texcoord.y;
		}
	
	[loop]
	for (int j = 0; j < 4; ++j) 
	{	
		S = samples[j] * MS;
		
		float L = tex2Dlod(SamplerDis,float4(TCL.x+S, TCL.y,0,0)).r;
		float R = tex2Dlod(SamplerDis,float4(TCR.x-S, TCR.y,0,0)).r;
		
		float ZL = tex2Dlod(SamplerDis,float4(TCL.x+S, TCL.y,0,0)).b;
		float ZR = tex2Dlod(SamplerDis,float4(TCR.x-S, TCR.y,0,0)).b;
		
		DepthL =  min(DepthL,L);
		DepthR =  min(DepthR,R);
		DepthZL =  min(DepthZL,ZL);
		DepthZR =  min(DepthZR,ZR);
	}
	
	float ParallaxL = max(-0.1,MS * (1-ZPD/DepthZL));
	float ParallaxR = max(-0.1,MS * (1-ZPD/DepthZR));
	
	if(ZPD == 0)
	{
	Z = 1.0;
	}
	else
	{
	Z = 0.5;
	}
	
		ParallaxL = lerp(ParallaxL,DepthL * MS,0.5);
		ParallaxR = lerp(ParallaxR,DepthR * MS,0.5);
		
		float ReprojectionLeft =  ParallaxL;
		float ReprojectionRight = ParallaxR;
	
	if(!Depth_Map_View)
	{
		if(Stereoscopic_Mode == 0)
		{
			if(Custom_Sidebars == 0)
			{
			color = texcoord.x < 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x*2 + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferMIRROR, float2((texcoord.x*2-1 - P) - ReprojectionRight, texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.x < 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x*2 + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x*2-1 - P) - ReprojectionRight, texcoord.y));
			}
			else
			{
			color = texcoord.x < 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x*2 + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x*2-1 - P) - ReprojectionRight, texcoord.y));
			}
		}
		else if(Stereoscopic_Mode == 1)
		{	
			if(Custom_Sidebars == 0)
			{
			color = texcoord.y < 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y*2)) : tex2D(BackBufferMIRROR, float2((texcoord.x - P) - ReprojectionRight, texcoord.y*2-1));
			}
			else if(Custom_Sidebars == 1)
			{
			color = texcoord.y < 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y*2)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - ReprojectionRight, texcoord.y*2-1));
			}
			else
			{
			color = texcoord.y < 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y*2)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - ReprojectionRight, texcoord.y*2-1));
			}
		}
		else if(Stereoscopic_Mode == 2)
		{
			float gridL;
			
			if(Scaling_Support == 0)
			{
			gridL = frac(texcoord.y*(2160.0/2));
			}			
			else if(Scaling_Support == 1)
			{
			gridL = frac(texcoord.y*(BUFFER_HEIGHT/2)); //Native
			}
			else if(Scaling_Support == 2)
			{
			gridL = frac(texcoord.y*(1080.0/2));
			}
			else if(Scaling_Support == 3)
			{
			gridL = frac(texcoord.y*(1081.0/2));
			}
			else if(Scaling_Support == 4)
			{
			gridL = frac(texcoord.y*(1050.0/2));
			}
			else if(Scaling_Support == 5)
			{
			gridL = frac(texcoord.y*(1051.0/2));
			}
			
			if(Custom_Sidebars == 0)
			{
			color = gridL > 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) :  tex2D(BackBufferMIRROR, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = gridL > 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else
			{
			color = gridL > 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
		}
		else if(Stereoscopic_Mode == 3)
		{
			float gridC;
			
			if(Scaling_Support == 0)
			{
			gridC = frac(texcoord.x*(3840.0/2));
			}			
			else if(Scaling_Support == 1)
			{
			gridC = frac(texcoord.x*(BUFFER_WIDTH/2)); //Native
			}
			else if(Scaling_Support == 2)
			{
			gridC = frac(texcoord.x*(1920.0/2));
			}
			else if(Scaling_Support == 3)
			{
			gridC = frac(texcoord.x*(1921.0/2));
			}
			else if(Scaling_Support == 6)
			{
			gridC = frac(texcoord.x*(1280.0/2));
			}
			else if(Scaling_Support == 7)
			{
			gridC = frac(texcoord.x*(1281.0/2));
			}
			
			
			if(Custom_Sidebars == 0)
			{
			color = gridC > 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) :  tex2D(BackBufferMIRROR, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = gridC > 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else
			{
			color = gridC > 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
		}
		else if(Stereoscopic_Mode == 4)
		{
			float gridy;
			float gridx;

			if(Scaling_Support == 1)
			{
			gridy = floor(texcoord.y*(BUFFER_HEIGHT)); //Native
			gridx = floor(texcoord.x*(BUFFER_WIDTH)); //Native
			}
			else if(Scaling_Support == 2)
			{
			gridy = floor(texcoord.y*(1080.0));
			gridx = floor(texcoord.x*(1920.0));
			}
			else if(Scaling_Support == 3)
			{
			gridy = floor(texcoord.y*(1081.0));
			gridx = floor(texcoord.x*(1921.0));
			}
			else if(Scaling_Support == 6)
			{
			gridy = floor(texcoord.y*(720.0));
			gridx = floor(texcoord.x*(1280.0));
			}
			else if(Scaling_Support == 7)
			{
			gridy = floor(texcoord.y*(721.0));
			gridx = floor(texcoord.x*(1281.0));
			}
			
			if(Custom_Sidebars == 0)
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(BackBufferMIRROR, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) :  tex2D(BackBufferMIRROR, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else if(Custom_Sidebars == 1)
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(BackBufferBORDER, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferBORDER, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
			else
			{
			color = (int(gridy+gridx) & 1) < 0.5 ? tex2D(BackBufferCLAMP, float2((texcoord.x + P) + ReprojectionLeft, texcoord.y)) : tex2D(BackBufferCLAMP, float2((texcoord.x - P) - ReprojectionRight, texcoord.y));
			}
		}
		else
		{
													
				float3 HalfLM = dot(tex2D(BackBufferMIRROR,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 HalfRM = dot(tex2D(BackBufferMIRROR,float2((texcoord.x - P) - ReprojectionRight,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 LM = lerp(HalfLM,tex2D(BackBufferMIRROR,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)).rgb,Anaglyph_Desaturation);  
				float3 RM = lerp(HalfRM,tex2D(BackBufferMIRROR,float2((texcoord.x - P) - ReprojectionRight,texcoord.y)).rgb,Anaglyph_Desaturation); 
				
				float3 HalfLB = dot(tex2D(BackBufferBORDER,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 HalfRB = dot(tex2D(BackBufferBORDER,float2((texcoord.x - P ) - ReprojectionRight,texcoord.y)).rgb,float3(0.299, 0.587, 0.114));
				float3 LB = lerp(HalfLB,tex2D(BackBufferBORDER,float2((texcoord.x + P) + ReprojectionLeft,texcoord.y)).rgb,Anaglyph_Desaturation);  
				float3 RB = lerp(HalfRB,tex2D(BackBufferBORDER,float2((texcoord.x - P) - ReprojectionRight,texcoord.y)).rgb,Anaglyph_Desaturation); 
				
				float4 C;
				float4 CT;
				
				if(Custom_Sidebars == 0)
				{
				C = float4(LM,1);
				CT = float4(RM,1);
				}
				else
				{
				C = float4(LB,1);
				CT = float4(RB,1);
				}

				
			if (Anaglyph_Colors == 0)
			{
				float4 LeftEyecolor = float4(1.0,0.0,0.0,1.0);
				float4 RightEyecolor = float4(0.0,1.0,1.0,1.0);
				

				color =  (C*LeftEyecolor) + (CT*RightEyecolor);

			}
			else if (Anaglyph_Colors == 1)
			{
			float red = 0.437 * C.r + 0.449 * C.g + 0.164 * C.b
					- 0.011 * CT.r - 0.032 * CT.g - 0.007 * CT.b;
			
			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = -0.062 * C.r -0.062 * C.g -0.024 * C.b 
						+ 0.377 * CT.r + 0.761 * CT.g + 0.009 * CT.b;
			
			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.048 * C.r - 0.050 * C.g - 0.017 * C.b 
						-0.026 * CT.r -0.093 * CT.g + 1.234  * CT.b;
			
			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }


			color = float4(red, green, blue, 0);
			}
			else if (Anaglyph_Colors == 2)
			{
				float4 LeftEyecolor = float4(0.0,1.0,0.0,1.0);
				float4 RightEyecolor = float4(1.0,0.0,1.0,1.0);
				
				color =  (C*LeftEyecolor) + (CT*RightEyecolor);
				
			}
			else
			{
				
				
			float red = -0.062 * C.r -0.158 * C.g -0.039 * C.b
					+ 0.529 * CT.r + 0.705 * CT.g + 0.024 * CT.b;
			
			if (red > 1) { red = 1; }   if (red < 0) { red = 0; }

			float green = 0.284 * C.r + 0.668 * C.g + 0.143 * C.b 
						- 0.016 * CT.r - 0.015 * CT.g + 0.065 * CT.b;
			
			if (green > 1) { green = 1; }   if (green < 0) { green = 0; }

			float blue = -0.015 * C.r -0.027 * C.g + 0.021 * C.b 
						+ 0.009 * CT.r + 0.075 * CT.g + 0.937  * CT.b;
			
			if (blue > 1) { blue = 1; }   if (blue < 0) { blue = 0; }
					
			color = float4(red, green, blue, 0);
			}
		}	
	}
		else
	{
			float3 FinDM = lerp(tex2Dlod(SamplerDis,float4(texcoord.x,texcoord.y*2-1,0,0)).rrr,tex2Dlod(SamplerDis,float4(texcoord.x,texcoord.y*2-1,0,0)).bbb,0.5);
			float4 DMV = texcoord.x < 0.5 ? GetAO(float2(texcoord.x*2 , texcoord.y*2)) : tex2Dlod(SamplerDM,float4(texcoord.x*2-1 , texcoord.y*2,0,0)).bbbb;
			color = texcoord.y < 0.5 ? DMV : float4(FinDM,1) ;
	}
return color;
}

////////////////////////////////////////////////////////Logo/////////////////////////////////////////////////////////////////////////
uniform float timer < source = "timer"; >;
float4 Out(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	//#define pix float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
	float HEIGHT = BUFFER_HEIGHT/2,WIDTH = BUFFER_WIDTH/2;	
	float2 LCD,LCE,LCP,LCT,LCH,LCThree,LCDD,LCDot,LCI,LCN,LCF,LCO;
	float size = 9.5,set = BUFFER_HEIGHT/2,offset = (set/size),Shift = 50;
	float4 Color = PS_renderLR(texcoord),Done,Website,D,E,P,T,H,Three,DD,Dot,I,N,F,O;

	if(timer <= 10000)
	{
	//DEPTH
	//D
	float offsetD = (size*offset)/(set-((size/size)+(size/size)));
	LCD = float2(-90-Shift,0); 
	float4 OneD = all(abs(LCD+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoD = all(abs(LCD+float2(WIDTH*offsetD,HEIGHT)-position.xy) < float2(size,size*1.5));
	D = OneD-TwoD;
	//
	
	//E
	float offs = (size*offset)/(set-(size/size)/2);
	LCE = float2(-62-Shift,0); 
	float4 OneE = all(abs(LCE+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoE = all(abs(LCE+float2(WIDTH*offs,HEIGHT)-position.xy) < float2(size*0.875,size*1.5));
	float4 ThreeE = all(abs(LCE+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size/3));
	E = (OneE-TwoE)+ThreeE;
	//
	
	//P
	float offsetP = (size*offset)/(set-((size/size)*5));
	float offsP = (size*offset)/(set-(size/size)*-11);
	float offseP = (size*offset)/(set-((size/size)*4.25));
	LCP = float2(-37-Shift,0);
	float4 OneP = all(abs(LCP+float2(WIDTH,HEIGHT/offsetP)-position.xy) < float2(size,size*1.5));
	float4 TwoP = all(abs(LCP+float2((WIDTH)*offsetD,HEIGHT/offsetP)-position.xy) < float2(size,size));
	float4 ThreeP = all(abs(LCP+float2(WIDTH/offseP,HEIGHT/offsP)-position.xy) < float2(size*0.200,size));
	P = (OneP-TwoP)+ThreeP;
	//

	//T
	float offsetT = (size*offset)/(set-((size/size)*16.75));
	float offsetTT = (size*offset)/(set-((size/size)*1.250));
	LCT = float2(-10-Shift,0);
	float4 OneT = all(abs(LCT+float2(WIDTH,HEIGHT*offsetTT)-position.xy) < float2(size/4,size*1.875));
	float4 TwoT = all(abs(LCT+float2(WIDTH,HEIGHT/offsetT)-position.xy) < float2(size,size/4));
	T = OneT+TwoT;
	//
	
	//H
	LCH = float2(13-Shift,0);
	float4 OneH = all(abs(LCH+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoH = all(abs(LCH+float2(WIDTH,HEIGHT)-position.xy) < float2(size/2,size*2));
	float4 ThreeH = all(abs(LCH+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size/3));
	H = (OneH-TwoH)+ThreeH;
	//
	
	//Three
	float offsThree = (size*offset)/(set-(size/size)*1.250);
	LCThree = float2(38-Shift,0);
	float4 OneThree = all(abs(LCThree+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoThree = all(abs(LCThree+float2(WIDTH*offsThree,HEIGHT)-position.xy) < float2(size*1.2,size*1.5));
	float4 ThreeThree = all(abs(LCThree+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size/3));
	Three = (OneThree-TwoThree)+ThreeThree;
	//
	
	//DD
	float offsetDD = (size*offset)/(set-((size/size)+(size/size)));
	LCDD = float2(65-Shift,0);
	float4 OneDD = all(abs(LCDD+float2(WIDTH,HEIGHT)-position.xy) < float2(size,size*2));
	float4 TwoDD = all(abs(LCDD+float2(WIDTH*offsetDD,HEIGHT)-position.xy) < float2(size,size*1.5));
	DD = OneDD-TwoDD;
	//
	
	//Dot
	float offsetDot = (size*offset)/(set-((size/size)*16));
	LCDot = float2(85-Shift,0);	
	float4 OneDot = all(abs(LCDot+float2(WIDTH,HEIGHT*offsetDot)-position.xy) < float2(size/3,size/3.3));
	Dot = OneDot;
	//
	
	//INFO
	//I
	float offsetI = (size*offset)/(set-((size/size)*18));
	float offsetII = (size*offset)/(set-((size/size)*8));
	float offsetIII = (size*offset)/(set-((size/size)*5));
	LCI = float2(101-Shift,0);	
	float4 OneI = all(abs(LCI+float2(WIDTH,HEIGHT*offsetI)-position.xy) < float2(size,size/4));
	float4 TwoI = all(abs(LCI+float2(WIDTH,HEIGHT/offsetII)-position.xy) < float2(size,size/4));
	float4 ThreeI = all(abs(LCI+float2(WIDTH,HEIGHT*offsetIII)-position.xy) < float2(size/4,size*1.5));
	I = OneI+TwoI+ThreeI;
	//
	
	//N
	float offsetN = (size*offset)/(set-((size/size)*7));
	float offsetNN = (size*offset)/(set-((size/size)*5));
	LCN = float2(126-Shift,0);	
	float4 OneN = all(abs(LCN+float2(WIDTH,HEIGHT/offsetN)-position.xy) < float2(size,size/4));
	float4 TwoN = all(abs(LCN+float2(WIDTH*offsetNN,HEIGHT*offsetNN)-position.xy) < float2(size/5,size*1.5));
	float4 ThreeN = all(abs(LCN+float2(WIDTH/offsetNN,HEIGHT*offsetNN)-position.xy) < float2(size/5,size*1.5));
	N = OneN+TwoN+ThreeN;
	//
	
	//F
	float offsetF = (size*offset)/(set-((size/size*7)));
	float offsetFF = (size*offset)/(set-((size/size)*5));
	float offsetFFF = (size*offset)/(set-((size/size)*-7.5));
	LCF = float2(153-Shift,0);	
	float4 OneF = all(abs(LCF+float2(WIDTH,HEIGHT/offsetF)-position.xy) < float2(size,size/4));
	float4 TwoF = all(abs(LCF+float2(WIDTH/offsetFF,HEIGHT*offsetFF)-position.xy) < float2(size/5,size*1.5));
	float4 ThreeF = all(abs(LCF+float2(WIDTH,HEIGHT/offsetFFF)-position.xy) < float2(size,size/4));
	F = OneF+TwoF+ThreeF;
	//
	
	//O
	float offsetO = (size*offset)/(set-((size/size*-5)));
	LCO = float2(176-Shift,0);	
	float4 OneO = all(abs(LCO+float2(WIDTH,HEIGHT/offsetO)-position.xy) < float2(size,size*1.5));
	float4 TwoO = all(abs(LCO+float2(WIDTH,HEIGHT/offsetO)-position.xy) < float2(size/1.5,size));
	O = OneO-TwoO;
	//
	}
	
	Website = D+E+P+T+H+Three+DD+Dot+I+N+F+O ? float4(1.0,1.0,1.0,1) : Color;
	
	if(timer >= 10000)
	{
	Done = Color;
	}
	else
	{
	Done = Website;
	}

	return Done;
}

///////////////////////////////////////////////////////////ReShade.fxh/////////////////////////////////////////////////////////////

// Vertex shader generating a triangle covering the entire screen
void PostProcessVS(in uint id : SV_VertexID, out float4 position : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	position = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

//*Rendering passes*//

technique Cross_Cursor
{			
			pass Cursor
		{
			VertexShader = PostProcessVS;
			PixelShader = MouseCursor;
		}	
}

technique Depth3D_Reprojection
{			
			pass zbuffer
		{
			VertexShader = PostProcessVS;
			PixelShader = DepthMap;
			RenderTarget = texDM;
		}
			pass AmbientOcclusion
		{
			VertexShader = PostProcessVS;
			PixelShader = AO_in;
			RenderTarget = texAO;
		}	
			pass Disocclusion
		{
			VertexShader = PostProcessVS;
			PixelShader = Disocclusion;
			RenderTarget = texDis;
		}
			pass AverageLuminance
		{
			VertexShader = PostProcessVS;
			PixelShader = Average_Luminance;
			RenderTarget = texLum;
		}
			pass StereoOut
		{
			VertexShader = PostProcessVS;
			PixelShader = Out;
		}
}
