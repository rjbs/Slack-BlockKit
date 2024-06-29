package Slack::BlockKit::Block::RichText::Text;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasStyle';

use experimental qw(signatures); # XXX

has text => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'text',
    text => $self->text,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
