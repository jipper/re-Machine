#!/usr/bin/perl
# cODEd by jikri Van Buuren -> fb.com/jikri
#
 
use Data::Dumper;
use Thread;
# ########################## DEKLARASI #################### #
my @informationen = 
( 
	{ 
	     APP => 
			[ 
			{
				 NAME => "ngeping", 
				 AKTIF => 1,
				 BINARY => "ping",
				 PARAMETER => " localhost" ,
				 RUN => \&ngeping_main,
				 AKSI => 
					  [
					       qr/icmp_req=(\d+)(.*)time=([0-9]+)\.([0-9]*)(.*)\n/
				  	  ],
				 REAKSI => 
					  [
						\&ngeping_test 
					  ]			
			} 
			]
	}
 
);
# ########################## DEKLARASI #################### #

# ############### Fungsi Callback ############## #
sub ngeping_main
{
	$_ = $_[0];
	$appname = $_->{NAME};
	open($appname,$_->{BINARY}.' '.$_->{PARAMETER}."|") or die "gagal Fork() : $!";
	while(my $res = <$appname>)
	{
	#	chomp($res);
		for($i = 0;$i <= @{ $_->{AKSI} } - 1; $i++)
		{	
			if( $res =~ /$_->{AKSI}[$i]/ )
			{
				$_->{REAKSI}[$i]($1,$2,$3,$4,$5);
			}
		}
	}
}

sub ngeping_test
{
 	print "value : ".$_[0]." -> ".$_[2].",".$_[3]." ms\n";
}
# ############### Fungsi Callback ############## #


sub engine
{	
	$_[0] eq "start" or die "";
	system "clear";
	init();
	algoritma();
	console();
	#starting
}

sub console
{
	while(<STDIN>)
	{
		chomp;
		if($_)
		{
			print "::-> ".$_."\n";
		}
	}
}

sub algoritma
{
	foreach(@informationen)
	{
		if($_->{APP})
		{
			foreach(@{ $_->{APP} })
			{
				if($_->{AKTIF})
				{
					$thread[$_->{NAME}] = threads->new($_->{RUN},$_);
				}
			}

		}
	
	}
}

sub init
{
	my $banner = "\t\t\t".'--------------------'."\n";
	$banner   .= "\t\t\t".'    re-Machine v1.0'."\n";
	$banner   .= "\t\t\t".'   Coded by jikri'."\n";
	$banner   .= "\t\t\t".'--------------------'."\n\n\n";
	print $banner;

	#data struktur konfigurasi
	print "Data Struktur Konfig\t\t";
	(scalar(@informationen) > 0) or die "Failed";
	foreach(@informationen)
	{
		if($_->{APP})
		{
			foreach(@{ $_->{APP} })
			{
				(@{ $_->{AKSI} } == @{ $_->{REAKSI} }) or die "Failed";
				if( !$_->{NAME} || !$_->{BINARY} )
				{
					die "Failed";
				}
			}
		}
		
	}
	print '[OK]'."\n";	
}


engine("start");
