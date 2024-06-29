package Slack::BlockKit::Role::Block;
use Moose::Role;

use experimental qw(signatures); # XXX

has block_id => (
  is  => 'ro',
  isa => 'Str',
  predicate => 'has_block_id',
);

requires 'as_struct';

around as_struct => sub ($orig, $self, @rest) {
  my $struct = $self->$orig(@rest);

  if ($self->has_block_id) {
    $struct->{block_id} = $self->block_id;
  }

  return $struct;
};

no Moose::Role;
1;
