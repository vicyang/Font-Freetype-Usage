=info
    提取Outlines(轮廓信息)
=cut
use autodie;
use utf8;
use Encode;
use Data::Dump qw/dump/;
use Data::Dumper;
use Font::FreeType;
use feature 'state';
use OpenGL qw/ :all /;
use OpenGL::Config;

BEGIN
{
    use utf8;
    use Storable;
    use File::Slurp;
    use IO::Handle;
    STDOUT->autoflush(1);

    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 500;

    our ($font, $size) = ("C:/windows/fonts/msyh.ttf", 32);
    our $dpi = 100;

    our $face = Font::FreeType->new->face($font);
    $face->set_char_size($size, $size, $dpi, $dpi);

    our $tobj;
}

INIT
{
    our %TEXT;
    print "Loading contours ... ";
    my $code;
    my $char;

    foreach $code (0x00..0x7F, 0x4E00..0x9FA5 )
    {
        $char = chr( $code );
        $TEXT{ $char } = get_contour( $char ); 
    }

    print "Done\n";

    print "Dumping ... ";
    store \%TEXT, 'msyhContour.perldb';
    print "Done\n";
}


BEZIER_FUNCTION:
{
    sub pointOnLine
    {
        my ($x1, $y1, $x2, $y2, $t) = @_;
        return (
            ($x2-$x1)*$t + $x1, 
            ($y2-$y1)*$t + $y1 
        );
    }

    sub pointOnQuadBezier
    {
        my ($x1, $y1, $x2, $y2, $x3, $y3, $t) = @_;
        return pointOnLine(
                   pointOnLine( $x1, $y1, $x2, $y2, $t ),
                   pointOnLine( $x2, $y2, $x3, $y3, $t ),
                   $t
               );
    }
}

sub get_contour
{
    our $glyph;
    my $char = shift;
    #previous x, y
    my $px, $py, $parts, $step;
    my @contour = ();
    my $ncts    = -1;
    
    $parts = 5;
    $glyph = $face->glyph_from_char($char) || return undef;

    $glyph->outline_decompose(
        move_to  => 
            sub 
            {
                ($px, $py) = @_;
                $ncts++;
                push @{$contour[$ncts]}, [$px, $py];
            },
        line_to  => 
            sub
            {
                ($px, $py) = @_;
                push @{$contour[$ncts]}, [$px, $py];
            },
        conic_to => 
            sub
            {
                for ($step = 0.0; $step <= $parts; $step+=1.0)
                {
                    push @{$contour[$ncts]}, 
                        [pointOnQuadBezier( $px, $py, @_[2,3,0,1], $step/$parts )];
                }
                ($px, $py) = @_;
            },
        cubic_to => sub { warn "cubic\n"; }
    );

    #printf "%d\n", $#contour;

    return { 
        outline => [ @contour ],
        right   => $glyph->horizontal_advance(),
    };
}