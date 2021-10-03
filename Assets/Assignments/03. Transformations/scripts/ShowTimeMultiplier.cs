using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShowTimeMultiplier : MonoBehaviour {
    private Text text;
    public SendTime timer;
    void Start() {
        text = GetComponent<Text>();
    }

    // Update is called once per frame
    void Update() {
        string speed = "";
        switch (timer.speed) {
            case SendTime.Speed.RealTime:
                speed = "Realtime";
                break;
            case SendTime.Speed.HalfYear:
                speed = "0.5 Earth Year";
                break;
            case SendTime.Speed.OneYear:
                speed = "1 Earth Year";
                break;
            case SendTime.Speed.TwoYear:
                speed = "2 Earth Year";
                break;
        }
        text.text = $"speed x {speed}";
    }
}
