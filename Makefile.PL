use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::TagHelpers::ContentBlock',
  VERSION_FROM => 'lib/Mojolicious/Plugin/TagHelpers/ContentBlock.pm',
  AUTHOR       => 'Nils Diewald',
  PREREQ_PM    => {
    'Mojolicious' => '6.22',
    'Test::More' => 0
  },
  test         => {
    TESTS => 't/*.t'
  },
  LICENSE      => 'perl',
  META_MERGE   => {
    'meta-spec' => { version => 2 },
    requires  => {perl => '5.010001'},
    resources => {
      license     => 'http://www.opensource.org/licenses/artistic-license-2.0',
      repository  => {
        type => 'git',
        url => 'https://github.com/Akron/Mojolicious-Plugin-TagHelpers-ContentBlock.git',
        web => 'https://github.com/Akron/Mojolicious-Plugin-TagHelpers-ContentBlock',
      },
      bugtracker => {
        web => 'https://github.com/Akron/Mojolicious-Plugin-TagHelpers-ContentBlock/issues'
      }
    }
  }
);
