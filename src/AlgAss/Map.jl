mutable struct AbsAlgAssMor{R, S, T} <: Map{R, S, HeckeMap, AbsAlgAssMor}
  header::MapHeader{R, S}

  mat::T
  imat::T
  c_t::T
  d_t::T

  function AbsAlgAssMor{R, S, T}(A::R, B::S) where {R, S, T}
    z = new{R, S, T}()
    z.header = MapHeader(A, B)
    return z
  end

  function AbsAlgAssMor{R, S, T}(A::R, B::S, M::T) where {R, S, T}
    z = new{R, S, T}()
    z.c_t = similar(M, 1, dim(A))
    z.d_t = similar(M, 1, dim(B))
    z.mat = M

    function image(a)
      for i in 1:dim(A)
        z.c_t[1, i] = a.coeffs[i]
      end
      s = Vector{elem_type(base_ring(B))}(undef, dim(B))
      #mul!(z.d_t, z.c_t, M) # there is no mul! for Generic.Mat
      z.d_t = z.c_t*M
      for i in 1:dim(B)
        s[i] = z.d_t[1, i]
      end

      return B(s)
    end

    z.header = MapHeader(A, B, image)
    return z
  end

  function AbsAlgAssMor{R, S, T}(A::R, B::S, M::T, N::T) where {R, S, T}
    z = new{R, S, T}()
    z.c_t = similar(M, 1, dim(A))
    z.d_t = similar(M, 1, dim(B))

    z.mat = M
    z.imat = N

    function image(a)
      for i in 1:dim(A)
        z.c_t[1, i] = a.coeffs[i]
      end
      s = Vector{elem_type(base_ring(B))}(undef, dim(B))
      #mul!(z.d_t, z.c_t, M) # there is no mul! for Generic.Mat
      z.d_t = z.c_t * M
      for i in 1:dim(B)
        s[i] = z.d_t[1, i]
      end

      return B(s)
    end

    function preimage(a)
      for i in 1:dim(B)
        z.d_t[1, i] = a.coeffs[i]
      end
      s = Vector{elem_type(base_ring(A))}(undef, dim(A))
      z.c_t = z.d_t * N
      for i in 1:dim(A)
        s[i] = z.c_t[1, i]
      end
      return A(s)
    end

    z.header = MapHeader(A, B, image, preimage)
    return z
  end
end

#mutable struct AlgAssMor{R, S, T} <: Map{AlgAss{R}, AlgAss{S}, HeckeMap, AlgAssMor}
#  header::MapHeader{AlgAss{R}, AlgAss{S}}
#
#  mat::T
#  imat::T
#  c_t::T
#  d_t::T
#
#  function AlgAssMor(A::AlgAss{R}, B::AlgAss{S}, M::T) where {R, S, T}
#    z = new{R, S, T}()
#    z.c_t = similar(M, 1, dim(A))
#    z.d_t = similar(M, 1, dim(B))
#    z.mat = M
#
#    function image(a::AlgAssElem)
#      for i in 1:dim(A)
#        z.c_t[1, i] = a.coeffs[i]
#      end
#      s = Vector{S}(undef, dim(B))
#      #mul!(z.d_t, z.c_t, M) # there is no mul! for Generic.Mat
#      z.d_t = z.c_t*M
#      for i in 1:dim(B)
#        s[i] = z.d_t[1, i]
#      end
#
#      return AlgAssElem{S}(B, s)
#    end
#
#    z.header = MapHeader(A, B, image)
#    return z
#  end
#
#  function AlgAssMor(A::AlgAss{R}, B::AlgAss{S}, M::T, N::T) where {R, S, T}
#    z = new{R, S, T}()
#    z.c_t = similar(M, 1, dim(A))
#    z.d_t = similar(M, 1, dim(B))
#
#    z.mat = M
#    z.imat = N
#
#    function image(a::AlgAssElem)
#      for i in 1:dim(A)
#        z.c_t[1, i] = a.coeffs[i]
#      end
#      s = Vector{S}(undef, dim(B))
#      #mul!(z.d_t, z.c_t, M) # there is no mul! for Generic.Mat
#      z.d_t = z.c_t * M
#      for i in 1:dim(B)
#        s[i] = z.d_t[1, i]
#      end
#
#      return AlgAssElem{S}(B, s)
#    end
#
#    function preimage(a::AlgAssElem)
#      for i in 1:dim(B)
#        z.d_t[1, i] = a.coeffs[i]
#      end
#      s = Vector{R}(undef, dim(A))
#      z.c_t = z.d_t * N
#      for i in 1:dim(A)
#        s[i] = z.c_t[1, i]
#      end
#      return AlgAssElem{R}(A, s)
#    end
#
#    z.header = MapHeader(A, B, image, preimage)
#    return z
#  end
#end

