package Slack::BlockKit::CompObj::Text;
use Moose;
use MooseX::StrictConstructor;

use Moose::Util::TypeConstraints qw(enum);

with 'Slack::BlockKit::Role::Block';

use experimental qw(signatures); # XXX

has type => (
  is => 'ro',
  isa => enum([ qw( plain_text mrkdwn ) ]),
  required => 1,
);

has text => (
  is  => 'ro',
  isa => 'Str', # add length requirements, mayyyybe
  required => 1,
);

has emoji => (
  is => 'ro',
  isa => 'Bool',
  predicate => 'has_emoji',
);

has verbatim => (
  is => 'ro',
  isa => 'Bool',
  predicate => 'has_verbatim',
);

sub BUILD ($self, @) {
  Carp::croak("can't use 'emoji' with text composition object of type 'mrkdwn'")
    if $self->type eq 'mrkdwn' and $self->has_emoji;

  Carp::croak("can't use 'verbatim' with text composition object of type 'plain_text'")
    if $self->type eq 'plain_text' and $self->has_verbatim;
}

sub as_struct ($self) {
  return {
    type => $self->type, # (not the object type, as with a block element)
    text => $self->text,
    ($self->has_emoji     ? (emoji    => Slack::BlockKit::boolify($self->emoji))   : ()),
    ($self->has_verbatim  ? (verbatim => Slack::BlockKit::boolify($self->verbatim)) : ()),
  };
}

no Moose;
no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;
