package Slack::BlockKit::Block::RichText::Link;
# ABSTRACT: a Block Kit rich text hyperlink element

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasBasicStyle';

=head1 OVERVIEW

This represents a hyperlink element in rich text in Block Kit.

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

This attribute stores a string, not any form of Block Kit text object.

=cut

has text => (
  is  => 'ro',
  isa => 'Str',
  predicate => 'has_text',
);

=attr unsafe

This is a boolean indicating whether the link is unsafe.

When set to true, this disables Slack's automatic URL sanitization. This allows
the use of non-standard URI schemes or custom protocols, which Slack's default
security measures would typically prevent.

It's called "unsafe" because it bypasses these default safety checks, so it
should be used with caution and only when you're confident in the integrity of
the URI you're providing.

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
