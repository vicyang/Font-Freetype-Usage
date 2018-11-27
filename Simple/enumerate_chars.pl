use Font::FreeType;
use Encode;
use File::Slurp;
use File::Basename qw/basename/;

my $buff = "";
my $ft = "trebuc";
my $filename = "C:/Windows/Fonts/${ft}.ttf";
my $face = Font::FreeType->new->face($filename);
my $iter = 0;

$face->foreach_char(
    sub 
    {
        if (defined $_->name )
        {
            printf "%d\t%s\n", $_->char_code, $_->name;
            $buff .= encode('utf8', chr($_->char_code));
            $buff .="\n" if $iter++ % 80 == 0;
        }
        else
        {
            printf "Out: %s\n", $_->char_code;
        }
    }
);

write_file( basename(__FILE__, ".pl") ."_${ft}.txt" , $buff );
