struct Signal
    freq::Union{Vector,Number}
    amp::Union{Vector,Number}
    func::Union{Vector,Function}
    offset::Union{Vector,Number}
    info::Dict
    function Signal(fr, a, f = sin, o = 0, info = Dict(); name::String = "")
        if !isempty(name)
            info["name"] = name
        end
        new(fr, a, f, o, info)
    end
end

struct Wave
    amps::Vector
    time::Any
    framerate::Number
    signal::Signal
    #isnoise::Bool
end

struct Spectrum
    amps::Any
    fs::Any
    power::Any
    signal::Signal
    framerate::Number
    #start # start time of the signal
    d::Any # length of the converted wave
end

