module FMSynth

using Base: promote_op

export Oscillator,
       next!,
       setfrequency!,
       sine_wave,
       square_wave,
       saw_wave,
       triangle_wave,
       Mixer,
       Volume,
       FrequencyModulator,
       SynthesizerSource,
       PitchController

#####
##### `SAMPLE_RATE`
#####

const SAMPLE_RATE = Ref{Int}(44_100)

set_sample_rate!(sr::Int) = SAMPLE_RATE[] = sr

#####
##### `AbstractSynthComponent`
#####

abstract type AbstractSynthComponent end

function output_type end

output_type(::T) where {T<:AbstractSynthComponent} = output_type(T)


include("abstract_oscillator.jl")
include("abstract_synth_controller.jl")
include("components_util.jl")

include("sampled_signals.jl")

end
