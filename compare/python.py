#Kackversion in python

def mandel (x,y, max_iter):
	c = 0
	ci = 0
	ci2 = 0
	c2 = 0
	i = 0
	while( ((c2+ci2) < 4) and (i < max_iter)):
		ci = (c * ci * 2) + y
		c = (c2 - ci2) + x
		c2 = c * c
		ci2 = ci * ci
		i=i+1
	return [c, ci, i]

print(mandel(0.1,-0.5,5000))

def benchmark (n):
	for i in range(n):
		mandel(0.1,-0.5,5000)



benchmark(50000)		

