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

    foreach $code ( 0x00 .. 0x7F )
    {
        $char = chr( $code );
        $TEXT{ $char } = get_contour( $char ); 
    }

    foreach $char ( split //, "年日月期数据" )
    {
        $TEXT{ $char } = get_contour( $char ); 
    }
    
    print "Done\n";
}

&main();

sub draw_box_lines
{
    glBegin(GL_LINES);
    glColor3f(1.0, 0.0, 0.0);
    glVertex3f(-200.0, 0.0, 0.0);
    glVertex3f(200.0, 0.0, 0.0);
    glVertex3f(0.0, -200.0, 0.0);
    glVertex3f(0.0, 200.0, 0.0);

    glColor3f(0.0, 0.8, 0.0);
    glVertex3f(-200.0, $glyph->vertical_advance(), 0.0);
    glVertex3f(200.0, $glyph->vertical_advance(), 0.0);
    glEnd();
}

sub draw_character
{
    our @TEXT;
    my $char = shift;
    my $cts;
    gluTessBeginPolygon($tobj);
    for $cts ( @{$TEXT{$char}->{outline}} )
    {
        gluTessBeginContour($tobj);
        grep { gluTessVertex_p($tobj, @$_, 0.0 ) } @$cts;
        gluTessEndContour($tobj);
    }
    gluTessEndPolygon($tobj);
}

sub draw_string
{
    my $s = shift;
    for my $c ( split //, $s )
    {
        draw_character($c);
        glTranslatef($TEXT{$c}->{right}, 0.0, 0.0);
    }
}

sub display 
{
    state $iter = 0;
    state $ti = 0;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glPushMatrix();
    glRotatef($rx, 1.0, 0.0, 0.0);
    glRotatef($ry, 0.0, 1.0, 0.0);
    glRotatef($rz, 0.0, 0.0, 1.0);

    draw_box_lines();

    glColor3f(1.0, 1.0, 1.0);
    draw_string("abge数据QT");

    glPopMatrix();
    $iter++;
    glutSwapBuffers();
}

sub idle 
{
    sleep 0.02;
    glutPostRedisplay();
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 0.5);
    glPointSize(4.0);
    glLineWidth(1.0);
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    # glEnable(GL_POINT_SMOOTH);
    glEnable(GL_LINE_SMOOTH);
    glShadeModel(GL_FLAT);

    $tobj = gluNewTess();

    # gluTessCallback($tobj, GLU_TESS_VERTEX, \&glVertex3f );
    # #gluTessCallback($tobj, GLU_TESS_VERTEX, \&vertexCallback);
    # gluTessCallback($tobj, GLU_TESS_BEGIN,  \&beginCallback);
    # gluTessCallback($tobj, GLU_TESS_END,    \&endCallback);
    # gluTessCallback($tobj, GLU_TESS_ERROR,  \&errorCallback);

    gluTessCallback($tobj, GLU_TESS_BEGIN,     'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_END,       'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_VERTEX,    'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_COMBINE,   'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_ERROR,     'DEFAULT');
    gluTessCallback($tobj, GLU_TESS_EDGE_FLAG, 'DEFAULT');
}

sub reshape 
{
    my ($w, $h) = (shift, shift);
    #Same with screen size
    state $hz_half = $WIDTH/2.0;
    state $vt_half = $HEIGHT/2.0;
    state $fa = 250.0;

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-$hz_half, $hz_half, -$vt_half, $vt_half, 0.0, $fa*2.0); 
    #gluPerspective( 90.0, 1.0, 1.0, $fa*2.0 );
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}

sub hitkey 
{
    our $WinID;
    my $k = lc(chr(shift));

    if ( $k eq 'q') { quit() }
    if ( $k eq 'w') { $rx+=10.0 }
    if ( $k eq 's') { $rx-=10.0 }
    if ( $k eq 'a') { $ry-=10.0 }
    if ( $k eq 'd') { $ry+=10.0 }
    if ( $k eq 'j') { $rz+=10.0 }
    if ( $k eq 'k') { $rz-=10.0 }
}

sub quit
{
    glutDestroyWindow( $WinID );
    exit;
}

sub main
{
    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE |GLUT_DEPTH | GLUT_MULTISAMPLE  );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    our $WinID = glutCreateWindow("Display");
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
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

TESS_CALLBACK_FUNCTION:
{
    sub beginCallback  { glBegin( $_[0] ); print( $_[0] ," ") }
    sub endCallback    { glEnd(); }
    sub errorCallback  { print gluErrorString($_[0]),"\n"; quit(); }
    sub vertexCallback { glVertex3f( @_ ); }
}

sub get_contour
{
    my ($char) = shift;
    #previous x, y
    my $px, $py, $parts, $step;
    my @contour;
    my $nts = -1;
    our ($glyph);
    
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
                        [ pointOnQuadBezier( $px, $py, @_[2,3,0,1], $step/$parts ) ];
                }
                ($px, $py) = @_;
            },
        cubic_to => sub { warn "cubic\n"; }
    );

    return { 
        outline => \@contour,
        n       => $ncts+1,
        right   => $glyph->horizontal_advance(),
        };
}