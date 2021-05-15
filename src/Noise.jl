"""
    WhiteNoise(amplitude)
Defining WhiteNoise struct, values generated by it are all between -amplitude and +amplitude

# Example
```julia.repl
julia> w = WhiteNoise(1)
WhiteNoise(1)
julia> w(1)
```
"""
struct WhiteNoise

    amplitude::Number

end


"""
    GaussianNoise(amplitude)
Defining GaussianNoise struct, values are generated by normal distribution function randn()

# Example
```julia.repl
julia> w = WhiteNoise(1)
WhiteNoise(1)
julia> w(1)
```
"""
struct GaussianNoise

    amplitude::Number

end

struct BrownianNoise

    amplitude::Number

end

struct PinkNoise

    amplitude::Number
    beta::Number

end

function (wn::WhiteNoise)(t, fr)

    time = 0:inv(fr):t
    amps = zeros(length(time)) + wn

    return Wave(
        amps,
        0:inv(fr):t,
        fr,
        Signal(fr, wn.amplitude, x->0, 0, Dict("name" => "Noise")),
    )

end

function (gn::GaussianNoise)(t, fr)

    time = 0:inv(fr):t
    amps = zeros(length(time)) + gn

    return Wave(
        amps,
        0:inv(fr):t,
        fr,
        Signal(fr, gn.amplitude, x -> 0, 0, Dict("name" => "Noise")),
    )

end

function (pn::PinkNoise)(t, fr)

    time = 0:inv(fr):t
    amps = zeros(length(time)) + pn


    return Wave(
        amps,
        0:inv(fr):t,
        fr,
        Signal(fr, pn.amplitude, x->0,0, Dict("name" => "Noise")),
    )

end

# TO Do check type interference!
function +(v, wn::WhiteNoise)

    a =  wn.amplitude

    r = rand(-a:eps(Float64):a,size(v)) 

    return v + r

end

function +(v, gn::GaussianNoise)

    a =  gn.amplitude

    r = randn(size(v)) .* a

    return v + r

end

function +(v, pn::PinkNoise)

    s = length(v)

    wn = WhiteNoise(pn.amplitude)(1 - inv(s),s) 
    swn = wn |> Spectrum

    denominator = swn.fs .^(pn.beta/2)

    denominator[1] = 1
    
    pink_amps = swn.amps ./ denominator

    spec = Spectrum(pink_amps,inv(s),abs2.(pink_amps), Signal(100,1),wn.framerate ,length(wn.amps)) 

    w = Wave(spec)

    amps = w.amps

    amps = amps .- mean(amps)

    amps = amps .* (pn.amplitude / maximum(abs,amps))

    return v + amps

end

function +(v, bn::BrownianNoise)

    a = bn.amplitude

    r = rand(-a:eps(Float64):a,size(v)) 

    cumr = cumsum(r) 

    cumr = cumr .- mean(cumr) # make signal zero mean

    cumr = cumr * bn.amplitude/maximum(abs,cumr) # normalize
    

    return v + cumr

end


function (bn::BrownianNoise)(t, fr)

    time = 0:inv(fr):t
    n = length(time)
    v = zeros(n)
    
    brownian_amps = v + bn


    return Wave(
        brownian_amps,
        time,
        fr,
        Signal(fr, bn.amplitude,x -> 0, 0, Dict("name" => "Noise")),
    )

end

function +(s::Signal, wn::WhiteNoise)

    s_new = deepcopy(s)

    s_new.info["WhiteNoise"] = wn.amplitude

    if haskey(s_new.info, "name")

        s_new.info["name"] *= " with White Noise"

    end

    return s_new

end

function +(s::Signal, gn::GaussianNoise)

    s_new = deepcopy(s)

    s_new.info["GaussianNoise"] = gn.amplitude

    if haskey(s_new.info, "name")

        s_new.info["name"] *= " with Gaussian Noise"

    end

    return s_new

end

function +(s::Signal, bn::BrownianNoise)

    s_new = deepcopy(s)

    s_new.info["BrownianNoise"] = bn.amplitude

    if haskey(s_new.info, "name")

        s_new.info["name"] *= " with Brownian Noise"

    end

    return s_new

end

function +(s::Signal, pn::PinkNoise)

    s_new = deepcopy(s)

    s_new.info["PinkNoise"] = (pn.amplitude, pn.beta)

    if haskey(s_new.info, "name")

        s_new.info["name"] *= " with Pink Noise"

    end

    return s_new

end