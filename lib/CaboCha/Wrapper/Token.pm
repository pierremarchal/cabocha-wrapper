package CaboCha::Wrapper::Token;

use Moose;
use MooseX::ClassAttribute;

class_has 'count' => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

# -- ATTRIBUTES --

has 'tree' => (
    is          => 'ro',
    isa         => 'CaboCha::Wrapper::Tree',
    required    => 1,
    weak_ref    => 1,
);

has 'chunk' => (
    is          => 'ro',
    isa         => 'CaboCha::Wrapper::Chunk',
    required    => 1,
    weak_ref    => 1,
);

has 'cabocha_token' => (
    is          => 'ro',
    isa         => 'CaboCha::Token',
    lazy        => 1,
    builder     => '_build_cabocha_token',
);

has 'rel_index' => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

has 'abs_index' => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

has 'ne' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder =>  '_build_ne',
);

has 'surface' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder =>  '_build_surface',
);

has 'features' => (
    is      => 'ro',
    isa     => 'ArrayRef[Str|Undef]',
    lazy    => 1,
    builder => '_build_features',
);

has 'is_head' => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    builder => '_build_is_head',
);

has 'is_func' => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    builder => '_build_is_func',
);

sub BUILD {
    $_[0]->count( $_[0]->count + 1 );
}

sub DEMOLISH {
    $_[0]->count( $_[0]->count - 1 );
}


# -- METHODS --

sub feature { $_[0]->features->[$_[1]] }

# swig_feature_get: renvoie la liste d’attributs sous forme de String
sub features_to_string {
    my $separator = defined $_[1] ? $_[1] : ',';
    join $separator, @{ $_[0]->features }
}

# -- BUILDERS --

sub _build_cabocha_token { $_[0]->tree->cabocha_tree->token($_[0]->abs_index) } 

sub _build_is_head { $_[0]->chunk->cabocha_chunk->swig_head_pos_get == $_[0]->rel_index ? 1 : 0 }

sub _build_is_func { $_[0]->chunk->cabocha_chunk->swig_func_pos_get == $_[0]->rel_index ? 1 : 0 }

sub _build_ne { $_[0]->cabocha_token->swig_ne_get }

sub _build_surface { $_[0]->cabocha_token->swig_normalized_surface_get }

sub _build_features {
    my $ra_features = [];
    push @$ra_features, map {
        $_[0]->cabocha_token->feature_list($_)
    } 0..$_[0]->cabocha_token->swig_feature_list_size_get - 1;
    return $ra_features;
}

__PACKAGE__->meta->make_immutable;
no Moose;


1;

