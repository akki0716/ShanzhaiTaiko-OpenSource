﻿Shader "Custom/SurfTexture"
{
	Properties
	{
	     /* 
		 材质面板属性定义，格式：变量名("<显示变量名>",变量类型)=<缺省变量值>
		 */
		 _Color("BaseColor",Color) = (1,1,1,1) 
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	/*
	    子着色器
	*/
	SubShader
	{
		Tags { "RenderType" = "Opaque" "QUEUE"="Geometry" } // 标签，这里"RenderType"标明渲染物体类型为"Opaque",非透明物体
		LOD 100 // shader LOD(level of detail ) ,可以通过这个对画质进行分档

		Pass
		{
			CGPROGRAM // CG 代码段的开始标志
			#pragma vertex vert // 预编译指令，指示顶点着色器(vertex)使用名称为vert的函数
			#pragma fragment frag // 预编译指令，告诉编译器，片元着色器(frament)使用名称为frag的函数

			#include "UnityCG.cginc" // 预编译指令，引用文件"UnityCG.cginc"，这里包含一些预定义的一些变量和函数


            /* 
			变量声明，前面Properties中定义的，暴露给编辑器材质面板的变量，
			必须在这里再次声明，因为这里才是真正的变量声明位置
			*/
			half4 _Color; 
			

			/* 
				结构体，这个结构体是顶点着色器的输入数据，
                是从应用阶段(cpu)传输给顶点处理阶段(gpu)的顶点属性，
                因此这里命名为appdata，其他任意名称也ok
			*/
            struct appdata
            {
                /*
                这里变量声明后加的":POSITION"，是语义说明，
                用来告诉GPU，顶点的坐标放在positionOS这个变量里。
                */
                float4 positionOS : POSITION;
            };

			/* 
				结构体，这个结构体是顶点着色器的输出以及片元着色器的输入，因此命名为v2f(vector to fragment ),其他任意名称也ok
			*/
            struct v2f
            {
                float4 positionCS : SV_POSITION;  // 这里的语义说明":SV_POSITION",是告诉GPU，把光栅化阶段之后的裁剪空间顶点坐标放在positionCS这个变量里。
            };

			/*
				顶点着色器函数，每个模型顶点需要调用一次该顶点着色器， 以appdata作为输入，v2f作为输出
			*/
            v2f vert (appdata v)
            {
                v2f o;

				/* 
				使用UnityCG.cginc中定义的函数,UnityObjectToClipPos()，
				把模型空间的顶点坐标转换到裁剪空间
				*/
                o.positionCS = UnityObjectToClipPos(v.positionOS); 
				/*
				上述函数的实现如下，
				实际上就是把顶点坐标先从模型空间转换到世界空间(乘以模型空间到世界空间的变换矩阵-unity_ObjectToWorld),
				然后从世界空间转换到齐次裁剪空间(世界空间坐标，乘以观察投影矩阵-UNITY_MATRIX_VP)。
				
				这里需要注意的是，
				很多教程中会告诉你使用UNITY_MATRIX_MVP矩阵直接乘以模型空间坐标，
				这种方式虽然结果上是正确的，
				但是因为UNITY_MATRIX_MPV矩阵实际上是UNITY_MATIRX_VP和unity_ObjectToWrold相乘的预编译指令，
				因此直接使用MVP矩阵会导致运算为4x4矩阵与4x4矩阵的相乘结果再乘以四维向量，
				运算次数远多于4x4矩阵乘以两次四维向量。

				因此建议使用unity内置的UnityObjectToClipPos方法或者下面的实现，进行空间变换，可以得到更好的性能
				
				o.positionCS = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(v.positionOS.xyz, 1.0)));

				*/
                return o;
            }
			/* 
				片元着色器函数，以v2f作为输入，这里v2f，是经过光栅化之后的插值过的v2f。
				每一个片元(类似于屏幕像素，只是此时还没有输送给屏幕颜色缓冲)都需要执行一次片元着色器
			*/
            half4 frag (v2f i) : SV_Target 
            {
				/* 
                "SV_Target"同样是语义说明，用来标记返回类型half4,
                说明这里返回结果保存到SV_Target0(这里0省掉了)，
                指向的颜色缓冲区的对应位置
                */

				/* 
                这里的返回值使用了half4，而不是常见的fixed4格式，
                因为目前的几乎所有显卡都不再支持fixed4类型格式，
                而编译器会内部把fixed 类型 转为 half 类型。
                
                但是除非你非常了解unity shader编译器在目标平台的编译结果，
                建议使用half4代替fixed4类型。
                */

				half4 col = half4(_Color.rgb, 1); 
                /* 
                把我们定义的变量类型_BaseColor赋值给col，并返回。
                这里".rgba"的写法或者".xyzw"是CG或者HLSL语言对向量的特有操作，
                表示把向量的指定分量(例如 .r .xy .xx .a 等 赋值给对应变量)
                */
                return col;
            }
            ENDCG // CG代码段的结束标志
        }
    }
}