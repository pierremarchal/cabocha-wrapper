package CaboCha::Wrapper::Parser;

use Moose;
use Data::Dumper;

has 'args' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 0,
    default     => q{},
);


has 'parser' => (
    is      => 'ro',
    isa     => 'CaboCha::Parser',
    writer  => '_parser',
);


sub BUILD {
    my $self = shift;
    $self->_parser(CaboCha::Parser->new($self->args));
    return $self;
}

sub cabocha_version { CaboChac::Parser_version }

sub parse_to_string {
    my $self = shift;
    return $self->parser->parseToString(@_);
}

sub parse {
    my $self = shift;
    my $tree = $self->parser->parse(@_);
    return CaboCha::Wrapper::Tree->new( 'cabocha_tree' => $tree );
}


1;

