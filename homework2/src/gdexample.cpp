#include "gdexample.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void GDExample::_bind_methods() {

    ClassDB::bind_method(D_METHOD("get_amplitude"), &GDExample::get_amplitude);
    ClassDB::bind_method(D_METHOD("set_amplitude", "p_amplitude"), &GDExample::set_amplitude);
    ClassDB::bind_method(D_METHOD("get_pulse_frequency"), &GDExample::get_pulse_frequency);
    ClassDB::bind_method(D_METHOD("set_pulse_frequency", "p_pulse_frequency"), &GDExample::set_pulse_frequency);
    

    ClassDB::bind_method(D_METHOD("get_bounce_height"), &GDExample::get_bounce_height);
    ClassDB::bind_method(D_METHOD("set_bounce_height", "p_bounce_height"), &GDExample::set_bounce_height);
    ClassDB::bind_method(D_METHOD("start_bouncing"), &GDExample::start_bouncing);
    ClassDB::bind_method(D_METHOD("stop_bouncing"), &GDExample::stop_bouncing);
    

    ClassDB::bind_method(D_METHOD("get_rotation_speed"), &GDExample::get_rotation_speed);
    ClassDB::bind_method(D_METHOD("set_rotation_speed", "p_rotation_speed"), &GDExample::set_rotation_speed);
    ClassDB::bind_method(D_METHOD("start_rotating"), &GDExample::start_rotating);
    ClassDB::bind_method(D_METHOD("stop_rotating"), &GDExample::stop_rotating);
    

    ClassDB::bind_method(D_METHOD("on_external_trigger"), &GDExample::on_external_trigger);


    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "amplitude", PROPERTY_HINT_RANGE, "0.0,100.0"), "set_amplitude", "get_amplitude");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "pulse_frequency", PROPERTY_HINT_RANGE, "0.1,10.0"), "set_pulse_frequency", "get_pulse_frequency");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "bounce_height", PROPERTY_HINT_RANGE, "0.0,200.0"), "set_bounce_height", "get_bounce_height");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "rotation_speed", PROPERTY_HINT_RANGE, "0.0,10.0"), "set_rotation_speed", "get_rotation_speed");


    ADD_SIGNAL(MethodInfo("animation_cycle_complete"));
    ADD_SIGNAL(MethodInfo("bounce_peak_reached", PropertyInfo(Variant::VECTOR2, "position")));
}

GDExample::GDExample() {
    time_passed = 0.0;
    amplitude = 10.0;
    rotation_speed = 1.0;
    pulse_frequency = 2.0;
    bounce_height = 50.0;
    original_position = Vector2(0, 0);
    is_bouncing = false;
    is_rotating = false;
    bounce_timer = 0.0;
}

GDExample::~GDExample() {
}

void GDExample::_ready() {

    Vector2 start_pos = Vector2(400, 300); 
    set_position(start_pos);
    original_position = start_pos;
}

void GDExample::_process(double delta) {
    time_passed += delta;
    bounce_timer += delta;
    
    Vector2 new_position = original_position;
    

    new_position.x += amplitude * sin(time_passed * pulse_frequency);
    new_position.y += amplitude * cos(time_passed * pulse_frequency * 0.75);
    

    if (is_bouncing) {
        double bounce_offset = bounce_height * abs(sin(bounce_timer * 3.0));
        new_position.y -= bounce_offset;
        

        static bool was_at_peak = false;
        bool at_peak = abs(sin(bounce_timer * 3.0)) > 0.95;
        if (at_peak && !was_at_peak) {
            emit_signal("bounce_peak_reached", new_position);
        }
        was_at_peak = at_peak;
    }
    
    set_position(new_position);
    

    if (is_rotating) {
        set_rotation(get_rotation() + rotation_speed * delta);
    }
    

    static double last_cycle_time = 0.0;
    if (time_passed - last_cycle_time >= (2.0 * Math_PI / pulse_frequency)) {
        emit_signal("animation_cycle_complete");
        last_cycle_time = time_passed;
    }
}


void GDExample::set_bounce_height(const double p_bounce_height) {
    bounce_height = p_bounce_height;
}

double GDExample::get_bounce_height() const {
    return bounce_height;
}

void GDExample::start_bouncing() {
    is_bouncing = true;
    bounce_timer = 0.0;
}

void GDExample::stop_bouncing() {
    is_bouncing = false;
}


void GDExample::set_rotation_speed(const double p_rotation_speed) {
    rotation_speed = p_rotation_speed;
}

double GDExample::get_rotation_speed() const {
    return rotation_speed;
}

void GDExample::start_rotating() {
    is_rotating = true;
}

void GDExample::stop_rotating() {
    is_rotating = false;
    set_rotation(0.0);
}


void GDExample::set_amplitude(const double p_amplitude) {
    amplitude = p_amplitude;
}

double GDExample::get_amplitude() const {
    return amplitude;
}

void GDExample::set_pulse_frequency(const double p_pulse_frequency) {
    pulse_frequency = p_pulse_frequency;
}

double GDExample::get_pulse_frequency() const {
    return pulse_frequency;
}


void GDExample::on_external_trigger() {

    if (is_bouncing) {
        stop_bouncing();
        start_rotating();
    } else if (is_rotating) {
        stop_rotating();
        start_bouncing();
    } else {
        start_bouncing();
    }
    

    UtilityFunctions::print("GDExample received external trigger!");
}