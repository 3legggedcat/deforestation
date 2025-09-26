#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/core/gdvirtual.gen.inc>

using namespace godot;

class GDExample : public Sprite2D {
    GDCLASS(GDExample, Sprite2D)

private:
    double time_passed;
    double amplitude;
    double rotation_speed;
    double pulse_frequency;
    double bounce_height;
    Vector2 original_position;
    bool is_bouncing;
    bool is_rotating;
    double bounce_timer;

protected:
    static void _bind_methods();

public:
    GDExample();
    ~GDExample();

    void _ready() override;
    void _process(double delta) override;
    
    // Feature 1
    void set_bounce_height(const double p_bounce_height);
    double get_bounce_height() const;
    void start_bouncing();
    void stop_bouncing();
    
    // Feature 2
    void set_rotation_speed(const double p_rotation_speed);
    double get_rotation_speed() const;
    void start_rotating();
    void stop_rotating();
    

    void set_amplitude(const double p_amplitude);
    double get_amplitude() const;
    

    void set_pulse_frequency(const double p_pulse_frequency);
    double get_pulse_frequency() const;
    
    // requirement 4
    void on_external_trigger();
};

#endif