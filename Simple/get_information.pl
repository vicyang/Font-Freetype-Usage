use Font::FreeType;
 
my $freetype = Font::FreeType->new;
my $face = $freetype->face('C:/windows/fonts/Consola.ttf');
my $bbox = $face->bounding_box();

my $size = 100;
my $dpi  = 100;

$face->set_char_size($size, $size, $dpi, $dpi);
print join(",",  $bbox->x_min, $bbox->y_min, $bbox->x_max, $bbox->y_max);

my $glyph = $face->glyph_from_char("g");
my ($xmin, $ymin, $xmax, $ymax) = $glyph->outline_bbox();
print "glyph\n";

printf 
"                  W,H: %.2f,%.2f
           hz_advance: %.2f 
  left, right bearing: %.2f,%.2f
xmin ymin, xmax, ymax: %.2f,%.2f %.2f,%.2f\n", 
$glyph->width(),
$glyph->height(),
$glyph->horizontal_advance(),
$glyph->left_bearing(),
$glyph->right_bearing(),
$xmin,
$ymin,
$xmax,
$ymax
;