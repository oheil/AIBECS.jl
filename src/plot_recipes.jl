"""
    HorizontalSlice(x, grd, depth)

Plots a horizontal slice of tracer `x` at depth `depth`.
"""
@userplot HorizontalSlice
@recipe function f(p::HorizontalSlice)
    x, grd, depth = p.args
    xunit = string(unit(x[1]))
    x3D = rearrange_into_3Darray(ustrip.(x), grd)
    lon, lat = grd.lon .|> ustrip, grd.lat .|> ustrip
    iz = findfirst(ustrip.(grd.depth) .≥ ustrip(upreferred(depth)))
    isnothing(iz) && (iz = length(grd.depth))
    @series begin
        seriestype := :contourf
        xlabel --> "Longitude"
        ylabel --> "Latitude"
        colorbar_title --> xunit
        lon, lat, view(x3D, :, :, iz)
    end
end

"""
    SurfaceMap(x, grd)

Plots a surface map of tracer `x`.
"""
@userplot SurfaceMap
@recipe function f(p::SurfaceMap)
    x, grd = p.args
    xunit = string(unit(x[1]))
    x3D = rearrange_into_3Darray(ustrip.(x), grd)
    lon, lat = grd.lon .|> ustrip, grd.lat .|> ustrip
    @series begin
        seriestype --> :contourf
        xlabel --> "Longitude"
        ylabel --> "Latitude"
        colorbar_title --> xunit
        lon, lat, view(x3D, :, :, 1)
    end
end

"""
    VerticalIntegral(x, grd)

Plots the vertical integral of tracer `x`.
"""
@userplot VerticalIntegral
@recipe function f(p::VerticalIntegral)
    x, grd = p.args
    intunit = string(unit(x[1]) * u"m")
    x3D = rearrange_into_3Darray(ustrip.(x), grd)
    lon, lat = grd.lon .|> ustrip, grd.lat .|> ustrip
    δz_3D = ustrip.(grd.δz_3D)
    xvint = sum(x -> ismissing(x) ? 0.0 : x, x3D .* δz_3D, dims=3) ./ grd.wet3D[:,:,1]
    @series begin
        seriestype := :contourf
        xlabel --> "Longitude"
        ylabel --> "Latitude"
        colorbar_title --> intunit
        lon, lat, view(xvint, :, :, 1)
    end
end

"""
    VerticalAverage(x, grd)

Plots the vertical average of tracer `x`.
"""
@userplot VerticalAverage
@recipe function f(p::VerticalAverage)
    x, grd = p.args
    xunit = string(unit(x[1]))
    x3D = rearrange_into_3Darray(ustrip.(x), grd)
    v = ustrip.(vector_of_volumes(grd))
    v3D = rearrange_into_3Darray(v, grd)
    lon, lat = grd.lon .|> ustrip, grd.lat .|> ustrip
    xmean = sum(x -> ismissing(x) ? 0.0 : x, x3D .* v3D, dims=3) ./
                sum(x -> ismissing(x) ? 0.0 : x, v3D, dims=3)
    @series begin
        seriestype := :contourf
        lon, lat, view(xmean, :, :, 1)
    end
end


"""
    ZonalSlice(x, grd, lon)

Plots a zonal slice of tracer `x` at longitude `lon`.
"""
@userplot ZonalSlice
@recipe function f(p::ZonalSlice)
    x, grd, lon = p.args
    lon = mod(ustrip(lon), 360)
    xunit = string(unit(x[1]))
    x3D = rearrange_into_3Darray(ustrip.(x), grd)
    depth, lat = grd.depth .|> ustrip, grd.lat .|> ustrip
    ix = findfirst(ustrip(grd.lon) .≥ mod(ustrip(lon), 360))
    @series begin
        seriestype := :contourf
        yflip := true
        yticks --> Int.(round.(depth))
        ylims --> (0, maximum(depth))
        xlabel --> "Latitude"
        ylabel --> "Depth (m)"
        colorbar_title --> xunit
        lat, depth, permutedims(view(x3D,:,ix,:), [2,1])
    end
end


