package Slack::BlockKit::Types;
use v5.36.0;

use MooseX::Types -declare => [qw(
  ExpansiveBlockList
  RichTextArray
)];

use MooseX::Types::Moose qw(ArrayRef);

subtype ExpansiveBlockList, as ArrayRef[
  union([
    map {; class_type("Slack::BlockKit::Block::RichText::$_") }
      (qw( Channel Emoji Link Text User UserGroup ))
  ])
];

subtype RichTextArray, as ArrayRef[
  class_type("Slack::BlockKit::Block::RichText::Section")
];

1;
