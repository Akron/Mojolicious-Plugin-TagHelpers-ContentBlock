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
    requires  => {perl => '5.010001'},
    resources => {
      license     => 'http://www.opensource.org/licenses/artistic-license-2.0',
      repository  => 'https://github.com/Akron/Mojolicious-Plugin-TagHelpers-ContentBlock'
    }
  }
);
