package Slack::BlockKit::BlockCollection;
use Moose;

use experimental qw(signatures); # XXX

use MooseX::Types::Moose qw(ArrayRef);
use Moose::Util::TypeConstraints qw(role_type);

has blocks => (
  isa => ArrayRef([ role_type('Slack::BlockKit::Role::Block') ]),
  traits  => [ 'Array' ],
  handles => { blocks => 'elements', block_count => 'count' },
);

sub BUILD ($self, @) {
  Carp::croak("a BlockCollection's list of blocks can't be empty")
    unless $self->block_count;
}

sub as_struct ($self) {
  return [ map {; $_->as_struct } $self->blocks ];
}

no Moose;
no MooseX::Types::Moose;
no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;
