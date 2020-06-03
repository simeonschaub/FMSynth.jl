using SampledSignals

#####
##### `SynthesizerSource`
#####

struct SynthesizerSource{T<:AbstractSynthComponent} <: SampleSource
    output::T
end

function SampledSignals.unsafe_read!(source::SynthesizerSource, buf::Array, frameoffset, framecount)
    for i in (1:framecount) .+ frameoffset
        buf[i] = next!(source.output)
    end
    return framecount
end

SampledSignals.samplerate(::SynthesizerSource) = SAMPLE_RATE[]
SampledSignals.nchannels(::SynthesizerSource) = 1
SampledSignals.eltype(::SynthesizerSource{T}) where {T} = output_type(T)
