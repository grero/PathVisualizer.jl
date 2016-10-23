module PathVisualizer
using GLAbstraction, Colors, GeometryTypes, GLVisualize, Reactive
#TODO: Use dimensionality reduction to reduce from `ncells` to 3 dimensions
"""
Animate the paths specified by the matrix `X`. The fist dimension of `X` specifies the number of dimensions (only 3 works), the second the number of time points and the third the individual paths.

	function show_paths(X::Array{Float32,3})
"""
function animate_paths{T<:RGB}(X::Array{Float32,3},colors::Array{T,1}=RGB[],fps=60)
  window = glscreen()
  #convert to points
  ncells, nbins, nn = size(X)
  Y = Array(Point3f0, nbins, nn)
  C = Array(RGBA{Float32},nbins,nn)
	#center on the initial points
	centroid = Vec3f0(-mean(X[:,1,:], 2)[:]...)
	translation = translationmatrix(centroid)
	#scale
	mi = minimum(X,(2,3))[:]
	mx = maximum(X,(2,3))[:]
	doscale = scalematrix(Vec3f0(1.0/(mx[1]-mi[1]), 1.0/(mx[2]-mi[2]), 1.0/(mx[3]-mi[3])))
	model = doscale*translation
	if isempty(colors)
		_colors = Colors.distinguishable_colors(nn)
	else
		_colors = colors
	end
  for i in 1:nbins
    for j in 1:nn
      Y[i,j] = Point3f0(X[1,i,j], X[2, i,j], X[3, i, j])
      C[i,j] = RGBA(_colors[j].r, _colors[j].g, _colors[j].b, 1.0)
    end
  end
  colors_ = Array(Signal,nn)
  for i in 1:nn
    timesignal = loop(1:nbins, fps)
    colors_[i] = map(timesignal)  do t
      _C = similar(C[:,i])
      for j in 1:t
        _C[j] = RGBA(C[j,i].r, C[j,i].g, C[j,i].b, 1.0)
      end
      for j in t+1:nbins
        _C[j] = RGBA(C[j,i].r, C[j,i].g, C[j,i].b, 0.0)
      end
      _C
    end
  end
  for i in 1:nn
    lines3d = visualize(Y[:,i], :lines, color=colors_[i],model=model)
    _view(lines3d, window, camera=:perspective)
  end
  renderloop(window)
end

function animate_points{T<:RGB}(X::Array{Float32,3},colors::Array{T,1}=RGB[],fps=60)
  window = glscreen()
  #convert to points
  ncells, nbins, nn = size(X)
	centroid = -mean(X, (2,3))[:]
	translation = translationmatrix(Vec3f0(centroid...))
	#find scales
	mi = minimum(X,(2,3))[:]
	mx = maximum(X,(2,3))[:]
	doscale = scalematrix(Vec3f0(1.0/(mx[1]-mi[1]), 1.0/(mx[2]-mi[2]), 1.0/(mx[3]-mi[3])))
	model = doscale*translation
  Y = Array(Point3f0, nbins, nn)
  C = Array(RGBA{Float32},nbins,nn)
	if isempty(colors)
		_colors = Colors.distinguishable_colors(nn)
	else
		_colors = colors
	end
  for i in 1:nbins
    for j in 1:nn
      Y[i,j] = Point3f0(X[1,i,j], X[2, i,j], X[3, i, j])
      C[i,j] = RGBA(_colors[j].r, _colors[j].g, _colors[j].b, 1.0)
    end
  end
	timesignal = loop(1:nbins,fps)
	points_ = map(timesignal) do t
			Y[t,:]
    end
		points3d = visualize((Circle, points_), color=C[1,:],model=model)
	_view(points3d, window, camera=:perspective)
  renderloop(window)
end
end #module
