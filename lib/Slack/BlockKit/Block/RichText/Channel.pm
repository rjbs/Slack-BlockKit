package Slack::BlockKit::Block::RichText::Channel;
# ABSTRACT: a BlockKit rich text element that mentions a #channel

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasMentionStyle';

=head1 OVERVIEW

This represents the mention of a specific Slack channel in a hunk of rich text.
The channel name will be styled and linked-to.  So, to send something like:

    We are discussing this on <#kerfuffles>.

You would use the L<sugar|Slack::BlockKit::Sugar> like so:

    blocks(richtext(section(
      "We are discussing this on ", channel($channel_id), "."
    )));

=cut

use v5.36.0;

=attr channel_id

This must be the Slack channel id for the channel being mentioned.  This is
generally a bunch of alphanumeric characters beginning with C<C>.

=cut

has channel_id => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'channel',
    channel_id => $self->channel_id,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
