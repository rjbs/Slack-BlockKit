package Slack::BlockKit::Block::RichText::List;
# ABSTRACT: a BlockKit rich text list element
use Moose;
use MooseX::StrictConstructor;

use Moose::Util::TypeConstraints qw(class_type enum);
use MooseX::Types::Moose qw(ArrayRef);
use Slack::BlockKit::Types qw(Pixels RichTextArray);

=head1 OVERVIEW

This represents a rich text list, which will be rendered as either a bullet or
numbered list.

=cut

use v5.36.0;

=attr elements

This must be an arrayref of L<rich text
section|Slack::BlockKit::Block::RichText::Section> objects.  Each section will
be one item in the list.

=cut

has elements => (
  isa => RichTextArray(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

=attr indent

This optional attribute is a count of pixels to indent the list.  The author
has never managed to use this successfully.

=attr offset

This optional attribute is a count of pixels to offset the list.  The author
has never managed to use this successfully.

=attr border

This optional attribute is a count of pixels for the list's border width.  The
author has never managed to use this successfully.

=cut

# I don't know how to use these successfully. -- rjbs, 2024-06-29
my @PX_PROPERTIES = qw(indent offset border);
for my $name (@PX_PROPERTIES) {
  has $name => (
    is => 'ro',
    isa => Pixels(),
    predicate => "has_$name",
  );
}

=attr style

This required attribute is I<not> the text style, but the list style.  It may
be either C<bullet> or C<ordered>.

=cut

has style => (
  is  => 'ro',
  isa => enum([ qw(bullet ordered) ]),
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'rich_text_list',
    elements => [ map {; $_->as_struct } $self->elements ],
    style => $self->style,

    (map {; my $p = "has_$_"; ($self->$p ? ($_ => $self->$_) : ()) }
      @PX_PROPERTIES)
  };
}

no Moose::Util::TypeConstraints;
no Moose;
__PACKAGE__->meta->make_immutable;
