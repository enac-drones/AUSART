use core
use base
use gui




_define_
VFRPoint (double x, double y, string name) {

	Translation tr (x, y)

	Double repr_size (1/4000.1)
	Scaling size ($repr_size, $repr_size, 0, 0)

	FillColor _ (120, 120, 120)
	Circle c (0, 0, 10)
	FillColor _ (190, 190, 190)
	TextAnchor _ (1)
	Text _ (0, 30, name)

}