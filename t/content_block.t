use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use lib '.', 't';

plugin 'TagHelpers::ContentBlock';

# Add own plugin namespace
unshift @{app->plugins->namespaces}, 'ExamplePlugin';

my $navi_template =<< 'NAVI';
<nav>
%= content_block 'administration'
</nav>
NAVI

app->defaults(
  email_address => 'akron@sojolicio.us'
);

get '/' => sub {
  shift->render(inline => $navi_template);
};

my $t = Test::Mojo->new;

$t->get_ok('/')
  ->status_is(200)
  ->element_count_is('nav > *', 0);

app->plugin('Admin');

$t->get_ok('/')
  ->status_is(200)
  ->element_count_is('nav > *', 1)
  ->text_is('nav > a', 'Admin')
  ->text_is('nav > a[rel=admin]', 'Admin');

app->plugin('Email');

$t->get_ok('/')
  ->status_is(200)
  ->element_count_is('nav > *', 2)
  ->text_is('nav > a', 'Admin')
  ->text_is('nav > a[rel=admin]', 'Admin')
  ->text_is('nav > a[rel=email]', 'akron@sojolicio.us');

get '/newmail' => sub {
  my $c = shift;
  $c->stash(email_address => 'peter@sojolicio.us');
  $c->render(inline => $navi_template);
};

$t->get_ok('/newmail')
  ->status_is(200)
  ->element_count_is('nav > *', 2)
  ->text_is('nav > a', 'Admin')
  ->text_is('nav > a[rel=admin]', 'Admin')
  ->text_is('nav > a[rel=email]', 'peter@sojolicio.us');

get '/withhome' => sub {
  my $c = shift;

  $c->content_block(
    administration => q!<%= link_to 'Home' => '/home', rel => 'home' %>!
  );

  $c->render(inline => $navi_template);
};

$t->get_ok('/withhome')
  ->status_is(200)
  ->element_count_is('nav > *', 3)
  ->text_is('nav > a', 'Admin')
  ->text_is('nav > a[rel=admin]', 'Admin')
  ->text_is('nav > a[rel=email]', 'akron@sojolicio.us')
  ->text_is('nav > a[rel=home]', 'Home');

$t->get_ok('/')
  ->status_is(200)
  ->element_count_is('nav > *', 2)
  ->text_is('nav > a', 'Admin')
  ->text_is('nav > a[rel=admin]', 'Admin')
  ->text_is('nav > a[rel=email]', 'akron@sojolicio.us');

done_testing();
__END__
