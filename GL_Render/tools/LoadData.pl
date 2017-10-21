=info
    提取Outlines(轮廓信息)
=cut

BEGIN
{
    use Storable;
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
