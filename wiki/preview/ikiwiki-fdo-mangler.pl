#!/usr/bin/perl

use strict;
use warnings;

my $outputdir=$ARGV[0];

-d $outputdir || exit 2;

package IkiWiki::Setup::Standard;

$INC{"IkiWiki/Setup/Standard.pm"} = "/fake/path";

use Data::Dumper qw( );

sub import {
  my ( $class, $config ) = @_;

#  foreach my $key ( grep { /^[^aeiou]/i } keys %{$config} ) {
#    delete $config->{$key};
#  };

  delete $config->{cgiurl};
  delete $config->{diffurl};
  delete $config->{historyurl};
  delete $config->{wrappers};

  # delete cgi-relevant plugins
  @{$config->{add_plugins}} = grep(!/^(wmd|httpauth|attachment|rename|remove|search)$/, @{$config->{add_plugins}});

  push(@{$config->{disable_plugins}}, 'recentchanges', 'git');

  $config->{srcdir} = `git rev-parse --show-toplevel`; # We'll have to specify this on the command line
  chomp($config->{srcdir});
  $config->{add_underlays} = [ "$outputdir/underlay" ];
  $config->{templatedir} = "$outputdir/templates";
  $config->{destdir} = "$outputdir/output";
  $config->{url} = "file://$outputdir/output";
  
  $config->{wikistatedir} = "$outputdir/state";

  my $newconfig = Data::Dumper->new( [ $config ] );
  $newconfig->Terse( 1 );

  print "#!/usr/bin/perl\n\nuse IkiWiki::Setup::Standard " . $newconfig->Dump( ) . ";\n";

};

do "/dev/stdin";

