package Slack::BlockKit;
use v5.32.0;
use warnings;

use experimental qw(signatures); # XXX

# Boolean and set handling
use JSON::PP (); # to ensure that JSON::PP::true and ::false are populated

sub boolify ($val) { $val ? JSON::PP::true : JSON::PP::false }

# The top-level collection object
use Slack::BlockKit::BlockCollection;

# Rich Text
use Slack::BlockKit::Block::RichText;
use Slack::BlockKit::Block::RichText::Channel;
use Slack::BlockKit::Block::RichText::Emoji;
use Slack::BlockKit::Block::RichText::Link;
use Slack::BlockKit::Block::RichText::List;
use Slack::BlockKit::Block::RichText::Preformatted;
use Slack::BlockKit::Block::RichText::Quote;
use Slack::BlockKit::Block::RichText::Section;
use Slack::BlockKit::Block::RichText::Text;
use Slack::BlockKit::Block::RichText::User;
use Slack::BlockKit::Block::RichText::UserGroup;

# Everything Else
use Slack::BlockKit::Block::Divider;
use Slack::BlockKit::Block::Header;
use Slack::BlockKit::Block::Section;
use Slack::BlockKit::CompObj::Text;

1;
