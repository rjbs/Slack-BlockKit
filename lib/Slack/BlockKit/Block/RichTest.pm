package Slack::BlockKit::Block::RichText;
use Moose;
use MooseX::StrictConstructor;

use experimental qw(signatures); # XXX

has block_id => (is => 'ro', isa => 'Str', predicate => 'has_block_id');

has elements => (
  isa => 'ArrayRef', # <-- Make better
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

sub as_struct ($self) {
  return {
    type => 'rich_text',
    ($self->has_block_id ? (block_id => $self->block_id) : ()),
    elements => [ map {; $_->as_struct } $self->elements ],
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