"""
    MeridionalSlice(x, grd, lat)

Plots a Meridional slice of tracer `x` at longitude `lat`.
"""
@userplot MeridionalSlice
@recipe function f(p::MeridionalSlice)
    x, grd, lat = p.args
    xunit = string(unit(x[1]))
    x3D = rearrange_into_3Darray(ustrip.(x), grd)
    depth, lon = grd.depth .|> ustrip, grd.lon .|> ustrip
    iy = findfirst(ustrip(grd.lat) .≥ ustrip(lat))
    @series begin
        seriestype := :contourf
        yflip := true
        yticks --> Int.(round.(depth))
        ylims --> (0, maximum(depth))
        xlabel --> "Longitude"
        ylabel --> "Depth (m)"
        colorbar_title --> xunit
        lon, depth, permutedims(view(x3D,iy,:,:), [2,1])
    end
end


"""
    ZonalAverage(x, grd; mask=1)

Plots a zonal average of tracer `x`.
"""
@userplot ZonalAverage
@recipe function f(p::ZonalAverage; mask=1)
    x, grd = p.args
    xunit = string(unit(x[1]))
    x3D = rearrange_into_3Darray(ustrip.(x) .* mask, grd)
    v = ustrip.(vector_of_volumes(grd))
    v3D = rearrange_into_3Darray(v .* mask, grd)
    depth, lat = grd.depth .|> ustrip, grd.lat .|> ustrip
    xmean = sum(x -> ismissing(x) ? 0.0 : x, x3D .* v3D, dims=2) ./
                sum(x -> ismissing(x) ? 0.0 : x, v3D, dims=2)
    @series begin
        seriestype := :contourf
        yflip := true
        yticks --> Int.(round.(depth))
        ylims --> (0, maximum(depth))
        xlabel --> "Latitude"
        ylabel --> "Depth (m)"
        colorbar_title --> xunit
        lat, depth, permutedims(view(xmean, :, 1, :), [2,1])
    end
end



@userplot ZonalAverage2
@recipe function f(p::ZonalAverage2)
    x, grd = p.args
    x3D = rearrange_into_3Darray(x, grd)
    v = ustrip.(vector_of_volumes(grd))
    v3D = rearrange_into_3Darray(v, grd)
    depth, lat = grd.depth .|> ustrip, grd.lat .|> ustrip
    xmean = sum(x -> ismissing(x) ? 0.0 : x, x3D .* v3D, dims=2) ./
                sum(x -> ismissing(x) ? 0.0 : x, v3D, dims=2)
    xmean = dropdims(xmean, dims=2)

    x, grd, ct = p.args
    x3D = rearrange_into_3Darray(x, grd)
    depths = ustrip.(grd.depth)
    ndepths = length(depths)

    itp = interpolate(xmean, (BSpline(Linear()), BSpline(Linear()))) # interpolate linearly between the data points
    lats = range(ustrip(grd.lat[1]), ustrip(grd.lat[end]), length=length(grd.lat))
    ndepths = length(depth)
    stp = Interpolations.scale(itp, lats, 1:ndepths) # re-scale to the actual domain
    etp = extrapolate(stp, (Line(), Line())) # periodic longitude
    @series begin
        seriestype := :contourf
        yflip := true
        yticks --> Int.(round.(depth))
        ylims --> (0, maximum(depth))
        y, depth, [etp(lat, i) for i in 1:nz, lat in y]
    end
end

@userplot DepthProfile
@recipe function f(p::DepthProfile)
    x, grd, lat, lon = p.args
    x3D = rearrange_into_3Darray(x, grd)
    depth = ustrip.(grd.depth)
    ix = findfirst(ustrip.(grd.lon) .≥ mod(ustrip(lon), 360))
    iy = findfirst(ustrip.(grd.lat) .≥ ustrip(lat))
    @series begin
        yflip := true
        yticks --> Int.(round.(depth))
        ylims --> (0, maximum(depth))
        view(x3D, iy, ix, :), depth
    end
end

