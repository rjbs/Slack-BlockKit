package Slack::BlockKit::Block::Section;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::Block';

use experimental qw(signatures); # XXX

use Moose::Util::TypeConstraints qw(class_type);
use MooseX::Types::Moose qw(ArrayRef);

# I have intentionally omitted "accessory" for now.

has text => (
  is  => 'ro',
  isa => class_type('Slack::BlockKit::CompObj::Text'),
  predicate => 'has_text',
);

has fields => (
  isa => ArrayRef([ class_type('Slack::BlockKit::CompObj::Text') ]),
  predicate => 'has_fields',
  traits    => [ 'Array' ],
  handles   => { fields => 'elements' },
);

sub BUILD ($self, @) {
  Carp::croak("neither text nor fields provided in Slack::BlockKit::Block::Section construction")
    unless $self->has_text or $self->has_fields;

  Carp::croak("both text and fields provided in Slack::BlockKit::Block::Section construction")
    if $self->has_text and $self->has_fields;
}

sub as_struct ($self) {
  return {
    type => 'section',
    ($self->has_text
      ? (text => $self->text->as_struct)
      : ()),
    ($self->has_fields
      ? (fields => [ map {; $_->as_struct } $self->fields ])
      : ()),
  };
}

no Moose;
no Moose::Util::TypeConstraints;
no MooseX::Types::Moose;
__PACKAGE__->meta->make_immutable;
