package Slack::BlockKit::Block::Context;
# ABSTRACT: a Block Kit context block, used to collect images and text

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::Block';

=head1 OVERVIEW

This represents a C<context> block, which is commonly used to contain text to
be sent.  Don't confuse this class with L<Slack::BlockKit::Block::RichText> or
L<Slack::BlockKit::Block::RichText::Section>, which are used to present I<rich>
text.  A "normal" section block can only present rich text in the form of
C<mrkdwn>-type text objects.

A C<context> block is similar to a C<section> block, but can contain images.
Also, it seems like a C<section> block is a bit smaller, textwise?  It's a bit
of a muddle.

=cut

use v5.36.0;

use Moose::Util::TypeConstraints qw(class_type);
use MooseX::Types::Moose qw(ArrayRef);

use Slack::BlockKit::Types qw(ContextElementList);

=attr elements

This must be an arrayref of element objects, of either text or image types.
(At present, though, Slack::BlockKit does not support image elements.)

=cut

has elements => (
  isa => ContextElementList(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

sub as_struct ($self) {
  return {
    type => 'context',
    elements => [ map {; $_->as_struct } $self->elements ],
  }
}

no Moose;
no Moose::Util::TypeConstraints;
no MooseX::Types::Moose;
__PACKAGE__->meta->make_immutable;
