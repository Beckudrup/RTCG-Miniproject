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
                    float4 pos    : SV_POSITION; // clip-space position
                    float3 objPos : TEXCOORD1;   // displaced object-space position
                    float3 normal : TEXCOORD2;   // normalized normal (object space)
                    float2 uv     : TEXCOORD0;
                };

                struct g2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv  : TEXCOORD0;
                    fixed4 col : COLOR;
                };

                // parameters
                float _Frequency;
                float _Speed;
                float _Amplitude;
                float3 _Axis;
                float _Factor;
                sampler2D _MainTex;
                float4 _MainTex_ST;

                // displacer
                v2g vert(appdata v)
                {
                    v2g o;
                    float time = _Speed * _Time.y * 200;
                    float3 sineWave = sin(time + v.vertex.xyz * _Frequency) * _Amplitude;
                    float3 displaced = v.vertex.xyz + sineWave * _Axis;

                    o.objPos = displaced;
                    o.normal = normalize(v.normal);
                    o.pos = UnityObjectToClipPos(float4(displaced, 1.0));
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }

                // Append one vertex into the triangle stream
                void AppendVert(inout TriangleStream<g2f> stream, float4 clipPos, float2 uv, fixed4 color)
                {
                    g2f o;
                    o.pos = clipPos;
                    o.uv = uv;
                    o.col = color;
                    stream.Append(o);
                }

                // Emit a single triangle (three vertices)
                void EmitTri(inout TriangleStream<g2f> stream,
                             float4 aPos, float2 aUV,
                             float4 bPos, float2 bUV,
                             float4 cPos, float2 cUV,
                             fixed4 color)
                {
                    AppendVert(stream, aPos, aUV, color);
                    AppendVert(stream, bPos, bUV, color);
                    AppendVert(stream, cPos, cUV, color);
                }

                // Emit a quad between edge (A->B) extruded to (A'->B') as two triangles
                void EmitSideQuad(inout TriangleStream<g2f> stream,
                                  float4 aOrig, float2 aUV,
                                  float4 bOrig, float2 bUV,
                                  float4 aExtr, float2 aExtrUV,
                                  float4 bExtr, float2 bExtrUV,
                                  fixed4 color)
                {
                    // triangle 1: A -> B -> B'
                    EmitTri(stream, aOrig, aUV, bOrig, bUV, bExtr, bExtrUV, color);
                    // triangle 2: A -> B' -> A'
                    EmitTri(stream, aOrig, aUV, bExtr, bExtrUV, aExtr, aExtrUV, color);
                }

                // front cap (3) + back cap (3) + 3 edges * 2 triangles * 3 verts = 24
                [maxvertexcount(24)]
                void geom(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
                {
                    float4 clipOrig[3];
                    float4 clipExtr[3];
                    float3 objPos[3];
                    float3 nrm[3];

                    // compute object-space extruded positions and clip-space versions
                    for (int i = 0; i < 3; i++)
                    {
                        objPos[i] = IN[i].objPos;
                        nrm[i] = normalize(IN[i].normal);
                        clipOrig[i] = IN[i].pos;
                        float3 extrObj = objPos[i] + nrm[i] * _Factor;
                        clipExtr[i] = UnityObjectToClipPos(float4(extrObj, 1.0));
                    }

                    // use white vertex color so the texture shows plainly
                    fixed4 white = fixed4(1,1,1,1);

                    // front cap (original displaced triangle)
                    EmitTri(tristream,
                            clipOrig[0], IN[0].uv,
                            clipOrig[1], IN[1].uv,
                            clipOrig[2], IN[2].uv,
                            white);

                    // back cap (extruded triangle) - reversed winding so normal faces outward
                    EmitTri(tristream,
                            clipExtr[2], IN[2].uv,
                            clipExtr[1], IN[1].uv,
                            clipExtr[0], IN[0].uv,
                            white);

                    // sides: edges (0-1), (1-2), (2-0)
                    EmitSideQuad(tristream, clipOrig[0], IN[0].uv, clipOrig[1], IN[1].uv, clipExtr[0], IN[0].uv, clipExtr[1], IN[1].uv, white);
                    EmitSideQuad(tristream, clipOrig[1], IN[1].uv, clipOrig[2], IN[2].uv, clipExtr[1], IN[1].uv, clipExtr[2], IN[2].uv, white);
                    EmitSideQuad(tristream, clipOrig[2], IN[2].uv, clipOrig[0], IN[0].uv, clipExtr[2], IN[2].uv, clipExtr[0], IN[0].uv, white);
                }

                fixed4 frag(g2f i) : SV_Target
                {
                    fixed4 tex = tex2D(_MainTex, i.uv);
                    return tex * i.col; // vertex color is white by default so texture appears normally
                }
                ENDCG
            }
        }
    }
