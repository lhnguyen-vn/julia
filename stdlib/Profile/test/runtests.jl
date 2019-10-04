# This file is a part of Julia. License is MIT: https://julialang.org/license

using Test, Profile

@testset "time" begin
    include("time.jl")
end

@testset "memory" begin
    include("memory.jl")
end

