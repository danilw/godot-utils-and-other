**update 2019**

gitlab mirror [https://gitlab.com/danilw](https://gitlab.com/danilw), untill I can update github repo I will (depends of github rules(region block) updates based on U.S. laws)

# godot-utils-and-other
**what is it** random(mosly some very broken demos, and very unusable utils) code I write using Godot. I do not recoment use this code for learning.


*new:*
___

**Menu_2DGI** rendering static textures and use them as menu textures, include render and examples.
To edit *max number of shapes* (is 5) edit `const max_elems` in scene.gd, and `int max_elems` in 2dGI.shader. (used default Godot 3.1.1)

How to use [watch video](https://youtu.be/HTuG5UOMC74).

**Web version**, live **Examples**: [Smooth color](https://danilw.github.io/godot-utils-and-other/menu_2DGI/example_3/web/example_3.html) example. *Minimal* examples [1](https://danilw.github.io/godot-utils-and-other/menu_2DGI/example_1/web/example_1_minimal.html) [2](https://danilw.github.io/godot-utils-and-other/menu_2DGI/example_2/web/example_2_text.html).

Download *bin*:**Render** for [Windows](https://danilw.github.io/godot-utils-and-other/menu_2DGI/editor/menu_2D_GI_editor_win.zip) or [Linux](https://danilw.github.io/godot-utils-and-other/menu_2DGI/editor/menu_2D_GI_editor_linux.zip). **Examples** example [1](https://danilw.github.io/godot-utils-and-other/menu_2DGI/menu2DGI_examples_bin/menu2DGI_example_1.zip), [2](https://danilw.github.io/godot-utils-and-other/menu_2DGI/menu2DGI_examples_bin/menu2DGI_example_2.zip), [3](https://danilw.github.io/godot-utils-and-other/menu_2DGI/menu2DGI_examples_bin/menu2DGI_example_3.zip)
___

**e-ani** link to repo with source code https://github.com/danilw/e-ani playable version download from https://danilw.itch.io/e-ani
___

**a_rel_bw_game** *Warning: code very bad!* || Using lots of particles in Godot, in small demo-game.
To build this project you need build Godot with module **futari-addon** (google it(gitlab) ot use this [link](https://gitlab.com/polymorphcool/futari-addon) ) *Binary versions*: [win64](https://danilw.github.io/godot-utils-and-other/a_rel_bw_game/bw_game_win64.zip) [linux64](https://danilw.github.io/godot-utils-and-other/a_rel_bw_game/bw_game_lin64.zip) [live/web](https://danilw.github.io/godot-utils-and-other/a_rel_bw_game/web/afg.html)(work only in Firefox [reason](https://github.com/godotengine/godot/issues/28573)) (native builds have Mipmap On, web build off)
___

**Dynamic sky and reflection** two shaders for sky and reflection [video](https://youtu.be/IQ-yw19xBQ8), [live link](https://danilw.github.io/godot-utils-and-other/dyn_sky_refl/web/dsr.html) and [windows version](https://danilw.github.io/godot-utils-and-other/dyn_sky_refl/bin/win.zip)

**Environment bug**(on first load): Godot has bug with removing *Default Environment* after re-import Assets(project is work if launch, it does not work only in Godot editor), set Project->Projet Setting->Rendering->Environment->Default Environment select file *default_env.tres*
___

*new small:*

**2d_ex_physics** simply(100 lines of code) circle collision with gravity on GDScript, from my [old project](https://youtu.be/lVCIEaFEMO4), check [video](https://youtu.be/zOYQ6vljZSI) and [live_web](https://danilw.github.io/godot-utils-and-other/2d_ex_physics/web/2d_ex_physics.html)

2d explossion effects [video](https://youtu.be/h7C2-YMFn94) [src1](https://danilw.github.io/godot-utils-and-other/2d_explossions/explossion_no_bb.zip) [src2](https://danilw.github.io/godot-utils-and-other/2d_explossions/explossion_with_backbuffer_ex.zip) [live1](https://danilw.github.io/godot-utils-and-other/2d_explossions/web/no_fb_v0/explossion_with_backbuffer_ex.html) [live2](https://danilw.github.io/godot-utils-and-other/2d_explossions/web/feedback_v1/explossion_with_backbuffer_ex.html)
___

*old:*

**Godot_shadertoy** very simple "Shadertoy logic to Godot" [video](https://youtu.be/v48O7Nk_n4g), [source repo](https://github.com/danilw/GLSL-howto/tree/master/Godot_shadertoy)

**Cubemap to panorama** convertor [live link](https://danilw.github.io/GLSL-howto/cubemap_to_panorama_js/cubemap_to_panorama.html) 

**Godot-particles-collision** *unfinished* particle collision shader for Godot [source repo](https://github.com/danilw/Godot-particles-collision)

### Contact: [**Join discord server**](https://discord.gg/JKyqWgt)



### Graphic

**Menu_2DGI** video(click)

[![Menu_2DGI](https://danilw.github.io/godot-utils-and-other/menu_2DGI/2dgi_yt.jpg)](https://youtu.be/HTuG5UOMC74)

**e-ani** video 

[![e-ani](https://danilw.github.io/godot-utils-and-other/yt_e-ani.png)](https://youtu.be/0jKyTBFrpjU)


**a_rel_bw_game** video

[![a_rel_bw_game](https://danilw.github.io/godot-utils-and-other/a_rel_bw_game/bw_game_yt.jpg)](https://youtu.be/jTmppCifnYE)

**Dynamic sky and reflection**

![dyn](https://danilw.github.io/godot-utils-and-other/dyn_sky_refl/dsr.jpg)
