module PathVisualizer
using GLAbstraction, Colors, GeometryTypes, GLVisualize, Reactive

function prepare_data(nbins, nn)
  X = zeros(Float32, 3,nbins, nn)
  X[:,1,:] = randn(3,nn)
  for j in 1:3
    for i in 2:nbins
      X[:, i,j] = X[:,i-1,j] + 0.01*randn(3)
    end
  end
  X
end

function show_paths(X::Array{Float32,3})
  window = glscreen()
  #convert to points
  ncells, nbins, nn = size(X)
  Y = Array(Point3f0, nbins, nn)
  C = Array(RGBA{Float32},nbins,nn)
  _colors = Colors.distinguishable_colors(nn)
  for i in 1:nbins
    for j in 1:nn
      Y[i,j] = Point3f0(X[1,i,j], X[2, i,j], X[3, i, j])
      C[i,j] = RGBA(_colors[j].r, _colors[j].g, _colors[j].b, 1.0)
    end
  end
  colors_ = Array(Signal,3)
  for i in 1:nn
    timesignal = loop(1:nbins)
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
    lines3d = visualize(Y[:,i], :lines, color=colors_[i])
    _view(lines3d, window, camera=:perspective)
  end
  renderloop(window)
end
end #module