"""
    InterpolatedDepthProfile(x, grd, lat, lon)

Plots the profile of tracer `x` interpolated at `(lat,lon)` coordinates.
"""
@userplot InterpolatedDepthProfile
@recipe function f(p::InterpolatedDepthProfile)
    x, grd, lat, lon = p.args
    u = unit(eltype(x))
    x3D = rearrange_into_3Darray(ustrip.(x), grd)
    udepths = unit(eltype(grd.depth))
    depths = ustrip.(grd.depth)
    knots = (ustrip.(grd.lat), ustrip.(grd.lon), 1:length(depths))
    itp = interpolate(knots, x3D, (Gridded(Linear()), Gridded(Linear()), NoInterp()))
    @series begin
        yflip --> true
        yticks --> Int.(round.(depths))
        ylims --> (0, maximum(depths))
        yguide --> "depth"
        xguide --> "tracer"
        xs, ys = itp(ustrip(lat), ustrip(lon), 1:length(depths)), depths * udepths
        [ismissing(x) ? NaN : x for x in xs] * u, ys
    end
end


@userplot TransectContourfByDistance
@recipe function f(p::TransectContourfByDistance)
    x, grd, ct = p.args
    x3D = rearrange_into_3Darray(x, grd)
    depths = ustrip.(grd.depth)
    ndepths = length(depths)

    itp = interpolate(periodic_longitude(x3D), (BSpline(Linear()), BSpline(Linear()), NoInterp())) # interpolate linearly between the data points
    lats = range(ustrip(grd.lat[1]), ustrip(grd.lat[end]), length=length(grd.lat))
    lons = range(ustrip(grd.lon[1]), ustrip(grd.lon[1])+360, length=length(grd.lon)+1)
    stp = Interpolations.scale(itp, lats, lons, 1:ndepths) # re-scale to the actual domain
    etp = extrapolate(stp, (Line(), Periodic(), Line())) # periodic longitude

    n = length(ct)
    distances = cumsum(Distances.colwise(Haversine(6371.0),
                [view(ct.lon, :)'; view(ct.lat, :)'],
                [view(ct.lon, [1;1:n-1])'; view(ct.lat, [1;1:n-1])']))
    idx = unique(i -> distances[i], 1:length(ct)) # Remove stations at same (lat,lon)

    @series begin
        seriestype := :contourf
        yflip := true
        yticks --> Int.(round.(depths))
        ylims --> (0, maximum(depths))
        xlabel --> "$(ct.name) distance (km)"
        ylabel --> "Depth (m)"
        distances[idx], depths, [etp(lat, lon, i) for i in 1:ndepths, (lat, lon) in zip(ct.lat[idx], ct.lon[idx])]
    end
end

periodic_longitude(x3D::Array{T,3}) where T = view(x3D,:,[1:size(x3D,2); 1],:)
periodic_longitude(x2D::Array{T,2}) where T = view(x2D,:,[1:size(x3D,2); 1])


"""
    PlotCruiseTrack(ct; longitude_bounds)

Plots the cruise track `ct`.
"""
@userplot PlotCruiseTrack
@recipe function f(p::PlotCruiseTrack)
    ct = p.args[1]
    lons = [st.lon for st in ct.stations]
    lats = [st.lat for st in ct.stations]
    @series begin
        xlabel --> "Longitude"
        ylabel --> "Latitude"
        label --> ct.name
        markershape --> :hexagon
        linewidth --> 0
        linecolor --> :black
        markersize --> 3
        lons, lats
    end
end





"""
    MeridionalTransect(x, grd, ct)

Plots a Meridional transect of tracer `x` along cruise track `ct`.
"""
@userplot MeridionalTransect
@recipe function f(p::MeridionalTransect)
    x, grd, ct = p.args
    x, u = ustrip.(x), unit(eltype(x))
    x3D = rearrange_into_3Darray(x, grd)
    depths = ustrip.(grd.depth)
    ndepths = length(depths)

    itp = interpolate(periodic_longitude(x3D), (BSpline(Linear()), BSpline(Linear()), NoInterp())) # interpolate linearly between the data points

    lats = range(ustrip(grd.lat[1]), ustrip(grd.lat[end]), length=length(grd.lat))
    lons = range(ustrip(grd.lon[1]), ustrip(grd.lon[1])+360, length=length(grd.lon)+1)
    stp = Interpolations.scale(itp, lats, lons, 1:ndepths) # re-scale to the actual domain
    etp = extrapolate(stp, (Line(), Periodic(), Line())) # periodic longitude

    ctlats = [st.lat for st in ct.stations]
    ctlons = [st.lon for st in ct.stations]
    isort = sortperm(ctlats)
    idx = isort[unique(i -> ctlats[isort][i], 1:length(ct))] # Remove stations at same (lat,lon)
    @series begin
        seriestype := :contourf
        yflip := true
        yticks --> Int.(round.(depths))
        ylims --> (0, maximum(depths))
        title --> "$(ct.name)"
        ylabel --> "Depth (m)"
        xlabel --> "Latitude (°)"
        colorbar_title --> string(u)
        ctlats[idx], depths, [etp(lat, lon, i) for i in 1:ndepths, (lat, lon) in zip(ctlats[idx], ctlons[idx])]
    end
