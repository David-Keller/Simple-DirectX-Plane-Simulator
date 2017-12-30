Auther: David Keller 
Date: 12/9/2017

Summary:
This Program simple plane simulator to test out basic understanding of shaders and Windows code.
Shaders are writen in hlsl and executed using DirectX 11.

controls are as follows:
"w" and "s" are pitch "a" and "d" are yaw (this is no roll in this simulator yet)
"shift" to start the plane flying press. Once the plane is moving "shift" is a boost.

shaders and concepts shown:
terrain generation from height mapping a texture
warer wave generation from addition of 2 textures
simple billboarding
skybox
simple camera movement and controls
diffuse and specular lighting
texturing of objects

TODO:
add anti alising
switch to an render independant clock (current game speed depends on speed of rendering).
