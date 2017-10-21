use feature 'say';
use Font::FreeType;
use Data::Dumper;
 
my $freetype = Font::FreeType->new;
my $face = $freetype->face('C:/windows/fonts/arial.ttf');
my $charmap = $face->charmap;
say $charmap->platform_id;
say $charmap->encoding_id;
say $charmap->encoding;

print Dumper $charmap;