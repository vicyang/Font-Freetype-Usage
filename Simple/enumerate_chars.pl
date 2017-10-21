use Font::FreeType;

my $filename = "C:/Windows/Fonts/msyh.ttf";
my $face = Font::FreeType->new->face($filename);

$face->foreach_char(
    sub 
    {
        printf("%s\t%s\n", $_->char_code, $_->name) if (defined $_->name );
    }
);