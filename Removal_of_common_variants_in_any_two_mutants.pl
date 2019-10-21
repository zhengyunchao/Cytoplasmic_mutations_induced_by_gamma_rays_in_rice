use strict;
use warnings;
use Getopt::Long; 

sub prtHelp {
        print "\n$0 options:\n\n";
        print "  -i | -inputFile <Input file>\n";
        print "    File format is VCF\n";
        print "  -c | -comparedFile <Compare to file>\n";
        print "    File format is VCF\n";
        print "  -o | -outputFolder <Output folder name/path>\n";
        print "    Output folder should be created if not existing before processing\n";
        print "  -h | -help\n";
        print "    Prints this help\n";
        print "\n";
}

sub prtUsage {
        print "\nUsage: perl $0 <options>\n";
        prtHelp();
}

my $inputFileName = "";
my $compare_to_file = "";
my $outFolder = "";
my $helpAsked;

GetOptions(
                        "i|inputFile=s" => \$inputFileName,
                        "c|comparedFile=s" => \$compare_to_file,
                        "o|outputFolder=s" => \$outFolder,
                        "h|help" => \$helpAsked,
                  ) or die $!;

if ($inputFileName && $compare_to_file && $outFolder){
        print "Options received\n";
} else {
        prtHelp();
        exit;
}

if($helpAsked) {
        prtUsage();
        exit;
}

open(IN,"$inputFileName");
open(OUT,">$outFolder/temporary_file.vcf");
my %hash=&create_genotype_hash("$compare_to_file");
while(<IN>)
{  if($_=~/#/){print OUT $_;next;}
        chomp;
        my ($chrom,$start,$ref)=(split("\t",$_))[0,1,3];
	my $key=$chrom." ".$start;
        if((exists $hash{$key}) && ($ref eq $hash{$key}))	
              {
		print OUT "Filter ",$_,"\n";
         }
else {print OUT $_,"\n";}
 }
sub  create_genotype_hash
{
	my($file_name)=@_;
	my %hash=();
	open(FILE,$file_name);
	while(<FILE>)
	{
  if($_=~/#/){next;}
		chomp;
		my ($chrom,$start,$ref)=(split("\t",$_))[0,1,3];
		$hash{$chrom." ".$start}=$ref;
	}
	return %hash;
}

system(qq(grep -v 'Filter' $outFolder/temporary_file.vcf > $outFolder/Remaining_variants.vcf));
