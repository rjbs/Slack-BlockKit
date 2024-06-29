package Slack::BlockKit::Block::RichText::UserGroup;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasMentionStyle';

use experimental qw(signatures); # XXX

has usergroup_id => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'usergroup',
    usergroup_id => $self->usergroup_id,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
