requires 'perl', 'v5.10.1';

on 'test', sub {
  requires 'Test::Simple', '1.001003';
  requires 'Test::More', '1.001003';
  requires 'Test::Deep', '0';
  requires 'XML::XPath', '1.13';
  requires 'Pod::Simple::HTML', '>=3.23';
  requires 'Test::Pod' , '0';
};

requires 'Catmandu', '>=1.0201';
requires 'JSON::XS', '2.3';
requires 'YAML::XS', '0.34';
requires 'MARC::File::XML', '1.0.3';
requires 'MARC::File::MARCMaker', '0.05';
requires 'MARC::File::MiJ' , '0.04';
requires 'MARC::Record', '2.0.6';
requires 'MARC::Parser::RAW', '0';
requires 'Moo', '1.0';
