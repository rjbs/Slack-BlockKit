package Slack::BlockKit;
use v5.32.0;
use warnings;

use experimental qw(signatures); # XXX

use Slack::BlockKit::Block::RichTest;
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

1;
