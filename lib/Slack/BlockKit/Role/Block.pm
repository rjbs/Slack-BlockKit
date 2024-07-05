package Slack::BlockKit::Role::Block;
# ABSTRACT: a Block Kit block object

use Moose::Role;

use v5.36.0;

=head1 OVERVIEW

This role is composed by any "block" in Block Kit.  The definition of what is
or isn't a block is not well defined, but here it means "anything that can be
turned into a struct and has an optional C<block_id> attribute".

=attr block_id

This is an optional string, which will become the C<block_id> of this object in
the emitted structure.

=cut

has block_id => (
  is  => 'ro',
  isa => 'Str',
  predicate => 'has_block_id',
);

=method as_struct

All classes composing Block must provide an C<as_struct> method.  Its result is
decorated so that the C<block_id> of this block, if any, is added to the
returned structure.

=cut

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
