use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'CaboCha::Wrapper',
    VERSION_FROM    => 'lib/CaboCha/Wrapper.pm',
    AUTHOR          => 'Pierre Marchal <pierre.marchal@inalco.fr>',
    PREREQ_PM       => {
        'CaboCha' => 0,
    },
);


