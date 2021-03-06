#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
use File::Basename;
use JSON;

use constant DEFAULT_HEIGHT => '500px';
use constant DEFAULT_WIDTH  => 'auto';
use constant DEFAULT_TITLE  => 'Avengers Chart';
use constant DEFAULT        => 0;
use constant DEFAULT_FOLDER => 'none';

#my ($directory) = $ARGV[0]
#    or die "$0 : No Directory";

my $directory = 'toyota';

my $cmd = 'find ' . $directory . ' | egrep js$';
print "Generating HTML files for $directory\n";
chomp( my @files = `$cmd` );

$cmd = 'find ' . $directory . ' | egrep html$';
print "Generating list of existing HTML files for $directory\n";
chomp( my @html_files = `$cmd` );

my $defer_html = [];

my $file_data = [];
my @generated_html;
for my $file (@files) {
    my ($fullname, $dir) = fileparse($file);
    my ($name) = $fullname =~ /(.+)\.js/;
    my $meta = process_headers($file);
    next if ($dir eq $directory . "/");
    $dir =~ s|.+?(\w+)/$|$1|;
    my $html = create_html($name, $file, $meta);

    $dir =~ s|^\.\/||; # kill leading ./
    $dir =~ s|\/$||;   # kill trailing /
    $dir =~ s|$directory||;
    push @$file_data, {
        name => $name,
        file => $html,
        meta => $meta,
        folder => $dir || DEFAULT_FOLDER,
    };
    push @generated_html, $html;
}

for my $file (@html_files) {
    my ($fullname, $dir) = fileparse($file);
    next if ($dir eq $directory . "/");
    $dir =~ s|.+?(\w+)/$|$1|;
    $dir =~ s|^\.\/||; # kill leading ./
    $dir =~ s|\/$||;   # kill trailing /
    $dir =~ s|$directory||;
    my $html = $file;
    next if grep {$_ eq $html} @generated_html;
    
    print "   ---> $html \n";
    my $title = $fullname;
    $title =~ s|\.html$||;
    $title =~ s|_| |;
    $title = ucfirst($title);
    push @$file_data, {
        name => $fullname,
        file => $html,
        meta => {
            title => $title
        },
        folder => $dir || DEFAULT_FOLDER,
    };
}
my ($json) = create_js_data($file_data);
map { _defer_html($_, $json); } @$defer_html;

exit 0;

sub create_html {
    my ($name, $file, $meta) = @_;
    my ($fname) = $file =~ m|\/?(.+)\.js$|;
    my $html = "$fname.html";

    push @$defer_html, { name => $name, file => $file, meta => $meta, html => $html };
    return $html;
}

sub _defer_html {
    my ($h, $json) = @_;

    my ($name, $file, $meta, $html) = ($h->{name}, $h->{file}, $h->{meta}, $h->{html});
    my (@peers) = get_peers($html, $json);
    my ($fullname, $dir) = fileparse($file);
    $file = $fullname;
    print "$file\n";
    print "   -> $html\n";
    open my $fh, ">$html" or die $!;

    my $google_package = $meta->{package};
    my $height = $meta->{height};
    my $width  = $meta->{width};

    my $google_load = $google_package
        ? qq(google.load("visualization", "1", {packages: ["$google_package"]});)
        : qq(google.load("visualization", "1"););

    print $fh <<HTML;
<html>
  <head>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript" src="$file"></script>
    <script type="text/javascript">
      $google_load
      google.setOnLoadCallback(drawVisualization);
    </script>
    <style>
    body, html { margin:0; padding:0; }
        .doselect {width:100%;height: 20px;}
        .sel{float:right;margin: 6px 6px 0 0;}
    </style>
  </head>
  <body>
    <div class="doselect">
      <div class="sel">
       <select id="doselect" onchange="window.location.href=this.value">
HTML

   for my $option (@peers) {
       my $html = $option->{html};
       $html =~ s|.*/||;
       my $title = $option->{title};
       my $selected = $option->{selected} ? qq(selected="selected") : '';
       print $selected . "\n";
       print $fh qq|<option value="$html" $selected>$title</option>|."\n";
       print qq|<option value="$html" $selected>$title</option>|."\n";
#         <option value="top_car_websites.html">top car website</option>
#         <option value="toyota_search_terms.html" selected="selected">toyota search terms</optio
    }
    print $fh <<HTML;
       </select>
      </div>
    </div>
    <div id="visualization" style="width: $width; height: $height;"></div>
  </body>
</html>
HTML

}

sub process_headers {
    my ($file) = @_;
    my $meta = {
        title  => DEFAULT_TITLE,
        height => DEFAULT_HEIGHT,
        width  => DEFAULT_WIDTH,
        default => DEFAULT,
    };
    open my $fh, $file or die $!;
    while(<$fh>) {
        if (my ($key, $value) = m|^// meta (\w+)=(.+)$|) {
            $meta->{$key} = $value;
        }
    }
    return $meta;
}

sub create_js_data {
    my ($data) = @_;
    my $h = {};
    my $json = {};
    map {
        push @{ $h->{ $_->{folder} } },
            {
                %{ $_->{meta} },
            file    => $_->{file},
            };
    } @$data;
    
    map {
        my @arr = @{ $h->{$_} };
        $json->{$_} = [
            sort {
                       $a->{default} <=> $b->{default}
                    || $a->{title} cmp $b->{title}
                } @arr
        ];
    } keys %$h;

    print "Creating menu data\n";
    my $out =  $ENV{PWD} . "/menu_data.js";
    print "--> $out\n";
    open my $fh, ">$out" or die $!;
    print $fh to_json($json);
    close $fh;

    return $json;
}

sub get_peers {
    my ($html, $json) = @_;
    for my $key (keys %$json) {
        print $key . "\n";
        if (grep {$_->{file} eq $html} @{$json->{$key}}) {
            my @peers;
            for my $f (@{$json->{$key}}) {
                my $file = $f->{file};
                my $title = $f->{title};
                my $selected = $file eq $html ? 1 : 0;
                push @peers, { html => $file, title => $title, selected => $selected };
            }
            print Dumper(@peers);
            return @peers;
        }
    }
}


__END__

=head1 OVERVIEW 

    Generate a html files from js files.

=head1 USAGE

    perl gen_html.pl

=cut
