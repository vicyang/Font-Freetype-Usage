=info
    生成字符点阵的极简示例代码
    编辑: 523066680, Code-By.Org
    改自 examples/render-glyph.pl
=cut

use Data::Dump qw/dump/;
use Font::FreeType;

my ($filename, $char, $size) = ("C:/windows/fonts/arial.ttf", 'A', 20);
my $dpi = 100;

my $face = Font::FreeType->new->face($filename);
$face->set_char_size($size, $size, $dpi, $dpi);

$char = ord($char);
my $glyph = $face->glyph_from_char_code($char);
die "No glyph for character '$char'.\n" if (! $glyph);

print dump $glyph->bitmap;
