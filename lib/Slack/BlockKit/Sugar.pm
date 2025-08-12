package Slack::BlockKit::Sugar;
# ABSTRACT: sugar for building Block Kit structures easily (start here!)

use v5.36.0;

use Carp ();
use Slack::BlockKit;

# A small rant: Params::Util provided a perfectly good _HASH0 routine, which I
# knew I could use here.  But it turns out that years ago, an XS implementation
# was added to Params::Util, and it's *broken*.  It returns blessed references
# when the test is meant to exclude them.  The broken Params::Util will prefer
# XS, but there's Params::Util::PP -- but that code doesn't export any of its
# symbols.  There's a comment on the ticket from the current maintainer that
# he's not sure which is right, even though the original documentation makes
# the intended behavior clear.
#
# This cost me a good hour or two.  I *wrote* some of this code, so I was
# absolutely positive I knew the behavior of _HASH0.  Turns out, nope!
#
# https://rt.cpan.org/Ticket/Display.html?id=75561
my sub _HASH0 { return ref $_[0] eq 'HASH' ? $_[0] : undef; }

use experimental 'builtin'; # blessed

=head1 ACHTUNG

This library seems pretty good to me, its author, but it hasn't seen much use
yet.  As it gets used, it may change in somewhat backward-incompatible ways.
Upgrade carefully until this warning goes away!

=head1 OVERVIEW

This module exports a bunch of functions that can be composed to build Block
Kit block collections, which can then be easily turned into a data structure
that can be serialized.

If you learn to use I<this> library, you can generally ignore the other dozen
(more!) modules in this distribution.  On the other hand, you B<must> more or
less understand how Block Kit works, which means reading the L<BlockKit
documentation|https://api.slack.com/block-kit> at Slack's API site.

The key is to have a decent idea of the Block Kit structure you want.  Knowing
that, you can look at the list of functions provided by this library and
compose them together.  Start with a call to C<blocks>, passing the result of
calling other generators to it.  In the end, you'll have an object on which you
can call C<< ->as_struct >>.

