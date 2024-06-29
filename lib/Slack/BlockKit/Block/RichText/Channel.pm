package Slack::BlockKit::Block::RichText::Channel;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasStyle';

use experimental qw(signatures); # XXX

has channel_id => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'channel',
    channel_id => $self->channel_id,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
