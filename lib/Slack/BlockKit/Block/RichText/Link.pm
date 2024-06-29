package Slack::BlockKit::Block::RichText::Link;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasStyle';

use experimental qw(signatures); # XXX

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

my sub boolify ($val) { $val ? \1 : \0 }

sub as_struct ($self) {
  return {
    type => 'link',

    ($self->has_text    ? (text   => $self->text)             : ()),
    ($self->has_unsafe  ? (unsafe => boolify($self->unsafe))  : ()),
    url => $self->url,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
