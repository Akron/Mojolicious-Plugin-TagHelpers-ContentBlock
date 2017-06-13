package Mojolicious::Plugin::TagHelpers::ContentBlock;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::ByteStream 'b';

our $VERSION = '0.04';

# Sort based on the manual given position
# or the order the element was added
sub _position_sort {

  # Sort by manual positions
  if ($a->{position} < $b->{position}) {
    return -1;
  }
  elsif ($a->{position} > $b->{position}) {
    return 1;
  }

  # Manual positions are even, check order
  # of addition
  elsif ($a->{position_b} < $b->{position_b}) {
    return -1;
  }
  elsif ($a->{position_b} > $b->{position_b}) {
    return 1;
  };
  return 0;
};


# Register the plugin
sub register {
  my ($self, $app) = @_;

  # Store content blocks issued from plugins
  my %content_block;

  # Add elements to a content block
  $app->helper(
    content_block => sub {
      my $c = shift;
      my $name = shift;

      # No template passed - return content
      unless (@_) {
        my $string = '';

        # TODO: This may be optimizable - by sorting in advance and possibly
        # attaching compiled templates all the way. The only problem is the
        # difference between application called contents and controller
        # called contents.

        # The blocks are based on elements from the global
        # hash and from the stash
        my @blocks;
        @blocks = @{$content_block{$name}} if $content_block{$name};
        if ($c->stash('cblock.'. $name)) {
          push(@blocks, @{$c->stash('cblock.'. $name)});
        };

        # Iterate over default and stash content blocks
        foreach (sort _position_sort @blocks) {

          # Render inline template
          if ($_->{inline}) {
            $string .= $c->render_to_string(inline => $_->{inline}) // '';
          }

          # Render template
          elsif ($_->{template}) {
            $string .= $c->render_to_string(template => $_->{template}) // '';
          }

          # Render callback
          elsif ($_->{cb}) {
            $string .= $_->($c) // '';
          };
        };

        # Return content block
        return b($string);
      };


      # Parameter number is odd - get the last element as a template callback
      my $cb = pop if @_ % 2;

      my %element = @_;

      # Content block not yet defined
      $content_block{$name} ||= [];

      # The template may be defined either as 'cb', 'template' or 'inline'
      $element{cb} = $cb if $cb;

      # Two position definitions - first manually defined,
      # the second based on the position in the block
      $element{position} //= 0;
      $element{position_b} = scalar @{$content_block{$name}};

      # Probably called from app
      if ($c->tx->{req}) {

        # Add template to content block
        push(@{$c->stash->{'cblock.' . $name} ||= []}, \%element);
      }

      # Called from controller
      else {

        # Add template to content block
        push(@{$content_block{$name}}, \%element);
      };
    }
  );

  # Check, if the content block has any elements
  $app->helper(
    content_block_ok => sub {
      my ($c, $name) = @_;

      return unless $name;
      if ($content_block{$name}) {
        return 1 if @{$content_block{$name}};
      };
      return 1 if $c->stash('cblock.'. $name);
      return;
    }
  );
};


1;


__END__

=pod

=encoding utf8

=head1 NAME

Mojolicious::Plugin::TagHelpers::ContentBlock - Mojolicious Plugin for Content Blocks


=head1 SYNOPSIS

  use Mojolicious::Lite;

  plugin 'TagHelpers::ContentBlock';

  # Add snippets to a named content block, e.g. from a plugin
  app->content_block(
    admin => (
      inline => "<%= link_to 'Edit' => '/edit' %>"
    )
  );

  # or in a controller:
  get '/' => sub {
    my $c = shift;
    $c->content_block(
      admin => (
        inline => "<%= link_to 'Logout' => '/logout' %>",
        position => 20
      )
    );
    $c->render(template => 'home');
  };

  app->start;

  __DATA__
  @@ home.html.ep
  %# Call in a template
  %= content_block 'admin'

=head1 DESCRIPTION

L<Mojolicious::Plugin::TagHelpers::ContentBlock> is a L<Mojolicious> plugin
to create pluggable content blocks for page views.

B<Warning! This is early software! Use at your own risk!>


=head1 METHODS

L<Mojolicious::Plugin::TagHelpers::ContentBlock> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.


=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in a L<Mojolicious> application.


=head1 HELPERS

=head2 content_block

  # In a plugin
  $app->content_block(
    admin => (
      inline => '<%= link_to 'Edit' => '/edit' %>'
    )
  );

  # From a controller
  $c->content_block(
    admin => (
      inline => '<%= link_to 'Edit' => '/edit' %>',
      position => 40
    )
  );

  # From a template
  % content_block 'admin', position => 9, begin
    <%= link_to 'Edit' => '/edit' %>
  % end

  # Calling the content block
  %= content_block 'admin'

Add content to a named content block (like with
L<Mojolicious::Plugin::DefaultHelpers/content_for|content_for>)
and call the contents from a template.

In difference to L<Mojolicious::Plugin::DefaultHelpers/content_for|content_for>,
content of the content block can be defined in a global cache during
startup.

Supported content parameters are C<template> or C<inline>.
Additionally a numeric C<position> value can be passed, defining the order of elements
in the content block. If C<position> is omitted,
the default position is C<0>. Position values may be positive or negative.


=head2 content_block_ok

  # In a template
  % if (content_block_ok('admin')) {
    <ul>
    %= content_block 'admin'
    </ul>
  % };

Check if a C<content_block> contains elements.


=head1 DEPENDENCIES

L<Mojolicious>.


=head1 AVAILABILITY

  https://github.com/Akron/Mojolicious-Plugin-TagHelpers-ContentBlock


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015-2016, L<Nils Diewald|http://nils-diewald.de/>.

This program is free software, you can redistribute it
and/or modify it under the terms of the Artistic License version 2.0.


=cut
