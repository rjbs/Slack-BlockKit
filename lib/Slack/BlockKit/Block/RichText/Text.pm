package Slack::BlockKit::Block::RichText::Text;
# ABSTRACT: a Block Kit rich text object for the text in the rich text

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasBasicStyle';

=head1 OVERVIEW

When building a hunk of rich text with Slack::BlockKit, it's this object that
contains most of the actual text.  These objects represent the objects in
Block Kit with a C<type> of "text".

This class includes L<Slack::BlockKit::Role::HasBasicStyle>, so these objects
can have C<bold>, C<code>, C<italic>, and C<strike> styles.

(For more information on how to actually build text look at
L<Slack::BlockKit::Sugar>.)

=cut

use v5.36.0;

=attr text

This is the actual text of the text object.  It's a string, and required.

=cut

has text => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'text',
    text => q{} . $self->text,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
