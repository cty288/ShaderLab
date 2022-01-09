using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpaceshipControl : MonoBehaviour {
    [SerializeField] 
    private float speed = 0;
    private float targetSpeed = 0;


    [SerializeField] private float maxSpeed = 1000;
    [SerializeField] private float acceleration = 10f;

    [SerializeField] private float dashSpeed = 5000;

    [SerializeField] private float angularSpeed = 0;

    [SerializeField] private Material traverseImageEffect;

    private float targetAngle = 0;
    private float maxAnggulatrSpeed = 200;

    private void FixedUpdate() {
        if (Input.GetKey(KeyCode.W)) {
            targetSpeed += acceleration * Time.deltaTime;
        }
        if (Input.GetKey(KeyCode.S))
        {
            targetSpeed -= acceleration * Time.deltaTime;
        }

        if (Input.GetKey(KeyCode.LeftShift)) {
            targetSpeed += 1000 * Time.deltaTime;
            targetSpeed = Mathf.Clamp(targetSpeed, 0, dashSpeed);
            //dashSpeed;
            
        }
        else {
            targetSpeed = Mathf.Clamp(targetSpeed, 0, maxSpeed);
        }

        targetAngle *= 0.9f * Time.deltaTime;

        if (Mathf.Abs(targetAngle ) <= maxAnggulatrSpeed) {
            if (Input.GetKey(KeyCode.A))
            {
                targetAngle += 100 * Time.deltaTime;
            }


            if (Input.GetKey(KeyCode.D))
            {
                targetAngle -= 100 * Time.deltaTime;
            }
        }
        

        angularSpeed = Mathf.Lerp(angularSpeed, targetAngle, 0.1f);

        transform.Rotate(0,0,angularSpeed);

        speed = Mathf.Lerp(speed, targetSpeed, 0.1f);

        if (speed > 800) {
            traverseImageEffect.SetFloat("_Strength", (speed - 800) / (dashSpeed - 800));
        }
        else
        {
            traverseImageEffect.SetFloat("_Strength", 0);
        }
        


        transform.Translate(Vector3.forward * speed * Time.deltaTime, Space.Self);
    }
}