function compose_and_squash(f::AbsAlgAssMor{R, U, T}, g::AbsAlgAssMor{S, R, T}) where {R, T, S, U}
  if isdefined(f, :imat) && isdefined(g, :imat)
    return hom(domain(g), codomain(f), g.mat * f.mat, f.imat * g.imat)
  else
    return hom(domain(g), codomain(f), g.mat * f.mat)
  end
end

function hom(A::R, B::S, M::T) where {R <: AbsAlgAss, S <: AbsAlgAss, T}
  return AbsAlgAssMor{R, S, T}(A, B, M)
end

function hom(A::R, B::S, M::T, N::T) where {R <: AbsAlgAss, S <: AbsAlgAss, T}
  return AbsAlgAssMor{R, S, T}(A, B, M, N)
end

#function hom(A::AlgAss{R}, B::AlgAss{S}, M::T) where {R <: AlgAss, S <: AlgAss, T}
#  return AlgAssMor{R, S, T}(A, B, M)
#end
#
#function hom(A::AlgAss{R}, B::AlgAss{S}, M::T, N::T) where {R <: AlgAss, S <: AlgAss, T}
#  return AlgAssMor{R, S, T}(A, B, M, N)
#end

function haspreimage(m::AbsAlgAssMor, a::AbsAlgAssElem)
  if isdefined(m, :imat)
    return true, preimage(m, a)
  end

  A = parent(a)
  t = matrix(base_ring(A), 1, dim(A), coeffs(a))
  b, p = can_solve(m.mat, t, side = :left)
  if b
    return true, domain(m)([ p[1, i] for i = 1:nrows(m.mat) ])
  else
    return false, zero(domain(m))
  end
end

################################################################################
#
#  Morphisms between algebras and number fields
#
################################################################################

# S is the type of the algebra, T the element type of the algebra
mutable struct AbsAlgAssToNfAbsMor{S, T} <: Map{S, AnticNumberField, HeckeMap, AbsAlgAssToNfAbsMor}
  header::MapHeader{S, AnticNumberField}
  mat::fmpq_mat
  imat::fmpq_mat
  t::fmpq_mat # dummy vector used in image and preimage
  tt::fmpq_mat # another dummy vector

  function AbsAlgAssToNfAbsMor{S, T}(A::S, K::AnticNumberField, M::fmpq_mat, N::fmpq_mat) where { S <: AbsAlgAss{fmpq}, T <: AbsAlgAssElem{fmpq} }

    z = new{S, T}()
    z.mat = M
    z.imat = N
    z.t = zero_matrix(FlintQQ, 1, dim(A))
    z.tt = zero_matrix(FlintQQ, 1, degree(K))

    function _image(x::T)
      for i = 1:dim(A)
        z.t[1, i] = x.coeffs[i]
      end
      s = z.t*M
      return K(parent(K.pol)([ s[1, i] for i = 1:degree(K) ]))
    end

    function _preimage(x::nf_elem)
      for i = 1:degree(K)
        z.tt[1, i] = coeff(x, i - 1)
      end
      s = z.tt*N
      return A([ s[1, i] for i = 1:dim(A) ])
    end

    z.header = MapHeader{S, AnticNumberField}(A, K, _image, _preimage)
    return z
  end
end

function AbsAlgAssToNfAbsMor(A::AbsAlgAss{fmpq}, K::AnticNumberField, M::fmpq_mat, N::fmpq_mat)
  return AbsAlgAssToNfAbsMor{typeof(A), elem_type(A)}(A, K, M, N)
end

################################################################################
#
#  Morphisms between algebras and finite fields
#
################################################################################

