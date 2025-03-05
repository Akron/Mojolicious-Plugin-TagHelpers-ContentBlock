use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use lib '.', 't';

plugin 'TagHelpers::ContentBlock';

ok(!app->content_block_ok('administration'), 'Nothing in the content block');

my $navi_template =<< 'NAVI';
% content_block 'administration', { position => 100 }, begin
   <h1>Test</h1>
% end

<nav>
%= content_block 'administration'
</nav>
NAVI

get '/' => sub {
  shift->render(inline => $navi_template);
};

my $t = Test::Mojo->new;

$t->get_ok('/')
  ->status_is(200)
  ->element_exists('nav')
  ->element_count_is('nav > *', 1)
  ->text_is('h1','Test')
  ;

done_testing();
__END__
