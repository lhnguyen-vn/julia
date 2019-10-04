using Profile: Time

using Serialization

Time.init()

let iobuf = IOBuffer()
    for fmt in (:tree, :flat)
        Test.@test_logs (:warn, r"^There were no samples collected\.") Time.print(iobuf, format=fmt, C=true)
        Test.@test_logs (:warn, r"^There were no samples collected\.") Time.print(iobuf, [0x0000000000000001], Dict(0x0000000000000001 => [Base.StackTraces.UNKNOWN]), format=fmt, C=false)
    end
end

@noinline function busywait(t, n_tries)
    iter = 0
    init_data = Time.len_data()
    while iter < n_tries && Time.len_data() == init_data
        iter += 1
        tend = time() + t
        while time() < tend end
    end
end

busywait(0, 0) # compile
Time.@profile busywait(1, 20)

let r = Time.retrieve()
    mktemp() do path, io
        serialize(io, r)
        close(io)
        open(path) do io
            @test isa(deserialize(io), Tuple{Vector{UInt},Dict{UInt64,Vector{Base.StackTraces.StackFrame}}})
        end
    end
end

let iobuf = IOBuffer()
    Time.print(iobuf, format=:tree, C=true)
    str = String(take!(iobuf))
    @test !isempty(str)
    truncate(iobuf, 0)
    Time.print(iobuf, format=:tree, maxdepth=2)
    str = String(take!(iobuf))
    @test !isempty(str)
    truncate(iobuf, 0)
    Time.print(iobuf, format=:flat, C=true)
    str = String(take!(iobuf))
    @test !isempty(str)
    truncate(iobuf, 0)
    Time.print(iobuf)
    @test !isempty(String(take!(iobuf)))
    truncate(iobuf, 0)
    Time.print(iobuf, format=:flat, sortedby=:count)
    @test !isempty(String(take!(iobuf)))
    Time.print(iobuf, format=:tree, recur=:flat)
    str = String(take!(iobuf))
    @test !isempty(str)
    truncate(iobuf, 0)
end

Time.clear()
@test isempty(Time.fetch())

let
    @test Time.callers("\\") !== nothing
    @test Time.callers(\) !== nothing
    # linerange with no filename provided should fail
    @test_throws ArgumentError Time.callers(\; linerange=10:50)
end

# issue #13229
module I13229
using Test, Profile
global z = 0
@timed Profile.Time.@profile for i = 1:5
    function f(x)
        return x + i
    end
    global z = f(i)
end
@test z == 10
end

@testset "setting sample count and delay in init" begin
    n_, delay_ = Time.init()
    @test n_ == 1_000_000
    def_delay = Sys.iswindows() ? 0.01 : 0.001
    @test delay_ == def_delay
    Time.init(n=1_000_001, delay=0.0005)
    n_, delay_ = Time.init()
    @test n_ == 1_000_001
    @test delay_ == 0.0005
    Time.init(n=1_000_000, delay=def_delay)
end
