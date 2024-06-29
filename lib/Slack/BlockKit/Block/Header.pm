package Slack::BlockKit::Block::Header;
use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::Block';

use experimental qw(signatures); # XXX

use Moose::Util::TypeConstraints qw(class_type);

has text => (
  is  => 'ro',
  isa => class_type('Slack::BlockKit::CompObj::Text'),
  required => 1,
);

sub BUILD ($self, @) {
  if ($self->text->type ne 'plain_text') {
    Carp::croak("non-plain_text text object provided to header");
  }
}

sub as_struct ($self) {
  return {
    type  => 'header',
    text  => $self->text->as_struct,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
