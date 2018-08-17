module IE
using Hecke

import Base.==

mutable struct FactoredIdeal
  exp::Array{Int, 1}
  idl::NfAbsOrdIdl
  norm::Int
  pred::Int
  function FactoredIdeal(n::Int)
    r = new()
    r.exp = zeros(Int, n)
    r.norm = 1
    return r
  end
end

function ==(a::FactoredIdeal, b::FactoredIdeal) 
  return a.exp == b.exp
end

function Base.copy(a::FactoredIdeal)
  b = FactoredIdeal(length(a.exp))
  b.exp = copy(a.exp)
  b.norm = a.norm
  return b
end

mutable struct IdealEnum
  FB::Array{NfAbsOrdIdl, 1}
  cur::Array{FactoredIdeal, 1}
  lim::Array{Int, 1}
  mi::Int
  mi_idx::Array{Int, 1}

  function IdealEnum(FB::Array{<: NfAbsOrdIdl, 1})
    r = new()
    r.FB = FB
    r.cur = [FactoredIdeal(length(FB))]
    r.cur[1].idl = ideal(order(FB[1]), 1)
    r.lim = ones(Int, length(FB))
    r.mi = minimum(norm(x) for x = FB)
    r.mi_idx = find(x -> r.mi == norm(x), FB)
    return r
  end
end

function LinAlg.norm(I::FactoredIdeal)
  return I.norm
end
function Base.start(IE::IdealEnum)
  return 1
end

function expand!(IE::IdealEnum, i::Int)
  v = IE.lim[i]
  IE.lim[i] += 1
  N = []
  for ik = 1:length(IE.cur)
    k = IE.cur[ik]
    if k.exp[i] == 0
      kk = copy(k)
      kk.exp[i] = v
      kk.pred = ik
      kk.norm *= norm(IE.FB[i])^v
      push!(N, kk)
    end
  end
  i = 1
  j = 1
  while i <= length(IE.cur) && j <= length(N)
    if norm(IE.cur[i]) > norm(N[j])
      insert!(IE.cur, i, N[j])
      j += 1
    else
      i += 1
    end
  end
  while j <= length(N)
    push!(IE.cur, N[j])
    j += 1
  end
end

function Base.next(IE::IdealEnum, s::Int)
  if s == length(IE.cur) || norm(IE.cur[s+1]) > IE.mi
    id = copy(IE.mi_idx)
    for j = id
      expand!(IE, j)
    end
    mi = minimum(norm(IE.FB[i])^IE.lim[i] for i=1:length(IE.FB))
    idx = find(i -> norm(IE.FB[i])^IE.lim[i] == mi, 1:length(IE.FB))
    IE.mi = mi
    IE.mi_idx = idx
  end
  return s+1
end

function Base.done(IE::IdealEnum, s::Int)
  return false
end

function Hecke.ideal(IE::IdealEnum, s::Int)
  if isdefined(IE.cur[s], :idl)
    return IE.cur[s].idl
  end
  I = ideal(IE, IE.cur[s].pred)
  i = findfirst(x -> IE.cur[s].exp[x] != IE.cur[IE.cur[s].pred].exp[x], 1:length(IE.FB))
  IE.cur[s].idl = I*IE.FB[i]^IE.cur[s].exp[i]
  return IE.cur[s].idl
end

end
