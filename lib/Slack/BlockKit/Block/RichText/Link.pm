package Slack::BlockKit::Block::RichText::Link;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasBasicStyle';

use v5.36.0;

has url => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

has text => (
  is  => 'ro',
  isa => 'Str',
  predicate => 'has_text',
);

has unsafe => (
  is  => 'ro',
  isa => 'Bool',
  predicate => 'has_unsafe',
);

sub as_struct ($self) {
  return {
    type => 'link',

    ($self->has_text    ? (text   => q{} . $self->text) : ()),
    ($self->has_unsafe  ? (unsafe => Slack::BlockKit::boolify($self->unsafe))  : ()),
    url => $self->url,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
