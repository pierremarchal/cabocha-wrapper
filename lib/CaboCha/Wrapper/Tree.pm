package CaboCha::Wrapper::Tree;

use Moose;
use MooseX::ClassAttribute;

class_has 'count' => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);


has 'cabocha_tree' => (
	is			=> 'ro',
	isa			=> 'CaboCha::Tree',
	required	=> 1,
);

has 'surface' => (
	is		=> 'ro',
	isa		=> 'Str',
	lazy    => 1,
    builder	=> '_build_surface',
);

has 'chunks' => (
	is		=> 'ro',
	isa		=> 'ArrayRef[CaboCha::Wrapper::Chunk]',
	writer	=> '_chunks',
);

has 'tokens' => (
	is		=> 'ro',
	isa		=> 'ArrayRef[CaboCha::Wrapper::Token]',
	writer	=> '_tokens',
);

has 'chunk_count' => (
	is		=> 'ro',
	isa 	=> 'Int',
	lazy	=> 1,
	builder	=> '_build_chunk_count',
);

has 'token_count' => (
	is		=> 'ro',
	isa 	=> 'Int',
	lazy	=> 1,
	builder	=> '_build_token_count',
);


# -- BUILD --

sub BUILD {

	my ($self,$args) = @_;
	my $cabocha_tree = $args->{'cabocha_tree'};
	
	my $ra_tree_chunks = [];
	my $ra_tree_tokens = [];
	
	# K: governor; V: dependents
	my %dependencies = ();
	
	for( my $i = 0 ; $i < $self->chunk_count ; $i++ ){
	
		my $chunk = CaboCha::Wrapper::Chunk->new( 'tree' => $self, 'index' => $i );
		push @{ $dependencies{ $chunk->governor_index } }, $i;
		
		my $ra_chunk_tokens = [];
		
		for( my $j = $chunk->first_token_abs_index ; $j <= $chunk->last_token_abs_index ; $j++ ){
		
			my $token = CaboCha::Wrapper::Token->new(
				'tree'	=> $self,
				'chunk'	=> $chunk,
				'rel_index'	=> $j - $chunk->first_token_abs_index,
				'abs_index'	=> $j,
			);
			
			push @$ra_chunk_tokens, $token;
		} 
	
		$chunk->_dependent_indexes( $dependencies{$i} ) if exists $dependencies{$i};
		$chunk->_tokens($ra_chunk_tokens);
	
		push @$ra_tree_tokens, @$ra_chunk_tokens;
		push @$ra_tree_chunks, $chunk;
	}

	$self->_chunks($ra_tree_chunks);
	$self->_tokens($ra_tree_tokens);
	$_[0]->count( $_[0]->count + 1 );
}

sub DEMOLISH {
    $_[0]->count( $_[0]->count - 1 );
}


# -- METHODS --

sub token { $_[0]->tokens->[$_[1]] }

sub chunk { $_[0]->chunks->[$_[1]] }

sub to_string { $_[0]->cabocha_tree->toString($_[1]) }


# -- BUILDERS --

sub _build_surface { $_[0]->cabocha_tree->sentence; }

sub _build_chunk_count { $_[0]->cabocha_tree->chunk_size }

sub _build_token_count { $_[0]->cabocha_tree->token_size }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

