package Slack::BlockKit::Types;
# ABSTRACT: Moose type constraints used internally by Slack::Block Kit
use v5.36.0;

=head1 OVERVIEW

This library has some types used by Slack::BlockKit.  Generally, you shouldn't
need to think about them, and they're not being documented, so that they can be
rejiggered whenever convenient.  You can always read the source!

=cut

use MooseX::Types -declare => [qw(
  RichTextBlocks
  ExpansiveElementList
  ContextElementList
  Pixels
  RichTextArray
  RichTextStyle
  RichTextMentionStyle
)];

use MooseX::Types::Moose qw(ArrayRef Bool Int);
use MooseX::Types::Structured qw(Dict Optional);

subtype RichTextBlocks, as ArrayRef[
  union([
    map {; class_type("Slack::BlockKit::Block::RichText::$_") }
      (qw( List Quote Preformatted Section ))
  ])
];

subtype ExpansiveElementList, as ArrayRef[
  union([
    map {; class_type("Slack::BlockKit::Block::RichText::$_") }
      (qw( Channel Date Emoji Link Text User UserGroup ))
  ])
];

subtype ContextElementList, as ArrayRef[
  # This should really be union-ed with Image, but we don't have an Image type,
  # so there you go. -- rjbs, 2025-08-12
  class_type("Slack::BlockKit::CompObj::Text"),
];

subtype RichTextArray, as ArrayRef[
  class_type("Slack::BlockKit::Block::RichText::Section")
];

subtype Pixels, as Int, where { $_ >= 0 },
  message { "Pixel attributes must be integers, >= 0" };

# RichListStyle - enum( ordered, bullet )

1;
