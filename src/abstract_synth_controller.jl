#####
##### `AbstractSynthController`
#####

abstract type AbstractSynthController end

#####
##### `PitchController`
#####

struct PitchController{
    S<:AbstractFloat,
    T<:NTuple{<:Any,Pair{<:AbstractOscillator,<:Any}},
} <: AbstractSynthController
    base_frequency::Ref{S}
    to_set::T

    function PitchController(
        base_frequency::Real,
        to_set::Pair{<:AbstractOscillator,<:Any}...,
    )
        base_frequency = float(base_frequency)
        _setfrequency!(to_set, base_frequency)
        S = typeof(base_frequency)
        T = typeof(to_set)
        return new{S,T}(Ref(base_frequency), to_set)
    end
end

function PitchController(
    base_frequency::Real,
    to_set::Pair{<:AbstractOscillator,<:Real}...,
)
    to_set = map(((osc, c),) -> (osc => Base.Fix1(*, c)), to_set)
    return PitchController(base_frequency, to_set...)
end

function _setfrequency!(
    to_set::NTuple{<:Any,Pair{<:AbstractOscillator,<:Any}},
    frequency::Real
)
    for (osc, f) in to_set
        setfrequency!(osc, f(frequency))
    end
end

getfrequency(p::PitchController) = p.base_frequency[]
function setfrequency!(p::PitchController, frequency::Real)
    _setfrequency!(p.to_set, frequency)
    p.base_frequency[] = float(frequency)
end

@enum KeyState::Bool PRESSED=true RELEASED=false

struct Envelope{F,S<:Real,T<:AbstractFloat}
end

