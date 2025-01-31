# Lhalf pseudo-norm (times a constant)

export RootNormLhalf

@doc raw"""
    RootNormLhalf(λ=1)

Returns the ``\ell_{1/2}^{1/2}`` pseudo-norm operator
```math
f(x) = λ \sum |x|^{1/2}
```
where ``\lambda > 0``.
"""
struct RootNormLhalf{R <: Real}
  lambda::R
  function RootNormLhalf{R}(lambda::R) where {R <: Real}
    if lambda < 0
      error("parameter λ must be nonnegative")
    else
      new(lambda)
    end
  end
end

RootNormLhalf(lambda::R = 1) where {R <: Real} = RootNormLhalf{R}(lambda)

function (f::RootNormLhalf)(x::AbstractArray{T}) where {T <: Real}
  return f.lambda * T(sum(sqrt.(abs.(x))))
end

function prox!(
  y::AbstractArray{T},
  f::RootNormLhalf,
  x::AbstractArray{T},
  gamma::Real = 1,
) where {T <: Real}
  γλ = gamma * f.lambda
  ϕ(z) = acos(γλ / 4 * (abs(z) / 3)^(-3 / 2))
  ysum = zero(T)
  threshold = 54^(1 / 3) * ((2γλ)^(2 / 3)) / 4
  for i in eachindex(x)
    if abs(x[i]) <= threshold
      y[i] = 0
    else
      y[i] = 2 * sign(x[i]) / 3 * abs(x[i]) * (1 + cos(2 * π / 3 - 2 * ϕ(x[i]) / 3))
      ysum += sqrt(abs(y[i]))
    end
  end

  return f.lambda * ysum
end

fun_name(f::RootNormLhalf) = "L½^(½) pseudo-norm"
fun_dom(f::RootNormLhalf) = "AbstractArray{Real}, AbstractArray{Complex}"
fun_expr(f::RootNormLhalf{T}) where {T <: Real} = "x ↦ ½ λ ‖x‖_(½)^(½)"
fun_params(f::RootNormLhalf{T}) where {T <: Real} = "λ = $(f.lambda)"

function prox_naive(
  f::RootNormLhalf{R},
  x::AbstractArray{T},
  gamma::R = 1.0,
) where {R <: Real, T <: Real}
  γλ = gamma * f.lambda
  over = abs.(x) .> 3 * (2γλ)^(2 / 3) / 4
  y =
    (
      2 / 3 * sign.(x) .* abs.(x) .*
      (1 .+ cos.((2 / 3) * (π .- acos(γλ / 4 * (abs.(x) ./ 3) .^ (-3 / 2)))))
    ) .* over
  return y, f.lambda * R(sum(sqrt.(abs.(y))))
end
