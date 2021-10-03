using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class TimeDropDown : MonoBehaviour {
    private Dropdown dropdown;

    public SendTime sendTime;

    // Start is called before the first frame update
    void Start() {
        dropdown = GetComponent<Dropdown>();

        
    }


    // Update is called once per frame
    void Update() {
        sendTime.speed =(SendTime.Speed)dropdown.value;
    }
}