# Morphism between an algebra A and a finite field Fq.
# base_ring(A) can be a GaloisField, a Generic.ResField{fmpz} or a Fq(Nmod)FiniteField, Fq can be a
# Fq(Nmod)FiniteField.
# MatType is the type of matrices over base_ring(A), PolyRingType the type of a
# polynomial ring over base_ring(A)
mutable struct AbsAlgAssToFqMor{S, T, MatType, PolyRingType} <: Map{S, T, HeckeMap, AbsAlgAssToFqMor}
  header::MapHeader{S, T}
  mat::MatType
  imat::MatType
  t::MatType # dummy vector used in image and preimage
  tt::MatType # another dummy vector
  R::PolyRingType
  RtoFq::FqPolyRingToFqMor # only used if S == AbsAlgAss{fq} or S == AbsAlgAss{fq_nmod}

  function AbsAlgAssToFqMor{S, T, MatType, PolyRingType}(A::S, Fq::T, M::MatType, N::MatType, R::PolyRingType, RtoFq::FqPolyRingToFqMor...) where {
           S <: AbsAlgAss{S1} where { S1 <: Union{ gfp_elem, Generic.ResF{fmpz}, fq, fq_nmod} },
           T <: Union{ FqNmodFiniteField, FqFiniteField },
           MatType <: Union{ gfp_mat, Generic.Mat{Generic.ResF{fmpz}}, fq_nmod_mat, fq_mat },
           PolyRingType <: Union{ GFPPolyRing, GFPFmpzPolyRing, FqNmodPolyRing, FqPolyRing }
    }

    z = new{S, T, MatType, PolyRingType}()
    z.mat = M
    z.imat = N
    z.t = zero_matrix(base_ring(A), 1, dim(A))
    z.tt = zero_matrix(base_ring(A), 1, dim(A))
    z.R = R

    isfq = ( base_ring(A) isa FqNmodFiniteField || base_ring(A) isa FqFiniteField )
    if isfq
      z.RtoFq = RtoFq[1]
    end

    function _image(x::AlgAssElem)
      @assert typeof(x) == elem_type(A)
      for i = 1:dim(A)
        z.t[1, i] = x.coeffs[i]
      end
      s = z.t*M
      sR = z.R([ s[1, i] for i = 1:dim(A) ])
      if isfq
        return Fq(z.RtoFq(sR))
      else
        return Fq(sR)
      end
    end

    function _preimage(x::Union{ fq_nmod, fq })
      @assert typeof(x) == elem_type(T)
      if isfq
        x = z.RtoFq\x
      end
      for i = 1:dim(A)
        z.tt[1, i] = base_ring(A)(coeff(x, i - 1))
      end
      s = z.tt*N
      return A([ s[1, i] for i = 1:dim(A) ])
    end

    z.header = MapHeader{S, T}(A, Fq, _image, _preimage)
    return z
  end
end

function AbsAlgAssToFqMor(A::AbsAlgAss{gfp_elem}, Fq::FqNmodFiniteField, M::gfp_mat, N::gfp_mat, R::GFPPolyRing)
  return AbsAlgAssToFqMor{typeof(A), FqNmodFiniteField, gfp_mat, GFPPolyRing}(A, Fq, M, N, R)
end

function AbsAlgAssToFqMor(A::AbsAlgAss{fq_nmod}, Fq::FqNmodFiniteField, M::fq_nmod_mat, N::fq_nmod_mat, R::FqNmodPolyRing, RtoFq::FqPolyRingToFqMor)
  return AbsAlgAssToFqMor{typeof(A), FqNmodFiniteField, fq_nmod_mat, FqNmodPolyRing}(A, Fq, M, N, R, RtoFq)
end

function AbsAlgAssToFqMor(A::AbsAlgAss{Generic.ResF{fmpz}}, Fq::FqFiniteField, M::Generic.Mat{Generic.ResF{fmpz}}, N::Generic.Mat{Generic.ResF{fmpz}}, R::GFPFmpzPolyRing)
  return AbsAlgAssToFqMor{typeof(A), FqFiniteField, Generic.Mat{Generic.ResF{fmpz}}, GFPFmpzPolyRing}(A, Fq, M, N, R)
end

function AbsAlgAssToFqMor(A::AbsAlgAss{fq}, Fq::FqFiniteField, M::fq_mat, N::fq_mat, R::FqPolyRing, RtoFq::FqPolyRingToFqMor)
  return AbsAlgAssToFqMor{typeof(A), FqFiniteField, fq_mat, FqPolyRing}(A, Fq, M, N, R, RtoFq)
end
