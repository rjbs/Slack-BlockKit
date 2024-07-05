package Slack::BlockKit::Block::RichText::Date;
# ABSTRACT: a Block Kit rich text element for a formatted date

use Moose;
use MooseX::StrictConstructor;

=head1 OVERVIEW

This represents a C<date> element in Block Kit, which takes a unix timestamp
and displays it in a format appropriate for the reader.

B<Be warned!>  The element is not documented in the Block Kit documentation,
but Slack support disclosed its existence.  They said it was just missing
documentation, but might it just go away?  Who can say.

=cut

use v5.36.0;

=attr timestamp

This is the date (and time) that you want to format, which will be formatted
into the reader's own time zone when displayed.  It is required, and must be a
unix timestamp.  (That is: a number of seconds since 1970, as per C<<
L<perlfunc/time> >>.

=cut

has timestamp => (
  is  => 'ro',
  isa => 'Int', # Maybe this should be stricter, like PosInt, but eh.
  required => 1,
);

=attr format

This is the format string to be used formatting the timestamp.  Because the
C<date> rich text element isn't documented in the Block Kit docs (currently),
you'll want to find the format specification in the "L<Formatting text for app
surfaces|https://api.slack.com/reference/surfaces/formatting#date-formatting>"
docs.

Something like this is plausible:

  "{date_short_pretty}, {time}"

Probably because of the C<date> element's origin in C<mrkdwn>, it has the odd
property that the first character will be capitalized.  To suppress this, you
can prefix your format string with C<U+200B>, the zero-width space.  For
example:

  "\x{200b}{date_short_pretty}, {time}"

This is done, by default, in L<Slack::BlockKit::Sugar>'s C<date> function.

=cut

has format => (
  is  => 'ro',
  isa => 'Str',
);

=attr fallback

If given, and if the client can't process the given date, this string will be
displayed instead.  If you put a pre-formatted date string in this, include the
time zone, because the reader will expect that it will have been localized.

=cut

has fallback => (
  is  => 'ro',
  isa => 'Str',
  predicate => 'has_fallback',
);

=attr url

If given, the formatted date string will I<also> be a link to this URL.

=cut

has url => (
  is  => 'ro',
  isa => 'Str',
  predicate => 'has_url',
);

sub as_struct ($self) {
  return {
    type => 'date',
    timestamp => 0 + $self->timestamp, # 0+ for JSON serialization's sake
    format    => "" . $self->format,
    ($self->has_fallback  ? (fallback => "" + $self->fallback)  : ()),
    ($self->has_url       ? (url      => "" . $self->url)       : ()),
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