end


"""
    MeridionalScatterTransect(t)

Plots a scatter of the discrete obs of `t` in (lat,depth) space.
"""
@userplot MeridionalScatterTransect
@recipe function f(p::MeridionalScatterTransect)
    transect = p.args[1]
    depths = reduce(vcat, pro.depths for pro in transect.profiles)
    values = ustrip.(reduce(vcat, pro.values for pro in transect.profiles))
    lats = reduce(vcat, pro.station.lat * ones(length(pro)) for pro in transect.profiles)
    @series begin
        seriestype := :scatter
        yflip := true
        zcolor --> values
        markershape --> :circle
        label --> ""
        xlim --> extrema(lats)
        clims --> (0, maximum(transect))
        title --> "$(transect.tracer) along $(transect.cruise)"
        ylabel --> "Depth (m)"
        xlabel --> "Latitude (°)"
        colorbar_title --> string(unit(transect))
        lats, depths
    end
end




"""
    ZonalTransect(x, grd, ct)

Plots a Zonal transect of tracer `x` along cruise track `ct`.
"""
@userplot ZonalTransect
@recipe function f(p::ZonalTransect)
    x, grd, ct = p.args
    x, u = ustrip.(x), unit(eltype(x))
    x3D = rearrange_into_3Darray(x, grd)
    depths = ustrip.(grd.depth)
    ndepths = length(depths)

    itp = interpolate(periodic_longitude(x3D), (BSpline(Linear()), BSpline(Linear()), NoInterp())) # interpolate linearly between the data points

    lats = range(ustrip(grd.lat[1]), ustrip(grd.lat[end]), length=length(grd.lat))
    lons = range(ustrip(grd.lon[1]), ustrip(grd.lon[1])+360, length=length(grd.lon)+1)
    stp = Interpolations.scale(itp, lats, lons, 1:ndepths) # re-scale to the actual domain
    etp = extrapolate(stp, (Line(), Periodic(), Line())) # periodic longitude

    ctlats = [st.lat for st in ct.stations]
    ctlons = [st.lon for st in ct.stations]
    isort = sortperm(ctlons)
    idx = isort[unique(i -> ctlons[isort][i], 1:length(ct))] # Remove stations at same (lat,lon)
    @series begin
        seriestype := :contourf
        yflip := true
        yticks --> Int.(round.(depths))
        ylims --> (0, maximum(depths))
        title --> "$(ct.name)"
        ylabel --> "Depth (m)"
        xlabel --> "Longitude (°)"
        colorbar_title --> string(u)
        ctlons[idx], depths, [etp(lat, lon, i) for i in 1:ndepths, (lat, lon) in zip(ctlats[idx], ctlons[idx])]
    end
end


"""
    ZonalScatterTransect(t)

Plots a scatter of the discrete obs of `t` in (lat,depth) space.
"""
@userplot ZonalScatterTransect
@recipe function f(p::ZonalScatterTransect)
    transect = p.args[1]
    depths = reduce(vcat, pro.depths for pro in transect.profiles)
    values = ustrip.(reduce(vcat, pro.values for pro in transect.profiles))
    lons = reduce(vcat, pro.station.lon * ones(length(pro)) for pro in transect.profiles)
    @series begin
        seriestype := :scatter
        zcolor := values
        yflip := true
        markershape --> :circle
        label --> ""
        xlim --> extrema(lons)
        clims --> (0, maximum(transect))
        title --> "$(transect.tracer) along $(transect.cruise)"
        ylabel --> "Depth (m)"
        xlabel --> "Longitude (°)"
        colorbar_title --> string(unit(transect))
        lons, depths
    end
