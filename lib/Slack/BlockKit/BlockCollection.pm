package Slack::BlockKit::BlockCollection;
# ABSTRACT: a collection of Block Kit blocks
use Moose;

=head1 OVERVIEW

This is the very top level "array of Block Kit blocks" object that exists
mostly to serve as a container for the blocks that are your real message.  You
don't exactly need it, but its C<< ->as_struct >> method will collect all the
structs created by its contained blocks, so it's easy to pass around as "the
thing that gets sent to Slack".

=cut

use v5.36.0;

use MooseX::Types::Moose qw(ArrayRef);
use Moose::Util::TypeConstraints qw(role_type);

=attr blocks

This is an arrayref of objects that implement L<Slack::BlockKit::Role::Block>.
It must be defined and non-empty, or an exception will be raised.

=cut

has blocks => (
  isa => ArrayRef([ role_type('Slack::BlockKit::Role::Block') ]),
  traits  => [ 'Array' ],
  handles => { blocks => 'elements', block_count => 'count' },
  predicate => '_has_blocks',
);

sub BUILD ($self, @) {
  Carp::croak("a BlockCollection's list of blocks can't be empty")
    unless $self->_has_blocks and $self->block_count;
}

sub as_struct ($self) {
  return [ map {; $_->as_struct } $self->blocks ];
}

sub TO_JSON ($self) {
  return $self->as_struct;
}

no Moose;
no MooseX::Types::Moose;
no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;
