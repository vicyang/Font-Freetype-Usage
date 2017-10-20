=info
    提取Outlines(轮廓信息)
=cut

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

    my ($filename, $char, $size) = ("C:/windows/fonts/arial.ttf", 'R', 100);
    my $dpi = 100;

    our $face = Font::FreeType->new->face($filename);
    $face->set_char_size($size, $size, $dpi, $dpi);

    our $glyph = $face->glyph_from_char($char);
    die "No glyph for character '$char'.\n" if (! $glyph);

    # $glyph->outline_decompose(
    #     move_to  => sub { printf "move_to: %f\n", $_[0] },
    #     line_to  => sub { printf "line_to: %f\n", $_[0] },
    #     conic_to => sub { printf "conic_to: %f\n", $_[0] },
    #     cubic_to => sub { printf "cubic_to: %f\n", $_[0] },
    # );

    print $glyph->svg_path();
}


&main();

sub display 
{
    state $iter = 0;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    #glRectf(0.0,0.0,100.0,100.0);

    #random
    #$glyph = $face->glyph_from_char( ('A'..'Z')[rand(26)] ) if ($iter % 20 == 1);

    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_POINTS);
    $glyph->outline_decompose(
        move_to  => sub { glColor3f(1.0, 0.2, 0.2); glVertex3f( $_[0], $_[1], 0.0) },
        line_to  => sub { glColor3f(0.0, 1.0, 0.0); glVertex3f( $_[0], $_[1], 0.0) },
        conic_to => sub { glColor3f(0.5, 0.5, 1.0); glVertex3f( $_[0], $_[1], 0.0) },
        cubic_to => sub { glColor3f(1.0, 1.0, 1.0); glVertex3f( $_[0], $_[1], 0.0) }
    );
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