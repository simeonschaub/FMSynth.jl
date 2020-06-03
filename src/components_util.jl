#####
##### `Mixer`
#####

struct Mixer{N,T<:NTuple{N,AbstractSynthComponent}} <: AbstractSynthComponent
    inputs::T
end

Mixer(inputs::AbstractSynthComponent...) = Mixer(inputs)

next!(m::Mixer) = sum(next!, m.inputs)

Base.:+(inputs::AbstractSynthComponent...) = Mixer(inputs...)
output_type(::Type{Mixer{N,T}}) where {N,T} = promote_op(+, output_type.(T.parameters)...)

#####
##### `Volume`
#####

struct Volume{S<:AbstractFloat,T<:AbstractSynthComponent} <: AbstractSynthComponent
    volume::S
    input::T
end

next!(v::Volume) = v.volume * next!(v.input)
output_type(::Type{Volume{S,T}}) where {S,T} = promote_op(*, S, output_type(T))

Base.:*(volume::Real, input::AbstractSynthComponent) = Volume(float(volume), input)
