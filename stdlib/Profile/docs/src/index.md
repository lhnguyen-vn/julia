# [Profiling](@id lib-profiling)

The methods in `Profile` are not exported and need to be called e.g. as `Profile.Time.print()`.

```@docs
Profile.Time.@profile
Profile.Time.clear
Profile.Time.print
Profile.Time.init
Profile.Time.fetch
Profile.Time.retrieve
```

```@docs
Profile.Memory.@profile
Profile.Memory.init
```

```@docs
Profile.callers
Profile.clear_malloc_data
```
