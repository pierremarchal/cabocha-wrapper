package CaboCha::Wrapper::Chunk;

use Moose;
use MooseX::ClassAttribute;


# -- ATTRIBUTES --

class_has 'count' => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

has 'tree' => (
	is			=> 'ro',
	isa			=> 'CaboCha::Wrapper::Tree',
	required	=> 1,
	weak_ref    => 1,
);

has 'cabocha_chunk' => (
	is			=> 'ro',
	isa			=> 'CaboCha::Chunk',
	lazy		=> 1,
	builder		=> '_build_cabocha_chunk',
);

has 'tokens' => (
	is		=> 'ro',
	isa		=> 'ArrayRef[CaboCha::Wrapper::Token]',
	writer	=> '_tokens',
);

has 'index' => (
	is			=> 'ro',
	isa			=> 'Int',
	required	=> 1,
);

has 'token_count' => (
	is		=> 'ro',
	isa		=> 'Int',
	lazy	=> 1,
	builder	=> '_build_token_count',
);

has 'first_token_abs_index' => (
	is		=> 'ro',
	isa		=> 'Int',
	lazy	=> 1,
	builder	=> '_build_first_token_abs_index',
);

has 'last_token_abs_index' => (
	is		=> 'ro',
	isa		=> 'Int',
	lazy	=> 1,
	builder	=> '_build_last_token_abs_index',
);

has 'head_rel_index' => (
	is		=> 'ro',
	isa		=> 'Int',
	lazy	=> 1,
	builder	=> '_build_head_rel_index',
);

has 'head_abs_index' => (
	is		=> 'ro',
	isa		=> 'Int',
	lazy	=> 1,
	builder	=> '_build_head_abs_index',
);

has 'func_rel_index' => (
	is		=> 'ro',
	isa		=> 'Int',
	lazy	=> 1,
	builder	=> '_build_func_rel_index',
);

has 'func_abs_index' => (
	is		=> 'ro',
	isa		=> 'Int',
	lazy	=> 1,
	builder	=> '_build_func_abs_index',
);

has 'surface' => (
	is		=> 'ro',
	isa		=> 'Str',
	lazy	=> 1,
	builder	=> '_build_surface',
);

has 'head' => (
	is		=> 'ro',
	isa		=> 'CaboCha::Wrapper::Token',
	lazy	=> 1,
	builder	=> '_build_head',
);

has 'func' => (
	is		=> 'ro',
	isa		=> 'CaboCha::Wrapper::Token',
	lazy	=> 1,
	builder	=> '_build_func',
);

has 'score' => (
	is		=> 'ro',
	isa		=> 'Str',
	lazy	=> 1,
	builder	=> '_build_score',
);

has 'features' => (
	is		=> 'ro',
	isa		=> 'ArrayRef[Str|Undef]',
	lazy	=> 1,
	builder	=> '_build_features',
);

has 'has_governor' => (
	is		=> 'ro',
	isa		=> 'Bool',
	lazy	=> 1,
	builder	=> '_build_has_governor',
);

has 'has_dependents' => (
	is		=> 'ro',
	isa		=> 'Bool',
	lazy	=> 1,
	builder	=> '_build_has_dependents',	
);

has 'governor_index' => (
	is		=> 'ro',
	isa		=> 'Int',
	lazy	=> 1,
	builder	=> '_build_governor_index',
);

has 'dependent_indexes' => (
	is		=> 'ro',
	isa		=> 'ArrayRef[Int]',
	default	=> sub { [] },
	writer	=> '_dependent_indexes',
);

has 'governor' => (
	is		=> 'ro',
	isa		=> 'CaboCha::Wrapper::Chunk',
	lazy	=> 1,
	builder	=> '_build_governor',
	weak_ref    => 1,
);

has 'dependents' => (
	is		=> 'ro',
	isa		=> 'ArrayRef[CaboCha::Wrapper::Chunk]',
	lazy	=> 1,
	builder	=> '_build_dependents',
);

sub BUILD {
    $_[0]->count( $_[0]->count + 1 );
}

sub DEMOLISH {
    $_[0]->count( $_[0]->count - 1 );
}

# -- METHODS --

sub feature { $_[0]->features->[$_[1]]; }

sub token { $_[0]->tokens->[$_[1]] }

# -- BUILDERS --

sub _build_cabocha_chunk { $_[0]->tree->cabocha_tree->chunk($_[0]->index) }

sub _build_token_count { $_[0]->cabocha_chunk->swig_token_size_get }

sub _build_first_token_abs_index { $_[0]->cabocha_chunk->swig_token_pos_get }

sub _build_last_token_abs_index { $_[0]->first_token_abs_index + $_[0]->token_count - 1 }

sub _build_head_rel_index { $_[0]->cabocha_chunk->swig_head_pos_get }

sub _build_head_abs_index { $_[0]->cabocha_chunk->swig_token_pos_get + $_[0]->head_rel_index }

sub _build_func_rel_index { $_[0]->cabocha_chunk->swig_func_pos_get }

sub _build_func_abs_index { $_[0]->cabocha_chunk->swig_token_pos_get + $_[0]->func_rel_index }

sub _build_score { $_[0]->cabocha_chunk->swig_score_get }

sub _build_surface { 
    join '', map { $_->surface } @{ $_[0]->tokens };
}

sub _build_head { $_[0]->tokens->[ $_[0]->head_rel_index ] }

sub _build_func { $_[0]->tokens->[ $_[0]->func_rel_index ] }

sub _build_features {
	my $ra_features = [];
	push @$ra_features, map {
		m/\*|^$/ ? undef : $_;
	} map {
		$_[0]->cabocha_chunk->feature_list($_)
	} 0..$_[0]->cabocha_chunk->swig_feature_list_size_get;
	return $ra_features;
}

sub _build_has_governor { $_[0]->governor_index != -1 ? 1 : 0 }

sub _build_has_dependents { @{ $_[0]->dependent_indexes } > 0 ? 1 : 0 }

sub _build_governor_index { $_[0]->cabocha_chunk->swig_link_get }

sub _build_governor { $_[0]->governor_index == -1 ? undef : $_[0]->tree->chunk($_[0]->governor_index) };

sub _build_dependents {
	my $ra_dependents = [];
	push @$ra_dependents, map {
		$_[0]->tree->chunk($_);
	} @{ $_[0]->dependent_indexes };
	return $ra_dependents;
} 


__PACKAGE__->meta->make_immutable;
no Moose;
no MooseX::ClassAttribute;

1;

