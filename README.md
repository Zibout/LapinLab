# LapinLab
Godot V-Tuber

## Pre-requisite
Godot 4.6



## Code convention
Follow godot naming convention:
- Use **snake_case** for folder and file names.
- Use **PascalCase** for node names, as this matches built-in node casing

GDScript:
- Use **snake_case** for functions.
- Use **_snake_case** for private functions.

## Todo:

### VTuber controller
- Lapin 3D model + Blendshapes
- Lapin character controller
- Face capture server + Publisher/Subscriber implementation
- Lapin IK arm controller
- Basic interaction with an object (fireworks)

### RL video
- Drone controller 
    - Control each propeller input power - Propellers will dampen to simulate speed-up/down time
    - Control torque using propellers (see how drone rotates)
    - Allow propeller to break!
    - Allow inputs from separate script as an array of fp32 

- Cleanup MLP training implementation
- RL environment
- 


