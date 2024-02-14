Shader "Unlit/TextureControler"
{
    Properties
    {
        [Header(Blend Mode)]

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFator("SrcBlend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("DstBlend", float) = 1

        [Space(10)]

        _MainTex ("Texture", 2D) = "white" {}
        _DisappearTex ("DisappearTex", 2D) = "white" {}

        [NoScaleOffset]_Mask ("Mask", 2D) = "white" {}

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend [_SrcFator] [_DstFactor]
        Cull Off
        Zwrite Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uvMask : TEXCOORD1;
                float2 uvDisappearTex : TEXCOORD2;
                float4 color : COLOR;

            };

            sampler2D _MainTex, _Mask, _DisappearTex;
            float4 _MainTex_ST, _Mask_ST, _DisappearTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uvMask = TRANSFORM_TEX(v.uv, _Mask);
                o.uvDisappearTex = TRANSFORM_TEX(v.uv, _DisappearTex);
                o.color = v.color;
                o.uv.z = v.uv.z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_Mask, i.uvMask);
                fixed4 disappearTex = tex2D(_DisappearTex, i.uvDisappearTex);

                disappearTex.a = step(i.uv.z, disappearTex.a);
                col.a *= mask.a * disappearTex.a;

                return col * i.color;
            }
            ENDCG
        }
    }
}
