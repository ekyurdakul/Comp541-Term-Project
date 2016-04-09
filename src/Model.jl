include("VGGNet.jl")

#w1=w[:, 1:4096];
#w2=w[:, 4097:8192];

#Produces the top 4096 dimensional vector
@knet function Layer3D(x)
	w=par(init=Gaussian(0.0, 0.01), dims=(5,5,5,3,96))
	b=par(init=Constant(0.0), dims=(1,1,1,96,1))
	y=conv(w,x; window=5, padding=1, stride=1)
	y=relu(y.+b)
	y=pool(y; window=2, padding=0, stride=2)

	w=par(init=Gaussian(0.0, 0.01), dims=(3,3,3,96,192))
	b=par(init=Constant(0.0), dims=(1,1,1,192,1))
	y=conv(w,y; window=3, stride=1)
	y=relu(y.+b)
	y=pool(y; window=2, stride=2)

	w=par(init=Gaussian(0.0, 0.01), dims=(3,3,3,192,384))
	b=par(init=Constant(0.0), dims=(1,1,1,384,1))
	y=conv(w,y; window=3, stride=1)
	y=relu(y.+b)

	#FC4
	w=par(init=Gaussian(0.0, 0.01), dims=(4096,24576))
	b=par(init=Constant(0.0), dims=(4096,1))
	y=relu(w*y.+b)
	return dropout(y)
end

#Entire model
@knet function Model(x2d, x3d)
	#Each produce 4096 dimensional vector
	v1=Layer3D(x3d)
	v2=VGGNet(x2d)

	#FC5
	#Reduce 8192 dimensions to 1000
	w1=par(init=Gaussian(0.0, 0.01), dims=(1000, 4096))
	w2=par(init=Gaussian(0.0, 0.01), dims=(1000, 4096))
	b1=par(init=Constant(0.0), dims=(1000,1))
	b2=par(init=Constant(0.0), dims=(1000,1))

	#Simulate concatenation
	y1=w1*v1.+b1
	y2=w2*v2.+b2
	v=relu(y1+y2)
	v=dropout(v)

	return softmax(v; num=20)
end
