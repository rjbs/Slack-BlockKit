package Slack::BlockKit::Block::RichText::Channel;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasMentionStyle';

use v5.36.0;

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
