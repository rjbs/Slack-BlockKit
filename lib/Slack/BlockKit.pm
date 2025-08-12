package Slack::BlockKit;
# ABSTRACT: a toolkit for building Block Kit blocks for Slack

=head1 OVERVIEW

This library is only useful if you're using L<Slack|https://slack.com/>.

Almost any time you want to send content to Slack and you want to end up in
front of a human, you will want to use Block Kit.  You can get away without
using Block Kit if you're only sending plain text or "mrkdwn" text, but even
then, the lack of an escaping mechanism in mrkdwn can be a problem.

The Block Kit system lets you build quite a few different pieces of
presentation, but it's fiddly and the error reporting is I<terrible> if you get
something wrong.  This library is meant to make it I<easy> to write Block Kit
content, and to provide client-side validation of constructed blocks with
better (well, less awful) errors when you make a mistake.

B<You probably want to start here>:  L<Slack::BlockKit::Sugar>.  This library
exports a bunch of functions that can be combined to produce valid Block Kit
structures.  Each of those functions will produce an object, or maybe several.
You shouldn't really need to build any of those objects by hand, but you can.
To find more about the classes shipped with Slack::Block Kit, look at the docs
for the Sugar library and follow the links from there.

=head1 SECRET ORIGINS

This library was written to improve RJBS's Synergy chat bot.  You can read more
about this process (and the bot) on L<his
blog|https://rjbs.cloud/blog/2024/06/slack-blockkit/>.

=cut

use v5.36.0;

# Boolean and set handling
use JSON::PP (); # to ensure that JSON::PP::true and ::false are populated

sub boolify ($val) { $val ? JSON::PP::true : JSON::PP::false }

# The top-level collection object
use Slack::BlockKit::BlockCollection;

# Rich Text
use Slack::BlockKit::Block::RichText;
use Slack::BlockKit::Block::RichText::Channel;
use Slack::BlockKit::Block::RichText::Date;
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
use Slack::BlockKit::Block::Context;
use Slack::BlockKit::Block::Divider;
use Slack::BlockKit::Block::Header;
use Slack::BlockKit::Block::Section;
use Slack::BlockKit::CompObj::Text;

1;
