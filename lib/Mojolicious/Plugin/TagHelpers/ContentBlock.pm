package Mojolicious::Plugin::TagHelpers::ContentBlock;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::ByteStream 'b';

our $VERSION = '0.01_1';

sub register {
  my ($self, $app) = @_;

  # Store content blocks issued from plugins
  my %content_block;

  # Add elements to a content block
  $app->helper(
    content_block => sub {
      my ($c, $name, $template) = @_;

      $content_block{$name} ||= [];
      $c->stash->{'cblock.' . $name} ||= [];

      # No template - release
      unless ($template) {
	my $string = '';

	# Iterate over default and stash content blocks
	foreach (@{$content_block{$name}}, @{$c->stash('cblock.'. $name)}) {
	  next unless $_;
	  $string .= (ref $_ ? $_->($c) : $c->render_to_string(inline => $_));
	};

	# Return content block
	return b($string);
      };

      # Probably called from app
      if ($c->tx->{req}) {

	# Add template to content block
	push(@{$c->stash->{'cblock.' . $name}}, $template);
      }

      # Called from controller
      else {
	# Add template to content block
	push(@{$content_block{$name}}, $template);
      };
    }
  );
};


1;


__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::TagHelpers::ContentBlock - Mojolicious Plugin for Content Blocks


=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('TagHelpers::ContentBlock');

  # Mojolicious::Lite
  plugin 'TagHelpers::ContentBlock';

  # Add snippets to a content block, e.g. from a plugin
  app->content_block(
    admin => '<%= link_to 'Edit' => '/edit' %>'
  );

  # In a template
  %= content_block 'admin'

=head1 DESCRIPTION

L<Mojolicious::Plugin::TagHelpers::ContentBlock> is a L<Mojolicious> plugin
to create pluggable content blocks for page views.

B<Warning! This is early software! Use at your own risk!>

=head1 METHODS

L<Mojolicious::Plugin::TagHelpers::ContentBlocks> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 HELPERS

=head2 content_block

  # In a plugin
  $app->content_block(
    admin => '<%= link_to 'Edit' => '/edit' %>'
  );

  # From a controller
  $c->content_block(
    admin => '<%= link_to 'Edit' => '/edit' %>'
  );

  # From a template
  % content_block 'admin', begin
    <%= link_to 'Edit' => '/edit' %>
  % end

  # Calling the content block
  %= content_block 'admin'

Add content to a named content block, like with
L<Mojolicious::Plugin::DefaultHelpers/content_for|content_for>,
and call the contents from a template.

In difference to L<Mojolicious::Plugin::DefaultHelpers/content_for|content_for>,
content of the content block can be defined in a global cache during
startup.


=head1 DEPENDENCIES

L<Mojolicious>.


=head1 AVAILABILITY

  https://github.com/Akron/Mojolicious-Plugin-TagHelpers-ContentBlock


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015, L<Nils Diewald|http://nils-diewald.de/>.

This program is free software, you can redistribute it
and/or modify it under the terms of the Artistic License version 2.0.


=cut
