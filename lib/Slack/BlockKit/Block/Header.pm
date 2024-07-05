package Slack::BlockKit::Block::Header;
# ABSTRACT: a Block Kit header block

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::Block';

=head1 OVERVIEW

This object represents a "header" block.  These blocks only have one special
attribute: the text they display.

=cut

use v5.36.0;

use Moose::Util::TypeConstraints qw(class_type);

=attr text

The C<text> attribute must be a L<text object|Slack::BlockKit::CompObj::Text>
with the text that will be displayed in the header.  The C<type> of that object
must be C<plain_text>, not C<mrkdwn>.

=cut

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
