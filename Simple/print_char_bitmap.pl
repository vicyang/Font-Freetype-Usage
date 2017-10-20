=info
    显示字符点阵
    bitmap
    bitmap_pgm
=cut

use Data::Dump qw/dump/;
use File::Slurp;
use Font::FreeType;

my ($filename, $char, $size) = ("C:/windows/fonts/arial.ttf", 'O', 10);
my $dpi = 100;

my $face = Font::FreeType->new->face($filename);
$face->set_char_size($size, $size, $dpi, $dpi);

my $glyph = $face->glyph_from_char($char);
die "No glyph for character '$char'.\n" if (! $glyph);

#print dump $glyph->bitmap;
my ($bitmap, $left, $top) = $glyph->bitmap();

for my $line ( @$bitmap )
{
    grep { printf "%2X ", ord($_) } split( "", $line );
    print "\n";
}

print "\nprint pgm\n";
my ($pgm, $left, $top) = $glyph->bitmap_pgm();
write_file( "$char.pgm", {binmode=>':raw'} ,$pgm );

# for my $line ( @$pgm )
# {
#     grep { printf "%2X ", ord($_) } split( "", $line );
#     print "\n";
# }

__END__
输出数据为灰度值，FF表示白色，0表示黑色
 0  0  0  0 4C FF 4A  0  0  0  0 
 0  0  0  0 B2 9B B1  0  0  0  0 
 0  0  0 1C E4  7 E2 1C  0  0  0 
 0  0  0 80 88  0 86 7F  0  0  0 
 0  0  3 E2 25  0 25 E2  3  0  0 
 0  0 4E C1  0  0  0 C1 4C  0  0 
 0  0 B4 FF FF FF FF FF B3  0  0 
 0 1E E4  7  0  0  0  8 E5 1D  0 
 0 82 75  0  0  0  0  0 79 81  0 
 3 D4  D  0  0  0  0  0  F D5  3 
