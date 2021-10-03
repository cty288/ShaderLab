using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[RequireComponent(typeof(MeshRenderer))]
public class SendTime : MonoBehaviour {

    public enum Speed {
        RealTime,
        HalfYear,
        OneYear,
        TwoYear
    }

    Material mat;
    [HideInInspector]
    public float timeMultiplier = 1;

    public Speed speed;

    private string totalSecInYearProp = "_totalSecInYear";

    private float startSecond;

    void Start () {
        mat = GetComponent<MeshRenderer>().material;
        


        long ticks = DateTime.Now.TimeOfDay.Ticks;

        TimeSpan duration = new TimeSpan(ticks);

        float hour = (float)(duration.TotalHours % 24);
        float min = (float)(duration.TotalMinutes % 60);
        float sec = (float)(duration.TotalSeconds % 60);
        float dayOfYear = (float)(DateTime.Now.DayOfYear);

        startSecond = ((dayOfYear - 1) * 24 * 60 * 60) +
                      ((hour - 1) * 60 * 60) + ((min - 1) * 60) + sec;
    }
    void Update () {

        switch (speed) {
            case Speed.RealTime:
                timeMultiplier = 1;
                break;
            case Speed.HalfYear:
                timeMultiplier = 15768000;
                break;
            case Speed.OneYear:
                timeMultiplier = 15768000 * 2;
                break;
            case Speed.TwoYear:
                timeMultiplier = 15768000 * 4;
                break;
        }

        mat.SetFloat(totalSecInYearProp, startSecond + Time.time*timeMultiplier);

    }
}
