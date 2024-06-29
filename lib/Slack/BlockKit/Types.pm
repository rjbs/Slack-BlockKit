package Slack::BlockKit::Types;
use v5.36.0;

use MooseX::Types -declare => [qw(
  ExpansiveBlockList
  Pixels
  RichTextArray
  RichTextStyle
  RichTextMentionStyle
)];

use MooseX::Types::Moose qw(ArrayRef Bool Int);
use MooseX::Types::Structured qw(Dict Optional);

subtype ExpansiveBlockList, as ArrayRef[
  union([
    map {; class_type("Slack::BlockKit::Block::RichText::$_") }
      (qw( Channel Emoji Link Text User UserGroup ))
  ])
];

subtype RichTextArray, as ArrayRef[
  class_type("Slack::BlockKit::Block::RichText::Section")
];

subtype Pixels, as Int, where { $_ >= 0 },
  message { "Pixel attributes must be integers, >= 0" };

# RichListStyle - enum( ordered, bullet )

1;
