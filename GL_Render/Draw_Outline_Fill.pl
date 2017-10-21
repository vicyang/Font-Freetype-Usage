=info
    提取Outlines(轮廓信息)
=cut
use Encode;
use Data::Dump qw/dump/;
use Data::Dumper;
use Font::FreeType;
use feature 'state';
use IO::Handle;

use OpenGL qw/ :all /;
use OpenGL::Config;

STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 500;
    our $WIDTH  = 500;

    my ($filename, $char, $size) = ("C:/windows/fonts/STXingKa.ttf", '风', 100);
    my $dpi = 100;

    our $face = Font::FreeType->new->face($filename);
    $face->set_char_size($size, $size, $dpi, $dpi);

    our $glyph = $face->glyph_from_char($char);
    die "No glyph for character '$char'.\n" if (! $glyph);

    our $tobj;
    our $bbox = $face->bounding_box();

    print join("\n", 
        $face->underline_position(),
        $face->underline_thickness(),
        $bbox->x_min(),

        $glyph->width(),
        $glyph->height(),
    );
}


&main();

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

sub beginCallback  { glBegin( $_[0] ); }
sub endCallback    { glEnd(); }
sub errorCallback  { print gluErrorString($_[0]),"\n"; quit(); }
sub vertexCallback { glVertex3f( @_ ); }

sub display 
{
    state $iter = 0;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    my $px, $py, $parts, $step;
    $parts = 5.0;

    my @contour;
    my $ncts = -1;

    glColor3f(1.0, 1.0, 1.0);
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

    gluTessBeginPolygon($tobj);
    for my $cts ( @contour )
    {
        gluTessBeginContour($tobj);
        grep { gluTessVertex_p($tobj, @$_, 0.0 ) } @$cts;
        gluTessEndContour($tobj);
    }
    gluTessEndPolygon($tobj);

    glBegin(GL_LINES);
    glColor3f(1.0, 0.0, 0.0);
    glVertex3f(-200.0, 0.0, 0.0);
    glVertex3f(200.0, 0.0, 0.0);
    glVertex3f(0.0, -200.0, 0.0);
    glVertex3f(0.0, 200.0, 0.0);

    glColor3f(0.0, 0.8, 0.0);
    glVertex3f(-200.0, $glyph->height(), 0.0);
    glVertex3f(200.0, $glyph->height(), 0.0);

    glVertex3f($glyph->width(), -200.0, 0.0);
    glVertex3f($glyph->width(), 200.0, 0.0);    

    glColor3f(0.8, 0.8, 0.0);
    glVertex3f($glyph->horizontal_advance(), -200.0, 0.0);
    glVertex3f($glyph->horizontal_advance(), 200.0, 0.0);
    
    glColor3f(0.8, 0.8, 1.0);
    glVertex3f($glyph->left_bearing(), -200.0, 0.0);
    glVertex3f($glyph->left_bearing(), 200.0, 0.0);

    glVertex3f($glyph->right_bearing(), -200.0, 0.0);
    glVertex3f($glyph->right_bearing(), 200.0, 0.0);

    glEnd();

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

    if ( $k eq 'q') { glutDestroyWindow( $WinID ) }
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