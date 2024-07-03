package Slack::BlockKit::Block::Section;
# ABSTRACT: a BlockKit section block, used to collect text

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::Block';

=head1 OVERVIEW

This represents a C<section> block, which is commonly used to contain text to
be sent.  Don't confuse this class with L<Slack::BlockKit::Block::RichText> or
L<Slack::BlockKit::Block::RichText::Section>, which are used to present I<rich>
text.  A "normal" section block can only present rich text in the form of
C<mrkdwn>-type text objects.

=cut

use v5.36.0;

use Moose::Util::TypeConstraints qw(class_type);
use MooseX::Types::Moose qw(ArrayRef);

# I have intentionally omitted "accessory" for now.

=attr text

This is a L<text composition object|Slack::BlockKit::CompObj::Text> with the
text to be displayed in this block.

If you provide C<text>, then providing C<fields> is an error and will cause an
exception to be raised.

=cut

has text => (
  is  => 'ro',
  isa => class_type('Slack::BlockKit::CompObj::Text'),
  predicate => 'has_text',
);

=attr fields

This is a an arrayref of L<text composition
object|Slack::BlockKit::CompObj::Text> with the text to be displayed in this
block.  These objects will be displayed in two columns, generally.

If you provide C<fields>, then providing C<text> is an error and will cause an
exception to be raised.

=cut

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
