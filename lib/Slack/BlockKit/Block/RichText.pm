package Slack::BlockKit::Block::RichText;
# ABSTRACT: the top-level rich text block in Block Kit

use Moose;
use MooseX::StrictConstructor;
use Slack::BlockKit::Types qw(RichTextBlocks);

=head1 OVERVIEW

The RichText block is pretty boring, but must exist to contain all the other
rich text object:

=for :list
* L<User        |Slack::BlockKit::Block::RichText::User>
* L<Link        |Slack::BlockKit::Block::RichText::Link>
* L<UserGroup   |Slack::BlockKit::Block::RichText::UserGroup>
* L<List        |Slack::BlockKit::Block::RichText::List>
* L<Channel     |Slack::BlockKit::Block::RichText::Channel>
* L<Emoji       |Slack::BlockKit::Block::RichText::Emoji>
* L<Quote       |Slack::BlockKit::Block::RichText::Quote>
* L<Preformatted|Slack::BlockKit::Block::RichText::Preformatted>
* L<Section     |Slack::BlockKit::Block::RichText::Section>
* L<Text        |Slack::BlockKit::Block::RichText::Text>

As usual, these classes are I<lightly> documented in the Slack::BlockKit
distribution, but to really understand how they're meant to be used, see the
Slack Block Kit documentation on Slack.

=cut

with 'Slack::BlockKit::Role::Block';

use v5.36.0;

=attr elements

This must be an arrayref of the kinds of objects that are permitted within a
rich test block:

=for :list
* L<List        |Slack::BlockKit::Block::RichText::List>
* L<Quote       |Slack::BlockKit::Block::RichText::Quote>
* L<Preformatted|Slack::BlockKit::Block::RichText::Preformatted>
* L<Section     |Slack::BlockKit::Block::RichText::Section>

=cut

has elements => (
  isa => RichTextBlocks(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

sub as_struct ($self) {
  return {
    type => 'rich_text',
    elements => [ map {; $_->as_struct } $self->elements ],
  };
}

no Slack::BlockKit::Types;
no Moose;
__PACKAGE__->meta->make_immutable;
