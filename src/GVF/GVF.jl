import Base.get

abstract type AbstractParameterFunction end

function get(apf::AbstractParameterFunction, state_t, action_t, state_tp1, action_tp1, preds_tilde) end

function call(apf::AbstractParameterFunction, state_t, action_t, state_tp1, action_tp1, preds_tilde)
    get(apf::AbstractParameterFunction, state_t, action_t, state_tp1, action_tp1, preds_tilde)
end

# This is a potential direction for letting people add more functionality if need be...
# function get(apf::AbstractParameterFunction, args...; kwargs...) end
# call(apf::AbstractParameterFunction, args...; kwargs...) = get(apf, args; kwargs)

include("Discounts.jl")
include("Cumulants.jl")
include("Policies.jl")

abstract type AbstractGVF end

function get(gvf::AbstractGVF, state_t, action_t, state_tp1, action_tp1, preds_tp1) end

get(gvf::AbstractGVF, state_t, action_t, state_tp1, preds_tp1) =
    get(gvf::AbstractGVF, state_t, action_t, state_tp1, nothing, preds_tp1)

get(gvf::AbstractGVF, state_t, action_t, state_tp1) =
    get(gvf::AbstractGVF, state_t, action_t, state_tp1, nothing, nothing)

function cumulant(gvf::AbstractGVF) end
function discount(gvf::AbstractGVF) end
function policy(gvf::AbstractGVF) end

struct GVF{C<:AbstractCumulant, D<:AbstractDiscount, P<:AbstractPolicy} <: AbstractGVF
    cumulant::C
    discount::D
    policy::P
end

cumulant(gvf::GVF) = gvf.cumulant
discount(gvf::GVF) = gvf.discount
policy(gvf::GVF) = gvf.policy

function get(gvf::GVF, state_t, action_t, state_tp1, action_tp1, preds_tp1)
    c = get(gvf.cumulant, state_t, action_t, state_tp1, action_tp1, preds_tp1)
    γ = get(gvf.discount, state_t, action_t, state_tp1, action_tp1, preds_tp1)
    π_prob = get(gvf.policy, state_t, action_t, state_tp1, action_tp1, preds_tp1)
    return c, γ, π_prob
end



