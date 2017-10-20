=info
    提取Outlines(轮廓信息)
=cut

use Data::Dump qw/dump/;
use Data::Dumper;
use Font::FreeType;

my ($filename, $char, $size) = ("C:/windows/fonts/arial.ttf", 'A', 20);
my $dpi = 100;

my $face = Font::FreeType->new->face($filename);
$face->set_char_size($size, $size, $dpi, $dpi);

$char = ord($char);
my $glyph = $face->glyph_from_char_code($char);
die "No glyph for character '$char'.\n" if (! $glyph);

$glyph->outline_decompose(
    move_to  => sub { printf "move_to: %f\n", $_[0] },
    line_to  => sub { printf "line_to: %f\n", $_[0] },
    conic_to => sub { printf "conic_to: %f\n", $_[0] },
    cubic_to => sub { printf "cubic_to: %f\n", $_[0] },
);
