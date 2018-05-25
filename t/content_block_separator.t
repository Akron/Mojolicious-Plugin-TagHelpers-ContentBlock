use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use lib '.', 't';

plugin 'TagHelpers::ContentBlock';

ok(!app->content_block_ok('admin'), 'Nothing in the content block');

my $template =<< 'NAVI';
% if (content_block_ok('admin')) {
  <nav>
  %= content_block 'admin', parameter => 'hui'
  </nav>
% };
NAVI

get '/' => sub {
  my $c = shift;
  $c->content_block(admin => {
    inline => 'second &amp; third',
    position => 100
  });
  $c->render(inline => $template);
};

my $t = Test::Mojo->new;

$t->get_ok('/')
  ->status_is(200)
  ->text_like('nav', qr/second \& third/);

done_testing();
__END__
