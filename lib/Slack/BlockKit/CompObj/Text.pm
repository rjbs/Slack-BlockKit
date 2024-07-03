package Slack::BlockKit::CompObj::Text;
# ABSTRACT: a BlockKit "composition object" for text
use Moose;
use MooseX::StrictConstructor;

use Moose::Util::TypeConstraints qw(enum);

with 'Slack::BlockKit::Role::Block';

=head1 OVERVIEW

This is the text "composition object", which is used for non-rich text values
in several places in BlockKit.

=cut

use v5.36.0;

=attr type

This required attribute must be either C<plain_text> or C<mrkdwn>, and
instructs Slack how to interpret the text attribute.

=cut

has type => (
  is => 'ro',
  isa => enum([ qw( plain_text mrkdwn ) ]),
  required => 1,
);

=attr text

This is the string that is the text of the text object.  There are length
constraints enforced by Slack I<but not by this code>.  Be mindful of those.

=cut

has text => (
  is  => 'ro',
  isa => 'Str', # add length requirements, mayyyybe
  required => 1,
);

=attr emoji

This optional boolean option can determine whether emoji colon-codes are
expanded within a C<plain_text> text object.  Using this attribute on a
C<mrkdwn> object will raise an exception.

=cut

has emoji => (
  is => 'ro',
  isa => 'Bool',
  predicate => 'has_emoji',
);

=attr verbatim

This optional boolean option can determine whether hyperlinks should be left
unlinked within a C<mrkdown> text object.  Using this attribute on a
C<plain_text> object will raise an exception.

=cut

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
    text => q{} . $self->text,
    ($self->has_emoji     ? (emoji    => Slack::BlockKit::boolify($self->emoji))   : ()),
    ($self->has_verbatim  ? (verbatim => Slack::BlockKit::boolify($self->verbatim)) : ()),
  };
}

no Moose;
no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;
