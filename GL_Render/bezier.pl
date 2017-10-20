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

sub display 
{
    state $iter = 0;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    #glRectf(0.0,0.0,100.0,100.0);

    my $parts;
    my @pta = (-100.0, 0.0  );
    my @ptb = (   0.0, 100.0);
    my @ptc = ( 100.0, 0.0  );

    glPushMatrix();
    glRotatef($rx, 1.0, 0.0, 0.0);
    glRotatef($ry, 0.0, 1.0, 0.0);
    glRotatef($rz, 0.0, 0.0, 1.0);

    $parts = 20.0;
    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_POINTS);
    for (my $step = 0.0; $step <= $parts; $step+=1.0)
    {
        my $t = $step/$parts;
        ($x1, $y1) = pointOnLine( @pta, @ptb, $t );
        glVertex3f( $x1, $y1, 0.0 );
        ($x2, $y2) = pointOnLine( @ptb, @ptc, $t );
        glVertex3f( $x2, $y2, 0.0 );
        ($x, $y) = pointOnLine( $x1, $y1, $x2, $y2, $t );
        glVertex3f( $x, $y, 0.0 );
    }
    glEnd();

    glTranslatef(0.0, -10.0, 0.0);
    $parts = 5.0;
    glBegin(GL_LINE_STRIP);
    for (my $step = 0.0; $step <= $parts; $step+=1.0)
    {
        my $t = $step/$parts;
        ($x, $y) = pointOnQuadBezier( @pta, @ptb, @ptc, $t );
        glVertex3f( $x, $y, 0.0 );
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