=info
    提取Outlines(轮廓信息)
=cut
use autodie;
use utf8;
use Encode;
use Data::Dump qw/dump/;
use Data::Dumper;

BEGIN
{
    use Storable;
    use File::Slurp;
    use IO::Handle;
    STDOUT->autoflush(1);
}

INIT
{
    our %TEXT;
    my $href;
    print "Loading ... ";
    $href = retrieve 'msyhContour.perldb';
    print "Done\n";
}
