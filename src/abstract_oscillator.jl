#####
##### `AbstractOscillator`
#####

abstract type AbstractOscillator <: AbstractSynthComponent end

function getfrequency end
function setfrequency! end

#####
##### `WaveForms`
#####

sine_wave(x) = sinpi(2x)
square_wave(x) = x < 0.5 ? 1.0 : -1.0
saw_wave(x) = 2x - 1
triangle_wave(x) = x < 0.5 ? 4x - 1 : 3 - 4x

#####
##### `Oscillator`
#####

mutable struct Oscillator{O<:Real,F,S<:AbstractFloat,T<:AbstractFloat} <: AbstractOscillator
    f::F
    frequency::S
    position::T
end

function Oscillator{O}(f, frequency::Real, position::Real = 0.0) where {O<:Real}
    frequency = float(frequency)
    position = float(position)
    return Oscillator{O,typeof(f),typeof(frequency),typeof(position)}(f, frequency, position)
end

function Oscillator(f, frequency::Real, position::Real = 0.0)
    frequency = float(frequency)
    position = float(position)
    return Oscillator{promote_op(f,typeof(position))}(f, frequency, position)
end

function next!(o::Oscillator{O})::O where {O}
    res = o.f(o.position)
    step = o.frequency / SAMPLE_RATE[]
    o.position = mod(o.position + step, true)
    return res
end

output_type(::Type{<:Oscillator{O}}) where {O} = O

getfrequency(o::Oscillator) = o.frequency
function setfrequency!(o::Oscillator{<:Any,<:Any,S}, frequency::Real) where {S}
    o.frequency = S(frequency)
end

#####
##### `FrequencyModulator`
#####

struct FrequencyModulator{
    O<:Real,
    S<:AbstractSynthComponent,
    T<:AbstractSynthComponent,
    U<:AbstractFloat,
    V<:NTuple{<:Any,<:Pair{<:AbstractOscillator,<:Any}},
} <: AbstractOscillator
    modulator::S
    output::T
    base_frequency::Ref{U}
    to_modulate::V

    function FrequencyModulator(
        modulator::S,
        output::T,
        base_frequency::Real,
        to_modulate::Pair{<:AbstractOscillator,<:Any}...,
    ) where {S<:AbstractSynthComponent,T<:AbstractSynthComponent}

        O = output_type(output)
        base_frequency = float(base_frequency)
        U = typeof(base_frequency)
        V = typeof(to_modulate)

        return new{O,S,T,U,V}(modulator, output, Ref(base_frequency), to_modulate)
    end
end

function FrequencyModulator(
    modulator::AbstractSynthComponent,
    output::AbstractOscillator,
    base_frequency::Real,
    modulation_function::Function,
)
    return FrequencyModulator(
        modulator,
        output,
        base_frequency,
        output => modulation_function,
    )
end

function FrequencyModulator(
    modulator::AbstractSynthComponent,
    output::AbstractOscillator,
    base_frequency::Real,
    weight::AbstractFloat,
)
    return FrequencyModulator(
        modulator,
        output,
        base_frequency,
        (base_frequency, modulation) -> base_frequency + weight * modulation,
    )
end

function FrequencyModulator(
    modulator::AbstractSynthComponent,
    output::AbstractOscillator,
    weight::AbstractFloat,
)
    return FrequencyModulator(
        modulator,
        output,
        getfrequency(output),
        weight,
    )
end

function next!(fm::FrequencyModulator)
    modulation = next!(fm.modulator)
    base_frequency = fm.base_frequency[]
    for (oscillator, modulation_function) in fm.to_modulate
        setfrequency!(oscillator, modulation_function(base_frequency, modulation))
    end
    return next!(fm.output)
end

output_type(::Type{<:FrequencyModulator{O}}) where {O} = O

getfrequency(fm::FrequencyModulator) = fm.base_frequency[]
setfrequency!(fm::FrequencyModulator, frequency::Real) = fm.base_frequency[] = float(frequency)
