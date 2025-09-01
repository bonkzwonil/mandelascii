//Kackversion in node
//im grunde kann man bei dem ganzen algol dreck auch direkt den code von c fast unverändern nehmen :D

//aber WOW: wie schnell nodejs is

function mandel(x, y, max_iter){
	let c = 0.0;
	let ci = 0.0;
	let ci2 = 0.0;
	let c2 = 0.0;
	let i = 0;
	while( ((c2+ci2) < 4) && (i < max_iter)){
		ci = (c * ci * 2) + y;
		c = (c2 - ci2) + x;
		c2 = c * c;
		ci2 = ci * ci;
		i++;
	}
	return {c: c, ci: ci, i: i};
}

function benchmark ( n){
	let r={};
	for(let i=0; i<n; i++){
		r = mandel(0.1,-0.5,5000); //compiler optimizes call away with O4, so we need to fake havig interest in the result
	}
	return r;
}


let r = mandel(0.1,-0.5,5000);
console.log(r.c + " " +r.ci +" "+r.i );
	r = benchmark(1000000);
console.log(r.c + " " +r.ci +" "+r.i );
