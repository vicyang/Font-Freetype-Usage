use Font::FreeType;

my $filename = "C:/Windows/Fonts/msyh.ttf";
my $face = Font::FreeType->new->face($filename);

$face->foreach_char(
    sub 
    {
        if (defined $_->name )
        {
            printf("%d\t%s\n", $_->char_code, $_->name);
        }
        else
        {
            printf("%s\n", $_->char_code);
        }
    }
);