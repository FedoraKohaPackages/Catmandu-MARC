package Catmandu::MARC;

use Catmandu::Util;
use Catmandu::Exporter::MARC::XML;

our $VERSION = '0.218';

sub marc_add {
    my ($data,$marc_tag,$subfield_array) = @_;

    my @subfields  = @{$subfield_array};
    my %subfields  = @subfields;
    my $record_key = $subfields{'-record'} // 'record';
    my $marc       = $data->{$record_key} // [];

    if ($marc_tag =~ /^\w{3}$/) {
        my @field = ();
        push @field , $marc_tag;
        push @field , $subfields{ind1} // ' ';
        push @field , $subfields{ind2} // ' ';


        for (my $i = 0 ; $i < @subfields ; $i += 2) {
            my $code  = $subfields[$i];
            next unless length $code == 1;
            my $value = $subfields[$i+1];

            if ($value =~ /^\$\.(\S+)$/) {
                my $path = $1;
                $value = Catmandu::Util::data_at($path,$data);
            }

            if (Catmandu::Util::is_array_ref $value) {
                for (@$value) {
                    push @field , $code;
                    push @field , $_;
                }
            }
            elsif (Catmandu::Util::is_hash_ref $value) {
                for (keys %$value) {
                    push @field , $code;
                    push @field , $value->{$_};
                }
            }
            elsif (Catmandu::Util::is_value($value) && length($value) > 0) {
                push @field , $code;
                push @field , $value;
            }
        }

        push @{ $marc } , \@field if @field > 3;
    }

    $data->{$record_key} = $marc;

    $data;
}

sub marc_xml {
    my ($data,$path) = @_;
    $path //= 'record';

    my $xml;
    my $exporter = Catmandu::Exporter::MARC::XML->new(file => \$xml , xml_declaration => 0 , collection => 0);
    $exporter->add($data);
    $exporter->commit;

    $data->{$path} = $xml;

    $data;
}

1;

__END__

=head1 NAME

Catmandu::MARC - Catmandu modules for working with MARC data

=begin markdown

# STATUS

[![Build Status](https://travis-ci.org/LibreCat/Catmandu-MARC.svg?branch=master)](https://travis-ci.org/LibreCat/Catmandu-MARC)
[![Coverage](https://coveralls.io/repos/LibreCat/Catmandu-MARC/badge.png?branch=master)](https://coveralls.io/r/LibreCat/Catmandu-MARC)
[![CPANTS kwalitee](http://cpants.cpanauthors.org/dist/Catmandu-MARC.png)](http://cpants.cpanauthors.org/dist/Catmandu-MARC)

=end markdown

=head1 SYNOPSIS

 # On the command line

 $ catmandu convert MARC to JSON < data.mrc

 $ catmandu convert MARC --type MiJ to YAML < data.marc_in_json

 $ catmandu convert MARC --fix "marc_map(245,title)" < data.mrc

 $ catmandu convert MARC --fix myfixes.txt < data.mrc

 myfixes:
 
 marc_map("245a", title)
 marc_map("5**", note.$append)
 marc_map('710','my.authors.$append')
 marc_map('008_/35-35','my.language')
 remove_field(record)
 add_field(my.funny.field,'test123')

 $ catmandu import MARC --fix myfixes.txt to ElasticSearch --index_name 'catmandu' < data.marc

 # In perl
 use Catmandu;

 my $importer = Catmandu->importer('MARC', file => 'data.mrc' );
 my $fixer    = Catmandu->fixer('myfixes.txt');
 my $store    = Catmandu->store('ElasticSearch', index_name => 'catmandu');

 $store->add_many(
 	$fixer->fix($importer)
 );

=head1 MODULES

=over

=item * L<Catmandu::Importer::MARC>

=item * L<Catmandu::Exporter::MARC>

=item * L<Catmandu::Fix::marc_map>

=item * L<Catmandu::Fix::marc_add>

=item * L<Catmandu::Fix::marc_remove>

=item * L<Catmandu::Fix::marc_xml>

=item * L<Catmandu::Fix::marc_in_json>

=item * L<Catmandu::Fix::marc_set>

=item * L<Catmandu::Fix::Bind::marc_each>

=item * L<Catmandu::Fix::Condition::marc_match>

=item * L<Catmandu::Fix::Inline::marc_map>

=item * L<Catmandu::Fix::Inline::marc_add>

=item * L<Catmandu::Fix::Inline::marc_remove>

=back

=head1 DESCRIPTION

With Catmandu, LibreCat tools abstract digital library and research services as data 
warehouse processes. As stores we reuse MongoDB or ElasticSearch providing us with 
developer friendly APIs. Catmandu works with international library standards such as 
MARC, MODS and Dublin Core, protocols such as OAI-PMH, SRU and open repositories such 
as DSpace and Fedora. And, of course, we speak the evolving Semantic Web.

Follow us on L<http://librecat.org> and read an introduction into Catmandu data 
processing at L<https://github.com/LibreCat/Catmandu/wiki>.

=head1 SEE ALSO

L<Catmandu>,
L<Catmandu::Importer>,
L<Catmandu::Fix>,
L<Catmandu::Store>

=head1 AUTHOR

Patrick Hochstenbach, C<< <patrick.hochstenbach at ugent.be> >>

=head1 CONTRIBUTORS

=over

=item * Nicolas Steenlant, C<< <nicolas.steenlant at ugent.be> >>

=item * Nicolas Franck, C<< <nicolas.franck at ugent.be> >>

=item * Johann Rolschewski, C<< jorol at cpan.org >>

=item * Chris Cormack

=item * Robin Sheat

=back

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
