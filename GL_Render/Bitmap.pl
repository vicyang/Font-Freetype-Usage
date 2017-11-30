=info
    逐点绘制字符点阵
    如果开启 GLUT_MULTISAMPLE，会造成字符走样
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

    my ($filename, $char, $size) = ("C:/windows/fonts/arial.ttf", 'Q', 50);
    my $dpi = 100;

    our $face = Font::FreeType->new->face($filename);
    $face->set_char_size($size, $size, $dpi, $dpi);

    our $glyph = $face->glyph_from_char($char);
    die "No glyph for character '$char'.\n" if (! $glyph);

    our ($bitmap, $left, $top) = $glyph->bitmap();
    our ($rx, $ry, $rz) = (0.0, 0.0, 0.0);
}

&main();

sub display 
{
    state $iter = 0;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    #glRectf(0.0,0.0,100.0,100.0);

    glPushMatrix();
    glRotatef($rx, 1.0, 0.0, 0.0);
    glRotatef($ry, 0.0, 1.0, 0.0);
    glRotatef($rz, 0.0, 0.0, 1.0);

    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_POINTS);
    my @ele;
    for my $r ( 0..$#$bitmap )
    {
        @ele = map { ord($_)/255.0 } split("", $bitmap->[$r]  );
        for my $c ( 0 .. $#ele )
        {
            glColor3f( $ele[$c], $ele[$c], $ele[$c] );
            glVertex3f($c, -$r, 0.0);
        }
    }
    glEnd();

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
    glPointSize(1.0);
    glLineWidth(1.0);
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_POINT_SMOOTH);
    glEnable(GL_LINE_SMOOTH);
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
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE |GLUT_DEPTH );
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