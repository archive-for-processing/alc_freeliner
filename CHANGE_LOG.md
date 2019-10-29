### Version 0.4.8
* Added output mapping layer
* Geometry names can be used in commands ie `tr A some_shape`
* Added workingDirectory option in `freeliner_sketch.pde` you can point it to a directory with freeliner files.
* experimantal DualInputShaderLayer

### Version 0.4.7
* Added macros in the `/userdata/macros` for keys `ctrl+(0-9)`
* Added template teams, you can `tp save AB fun_effect` and it will save `AB` and all their respective groups. You can then load them into any pair with `tp load fun_effect CD`.

### Version 0.4.6 ###
* `/userdata/startup` add commands, each line is executed.
* Shader sliders in webgui.
* More stuff I forgot about.

### Version 0.4.5 ###
 * `/userdata` paths have changed, seperate folders for shaders geometries templates...

### Version 0.4.4 ###
 * Syphon and Spout are now implmented as layers. Check `README.md` for how to enable them.
 * "tp color hex" is now "tp stroke hex" "tp fill hex"

### Version 0.4.3 ###
 * Many changes, mostly around layering system and LED/DMX stuff.
 * Use the webGUI to manage layers.
 * Layer commands go something like `layer layerName enable 1` or `layer layerName load file.type`.
 * All shaders and images are and should be stored in `data/userdata` with no sub directories.
 * Uniform floats for shaders can be set with `layer shaderLayerName uniforms i 0.75`, where i is an index 0-7.
 * Speed adjustement with `seq speed 0.5` works with negative value!

### Version 0.4.1 ###
 * `m` is now for miscValue, `d` is for breakLine.
 * Deprecated brushMode, use `a` for animationMode to switch brushes.
 * Parameter tweaking has limits now.
 * `p` key is for layers, templates are by default on layer 1.
 * Rendering pipeline, light or deluxe is set in `Config.pde`.
 * New OSC syntax for commands. Check the README.md for info.
 * New websocket for webgui, install the processing_websockets library.
 * Autodocumentation system

### Version 0.4 ###
 * New command system.
 * Masking, hitting `ctrl-m` will make a mask. Any pixels with some green will be transparent.
 * Fragment shaders. `p` to enable disable set shader.

### Version 0.3.2 ###
 * Substantial changes, testing encouraged.
 * Effects of animationMode are transfered into the more versatile enterpolator, use the `e` key to change it.
 * Painters have a array of Interpolators and a getPosition(Segment) to use them.
 * Saving geometry and templates (finaly) is now with ctrl-s and loading with ctrl-o

### Version 0.3.1 ###
* You can copy and paste templates now, ctrl-c still works the same, but you can paste with ctrl-v if you have a template selected.
* Group add template changed, check README. (works with ctrl-b)
-------
* Enabler `e` mode 0 now really disables, even disable triggering. Replaced with 2, which prevents looping but allows triggering.
* `>` for sequencer, check README.md
* Added `FreelinerConfig.pde` check it out for a bunch of settings.
