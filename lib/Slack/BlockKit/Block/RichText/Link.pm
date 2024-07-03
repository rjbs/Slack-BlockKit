package Slack::BlockKit::Block::RichText::Link;
# ABSTRACT: a BlockKit rich text hyperlink element

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasBasicStyle';

=head1 OVERVIEW

This represents a hyperlink element in rich text in BlockKit.

=cut

use v5.36.0;

=attr url

This is the URL to which the link links.

=cut

has url => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

=attr text

This is the text displayed for the link.  It's optional, and Slack will display
the URL if no text was given.

This attribute stores a string, not any form of BlockKit text object.

=cut

has text => (
  is  => 'ro',
  isa => 'Str',
  predicate => 'has_text',
);

=attr unsafe

This is a boolean indicating whether the link is unsafe.  The author has not
figured out what this actually I<does> and so never uses it.

=cut

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