end





"""
    RatioAtStation(x, y, grd, station, depthlims=(0,Inf))

Plots a meridional transect of tracer `x` along cruise track `ct`.

The keyword argument `zlims=(ztop, zbottom)` can be provided
if you only want to only plot for depths `z ∈ (ztop, zbottom)`.
(`z` is positive downwards in this case)
"""
@userplot RatioAtStation
@recipe function f(p::RatioAtStation; depthlims=(0,Inf))
    x, y, grd, st = p.args
    x3D = rearrange_into_3Darray(x, grd)
    y3D = rearrange_into_3Darray(y, grd)
    depths = ustrip.(grd.depth)
    knots = (ustrip.(grd.lat), ustrip.(grd.lon), 1:length(depths))
    itpx = interpolate(knots, x3D, (Gridded(Linear()), Gridded(Linear()), NoInterp()))
    itpy = interpolate(knots, y3D, (Gridded(Linear()), Gridded(Linear()), NoInterp()))
    iz = findall(depthlims[1] .≤ depths .≤ depthlims[2])
    ibot = findfirst(depths .> depthlims[2])
    x1D = itpx(ustrip(st.lat), mod(ustrip(st.lon), 360), iz)
    y1D = itpy(ustrip(st.lat), mod(ustrip(st.lon), 360), iz)
    @series begin
        seriestype := :scatter
        label --> st.name
        markershape --> :circle
        seriescolor --> :deep
        marker_z --> -depths
        colorbar_title --> "depth [m]"
        markersize --> 4
        legend --> :topleft
        x1D, y1D
    end
end





"""
    PlotParameter(p::AbstractParameters, s)

Plots the PDF of parameter `p` with symbol `s`
"""
@userplot PlotParameter
@recipe function f(plt::PlotParameter)
    d, v, initv, s, u = extract_dvisu(plt.args...)
    xs = default_range(d)
    ys = [pdf(d, x) for x in xs] # the PDF
    xu = xs * upreferred(u) .|> u .|> ustrip
    vu = v * upreferred(u) |> u |> ustrip
    @series begin
        label --> "prior"
        xu, ys
    end
    @series begin
        label --> "initial value"
        initv * [1,1], [0, pdf(d, v)]
    end
    @series begin
        xlabel --> "$s ($(string(u)))"
        ylabel --> "PDF"
        label --> "value"
        markershape --> :o
        [vu], [pdf(d, v)]
    end
end

"""
    PlotParameters(p::AbstractParameters)

Plots the PDF of all the flattenable parameters in `p`.
"""
@userplot PlotParameters
@recipe function f(plt::PlotParameters)
    p, = plt.args
    layout --> (length(p),1)
    for (i,s) in enumerate(flattenable_symbols(p))
        d, v, initvu, s, u = extract_dvisu(p,s)
        xs = default_range(d)
        ys = [pdf(d, x) for x in xs] # the PDF
        xu = xs * upreferred(u) .|> u .|> ustrip
        vu = v * upreferred(u) |> u |> ustrip
        initv = ustrip(upreferred(initvu * units(p,s)))
        @series begin
            label --> "prior"
            subplot := i
            xu, ys
        end
        @series begin
            label --> "initial value"
            subplot := i
            initvu * [1,1], [0, pdf(d, initv)]
        end
        @series begin
            xlabel --> "$s ($(string(u)))"
            ylabel --> "PDF"
            label --> "value"
            markershape --> :o
            subplot := i
            [vu], [pdf(d, v)]
        end
    end
end

extract_dvisu(d, v, initv, s, u) = d, v, initv, s, u
extract_dvisu(p::AbstractParameters, s) = prior(p,s), Parameters.unpack(p, Val(s)), initial_value(p,s), s, units(p,s)


function default_range(d::Distribution, n = 4)
    μ, σ = mean(d), std(d)
    xmin = max(μ - n*σ, minimum(support(d)))
    xmax = min(μ + n*σ, maximum(support(d)))
    range(xmin, xmax, length=1001)
end




#=




=#