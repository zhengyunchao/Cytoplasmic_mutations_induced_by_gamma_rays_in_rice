use strict;
use warnings;
use Getopt::Long; 

sub prtHelp {
        print "\n$0 options:\n\n";
        print "--------------------------------- Path To SAMtools ---------------------------------\n";
        print "  -s | -pathToSamtools <Path To SAMtools>\n";
        print "----------------------------------- Input Options ----------------------------------\n";
        print "  -i | -inputFile <Input file>\n";
        print "    Sorted BAM file as input file\n";
        print "  -g | -genomeSize <Chloroplast genome size> <Mitochondrial genome size>\n";
        print "---------------------------------- Output Options ----------------------------------\n";
        print "  -o | -outputFolder <Output folder name/path>\n";
        print "    Output folder should be created if not existing before processing\n";
        print "  -p | -prefixOfOutputFile <Prefix of output file name>\n";
        print "----------------------------------- Other Options ----------------------------------\n";
        print "  -h | -help\n";
        print "    Prints this help\n";
        print "\n";
}

sub prtUsage {
        print "\nUsage: perl $0 <options>\n";
        prtHelp();
}

my $samtools_path = "";
my $inputFileName = "";
my @genome_size = ();
my $outFolder = "";
my $prefix = "";
my $helpAsked;

GetOptions(
                        "s|pathToSamtools=s" => \$samtools_path,
                        "i|inputFile=s" => \$inputFileName,
                        "g|genomeSize=i{2}" => \@genome_size,
                        "o|outputFolder=s" => \$outFolder,
                        "p|prefixOfOutputFile=s" => \$prefix,
                        "h|help" => \$helpAsked,
                  ) or die $!;

if ($samtools_path && $inputFileName && @genome_size && $outFolder && $prefix){
        print "Options received\n";
} else {
        prtHelp();
        exit;
}

if($helpAsked) {
        prtUsage();
        exit;
}

my $average_depth = 0;
my $coverage = 0;

my $all_depth_file = $prefix.'_all.depth';
system(qq($samtools_path depth $inputFileName > $outFolder/$all_depth_file));

my $Pt_depth_file = $prefix.'_Pt.depth';
my $Pt_average_depth_file = $prefix.'_Pt.average_depth';
system(qq(awk '\$1~/Pt/{print}' $outFolder/$all_depth_file > $outFolder/$Pt_depth_file));
open IN, "$outFolder/$Pt_depth_file";
open OUT, ">$outFolder/$Pt_average_depth_file";
my $lines_Pt = 0;
my $bases_Pt = 0;
while(<IN>){
  chomp;
  $lines_Pt++;
  if(/(.+)\t(.+)/){
  $bases_Pt += $2;
  }
}
$average_depth = $bases_Pt/$genome_size[0];
$coverage = $lines_Pt/$genome_size[0];
print OUT "$inputFileName\tCoverage: $coverage\n";
print OUT "$inputFileName\tAverage depth: $average_depth\n";

my $Mt_depth_file = $prefix.'_Mt.depth';
my $Mt_average_depth_file = $prefix.'_Mt.average_depth';
system(qq(awk '\$1~/Mt/{print}' $outFolder/$all_depth_file > $outFolder/$Mt_depth_file));
open IN, "$outFolder/$Mt_depth_file";
open OUT, ">$outFolder/$Mt_average_depth_file";
my $lines_Mt = 0;
my $bases_Mt = 0;
while(<IN>){
  chomp;
  $lines_Mt++;
  if(/(.+)\t(.+)/){
  $bases_Mt += $2;
  }
}
$average_depth = $bases_Mt/$genome_size[1];
$coverage = $lines_Mt/$genome_size[1];
print OUT "$inputFileName\tCoverage: $coverage\n";
print OUT "$inputFileName\tAverage depth: $average_depth\n";

