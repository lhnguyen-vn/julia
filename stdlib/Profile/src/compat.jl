# Compatibility shims for old users who aren't used to the `Time` and `Memory` sub-modules

export @profile

function init(args...; kwargs...)
    @warn("Profile.init() is deprecated, use Profile.Time.init() or Profile.Memory.init() directly")
    Time.init(args...; kwargs...)
end

function print(args...; kwargs...)
    @warn("Profile.print() is deprecated, use Profile.Time.print() or Profile.Memory.print() directly")
    Time.print(args...; kwargs...)
end

macro profile(ex)
    @warn("@profile is deprecated, use Profile.Time.@profile or Profile.Memory.@profile directly")
    return quote
        Time.@profile $(esc(ex))
    end
end


"""
    clear_malloc_data()

Clears any stored memory allocation data when running julia with `--track-allocation`.
Execute the command(s) you want to test (to force JIT-compilation), then call
[`clear_malloc_data`](@ref). Then execute your command(s) again, quit
Julia, and examine the resulting `*.mem` files.
"""
clear_malloc_data() = ccall(:jl_clear_malloc_data, Cvoid, ())


# deprecated functions: use `getdict` instead
lookup(ip::UInt) = lookup(convert(Ptr{Cvoid}, ip))
