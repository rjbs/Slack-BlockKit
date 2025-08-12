package Slack::BlockKit::Block::Markdown;
# ABSTRACT: a Block Kit Markdown block

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::Block';

=head1 OVERVIEW

This object represents a "markdown" block.  These blocks only have one special
attribute: the text they display.

=cut

use v5.36.0;

use Moose::Util::TypeConstraints qw(class_type);

=attr text

The C<text> attribute must be a I<string>.  This is in contrast to most other
Block Kit blocks, where the C<text> attribute is a text composition object.
The Markdown block acts sort of like a text composition object, but it can't be
used as one.  It can only be used as a block in a section.

=cut

has text => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub as_struct ($self) {
  return {
    type  => 'markdown',
    text  => $self->text,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