For example, to produce something basically equivalent to this Markdown (well,
mrkdwn):

    Here is a *safe* link: **[click me](https://rjbs.cloud/)**
    * it will be fun
    * it will be cool 🙂
    * it will be enough

You can use this set of calls to the sugar functions:

    blocks(
      richblock(
        richsection(
          "Here is a ", italic("safe"), " link: ",
          link("https://fastmail.com/", "click me", { style => { bold => 1 } }),
        ),
        ulist(
          "it will be fun",
          richsection("it will be cool", emoji('smile')),
          "it will be enough",
        ),
      )
    );

=head2 Importing the functions

This library uses L<Sub::Exporter> for exporting its functions.  That means
that they can be renamed during import.  Since the names of these functions are
fairly generic, you might prefer to write this:

    use Slack::BlockKit::Sugar -all => { -prefix => 'bk_' };

This will import all the sugar functions with their names prefixed by C<bk_>.
So, for example, C<italic> will be C<bk_italic>.

=cut

use Sub::Exporter -setup => {
  exports => [
    # top-level
    qw( blocks ),

    # Rich Text
    qw( richblock ),
    qw( richsection list preformatted quote ), # top-level
    qw( olist ulist ), # specialized list()
    qw( channel date emoji link richtext user usergroup ), # deeper
    qw( bold code italic strike ), # specialized richtext()

    # Other Things
    qw( context divider header mrkdwn text section )
  ],
};

my sub _rtextify (@things) {
  [
    map {;  ref($_)
        ? $_
        : Slack::BlockKit::Block::RichText::Text->new({ text => $_ })
        } @things
  ]
}

my sub _rsectionize (@things) {
  [
    map {;  ref($_)
        ? $_
        : Slack::BlockKit::Block::RichText::Section->new({
            elements => _rtextify($_),
          })
        } @things
  ];
}

=func blocks

  my $block_col = blocks( @blocks );

This returns a L<Slack::BlockKit::BlockCollection>, which just collects blocks
and will return their serializable structure form in an arrayref when C<<
->as_struct >> is called on it.

If any argument is a non-reference, it will be upgraded to a L</section> block
containing a single L</mrkdwn> text object.

This means the simplest non-trivial message you could send is something like:

  blocks("This is a *formatted* message.")->as_struct;

=cut

sub blocks (@blocks) {
  return Slack::BlockKit::BlockCollection->new({
    blocks => [ map {; ref($_) ? $_ : section(mrkdwn($_)) } @blocks ]
  });
}

=func richblocks

  my $rich_text_block = richblocks( @rich_elements );

This returns a L<Slack::BlockKit::Block::RichText>, representing a
C<rich_text>-type block.  It's a bit annoying that you need it, but you do.
You'll also need to pass one or more rich text elements as arguments, something
like this:

  blocks(
    richblocks(
      section("This is ", italic("very"), " important."),
    ),
  );

Each non-reference passed in the list of rich text elements will be turned into
a rich text objects inside its own section object.

=cut

sub richblock (@elements) {
  Slack::BlockKit::Block::RichText->new({
    elements => _rsectionize(@elements),
  })
}

=func richsection

  $rich_text_section = richsection( @elements );

This returns a single L<rich text
section|Slack::BlockKit::Block::RichText::Section> object containing the passed
elements as its C<elements> attribute value.

Non-reference values in C<@elements> be converted to rich text objects.

=cut

sub richsection (@elements) {
  Slack::BlockKit::Block::RichText::Section->new({
    elements => _rtextify(@elements),
  });
}

=func list

  my $rich_text_list = list(\%arg, @sections);

This returns a L<rich text list|Slack::BlockKit::Block::RichText::List> object.
C<@sections> must be a list of rich text sections or plain scalars.  Plain
scalars will each be converted to a rich text object contained in a rich text
section.

The C<%arg> hash is more arguments to the List object constructor.  It B<must>
contain a C<style> key.  For shorthand, see L</olist> and L</ulist> below.

=cut

sub list ($arg, @sections) {
  Slack::BlockKit::Block::RichText::List->new({
    %$arg,
    elements => _rsectionize(@sections),
  });
}

=func olist

  my $rich_text_list = olist(@sections);
  # or
  my $rich_text_list = olist(\%arg, @sections);

This is just shorthand for L</list>, but with a C<style> of C<ordered>.
Because that's the only I<required> option for a list, you can omit the leading
hashref in calls to C<olist>.

=cut

sub olist (@sections) {
  my $arg = _HASH0($sections[0]) ? (shift @sections) : {};
  Slack::BlockKit::Block::RichText::List->new({
    %$arg,
    style => 'ordered',
    elements => _rsectionize(@sections),
  });
}

=func ulist

  my $rich_text_list = ulist(@sections);
  # or
  my $rich_text_list = ulist(\%arg, @sections);

This is just shorthand for L</list>, but with a C<style> of C<bullet>.
Because that's the only I<required> option for a list, you can omit the leading
hashref in calls to C<olist>.

=cut

sub ulist (@sections) {
  my $arg = _HASH0($sections[0]) ? (shift @sections) : {};
  Slack::BlockKit::Block::RichText::List->new({
    %$arg,
    style => 'bullet',
    elements => _rsectionize(@sections),
  });
}

=func preformatted

  my $rich_text_pre = preformatted(@elements);
  # or
  my $rich_text_pre = preformatted(\%arg, @elements);

This returns a new L<preformatted rich
text|Slack::BlockKit::Block::RichTextPreformatted> block object, with the given
elements as its C<elements>.  Any non-references in the list will be turned
into text objects.

The leading hashref, if given, will be used as extra arguments to the block
object's constructor.

B<Beware>:  The Slack documentation suggests that C<emoji> objects can be
present in the list of elements, but in practice, this always seems to get
rejected by Slack.

=cut

sub preformatted (@elements) {
  my $arg = _HASH0($elements[0]) ? (shift @elements) : {};

  Slack::BlockKit::Block::RichText::Preformatted->new({
    %$arg,
    elements => _rtextify(@elements),
  });
}

=func quote

  my $rich_text_quote = quote(@elements);
  # or
  my $rich_text_quote = quote(\%arg, @elements);

This returns a new L<quoted rich
text|Slack::BlockKit::Block::Quote> block object, with the given elements as
its C<elements>.  Any non-references in the list will be turned into text
objects.

The leading hashref, if given, will be used as extra arguments to the block
object's constructor.

=cut

sub quote (@elements) {
  my $arg = _HASH0($elements[0]) ? (shift @elements) : {};

  Slack::BlockKit::Block::RichText::Quote->new({
    %$arg,
    elements => _rtextify(@elements),
  });
}

=func channel

  my $rich_text_channel = channel($channel_id);
  # or
  my $rich_text_channel = channel(\%arg, $channel_id);

This function returns a L<channel mention
object|Slack::BlockKit::Block::RichText::Channel>, which can be used among
other rich text elements to "mention" a channel.  The C<$channel_id> should be
the alphanumeric Slack channel id, not a channel name.

If given, the C<%arg> hash is extra parameters to pass to the Channel
constructor.

=cut

sub channel {
  my ($arg, $id)
    = @_ == 2 ? @_
    : @_ == 1 ? ({}, $_[0])
    : Carp::croak("BlockKit channel sugar called with wrong number of arguments");

  Slack::BlockKit::Block::RichText::Channel->new({
    %$arg,
    channel_id => $id,
  });
}

=func date

  my $rich_text_date = date($timestamp, \%arg);

This returns a L<rich text date object|Slack::BlockKit::Block::RichText::Date>
for the given time (a unix timestamp).  If given, the referenced C<%arg> can
contain additional arguments to the Date constructor.

Date formatting objects have a mandatory C<format> property.  If none is given
in C<%arg>, the default is:

  \x{200b}{date_short_pretty} at {time}

Why that weird first character?  It's a zero-width space, and suppresses the
capitalization of "yesterday" (or other words) at the start.  This
capitalization seems like a bug (or bad design) in Slack.

=cut

sub date ($timestamp, $arg=undef) {
  $arg //= {};

  Slack::BlockKit::Block::RichText::Date->new({
    format => "\x{200b}{date_short_pretty} at {time}",
    %$arg,
    timestamp => $timestamp,
  });
}

=func emoji

  my $rich_text_emoji = emoji($emoji_name);

This function returns an L<emoji
object|Slack::BlockKit::Block::RichText::Emoji> for the named emoji.

=cut

sub emoji ($name) {
  Slack::BlockKit::Block::RichText::Emoji->new({
    name => $name,
  });
}

=func link

  my $rich_text_link = link($url);
  # or
  my $rich_text_link = link($url, \%arg);
  # or
  my $rich_text_link = link($url, $text_string);
  # or
  my $rich_text_link = link($url, $text_string, \%arg);

This function returns a rich text L<link
object|Slack::BlockKit::Block::RichText::Link> for the given URL.

If given, the C<$text_string> string will be used as the display text for the
link.  If not, URL itself will be displayed.

The optional C<\%arg> parameter contains additional attributes to be passed to
the Link object constructor.

=cut

sub link {
  Carp::croak("BlockKit link sugar called with wrong number of arguments")
    if @_ > 3 || @_ < 1;

  my $url  = $_[0];
  my $text = ref $_[1] ? undef : $_[1];
  my $arg  = ref $_[1] ? $_[1] : ($_[2] // {});

  Slack::BlockKit::Block::RichText::Link->new({
    %$arg,
    (defined $text ? (text => $text) : ()),
    url => $url,
  });
}

=func richtext

  my $rich_text = richtext($text_string);
  # or
  my $rich_text = richtext(\@styles, $text_string);

This function returns a new L<rich text text
object|Slack::BlockKit::Block::RichText::Text> for the given text string.  If a
an arrayref is passed as the first argument, it is taken as a list of styles to
apply to the string.  So,

  richtext(['bold','italic'], "Hi");

...will produce an object that has this structure form:

  {
    type   => 'text',
    styles => { bold => true(), italic => true() },
    text   => "Hi",
  }

=cut

sub richtext {
  my ($styles, $text)
    = @_ == 2   ? (@_)
    : @_ == 1   ? ([], $_[0])
    : @_ == 0   ? Carp::croak("BlockKit richtext sugar called too few arguments")
    : @_  > 2   ? Carp::croak("BlockKit richtext sugar called too many arguments")
    : Carp::confess("unreachable code");

  my $arg = {};
  $arg->{style}{$_} = 1 for $styles->@*;

  Slack::BlockKit::Block::RichText::Text->new({
    %$arg,
    text => $text,
  });
}

=func bold

=func code

=func italic

=func strike

These functions are all called the same way:

  my $rich_text = bold($text_string);

They are shortcuts for calling C<richtext> with one style applied: the style of
their function name.

=cut

sub bold   ($text) { richtext(['bold'], $text) }
sub code   ($text) { richtext(['code'], $text) }
sub italic ($text) { richtext(['italic'], $text) }
sub strike ($text) { richtext(['strike'], $text) }

=func user

  my $rich_text_user = user($user_id);
  # or
  my $rich_text_user = user(\%arg, $user_id);

This function returns a L<user mention
object|Slack::BlockKit::Block::RichText::User>, which can be used among
other rich text elements to "mention" a user.  The C<$user_id> should be
the alphanumeric Slack user id, not a user name.

If given, the C<%arg> hash is extra parameters to pass to the User
constructor.

=cut

sub user {
  my ($arg, $id)
    = @_ == 2 ? @_
    : @_ == 1 ? ({}, $_[0])
    : Carp::croak("BlockKit user sugar called with wrong number of arguments");

  Slack::BlockKit::Block::RichText::User->new({
    %$arg,
    user_id => $id,
  });
}

=func usergroup

  my $rich_text_usergroup = usergroup($usergroup_id);
  # or
  my $rich_text_usergroup = usergroup(\%arg, $usergroup_id);

This function returns a L<usergroup mention
object|Slack::BlockKit::Block::RichText::UserGroup>, which can be used among
other rich text elements to "mention" a user group.  The C<$usergroup_id>
should be the alphanumeric Slack usergroup id, not a group name.

If given, the C<%arg> hash is extra parameters to pass to the UserGroup
constructor.

=cut

sub usergroup {
  my ($arg, $id)
    = @_ == 2 ? @_
    : @_ == 1 ? ({}, $_[0])
    : Carp::croak("BlockKit usergroup sugar called with wrong number of arguments");

  Slack::BlockKit::Block::RichText::UserGroup->new({
    %$arg,
    user_group_id => $id,
  });
}

=func context

  my $context = context(@text_objs_or_strings);

This function returns a L<context object|Slack::BlockKit::Block::Context>.  You
can pass it a list of values, each of which is either a string or a L<text
object|Slack::BlockKit::CompObj::Text>.  Strings will be promoted to
C<mrkdwn>-type text objects.

=cut

sub context (@args) {
  my @elements;

  ARG: for my $arg (@args) {
    if (builtin::blessed $arg) {
      Carp::croak("non-Text section passed as argument to BlockKit context sugar")
        unless $arg->isa('Slack::BlockKit::CompObj::Text');

      push @elements, $arg;
      next ARG;
    }

    if (ref $arg) {
      Carp::croak("unblessed reference passed as argument to BlockKit context sugar");
    }

    push @elements, Slack::BlockKit::CompObj::Text->new({
      type => 'mrkdwn',
      text => $arg,
    });
  }

  return Slack::BlockKit::Block::Context->new({ elements => \@elements });
}

=func divider

  my $divider = divider();

This function returns a L<divider black
object|Slack::BlockKit::Block::Divider>.  It takes no parameters, because there
is nothing simpler than a divider block.

=cut

sub divider () {
  Slack::BlockKit::Block::Divider->new();
}

=func header

  my $header = header($text_string);
  # or
  my $header = header($text_obj);
  # or
  my $header = header(\%arg);

This function returns a L<header object|Slack::BlockKit::Block::Header>, which
generally has only one property: a C<text> object with type C<plain_text>.  To
make that easy to build, you can just pass a text string to C<header> and the
text object will be created for you.

Alternatively, you can pass in a text object (like you'd get from the
C<text>) function or a reference to an hash of arguments.  That last form is
mostly useful if you need to give the header a C<block_id>.

=cut

# This isn't great, it should have the $text,$arg format.
sub header ($arg) {
  if (builtin::blessed $arg) {
    # I am unfairly assuming this is a Text block, but I can tighten this up
    # later. -- rjbs, 2024-06-29
    Carp::croak("non-Text section passed as argument to BlockKit header sugar")
      unless $arg->isa('Slack::BlockKit::CompObj::Text');

    return Slack::BlockKit::Block::Header->new({ text => $arg })
  }

  if (ref $arg) {
    return Slack::BlockKit::Block::Header->new($arg);
  }

  return Slack::BlockKit::Block::Header->new({ text => text($arg) });
}

=func section

  my $section = section($text_obj);
  # or
  my $section = section($text_string);
  # or
  my $section = section(\%arg);

This function returns a L<section object|Slack::BlockKit::Block::Section>.  You
can pass it a text object, which will be used as the C<text> property of the
section.  You can pass it a string, which will be promoted the a text object
and then used the same way.

Otherwise, you'll have to pass a reference to a hash of argument that will be
passed to the section constructor.  If this function feels weird, it might just
be because the C<section> element in Block Kit is a bit weird.  Sorry!

=cut

# Maybe we should add a fields() function?  I'll do that in the future if I
# find myself ever wanting it. -- rjbs, 2024-07-03
sub section ($arg) {
  if (builtin::blessed $arg) {
    # I am unfairly assuming this is a Text block, but I can tighten this up
    # later. -- rjbs, 2024-06-29
    Carp::croak("non-Text section passed as argument to BlockKit section sugar")
      unless $arg->isa('Slack::BlockKit::CompObj::Text');

    return Slack::BlockKit::Block::Section->new({ text => $arg })
  }

  if (ref $arg) {
    return Slack::BlockKit::Block::Section->new($arg);
  }

  return Slack::BlockKit::Block::Section->new({ text => mrkdwn($arg) });
}

=func mrkdwn

  my $text_obj = mrkdown($text_string, \%arg);

This returns a L<text composition object|Slack::BlockKit::CompObj::Text> with a
type of C<mrkdwn> and the given string as its text.  The C<\%arg> option is
optional.  If given, it's extra parameters to pass to the text object
constructor.

For C<plain_text> text composition objects, see the C<text> function.

=cut

sub mrkdwn ($text, $arg=undef) {
  $arg //= {};

  Slack::BlockKit::CompObj::Text->new({
    %$arg,
    type => 'mrkdwn',
    text => $text,
  });
}

=func text

  my $text_obj = text($text_string, \%arg);

This returns a L<text composition object|Slack::BlockKit::CompObj::Text> with a
type of C<plain_text> and the given string as its text.  The C<\%arg> option is
optional.  If given, it's extra parameters to pass to the text object
constructor.

For C<mrkdwn> text composition objects, see the C<mrkdwn> function.

=cut

sub text ($text, $arg=undef) {
  $arg //= {};

  Slack::BlockKit::CompObj::Text->new({
    %$arg,
    type => 'plain_text',
    text => $text,
  });
}

1;
