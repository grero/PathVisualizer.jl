using PathVisualizer
using Base.Test

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

X = prepare_data(500,3)
PathVisualizer.show_paths(X)


