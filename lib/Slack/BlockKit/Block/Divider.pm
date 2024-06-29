package Slack::BlockKit::Block::Divider;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::Block';

use experimental qw(signatures); # XXX

sub as_struct ($self) {
  return {
    type => 'divider',
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
