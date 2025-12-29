Shader "Custom/Extrude Sinus"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Factor ("Factor", Range(0., 2.)) = 0.2
        _Frequency("Frequency", float) = 20
        _Speed("Speed", float) = 0.5
        _Amplitude("Amplitude", float) = 0.1
        _Axis("Axis", Vector) = (0.1, 1, 0.1)
        _Color("Axis", Color) = (0.23, 0.95, 0.33, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
            #pragma target 4.0
 
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct v2g
            {
                float4 pos    : SV_POSITION; // clip space position
                float3 objPos : TEXCOORD1;   // object-space position (for extrusion)
                float3 normal : TEXCOORD2;   // object-space normal
                float2 uv     : TEXCOORD0;
            };


            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
                fixed4 col : COLOR;
            };

            float _Frequency;
            float _Speed;
            float _Amplitude;
            float3 _Axis;
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
           
            float4 Unity_Combine_float(float R, float G, float B, float A)
            {
                return float4(R, G, B, A);
            }

            v2g vert (appdata v)
            {
                v2g o;

                float time = _Speed * _Time.y * 200;

                float3 sineWave = sin(time + v.vertex.xyz * _Frequency) * _Amplitude;

                float3 displaced = v.vertex.xyz + sineWave * _Axis;

                o.pos = UnityObjectToClipPos(float4(displaced, 1.0));
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            float _Factor;
 
            [maxvertexcount(3)]
void geom(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
{
    g2f o;
    for (int i = 0; i < 3; i++)
    {
        o.pos = IN[i].pos;
        o.uv = IN[i].uv;
        o.col = fixed4(1,0,1,1);
        tristream.Append(o);
    }
}

          


           
            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.col;
                return col;
            }
            ENDCG
        }
    }
}
