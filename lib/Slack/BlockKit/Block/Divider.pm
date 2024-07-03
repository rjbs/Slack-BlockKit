package Slack::BlockKit::Block::Divider;
# ABSTRACT: a BlockKit "divider" block
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::Block';

=head1 OVERVIEW

This is possibly the simplest block in BlockKit.  It's a divider.  It has no
attributes other than its type and optionally its block id.

=cut

use v5.36.0;

sub as_struct ($self) {
  return {
    type => 'divider',
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
