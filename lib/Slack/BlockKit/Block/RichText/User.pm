package Slack::BlockKit::Block::RichText::User;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasStyle';

use experimental qw(signatures); # XXX

has user_id => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'user',
    user_id => $self->user_id,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
