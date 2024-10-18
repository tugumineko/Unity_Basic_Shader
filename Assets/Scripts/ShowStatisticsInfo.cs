using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


public class ShowStatisticsInfo : MonoBehaviour
{
        private void OnGUI()
        {
            GUILayout.TextField("FPS: " + 1.0f/UnityStats.frameTime);
            GUILayout.TextField("Total DrawCall: " + UnityStats.drawCalls);
            GUILayout.TextField("Batch: " + UnityStats.batches);
            GUILayout.TextField("Static Batch DC: " + UnityStats.staticBatchedDrawCalls);
            GUILayout.TextField("Static Batch: " + UnityStats.staticBatches);
            GUILayout.TextField("DynamicBatch DC: " + UnityStats.dynamicBatchedDrawCalls);
            GUILayout.TextField("DynamicBatch: " + UnityStats.dynamicBatches);
            GUILayout.TextField("Tri: " + UnityStats.triangles);
            GUILayout.TextField("Ver: " + UnityStats.vertices);
            GUILayout.TextField("Screen: " + UnityStats.screenRes);
            GUILayout.TextField("Shadown casters: " + UnityStats.shadowCasters);
            GUILayout.TextField("Visible skinned meshed: " + UnityStats.visibleSkinnedMeshes);
            GUILayout.TextField("Animations: " + UnityStats.animationComponentsPlaying);
            GUILayout.TextField("Animator: " + UnityStats.animatorComponentsPlaying);
        }
}

