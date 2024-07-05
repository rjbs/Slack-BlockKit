package Slack::BlockKit::Block::RichText::Emoji;
# ABSTRACT: a Block Kit rich text element for a :colon_code: emoji

use Moose;
use MooseX::StrictConstructor;

=head1 OVERVIEW

This represents an C<emoji> element in Block Kit, which are generally put in
place of or between L<text|Slack::BlockKit::Block::RichText::Text> elements in
rich text sections.

=cut

use v5.36.0;

=attr name

This is the only notable attribute of an Emoji element.  It's the name of the
emoji, as you'd type it in Slack, except without the outer colons.  So C<adult>
rather than C<:adult:> and C<adult::skin-tone-4> rather than
C<:adult::skin-tone-4:>.

At time of writing, unknown emoji names are not an error, but will be displayed
as text inside colons.

=cut

has name => (
  is  => 'ro',
  isa => 'Str', # Unknown names show up as ":bogus_name_here:"
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'emoji',
    name => $self->name,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
