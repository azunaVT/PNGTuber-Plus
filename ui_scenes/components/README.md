# Slider Components Documentation

This document explains the new slider component system that replaces the individual sliders in the sprite viewer with reusable, consistent components.

## Components Overview

### 1. LabeledSlider (Base Component)
**File:** `ui_scenes/components/LabeledSlider.tscn`
**Script:** `ui_scenes/components/LabeledSlider.gd`

The base slider component that combines a label and slider into one reusable unit.

**Key Features:**
- Automatic label updates with current value
- Configurable value formatting
- Optional value suffix (%, Hz, etc.)
- Consistent styling
- Signal emission on value changes

**Properties:**
- `label_text`: Base text for the label
- `min_value`, `max_value`, `step`: Slider configuration
- `value`: Current value
- `show_value_in_label`: Whether to display value in label
- `value_format`: Format string for value display (e.g., "%.1f")
- `value_suffix`: Suffix to add after value (e.g., "%", "Hz")
- `editable`: Whether the slider can be modified

### 2. WobbleSlider (Specialized Component)
**File:** `ui_scenes/components/WobbleSlider.tscn`
**Script:** `ui_scenes/components/WobbleSlider.gd`

Extends LabeledSlider specifically for wobble parameters.

**Key Features:**
- Automatic synchronization with sprite wobble parameters
- Visual feedback for sync group status
- Integrated with wobble sync system
- Parameter-specific configuration

**Properties:**
- `parameter_name`: The wobble parameter this controls ("xFrq", "xAmp", etc.)
- All LabeledSlider properties

### 3. ParameterSlider (Generic Component)
**File:** `ui_scenes/components/ParameterSlider.tscn`
**Script:** `ui_scenes/components/ParameterSlider.gd`

Extends LabeledSlider for general sprite parameters.

**Key Features:**
- Generic parameter binding to sprite properties
- Automatic update method calling for specific parameters
- Property path configuration

**Properties:**
- `sprite_property`: The sprite property to bind to
- `parameter_name`: Display name for the parameter
- All LabeledSlider properties

### 4. WobbleControlPanel (Composite Component)
**File:** `ui_scenes/components/WobbleControlPanel.tscn`
**Script:** `ui_scenes/components/WobbleControlPanel.gd`

A complete panel containing all wobble sliders.

**Key Features:**
- Pre-configured wobble sliders
- Centralized sprite management
- Integrated sync feedback
- Easy integration with existing wobble sync controls

### 5. SliderManager (Management System)
**Script:** `ui_scenes/components/SliderManager.gd`

Manages collections of slider components.

**Key Features:**
- Centralized slider updates
- Consistent styling application
- Bulk operations on sliders
- Integration with sprite viewer

## Usage Examples

### Basic LabeledSlider
```gdscript
# In your scene
@onready var my_slider: LabeledSlider = $LabeledSlider

func _ready():
    my_slider.label_text = "Volume"
    my_slider.min_value = 0.0
    my_slider.max_value = 100.0
    my_slider.value_suffix = "%"
    my_slider.value_changed.connect(_on_volume_changed)

func _on_volume_changed(value: float):
    print("Volume changed to: ", value)
```

### WobbleSlider Configuration
```gdscript
# In scene setup
@onready var x_freq_slider: WobbleSlider = $XFrequencySlider

func _ready():
    x_freq_slider.label_text = "X Frequency"
    x_freq_slider.parameter_name = "xFrq"
    x_freq_slider.min_value = 0.0
    x_freq_slider.max_value = 10.0
    x_freq_slider.step = 0.1
    x_freq_slider.value_format = "%.1f"
    x_freq_slider.value_suffix = " Hz"

func set_sprite(sprite):
    x_freq_slider.set_target_sprite(sprite)
```

### Using WobbleControlPanel
```gdscript
# Replace individual wobble sliders with the panel
@onready var wobble_panel: WobbleControlPanel = $WobbleControlPanel

func setImage():
    if Global.heldSprite:
        wobble_panel.set_target_sprite(Global.heldSprite)
        wobble_panel.update_from_sprite()
```

### SliderManager Integration
```gdscript
# In sprite viewer
var slider_manager: SliderManager

func _ready():
    slider_manager = SliderManager.new(self)
    _setup_sliders()

func _setup_sliders():
    # Add sliders to manager
    slider_manager.add_slider($DragSlider)
    slider_manager.add_slider($OpacitySlider)
    # etc.

func setImage():
    if slider_manager:
        slider_manager.update_all_sliders(Global.heldSprite)
```

## Migration from Legacy Sliders

### Step 1: Replace Scene Nodes
Replace individual HSlider + Label combinations with LabeledSlider instances:

**Before:**
```
- Node2D
  - Label (for "x frequency: 5.0")
  - HSlider (for value input)
```

**After:**
```
- Node2D
  - LabeledSlider (handles both label and slider)
```

### Step 2: Update Script References
**Before:**
```gdscript
$WobbleControl/xFrqLabel.text = "x frequency: " + str(value)
$WobbleControl/xFrq.value = value
```

**After:**
```gdscript
$WobbleControl/XFrequencySlider.set_value(value)
# Label updates automatically
```

### Step 3: Connect Signals
**Before:**
```gdscript
func _on_x_frq_value_changed(value):
    Global.heldSprite.xFrq = value
```

**After:**
```gdscript
# Handled automatically by WobbleSlider component
# Or connect to the component's value_changed signal
```

## Benefits

1. **Consistency**: All sliders look and behave the same way
2. **Maintainability**: Changes to slider behavior only need to be made in one place
3. **Reusability**: Components can be used across different parts of the application
4. **Type Safety**: Proper class inheritance with specific functionality
5. **Reduced Code**: Less repetitive slider setup code
6. **Better Organization**: Clear separation of concerns

## Integration Notes

- The new system is designed to be backwards compatible
- Legacy slider code is maintained as fallback
- Components can be gradually adopted
- SliderManager provides centralized control
- Easy to extend for new parameter types

## Custom Styling

To apply consistent styling across all sliders, modify the base LabeledSlider component or use the SliderManager's styling methods:

```gdscript
func apply_custom_theme():
    for slider in slider_manager.sliders:
        slider.slider.add_theme_stylebox_override("slider", custom_style)
```
