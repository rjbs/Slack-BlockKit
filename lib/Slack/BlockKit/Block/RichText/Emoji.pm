package Slack::BlockKit::Block::RichText::Emoji;
use Moose;
use MooseX::StrictConstructor;

use v5.36.0;

has name => (
  is  => 'ro',
  isa => 'Str', # Unknown names show up as ":bogus_name_here:"
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'emoji',
    name => $self->name,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
