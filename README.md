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
- [ ] Lapin 3D model + Blendshapes
- [ ] Lapin character controller
- [ ] Face capture server + Publisher/Subscriber implementation
- [ ] Lapin IK arm controller
- [ ] Basic interaction with an object (fireworks)

### RL video
- [ ] Drone controller 
    - [ ] Control each propeller input power - Propellers will dampen to simulate speed-up/down time
    - [X] Control torque using propellers (see how drone rotates)
    - [ ] Allow propeller to break!
    - [ ] Allow inputs from separate script as an array of fp32 

- [ ] Cleanup MLP training implementation
- [ ] RL training environment 

### Car game video 1: Simulating a car
- [ ] Tenue de OuiOui pour lapin (ref aux kassos avec Laeticia)
- [ ] Car simulation
    - [ ] Engine simulation
    - [ ] Gearbox
    - [ ] Shaft simulation
    - [ ] Audio from car engine and exhaust
    - [ ] Car body (beam-NG)
- [ ] Simple track environment
- [ ] Top-gear style testing various engines


### Car game video 2: Creating a large world

- [ ] Terrain
    - [ ] Painting a rough map (height + lake and oceans)
    - [ ] Noise to add details
    - [ ] Errosion simulation
    - [ ] Marking the biomes
- [ ] Large-scale in godot
    - [ ] Tilable terrain 
    - [ ] Testing the car
    - [ ] Precision issues
    - [ ] Floating origin OR custom engine build ..?

### Car game video 3: Adding interest on our terrain

- [ ] Point Of Interest (POI)
    - [ ] Define POI following Zelda's / Ubi logic: Big (cities), Medium (Small building), Small (a specific landmark)
    - [ ] Use the generated terrain data to find places where there should be a POI
    
- [ ] Cities
    - [ ] Map + building placements and shape
    - [ ] Building generation (gray-box)
    - [ ] Roads within a city

- [ ] Roads
    - [ ] Splines for connecting points (cities, POI)
    - [ ] Structures: Bridges, Tunnels, ...
    - [ ] Edit the heightmap to match the road patterns


    