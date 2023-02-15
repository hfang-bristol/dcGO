package My_dcgo::Controller::Action;
use My_dcgo::Controller::Utils;
use Mojo::Base 'Mojolicious::Controller';
use JSON;
use LWP::Simple;
use List::Util qw( min max sum );
use POSIX qw(strftime);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

# Render template "index.html.ep"
# Render template "demo.html.ep"
sub index_1 {
	my $c = shift;
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGOR');
	my $sth;
	
	## Ontology Information
	my %OBO_INFO = (
		"DO" => 'Disease Ontology (DO)',
		"GOBP" => 'Gene Ontology Biological Process (GOBP)',
		"GOCC" => 'Gene Ontology Cellular Component (GOCC)',
		"GOMF" => 'Gene Ontology Molecular Function (GOMF)',
		"HPO" => 'Human Phenotype Ontology (HPO)',
		"MPO" => 'Mammalian Phenotype Ontology (MPO)',
	);
	## Level Information
	my %LVL_INFO = (
		"SCOPsf" => 'SCOP superfamily',
		"SCOPfa" => 'SCOP family',
		"Pfam" => 'Pfam family',
		"InterPro" => 'InterPro family',
	);
	
	if(0){
		#############
		# json_domain
		#############
		$sth = $dbh->prepare('select id,level,description from Table_domain;');
		$sth->execute();
		if($sth->rows>0){
			my @data_domain;
			while (my @row = $sth->fetchrow_array) {
				my $rec;
				$rec->{id}=$row[0];
				$rec->{level}=$row[1];
				$rec->{level_info}=$LVL_INFO{$row[1]};
				$rec->{description}=$row[2];
			
				push @data_domain,$rec;
			
			}
			print STDERR scalar(@data_domain)."\n";
			$c->stash(json_domain => encode_json(\@data_domain));
		}
		
	}else{
		#############
		# json_scop
		#############
		$sth = $dbh->prepare('select id,level,description from Table_domain where level in ("SCOPsf","SCOPfa");');
		$sth->execute();
		if($sth->rows>0){
			my @data_scop;
			while (my @row = $sth->fetchrow_array) {
				my $rec;
				$rec->{id}=$row[0];
				$rec->{level}=$row[1];
				$rec->{level_info}=$LVL_INFO{$row[1]};
				$rec->{description}=$row[2];
			
				push @data_scop,$rec;
			
			}
			print STDERR scalar(@data_scop)."\n";
			$c->stash(json_scop => encode_json(\@data_scop));
		}
		
		#############
		# json_pfam
		#############
		$sth = $dbh->prepare('select id,level,description from Table_domain where level="Pfam";');
		$sth->execute();
		if($sth->rows>0){
			my @data_pfam;
			while (my @row = $sth->fetchrow_array) {
				my $rec;
				$rec->{id}=$row[0];
				$rec->{level}=$row[1];
				$rec->{level_info}=$LVL_INFO{$row[1]};
				$rec->{description}=$row[2];
			
				push @data_pfam,$rec;
			
			}
			print STDERR scalar(@data_pfam)."\n";
			$c->stash(json_pfam => encode_json(\@data_pfam));
		}
		
	}
	
	#############
	# json_term
	#############
	$sth = $dbh->prepare('select obo,id,name from Table_term;');
	$sth->execute();
	if($sth->rows>0){
		my @data_term;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{obo}=$row[0];
			$rec->{id}=$row[1];
			$rec->{name}=$row[2];
				
			push @data_term,$rec;
		}
		print STDERR scalar(@data_term)."\n";
		$c->stash(json_term => encode_json(\@data_term));
	}
	
	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
  	$c->render();
}

# Render template "dcGO_sitemap.html.ep"
# Render template "dcGO_hie.html.ep"
sub index_default {
	my $c = shift;
  	$c->render();
}

sub booklet {
  	my $c = shift;
	$c->redirect_to("/dcGObooklet/index.html");
}

sub index {
	my $c = shift;
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGOdb');
	my $sth;
	
	## Ontology Information
	my %OBO_INFO = (
		"GOBP" => 'Gene Ontology Biological Process (GOBP)',
		"GOCC" => 'Gene Ontology Cellular Component (GOCC)',
		"GOMF" => 'Gene Ontology Molecular Function (GOMF)',
		"HPO" => 'Human Phenotype Ontology (HPO)',
		"MPO" => 'Mammalian Phenotype Ontology (MPO)',
		"WPO" => 'Worm Phenotype Ontology (WPO)',
		"FPO" => 'Fly Phenotype Ontology (FPO)',
		"FAN" => 'Fly Anatomy (FAN)',
		"ZAN" => 'Zebrafish Anatomy (ZAN)',
		"APO" => 'Arabidopsis Plant Ontology (APO)',
		#"DO" => 'Disease Ontology (DO)',
		"MONDO" => 'Mondo Disease Ontology (MONDO)',
		"EFO" => 'Experimental Factor Ontology (EFO)',
		"DGIdb" => 'DGIdb druggable categories (DGIdb)',
		"Bucket" => 'Target tractability buckets (Bucket)',
		"KEGG" => 'KEGG pathways (KEGG)',
		"REACTOME" => 'REACTOME pathways (REACTOME)',
		"PANTHER" => 'PANTHER pathways (PANTHER)',
		"WKPATH" => 'WiKiPathways pathways (WKPATH)',
		"CTF" => 'ENRICHR Consensus TFs (CTF)',
		"TRRUST" => 'TRRUST TFs (TRRUST)',
		"MSIGDB" => 'MSIGDB Hallmarks (MSIGDB)',
	);
	## Level Information
	my %LVL_INFO = (
		"sf" => 'SCOP superfamily',
		"fa" => 'SCOP family',
		"pfam" => 'Pfam family',
		"interpro" => 'InterPro family',
	);
	
	#############
	# json_scop
	#############
	$sth = $dbh->prepare('select id,level,description from scop_info;');
	$sth->execute();
	if($sth->rows>0){
		my @data_scop;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{id}=$row[0];
			$rec->{level}=$row[1];
			$rec->{level_info}=$LVL_INFO{$row[1]};
			$rec->{description}=$row[2];
			
			push @data_scop,$rec;
			
		}
		print STDERR scalar(@data_scop)."\n";
		$c->stash(json_scop => encode_json(\@data_scop));
	}
		
	#############
	# json_pfam
	#############
	$sth = $dbh->prepare('select id,level,description from pfam_info;');
	$sth->execute();
	if($sth->rows>0){
		my @data_pfam;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{id}=$row[0];
			$rec->{level}=$row[1];
			$rec->{level_info}=$LVL_INFO{$row[1]};
			$rec->{description}=$row[2];
			
			push @data_pfam,$rec;
			
		}
		print STDERR scalar(@data_pfam)."\n";
		$c->stash(json_pfam => encode_json(\@data_pfam));
	}
	
	#############
	# json_interpro
	#############
	$sth = $dbh->prepare('select id,level,description from interpro_info;');
	$sth->execute();
	if($sth->rows>0){
		my @data_interpro;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{id}=$row[0];
			$rec->{level}=$row[1];
			$rec->{level_info}=$LVL_INFO{$row[1]};
			$rec->{description}=$row[2];
			
			push @data_interpro,$rec;
			
		}
		print STDERR scalar(@data_interpro)."\n";
		$c->stash(json_interpro => encode_json(\@data_interpro));
	}
	
	#############
	# json_term
	#############
	$sth = $dbh->prepare('select obo,id,name from term_info;');
	$sth->execute();
	if($sth->rows>0){
		my @data_term;
		while (my @row = $sth->fetchrow_array) {
			
			######################################
			# what to show controlled by %OBO_INFO
			######################################
			if(exists($OBO_INFO{$row[0]})){
				my $rec;
				$rec->{obo}=$row[0];
				$rec->{id}=$row[1];
				$rec->{name}=$row[2];
				push @data_term,$rec;				
			}
			
		}
		print STDERR scalar(@data_term)."\n";
		$c->stash(json_term => encode_json(\@data_term));
	}
	
	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
  	$c->render();
}

# Render template "dcGO_level_domain.html.ep"
sub dcGO_level_domain {
	my $c = shift;

	my $level= $c->param("level");
	my $domain= $c->param("domain") || 53118;
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGOdb');
	my $sth;
	
	##############
	# http://127.0.0.1:3080/dcGO/fa/53118
	# http://127.0.0.1:3080/dcGO/sf/53098
	# http://127.0.0.1:3080/dcGO/pfam/PF00001
	# http://127.0.0.1:3080/dcGO/interpro/IPR000001
	my $domain_data; # reference or ''
	my $json = ""; # json or ''
	##############
	
	## Ontology Information
	my %OBO_INFO = (
		"GOBP" => 'Gene Ontology Biological Process (GOBP)',
		"GOCC" => 'Gene Ontology Cellular Component (GOCC)',
		"GOMF" => 'Gene Ontology Molecular Function (GOMF)',
		"HPO" => 'Human Phenotype Ontology (HPO)',
		"MPO" => 'Mammalian Phenotype Ontology (MPO)',
		"WPO" => 'Worm Phenotype Ontology (WPO)',
		"FPO" => 'Fly Phenotype Ontology (FPO)',
		"FAN" => 'Fly Anatomy (FAN)',
		"ZAN" => 'Zebrafish Anatomy (ZAN)',
		"APO" => 'Arabidopsis Plant Ontology (APO)',
		#"DO" => 'Disease Ontology (DO)',
		"MONDO" => 'Mondo Disease Ontology (MONDO)',
		"EFO" => 'Experimental Factor Ontology (EFO)',
		"DGIdb" => 'DGIdb druggable categories (DGIdb)',
		"Bucket" => 'Target tractability buckets (Bucket)',
		"KEGG" => 'KEGG pathways (KEGG)',
		"REACTOME" => 'REACTOME pathways (REACTOME)',
		"PANTHER" => 'PANTHER pathways (PANTHER)',
		"WKPATH" => 'WiKiPathway pathways (WKPATH)',
		"MITOPATH" => "MitoPathway pathways (MITOPATH)",
		"CTF" => 'ENRICHR Consensus TFs (CTF)',
		"TRRUST" => 'TRRUST TFs (TRRUST)',
		"MSIGDB" => 'MSIGDB Hallmarks (MSIGDB)',
	);
	## Level Information
	my %LVL_INFO = (
		"sf" => 'SCOP superfamily',
		"fa" => 'SCOP family',
		"pfam" => 'Pfam family',
		"interpro" => 'InterPro family',
	);
	
	if($level eq "sf" or $level eq "fa"){
		#SELECT id,description FROM scop_info WHERE level="sf" AND id=158235;
		$sth = $dbh->prepare( 'SELECT id,description FROM scop_info WHERE level=? AND id=?;' );
		$sth->execute($level,$domain);
		if($sth->rows > 0){
			$domain_data=$sth->fetchrow_hashref;
			$domain_data->{level}=$LVL_INFO{$level};
			$domain_data->{scop}="";
			if($level eq "sf"){
				#SELECT parent,child FROM scop_hie WHERE parent=46785;
				my $sth1 = $dbh->prepare( 'SELECT parent,child FROM scop_hie WHERE parent=?;' );
				$sth1->execute($domain);
				if($sth1->rows > 0){
					while (my @row = $sth1->fetchrow_array) {
						$domain_data->{scop}.="<a href='/dcGO/fa/".$row[1]."'><i class='fa fa-diamond 1x'></i>&nbsp;".$row[1]."</a> | ";
					}
					$domain_data->{scop}=~s/ \| $//g;
				}
				$sth1->finish();
			}elsif($level eq "fa"){
				#SELECT parent,child FROM scop_hie WHERE child=158236;
				my $sth1 = $dbh->prepare( 'SELECT parent,child FROM scop_hie WHERE child=?;' );
				$sth1->execute($domain);
				if($sth1->rows > 0){
					while (my @row = $sth1->fetchrow_array) {
						$domain_data->{scop}.="<a href='/dcGO/fa/".$row[0]."'><i class='fa fa-diamond 1x'></i>&nbsp;".$row[0]."</a> | ";
					}
					$domain_data->{scop}=~s/ \| $//g;
				}
				$sth1->finish();
			}
		}else{
			$domain_data="";
		}
		$sth->finish();
	
	}elsif($level eq "pfam"){
		#SELECT id,description FROM pfam_info WHERE id="PF00096";
		$sth = $dbh->prepare( 'SELECT id,description FROM pfam_info WHERE id=?;' );
		$sth->execute($domain);
		if($sth->rows > 0){
			$domain_data=$sth->fetchrow_hashref;
			$domain_data->{level}=$LVL_INFO{$level};
		}else{
			$domain_data="";
		}
		$sth->finish();
		
	}elsif($level eq "interpro"){
		#SELECT id,description FROM interpro_info WHERE id="IPR000001";
		$sth = $dbh->prepare( 'SELECT id,description FROM interpro_info WHERE id=?;' );
		$sth->execute($domain);
		if($sth->rows > 0){
			$domain_data=$sth->fetchrow_hashref;
			$domain_data->{level}=$LVL_INFO{$level};
		}else{
			$domain_data="";
		}
		$sth->finish();
		
	}
	$c->stash(domain_data => $domain_data);
	
	
	#SELECT des.id AS id, des.description AS description, des.classification AS classification, hie.parent AS parent FROM des, hie WHERE hie.id=des.id AND des.id=53118;
	
	if($level eq "sf" or $level eq "fa"){
		#SELECT a.domain_id AS did, b.obo AS obo, b.id AS oid, b.name AS oname, a.ascore AS score FROM mapping_scop as a, term_info as b WHERE a.obo=b.obo AND a.term_id=b.id AND a.domain_id=158236 AND a.term_id!="root" ORDER BY b.obo ASC, a.ascore DESC;
		$sth = $dbh->prepare('SELECT a.domain_id AS did, b.obo AS obo, b.id AS oid, b.name AS oname, a.ascore AS score FROM mapping_scop as a, term_info as b WHERE a.obo=b.obo AND a.term_id=b.id AND a.domain_id=? AND a.term_id!="root" ORDER BY b.obo ASC, a.ascore DESC;');
		$sth->execute($domain);
		
	}elsif($level eq "pfam"){
		#SELECT a.domain_id AS did, b.obo AS obo, b.id AS oid, b.name AS oname, a.ascore AS score FROM mapping_pfam as a, term_info as b WHERE a.obo=b.obo AND a.term_id=b.id AND a.domain_id='PF00001' AND a.term_id!="root" ORDER BY b.obo ASC, a.ascore DESC;
		$sth = $dbh->prepare('SELECT a.domain_id AS did, b.obo AS obo, b.id AS oid, b.name AS oname, a.ascore AS score FROM mapping_pfam as a, term_info as b WHERE a.obo=b.obo AND a.term_id=b.id AND a.domain_id=? AND a.term_id!="root" ORDER BY b.obo ASC, a.ascore DESC;');
		$sth->execute($domain);
		
	}elsif($level eq "interpro"){
		#SELECT a.domain_id AS did, b.obo AS obo, b.id AS oid, b.name AS oname, a.ascore AS score FROM mapping_interpro as a, term_info as b WHERE a.obo=b.obo AND a.term_id=b.id AND a.domain_id='IPR000001' AND a.term_id!="root" ORDER BY b.obo ASC, a.ascore DESC;
		$sth = $dbh->prepare('SELECT a.domain_id AS did, b.obo AS obo, b.id AS oid, b.name AS oname, a.ascore AS score FROM mapping_interpro as a, term_info as b WHERE a.obo=b.obo AND a.term_id=b.id AND a.domain_id=? AND a.term_id!="root" ORDER BY b.obo ASC, a.ascore DESC;');
		$sth->execute($domain);
		
	}

	$json = "";
	if($sth->rows > 0){
		my @data;
		while (my @row = $sth->fetchrow_array) {
		
			######################################
			# what to show controlled by %OBO_INFO
			######################################
			if(exists($OBO_INFO{$row[1]})){
				my $rec;
				$rec->{did}=$row[0];
				$rec->{obo}=$row[1];
				$rec->{obo_info}=$OBO_INFO{$row[1]};
				$rec->{oid}="<a href='/dcGO/".$row[1]."/".$row[2]."' target='_blank'><i class='fa fa-text-width fa-1x'></i></a>&nbsp;&nbsp;".$row[2];
				$rec->{oname}=$row[3];
				$rec->{score}=$row[4];
				push @data,$rec;
			}
			
		}
		print STDERR scalar(@data)."\n";
		$json = encode_json(\@data);
	}
	$sth->finish();
	$c->stash(rec_anno => $json);
	
	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
	$c->render();
}


# Render template "dcGO_obo_term.html.ep"
sub dcGO_obo_term {
	my $c = shift;

	my $obo= $c->param("obo");
	my $term= $c->param("term") || "GO:0008150";
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGOdb');
	my $sth;
	
	##############
	# http://127.0.0.1:3080/dcGO/GOBP/GO:0002376
	# http://127.0.0.1:3080/dcGO/PANTHER/P00011
	my $term_data; # reference or ''
	my $json = ""; # json or ''
	##############
		
	## Ontology Information
	my %OBO_INFO = (
		"GOBP" => 'Gene Ontology Biological Process (GOBP)',
		"GOCC" => 'Gene Ontology Cellular Component (GOCC)',
		"GOMF" => 'Gene Ontology Molecular Function (GOMF)',
		"HPO" => 'Human Phenotype Ontology (HPO)',
		"MPO" => 'Mammalian Phenotype Ontology (MPO)',
		"WPO" => 'Worm Phenotype Ontology (WPO)',
		"FPO" => 'Fly Phenotype Ontology (FPO)',
		"FAN" => 'Fly Anatomy (FAN)',
		"ZAN" => 'Zebrafish Anatomy (ZAN)',
		"APO" => 'Arabidopsis Plant Ontology (APO)',
		#"DO" => 'Disease Ontology (DO)',
		"MONDO" => 'Mondo Disease Ontology (MONDO)',
		"EFO" => 'Experimental Factor Ontology (EFO)',
		"DGIdb" => 'DGIdb druggable categories (DGIdb)',
		"Bucket" => 'Target tractability buckets (Bucket)',
		"KEGG" => 'KEGG pathways (KEGG)',
		"REACTOME" => 'REACTOME pathways (REACTOME)',
		"PANTHER" => 'PANTHER pathways (PANTHER)',
		"WKPATH" => 'WiKiPathway pathways (WKPATH)',
		"MITOPATH" => "MitoPathway pathways (MITOPATH)",
		"CTF" => 'ENRICHR Consensus TFs (CTF)',
		"TRRUST" => 'TRRUST TFs (TRRUST)',
		"MSIGDB" => 'MSIGDB Hallmarks (MSIGDB)',
	);
	## Level Information
	my %LVL_INFO = (
		"sf" => 'SCOP superfamily',
		"fa" => 'SCOP family',
		"pfam" => 'Pfam family',
		"interpro" => 'InterPro family',
	);


	if(exists($OBO_INFO{$obo})){
		#SELECT id,name FROM term_info WHERE obo="Bucket" AND id="AB:1";
		$sth = $dbh->prepare( 'SELECT id,name FROM term_info WHERE obo=? AND id=?;' );
		$sth->execute($obo,$term);
		$term_data=$sth->fetchrow_hashref;
		$term_data->{obo}=$obo;
		$term_data->{obo_info}=$OBO_INFO{$obo};
		if(!$term_data->{id}){
			#return $c->reply->not_found;
			$term_data="";
		}
		$sth->finish();
		
	}
	$c->stash(term_data => $term_data);
	
	################
	# scop
	################
	#SELECT b.level AS dlvl, b.id AS did, b.description AS ddes, a.ascore AS score FROM mapping_scop as a, scop_info as b WHERE a.domain_id=b.id AND a.obo="GOBP" AND a.term_id="GO:0002376" ORDER BY b.level ASC, a.ascore DESC;
	
	#SELECT b.level AS dlvl, b.id AS did, b.description AS ddes, a.ascore AS score FROM mapping_scop as a, scop_info as b WHERE a.domain_id=b.id AND a.obo="FPO" AND a.term_id="FBcv:0000347" ORDER BY b.level ASC, a.ascore DESC;
	
	$sth = $dbh->prepare('SELECT b.level AS dlvl, b.id AS did, b.description AS ddes, a.ascore AS score FROM mapping_scop as a, scop_info as b WHERE a.domain_id=b.id AND a.obo=? AND a.term_id=? ORDER BY b.level ASC, a.ascore DESC;');
	$sth->execute($obo,$term);
	$json = "";
	if($sth->rows > 0){
		my @data;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{oid}=$term;
			$rec->{dlvl}=$LVL_INFO{$row[0]};
			$rec->{did}="<a href='/dcGO/".$row[0]."/".$row[1]."' target='_blank'><i class='fa fa-diamond fa-1x'></i></a>&nbsp;&nbsp;".$row[1];
			$rec->{ddes}=$row[2];
			$rec->{score}=$row[3];
			
			push @data,$rec;
		}
		print STDERR scalar(@data)."\n";
		$json = encode_json(\@data);
	}
	$sth->finish();
	$c->stash(rec_anno_scop => $json);


	################
	# pfam
	################
	#SELECT b.level AS dlvl, b.id AS did, b.description AS ddes, a.ascore AS score FROM mapping_pfam as a, pfam_info as b WHERE a.domain_id=b.id AND a.obo="GOBP" AND a.term_id="GO:0002376" ORDER BY b.level ASC, a.ascore DESC;
	
	#SELECT b.level AS dlvl, b.id AS did, b.description AS ddes, a.ascore AS score FROM mapping_pfam as a, pfam_info as b WHERE a.domain_id=b.id AND a.obo="FPO" AND a.term_id="FBcv:0000347" ORDER BY b.level ASC, a.ascore DESC;
	
	$sth = $dbh->prepare('SELECT b.level AS dlvl, b.id AS did, b.description AS ddes, a.ascore AS score FROM mapping_pfam as a, pfam_info as b WHERE a.domain_id=b.id AND a.obo=? AND a.term_id=? ORDER BY b.level ASC, a.ascore DESC;');
	$sth->execute($obo,$term);
	$json = "";
	if($sth->rows > 0){
		my @data;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{oid}=$term;
			$rec->{dlvl}=$LVL_INFO{$row[0]};
			$rec->{did}="<a href='/dcGO/".$row[0]."/".$row[1]."' target='_blank'><i class='fa fa-diamond fa-1x'></i></a>&nbsp;&nbsp;".$row[1];
			$rec->{ddes}=$row[2];
			$rec->{score}=$row[3];
			
			push @data,$rec;
		}
		print STDERR scalar(@data)."\n";
		$json = encode_json(\@data);
	}
	$sth->finish();
	$c->stash(rec_anno_pfam => $json);
	
	
	################
	# interpro
	################
	#SELECT b.level AS dlvl, b.id AS did, b.description AS ddes, a.ascore AS score FROM mapping_interpro as a, interpro_info as b WHERE a.domain_id=b.id AND a.obo="PANTHER" AND a.term_id="P00011" ORDER BY b.level ASC, a.ascore DESC;
	
	$sth = $dbh->prepare('SELECT b.level AS dlvl, b.id AS did, b.description AS ddes, a.ascore AS score FROM mapping_interpro as a, interpro_info as b WHERE a.domain_id=b.id AND a.obo=? AND a.term_id=? ORDER BY b.level ASC, a.ascore DESC;');
	$sth->execute($obo,$term);
	$json = "";
	if($sth->rows > 0){
		my @data;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{oid}=$term;
			$rec->{dlvl}=$LVL_INFO{$row[0]};
			$rec->{did}="<a href='/dcGO/".$row[0]."/".$row[1]."' target='_blank'><i class='fa fa-diamond fa-1x'></i></a>&nbsp;&nbsp;".$row[1];
			$rec->{ddes}=$row[2];
			$rec->{score}=$row[3];
			
			push @data,$rec;
		}
		print STDERR scalar(@data)."\n";
		$json = encode_json(\@data);
	}
	$sth->finish();
	$c->stash(rec_anno_interpro => $json);
	
	
	################
	# crosslink
	################
	my @crosslink;
	$json = "";
	
	#SELECT a.source_id AS query, a.target AS obo, a.target_id AS oid, b.name AS oname, a.zscore AS zscore, a.adjp AS fdr FROM crosslink as a, term_info as b WHERE a.target=b.obo AND a.target_id=b.id AND a.source="DO" AND a.source_id="DOID:0014667" ORDER BY obo ASC, zscore DESC;
	$sth = $dbh->prepare('SELECT a.source_id AS query, a.target AS obo, a.target_id AS oid, b.name AS oname, a.zscore AS zscore, a.adjp AS fdr FROM crosslink as a, term_info as b WHERE a.target=b.obo AND a.target_id=b.id AND a.source=? AND a.source_id=? ORDER BY obo ASC, zscore DESC;');
	$sth->execute($obo,$term);
	if($sth->rows > 0){
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{query}=$row[0];
			$rec->{obo}=$row[1];
			$rec->{obo_info}=$OBO_INFO{$row[1]};
			$rec->{oid}="<a href='/dcGO/".$row[1]."/".$row[2]."' target='_blank'><i class='fa fa-text-width fa-1x'></i></a>&nbsp;&nbsp;".$row[2];
			#$rec->{oid}=$row[2];
			$rec->{oname}=$row[3];
			$rec->{zscore}=$row[4];
			$rec->{fdr}=$row[5];
			
			push @crosslink,$rec;
		}
	}
	$sth->finish();
	
	# SELECT a.target_id AS query, a.source AS obo, a.source_id AS oid, b.name AS oname, a.zscore AS zscore, a.adjp AS fdr FROM Table_crosslink as a, Table_term_info as b WHERE a.source=b.obo AND a.source_id=b.id AND a.target="HPO" AND a.target_id="HP:0001939" ORDER BY obo ASC, zscore DESC;
	$sth = $dbh->prepare('SELECT a.target_id AS query, a.source AS obo, a.source_id AS oid, b.name AS oname, a.zscore AS zscore, a.adjp AS fdr FROM crosslink as a, term_info as b WHERE a.source=b.obo AND a.source_id=b.id AND a.target=? AND a.target_id=? ORDER BY obo ASC, zscore DESC;');
	$sth->execute($obo,$term);
	if($sth->rows > 0){
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{query}=$row[0];
			$rec->{obo}=$row[1];
			$rec->{obo_info}=$OBO_INFO{$row[1]};
			$rec->{oid}="<a href='/dcGO/".$row[1]."/".$row[2]."' target='_blank'><i class='fa fa-text-width fa-1x'></i></a>&nbsp;&nbsp;".$row[2];
			#$rec->{oid}=$row[2];
			$rec->{oname}=$row[3];
			$rec->{zscore}=$row[4];
			$rec->{fdr}=$row[5];
			
			push @crosslink,$rec;
		}
	}
	$sth->finish();

	print STDERR scalar(@crosslink)."\n";
	if(scalar(@crosslink) > 0){
		$json = encode_json(\@crosslink);
	}
	$c->stash(rec_crosslink => $json);
	
	
	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
	$c->render();
}


# Render template "dcGO_hie_obo_term.html.ep"
sub dcGO_hie_obo_term {
	my $c = shift;

	my $obo= $c->param("obo");
	my $term= $c->param("term") || "root";
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGOdb');
	my $sth;
	
	## Ontology Information
	my %OBO_INFO = (
		"GOBP" => 'Gene Ontology Biological Process (GOBP)',
		"GOCC" => 'Gene Ontology Cellular Component (GOCC)',
		"GOMF" => 'Gene Ontology Molecular Function (GOMF)',
		"HPO" => 'Human Phenotype Ontology (HPO)',
		"MPO" => 'Mammalian Phenotype Ontology (MPO)',
		"WPO" => 'Worm Phenotype Ontology (WPO)',
		"FPO" => 'Fly Phenotype Ontology (FPO)',
		"FAN" => 'Fly Anatomy (FAN)',
		"ZAN" => 'Zebrafish Anatomy (ZAN)',
		"APO" => 'Arabidopsis Plant Ontology (APO)',
		#"DO" => 'Disease Ontology (DO)',
		"MONDO" => 'Mondo Disease Ontology (MONDO)',
		"EFO" => 'Experimental Factor Ontology (EFO)',
		"DGIdb" => 'DGIdb druggable categories (DGIdb)',
		"Bucket" => 'Target tractability buckets (Bucket)',
		"KEGG" => 'KEGG pathways (KEGG)',
		"REACTOME" => 'REACTOME pathways (REACTOME)',
		"PANTHER" => 'PANTHER pathways (PANTHER)',
		"WKPATH" => 'WiKiPathway pathways (WKPATH)',
		"MITOPATH" => "MitoPathway pathways (MITOPATH)",
		"CTF" => 'ENRICHR Consensus TFs (CTF)',
		"TRRUST" => 'TRRUST TFs (TRRUST)',
		"MSIGDB" => 'MSIGDB Hallmarks (MSIGDB)',
	);

	# http://127.0.0.1:3080/dcGO/hie/GOBP/root

	##########
	## rec_term
	## rec_term_child
	
	my $term_data;
	my $json = "";
	
	if($obo eq 'KEGG' or $obo eq 'MSIGDB' or $obo eq 'DGIdb' or $obo eq 'PANTHER' or $obo eq 'WKPATH' or $obo eq 'CTF' or $obo eq 'TRRUST'){
		if($term eq 'root'){
		
			$term_data->{obo}=$OBO_INFO{$obo};
			$term_data->{id}=$term;
			$term_data->{name}=$term;
		
			#SELECT obo,id,name FROM term_info WHERE obo="KEGG" limit 10;
			$sth = $dbh->prepare( 'SELECT obo,id,name FROM term_info WHERE obo=?;' );
			$sth->execute($obo);
			if($sth->rows > 0){
				my @data;
				while (my @row = $sth->fetchrow_array) {
					my $rec;
					$rec->{obo}=$row[0];
					$rec->{id}=$row[1];
					$rec->{name}=$row[2];
					
					my $hie="<i class='fa fa-sitemap fa-1x'></i>&nbsp;&nbsp;";
					$rec->{hie}=$hie;
					
					my $anno="<a href='/dcGO/".$row[0]."/".$row[1]."' target='_blank'><i class='fa fa-text-width fa-1x'></i></a>&nbsp;&nbsp;".$row[1];
					$rec->{anno}=$anno;
					
					#my $hie_anno="<i class='fa fa-sitemap fa-1x'></i>&nbsp;&nbsp;|&nbsp;&nbsp;"."<a href='/dcGO/".$row[0]."/".$row[1]."' target='_blank'><i class='fa fa-text-width fa-1x'></i></a>";
					#$rec->{hie_anno}=$hie_anno;
					
					push @data,$rec;
				}
				$term_data->{children}=scalar(@data);
				print STDERR scalar(@data)."\n";
				$json = encode_json(\@data);
		
			}
			$sth->finish();

		}else{
			$term_data="";
		}
		
	}else{
	
		if(exists($OBO_INFO{$obo})){
		
			if($term eq 'root'){
				#SELECT DISTINCT a.obo as obo, a.parent as id, b.name as name FROM term_hie as a, term_info as b WHERE a.obo=b.obo AND a.parent=b.id AND a.obo="MITOPATH" AND a.root="yes";
				
				#SELECT * FROM term_hie as a WHERE a.obo="MITOPATH";
				
				$sth = $dbh->prepare( 'SELECT DISTINCT a.obo as obo, a.parent as id, b.name as name FROM term_hie as a, term_info as b WHERE a.obo=b.obo AND a.parent=b.id AND a.obo=? AND a.root="yes";' );
				$sth->execute($obo);
				if($sth->rows > 0){
					$term_data=$sth->fetchrow_hashref;
					$term_data->{obo}=$OBO_INFO{$obo};
				}else{
					$term_data="";
				}
				$sth->finish();
			
				#SELECT a.obo,a.child,b.name FROM term_hie as a, term_info as b WHERE a.obo=b.obo AND a.child=b.id AND a.obo="GOBP" AND a.root="yes";
				$sth = $dbh->prepare( 'SELECT a.obo,a.child,b.name FROM term_hie as a, term_info as b WHERE a.obo=b.obo AND a.child=b.id AND a.obo=? AND a.root="yes";' );
				$sth->execute($obo);
				if($sth->rows > 0){
					my @data;
					while (my @row = $sth->fetchrow_array) {
						my $rec;
						$rec->{obo}=$row[0];
						$rec->{id}=$row[1];
						$rec->{name}=$row[2];
					
						my $hie="<a href='/dcGO/hie/".$row[0]."/".$row[1]."'<i class='fa fa-sitemap fa-1x'></i></a>&nbsp;&nbsp;";
						$rec->{hie}=$hie;
					
						my $anno="<a href='/dcGO/".$row[0]."/".$row[1]."' target='_blank'><i class='fa fa-text-width fa-1x'></i></a>&nbsp;&nbsp;".$row[1];
						$rec->{anno}=$anno;
			
						push @data,$rec;
					}
					$term_data->{children}=scalar(@data);
					print STDERR scalar(@data)."\n";
					$json = encode_json(\@data);
		
				}
				$sth->finish();
			
			}else{
				#SELECT DISTINCT obo, id, name FROM term_info WHERE obo="GOBP" AND id="GO:0007339";
				$sth = $dbh->prepare( 'SELECT obo, id, name FROM term_info WHERE obo=? AND id=?;' );
				$sth->execute($obo,$term);
				if($sth->rows > 0){
					$term_data=$sth->fetchrow_hashref;
					$term_data->{obo}=$OBO_INFO{$obo};
				}else{
					$term_data="";
				}
				$sth->finish();

				#SELECT a.obo,a.child,b.name FROM term_hie as a, term_info as b WHERE a.obo=b.obo AND a.child=b.id AND a.obo="GOBP" AND a.parent="GO:0001892";
				$sth = $dbh->prepare( 'SELECT a.obo,a.child,b.name FROM term_hie as a, term_info as b WHERE a.obo=b.obo AND a.child=b.id AND a.obo=? AND a.parent=?;' );
				$sth->execute($obo,$term);
				if($sth->rows > 0){
					my @data;
					while (my @row = $sth->fetchrow_array) {
						my $rec;
						$rec->{obo}=$row[0];
						$rec->{id}=$row[1];
						$rec->{name}=$row[2];
					
						my $hie="<a href='/dcGO/hie/".$row[0]."/".$row[1]."'><i class='fa fa-sitemap fa-1x'></i></a>&nbsp;&nbsp;";
						$rec->{hie}=$hie;
					
						my $anno="<a href='/dcGO/".$row[0]."/".$row[1]."' target='_blank'><i class='fa fa-text-width fa-1x'></i></a>&nbsp;&nbsp;".$row[1];
						$rec->{anno}=$anno;
						
						push @data,$rec;
					}
					$term_data->{children}=scalar(@data);
					print STDERR scalar(@data)."\n";
					$json = encode_json(\@data);
		
				}
				$sth->finish();
			
			}
		
		}
	
	}

	$c->stash(term_data => $term_data);
	$c->stash(rec_term_child => $json);

	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
	$c->render();
}

# Render template "dcGO_enrichment.html.ep"
sub dcGO_enrichment {
  	my $c = shift;
	
	my $ip = $c->tx->remote_address;
	print STDERR "Remote IP address: $ip\n";
	
	my $host = $c->req->url->to_abs->host;
	my $port = $c->req->url->to_abs->port;
	my $host_port = "http://".$host.":".$port."/";
	print STDERR "Server available at ".$host_port."\n";
	
	if($c->req->is_limit_exceeded){
		return $c->render(status => 400, json => { message => 'File is too big.' });
	}
	
	my $domain_type = $c->param('domain_type') || 'pfam'; # by default: pfam
  	my $domainlist = $c->param('domainlist');
  	my $obo = $c->param('obo') || 'GOMF'; # by default: GOMF
  	
	my $significance_threshold = $c->param('significance_threshold') || 0.05;
	my $min_overlap = $c->param('min_overlap') || 5;
  	
  	# The output json file (default: '')
	my $ajax_txt_file='';
  	# The output html file (default: '')
	my $ajax_rmd_html_file='';
	
	# The output _priority.xlsx file (default: '')
	my $ajax_priority_xlsx_file='';
  	
	# The output _manhattan.pdf file (default: '')
	my $ajax_manhattan_pdf_file='';
  	
  	if(defined($domainlist)){
		my $tmpFolder = $My_dcgo::Controller::Utils::tmpFolder; # public/tmp
		
		# 14 digits: year+month+day+hour+minute+second
		my $datestring = strftime "%Y%m%d%H%M%S", localtime;
		# 2 randomly generated digits
		my $rand_number = int rand 99;
		my $digit16 =$datestring.$rand_number."_".$ip;

		my $input_filename=$tmpFolder.'/'.'data.Domains.'.$digit16.'.txt';
		my $output_filename=$tmpFolder.'/'.'enrichment.Domains.'.$digit16.'.txt';
		my $rscript_filename=$tmpFolder.'/'.'enrichment.Domains.'.$digit16.'.r';
	
		my $my_input="";
		my $line_counts=0;
		foreach my $line (split(/\r\n|\n/, $domainlist)) {
			next if($line=~/^\s*$/);
			$line=~s/\s+/\t/;
			$my_input.=$line."\n";
			
			$line_counts++;
		}
		# at least two lines otherwise no $input_filename written
		if($line_counts >=2){
			My_dcgo::Controller::Utils::export_to_file($input_filename, $my_input);
		}
		
		my $placeholder;
		if(-e '/Users/hfang/Sites/SVN/github/bigdata_fdb'){
			# mac
			$placeholder="/Users/hfang/Sites/SVN/github/bigdata_fdb";
		}elsif(-e '/var/www/bigdata_fdb'){
			# huawei
			$placeholder="/var/www/bigdata_fdb";
		}
		
##########################################
# BEGIN: R
##########################################
my $my_rscript='
#!/home/hfang/R-3.6.2/bin/Rscript --vanilla
#/home/hfang/R-3.6.2/lib/R/library
# rm -rf /home/hfang/R-3.6.2/lib/R/library/00*
# Call R script, either using one of two following options:
# 1) R --vanilla < $rscript_file; 2) Rscript $rscript_file
';

# for generating R function
$my_rscript.='
R_pipeline <- function (input.file="", output.file="", domain.type="", obo="", significance.threshold="", min.overlap="", placeholder="", host.port="", ...){
	
	sT <- Sys.time()
	
	# for test
	if(0){
		#cd ~/Sites/XGR/dcGO-site
		placeholder <- "/Users/hfang/Sites/SVN/github/bigdata_fdb"
		
		domain.type <- "pfam"
		input.file <- "~/Sites/XGR/dcGO-site/my_dcgo/public/app/examples/eg_Pfam.txt"
		
		domain.type <- "sf"
		input.file <- "~/Sites/XGR/dcGO-site/my_dcgo/public/app/examples/eg_SF.txt"
		
		data <- read_delim(input.file, delim="\t", col_names=F) %>% as.data.frame() %>% pull(1)
		significance.threshold <- 0.05
		min.overlap <- 3
		obo <- "GOMF"
		obo <- "MONDO"
	}
	
	# read input file
	data <- read_delim(input.file, delim="\t", col_names=F) %>% as.data.frame() %>% pull(1)
	
	if(significance.threshold == "NULL"){
		significance.threshold <- 1
	}else{
		significance.threshold <- as.numeric(significance.threshold)
	}
	
	min.overlap <- as.numeric(min.overlap)

	set <- oRDS(str_c("dcGOdb.SET.", domain.type, "2", obo), placeholder=placeholder)
	background <- set$domain_info %>% pull(id)
	eset <- oSEA(data, set, background, test="fisher", min.overlap=min.overlap)

	if(class(eset)=="eSET"){
		# *_enrichment.txt
		df_eTerm <- eset %>% oSEAextract() %>% filter(adjp < significance.threshold)
		df_eTerm %>% write_delim(output.file, delim="\t")
		
		# *_enrichment.xlsx
		output.file.enrichment <- gsub(".txt$", ".xlsx", output.file, perl=T)
		df_eTerm %>% openxlsx::write.xlsx(output.file.enrichment)
		#df_eTerm %>% openxlsx::write.xlsx("/Users/hfang/Sites/XGR/dcGO-site/app/examples/dcGO_enrichment.xlsx")
		
		# Dotplot
		message(sprintf("Drawing dotplot (%s) ...", as.character(Sys.time())), appendLF=TRUE)
		gp_dotplot <- df_eTerm %>% mutate(name=str_c(id," (",name,")")) %>% oSEAdotplot(FDR.cutoff=0.05, label.top=5, size.title="Number of domains")		
		output.file.dotplot.pdf <- gsub(".txt$", "_dotplot.pdf", output.file, perl=T)
		#output.file.dotplot.pdf <-  "/Users/hfang/Sites/XGR/dcGO-site/app/examples/dcGO_enrichment_dotplot.pdf"
		ggsave(output.file.dotplot.pdf, gp_dotplot, device=cairo_pdf, width=5, height=4)
		output.file.dotplot.png <- gsub(".txt$", "_dotplot.png", output.file, perl=T)
		ggsave(output.file.dotplot.png, gp_dotplot, type="cairo", width=4, height=3)
		# Forest plot
		if(0){
			gp_forest <- df_eTerm %>% mutate(name=str_c(id," (",name,")")) %>% oSEAforest(top=10, colormap="ggplot2.top", legend.direction=c("auto","horizontal","vertical")[3], sortBy=c("or","none")[1])		
			output.file.forest.pdf <- gsub(".txt$", "_forest.pdf", output.file, perl=T)
			#output.file.forest.pdf <-  "/Users/hfang/Sites/XGR/dcGO-site/app/examples/dcGO_enrichment_forest.pdf"
			ggsave(output.file.forest.pdf, gp_forest, device=cairo_pdf, width=5, height=4)
			output.file.forest.png <- gsub(".txt$", "_forest.png", output.file, perl=T)
			ggsave(output.file.forest.png, gp_forest, type="cairo", width=5, height=4)
		}
		
		######################################
		# RMD
		## R at /Users/hfang/Sites/XGR/dcGO-site/pier_app/public
		## but outputs at public/tmp/eV2CG.SNPs.STRING_high.72959383_priority.xlsx
		######################################
		message(sprintf("RMD (%s) ...", as.character(Sys.time())), appendLF=TRUE)
		
		if(1){
		
		eT <- Sys.time()
		runtime <- as.numeric(difftime(strptime(eT, "%Y-%m-%d %H:%M:%S"), strptime(sT, "%Y-%m-%d %H:%M:%S"), units="secs"))
		
		ls_rmd <- list()
		ls_rmd$host_port <- host.port
		ls_rmd$runtime <- str_c(runtime," seconds")
		ls_rmd$data_input <- set$domain_info %>% select(id,level,description) %>% semi_join(tibble(id=data), by="id") %>% set_names(c("Identifier","Level","Description"))
		ls_rmd$min_overlap <- min.overlap
		
		ls_rmd$xlsx_enrichment <- gsub("public/", "", output.file.enrichment, perl=T)
		ls_rmd$pdf_dotplot <- gsub("public/", "", output.file.dotplot.pdf, perl=T)
		ls_rmd$png_dotplot <- gsub("public/", "", output.file.dotplot.png, perl=T)
		
		output_dir <- gsub("enrichment.*", "", output.file, perl=T)
		
		## rmarkdown
		if(file.exists("/usr/local/bin/pandoc")){
			Sys.setenv(RSTUDIO_PANDOC="/usr/local/bin")
		}else if(file.exists("/home/hfang/.local/bin/pandoc")){
			Sys.setenv(RSTUDIO_PANDOC="/home/hfang/.local/bin")
		}else{
			message(sprintf("PANDOC is NOT FOUND (%s) ...", as.character(Sys.time())), appendLF=TRUE)
		}
		rmarkdown::render("public/RMD_enrichment.Rmd", bookdown::html_document2(number_sections=F,theme=c("readable","united")[2], hightlight="default"), output_dir=output_dir)

		}
	}
	
	##########################################
}
';

# for calling R function
$my_rscript.="
startT <- Sys.time()

library(tidyverse)

# huawei
vec <- list.files(path='/root/Fang/R', pattern='.r', full.names=T)
ls_tmp <- lapply(vec, function(x) source(x))
# mac
vec <- list.files(path='/Users/hfang/Sites/XGR/Fang/R', pattern='.r', full.names=T)
ls_tmp <- lapply(vec, function(x) source(x))

R_pipeline(input.file=\"$input_filename\", output.file=\"$output_filename\", domain.type=\"$domain_type\", obo=\"$obo\", significance.threshold=\"$significance_threshold\", min.overlap=\"$min_overlap\", placeholder=\"$placeholder\", host.port=\"$host_port\")

endT <- Sys.time()
runTime <- as.numeric(difftime(strptime(endT, '%Y-%m-%d %H:%M:%S'), strptime(startT, '%Y-%m-%d %H:%M:%S'), units='secs'))
message(str_c('\n--- dcGO_enrichment: ',runTime,' secs ---\n'), appendLF=TRUE)
";

# for calling R function
My_dcgo::Controller::Utils::export_to_file($rscript_filename, $my_rscript);
# $input_filename (and $rscript_filename) must exist
if(-e $rscript_filename and -e $input_filename){
    chmod(0755, "$rscript_filename");
    
    my $command;
    if(-e '/home/hfang/R-3.6.2/bin/Rscript'){
    	# galahad
    	$command="/home/hfang/R-3.6.2/bin/Rscript $rscript_filename";
    }else{
    	# mac and huawei
    	$command="/usr/local/bin/Rscript $rscript_filename";
    }
    
    if(system($command)==1){
        print STDERR "Cannot execute: $command\n";
    }else{
		if(! -e $output_filename){
			print STDERR "Cannot find $output_filename\n";
		}else{
			my $tmp_file='';
			
			## notes: replace 'public/' with '/'
			$tmp_file=$output_filename;
			if(-e $tmp_file){
				$ajax_txt_file=$tmp_file;
				$ajax_txt_file=~s/^public//g;
				print STDERR "TXT locates at $ajax_txt_file\n";
			}
			
			##########################
			### for RMD_enrichment.html
			##########################
			$tmp_file=$tmpFolder."/"."RMD_enrichment.html";
			#public/tmp/RMD_eV2CG.html	
			print STDERR "RMD_enrichment (local & original) locates at $tmp_file\n";
			$ajax_rmd_html_file=$tmpFolder."/".$digit16."_RMD_enrichment.html";
			#public/tmp/digit16_RMD_enrichment.html
			print STDERR "RMD_enrichment (local & new) locates at $ajax_rmd_html_file\n";
			if(-e $tmp_file){
				# do replacing
    			$command="mv $tmp_file $ajax_rmd_html_file";
				if(system($command)==1){
					print STDERR "Cannot execute: $command\n";
				}
				$ajax_rmd_html_file=~s/^public//g;
				#/tmp/digit16_RMD_enrichment.html
				print STDERR "RMD_enrichment (server) locates at $ajax_rmd_html_file\n";
			}
			
		}
    }
}else{
    print STDERR "Cannot find $rscript_filename\n";
}
##########################################
# END: R
##########################################
	
	}
	
	# stash $ajax_txt_file;
	$c->stash(ajax_txt_file => $ajax_txt_file);
	
	# stash $ajax_rmd_html_file;
	$c->stash(ajax_rmd_html_file => $ajax_rmd_html_file);

	
  	$c->render();

}

# Render template "dcGO_crosslink.html.ep"
sub dcGO_crosslink {
  	my $c = shift;
	
	################################
	my $ip = $c->tx->remote_address;
	print STDERR "Remote IP address: $ip\n";
	my $host = $c->req->url->to_abs->host;
	my $port = $c->req->url->to_abs->port;
	my $host_port = "http://".$host.":".$port."/";
	print STDERR "Server available at ".$host_port."\n";
	################################
		
	my $obo= $c->param("obo");
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGOdb');
	my $sth;
	
	##########
	## rec_obo
	my %obo;
	$sth = $dbh->prepare('select distinct source,target from crosslink;');
	$sth->execute();
	if($sth->rows > 0){
		while (my @row = $sth->fetchrow_array) {
			$obo{$row[0]}=1;
			$obo{$row[1]}=1;
		}
	}
	$sth->finish();
	print STDERR "obo: ".scalar(keys %obo)."\n";
	$c->stash(rec_obo => \%obo);
	
	
	##########
	## rec_term
	my @term;
	#select a.source,a.source_id,b.name from crosslink as a, term_info as b where a.source=b.obo and a.source_id=b.id and a.source="EFO" limit 10;
	$sth = $dbh->prepare('select a.source,a.source_id,b.name from crosslink as a, term_info as b where a.source=b.obo and a.source_id=b.id;');
	$sth->execute();
	if($sth->rows > 0){
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{obo}=$row[0];
			$rec->{oid}=$row[1];
			$rec->{oname}=$row[2];
			
			push @term,$rec;
		}
	}
	$sth->finish();
	
	#select a.target,a.target_id,b.name from crosslink as a, term_info as b where a.target=b.obo and a.target_id=b.id and a.target="DO" limit 10;
	$sth = $dbh->prepare('select a.target,a.target_id,b.name from crosslink as a, term_info as b where a.target=b.obo and a.target_id=b.id;');
	$sth->execute();
	if($sth->rows > 0){
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{obo}=$row[0];
			$rec->{oid}=$row[1];
			$rec->{oname}=$row[2];
			
			push @term,$rec;
		}
	}
	$sth->finish();
	print STDERR "term: ".scalar(@term)."\n";
	$c->stash(rec_term => \@term);

	##########
	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
	$c->stash(obo => $obo);
	
  	$c->render();
}


sub dcGO_hie {
	my $c = shift;
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGOdb');
	my $sth;
	
	my %hie;
	$sth = $dbh->prepare('select obo,count(id) from term_info group by obo;');
	$sth->execute();
	if($sth->rows>0){
		while (my @row = $sth->fetchrow_array) {
			$hie{$row[0]}=$row[1];
		}
	}
	$sth->finish();
	print STDERR "hie: ".scalar(keys %hie)."\n";
	$c->stash(rec_hie => \%hie);
	
	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
  	$c->render();
}


sub def_ont_did {
	my $c = shift;
	
	my $def= $c->param("def");
	my $ont= $c->param("ont");
	my $did= $c->param("did") || 53118;
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGO');
	my $sth;
	
	my $domain_data="";
	
	if($def eq "fa" or $def eq "sf"){
		if($def eq "fa"){
			$sth = $dbh->prepare( 'SELECT des.id AS id, des.description AS description, des.classification AS classification, hie.parent AS parent FROM des, hie WHERE hie.id=des.id AND des.id=?;' );
			$sth->execute($did);
			$domain_data=$sth->fetchrow_hashref;
			$domain_data->{level}=$def;
			$domain_data->{scop}="";
			if(!$domain_data->{id}){
				return $c->reply->not_found;
			}else{
				my %pc;
				foreach my $val (split(/,/,$domain_data->{parent})){
					$pc{$val}{$did}=1;
					$domain_data->{scop}.="<a href='/dcGO/sf/$ont/".$val."' target='_blank'><i class='fa fa-diamond'></i>&nbsp;".$val."</a>, ";
				}
				$domain_data->{pc}=\%pc;
				$domain_data->{scop}=~s/, $//g;
			}
			$sth->finish();
			
		}elsif($def eq "sf"){
			$sth = $dbh->prepare( 'SELECT des.id AS id, des.description AS description, des.classification AS classification, hie.children AS children FROM des, hie WHERE hie.id=des.id AND des.id=?;' );
			$sth->execute($did);
			$domain_data=$sth->fetchrow_hashref;
			$domain_data->{level}=$def;
			$domain_data->{scop}="";
			if(!$domain_data->{id}){
				return $c->reply->not_found;
			}else{
				my %pc;
				foreach my $val (split(/,/,$domain_data->{children})){
					$pc{$did}{$val}=1;
					$domain_data->{scop}.="<a href='/dcGO/fa/$ont/".$val."' target='_blank'><i class='fa fa-diamond'></i>&nbsp;".$val."</a>, ";
				}
				$domain_data->{pc}=\%pc;
				$domain_data->{scop}=~s/, $//g;
			}
			$sth->finish();
			
		}
	}
	$c->stash(domain_data => $domain_data);
	
	## for order and ROOT
	my %OBO_ORDER = (
		'DO' => 1,
		'HP' => 2,
		'MP' => 3,
		'WP' => 4,
		'YP' => 5,
		'FP' => 6,
		'FA' => 7,
		'ZA' => 8,
		'XA' => 9,
		'AP' => 10,
		'EC' => 11,
		'DB' => 12,
		'KW' => 13,
		'UP' => 14,
		'CD' => 15,
		'CC' => 16,
	);
	
	
	if($ont eq "GO" and ($def eq "sf" or $def eq "fa" or $def eq "pfam")){
		if($def eq "sf" or $def eq "fa"){
			#$sth = $dbh->prepare('SELECT id AS did, CONCAT("GO:",go) AS ont, all_fdr_min AS fdr, all_hscore_max AS score FROM GO_mapping WHERE level="fa" AND all_fdr_min IS NOT NULL and all_hscore_max IS NOT NULL AND id=?;');
			
			# http://127.0.0.1:3010/dcGO/fa/GO/53118
			# http://127.0.0.1:3010/dcGO/sf/GO/53098
			
			$sth = $dbh->prepare('SELECT a.id AS did, CONCAT("GO:",a.go) AS oid, a.all_fdr_min AS fdr, a.all_hscore_max AS score, b.classification AS dcla, b.description AS ddes, c.name as oname, c.namespace as onamespace FROM GO_mapping as a, des as b, GO_info as c WHERE a.level=? AND a.all_fdr_min IS NOT NULL and a.all_hscore_max IS NOT NULL AND a.id=? AND a.id=b.id AND a.go=c.go;');
			$sth->execute($def,$did);
		
		}elsif($def eq "pfam"){
			
			# http://127.0.0.1:3010/dcGO/pfam/GO/PF07830
			
			$sth = $dbh->prepare('SELECT a.supradomain AS did, a.id AS oid, a.fdr_min AS fdr, a.hscore_max AS score, b.id AS dcla, b.description AS ddes, c.name as oname, c.namespace as onamespace FROM OBO_mapping as a, PFAM_info as b, OBO_info as c WHERE a.obo="GO" AND a.inherited_from !="" AND a.supradomain=? AND a.supradomain=b.acc AND a.id=c.id;');
			$sth->execute($did);
			
		}
		
	}elsif(exists($OBO_ORDER{$ont}) and ($def eq "sf" or $def eq "fa")){
		if($def eq "sf" or $def eq "fa"){
			# http://127.0.0.1:3010/dcGO/sf/AP/144122
			
			$sth = $dbh->prepare('SELECT a.id AS did, a.po AS oid, a.all_fdr_min AS fdr, a.all_hscore_max AS score, b.classification AS dcla, b.description AS ddes, c.name as oname, c.namespace as onamespace FROM PO_mapping as a, des as b, PO_info as c WHERE a.level=? AND a.all_fdr_min IS NOT NULL and a.all_hscore_max IS NOT NULL AND a.id=? AND a.id=b.id AND a.po=c.po AND a.obo=?;');
			$sth->execute($def,$did,$ont);
		}
		
	}
	
	#SELECT a.id AS did, a.po AS oid, a.all_fdr_min AS fdr, a.all_hscore_max AS score, b.classification AS dcla, b.description AS ddes, c.name as oname, c.namespace as onamespace FROM PO_mapping as a, des as b, PO_info as c WHERE a.level='sf' AND a.all_fdr_min IS NOT NULL and a.all_hscore_max IS NOT NULL AND a.id=144122 AND a.id=b.id AND a.po=c.po AND a.obo='AP';
	
	my $json = "";
	if($sth->rows==0){
		return $c->reply->not_found;
	}else{
		my @data;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{did}=$row[0];
			$rec->{oid}=$row[1];
			$rec->{fdr}=$row[2];
			$rec->{score}=$row[3];
			$rec->{dcla}=$row[4];
			$rec->{ddes}=$row[5];
			$rec->{oname}=$row[6];
			$rec->{onamespace}=$row[7];
			
			push @data,$rec;
		}
		print STDERR scalar(@data)."\n";
		$json = encode_json(\@data);
	}
	$sth->finish();
	$c->stash(rec_anno => $json);
	
	#My_dcgo::Controller::Utils::export_to_file("a.json", $json);
	
	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
	$c->render();
}


sub dcGO_level_domain_1 {
	my $c = shift;

	my $level= $c->param("level");
	my $domain= $c->param("domain") || 53118;
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGOR');
	my $sth;
	
	## Ontology Information
	my %OBO_INFO = (
		"DO" => 'Disease Ontology (DO)',
		"GOBP" => 'Gene Ontology Biological Process (GOBP)',
		"GOCC" => 'Gene Ontology Cellular Component (GOCC)',
		"GOMF" => 'Gene Ontology Molecular Function (GOMF)',
		"HPO" => 'Human Phenotype Ontology (HPO)',
		"MPO" => 'Mammalian Phenotype Ontology (MPO)',
	);
	## Level Information
	my %LVL_INFO = (
		"SCOPsf" => 'SCOP superfamily',
		"SCOPfa" => 'SCOP family',
		"Pfam" => 'Pfam family',
		"InterPro" => 'InterPro family',
	);
	
	my $domain_data="";
	
	if($level eq "SCOPsf" or $level eq "SCOPfa"){
		if($level eq "SCOPfa"){
			$sth = $dbh->prepare( 'SELECT des.id AS id, des.description AS description, des.classification AS classification, hie.parent AS parent FROM des, hie WHERE hie.id=des.id AND des.id=?;' );
			$sth->execute($domain);
			$domain_data=$sth->fetchrow_hashref;
			$domain_data->{level}=$LVL_INFO{$level};
			$domain_data->{scop}="";
			if(!$domain_data->{id}){
				return $c->reply->not_found;
			}else{
				foreach my $val (split(/,/,$domain_data->{parent})){
					$domain_data->{scop}.="<a href='/dcGO/SCOPsf/".$val."' target='_blank'><i class='fa fa-diamond'></i>&nbsp;".$val."</a>, ";
				}
				$domain_data->{scop}=~s/, $//g;
			}
			$sth->finish();
			
		}elsif($level eq "SCOPsf"){
			$sth = $dbh->prepare( 'SELECT des.id AS id, des.description AS description, des.classification AS classification, hie.children AS children FROM des, hie WHERE hie.id=des.id AND des.id=?;' );
			$sth->execute($domain);
			$domain_data=$sth->fetchrow_hashref;
			$domain_data->{level}=$LVL_INFO{$level};
			$domain_data->{scop}="";
			if(!$domain_data->{id}){
				return $c->reply->not_found;
			}else{
				foreach my $val (split(/,/,$domain_data->{children})){
					$domain_data->{scop}.="<a href='/dcGO/SCOPfa/".$val."' target='_blank'><i class='fa fa-diamond'></i>&nbsp;".$val."</a>, ";
				}
				$domain_data->{scop}=~s/, $//g;
			}
			$sth->finish();
			
		}
	
	}elsif($level eq "Pfam" or $level eq "InterPro"){
		$sth = $dbh->prepare( 'SELECT id,description FROM Table_domain WHERE level=? AND id=?;' );
		$sth->execute($level,$domain);
		$domain_data=$sth->fetchrow_hashref;
		$domain_data->{level}=$LVL_INFO{$level};
		if(!$domain_data->{id}){
			return $c->reply->not_found;
		}
		$sth->finish();
		
	}
	$c->stash(domain_data => $domain_data);
	

	
	# http://127.0.0.1:3010/dcGO/SCOPfa/53118
	# http://127.0.0.1:3010/dcGO/SCOPsf/53098
	# http://127.0.0.1:3010/dcGO/Pfam/PF07830
	
	#SELECT des.id AS id, des.description AS description, des.classification AS classification, hie.parent AS parent FROM des, hie WHERE hie.id=des.id AND des.id=53118;
	#SELECT c.id AS did, c.description AS ddes, b.obo AS obo, b.id AS oid, b.name AS oname, a.score AS score FROM Table_mapping as a, Table_term as b, Table_domain as c WHERE a.term=b.id AND a.id=c.id AND c.level='SCOPfa' AND a.id=53118 ORDER BY obo ASC, score DESC;
	
	$sth = $dbh->prepare('SELECT c.id AS did, c.description AS ddes, b.obo AS obo, b.id AS oid, b.name AS oname, a.score AS score FROM Table_mapping as a, Table_term as b, Table_domain as c WHERE a.term=b.id AND a.id=c.id AND c.level=? AND a.id=? ORDER BY obo ASC, score DESC;');
	$sth->execute($level,$domain);
	my $json = "";
	if($sth->rows==0){
		return $c->reply->not_found;
	}else{
		my @data;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{did}=$row[0];
			$rec->{ddes}=$row[1];
			$rec->{obo}=$row[2];
			$rec->{oid}="<a href='/dcGO/".$row[2]."/".$row[3]."' target='_blank'>&nbsp;".$row[3]."</a>";
			$rec->{oname}=$row[4];
			$rec->{score}=$row[5];
			
			push @data,$rec;
		}
		print STDERR scalar(@data)."\n";
		$json = encode_json(\@data);
	}
	$sth->finish();
	$c->stash(rec_anno => $json);
	
	#My_dcgo::Controller::Utils::export_to_file("a.json", $json);
	
	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
	$c->render();
}


sub dcGO_obo_term_1 {
	my $c = shift;

	my $obo= $c->param("obo");
	my $term= $c->param("term") || "GO:0008150";
	
	my $dbh = My_dcgo::Controller::Utils::DBConnect('dcGOR');
	my $sth;
	
	## Ontology Information
	my %OBO_INFO = (
		"DO" => 'Disease Ontology (DO)',
		"GOBP" => 'Gene Ontology Biological Process (GOBP)',
		"GOCC" => 'Gene Ontology Cellular Component (GOCC)',
		"GOMF" => 'Gene Ontology Molecular Function (GOMF)',
		"HPO" => 'Human Phenotype Ontology (HPO)',
		"MPO" => 'Mammalian Phenotype Ontology (MPO)',
	);
	## Level Information
	my %LVL_INFO = (
		"SCOPsf" => 'SCOP superfamily',
		"SCOPfa" => 'SCOP family',
		"Pfam" => 'Pfam family',
		"InterPro" => 'InterPro family',
	);

	my $term_data="";
	
	if(exists($OBO_INFO{$obo})){
		$sth = $dbh->prepare( 'SELECT id,name FROM Table_term WHERE obo=? AND id=?;' );
		$sth->execute($obo,$term);
		$term_data=$sth->fetchrow_hashref;
		$term_data->{obo}=$OBO_INFO{$obo};
		if(!$term_data->{id}){
			return $c->reply->not_found;
		}
		$sth->finish();
		
	}
	$c->stash(term_data => $term_data);
	
	# http://127.0.0.1:3010/dcGO/GOBP/GO:0002376
	
	# SELECT c.level AS dlvl, c.id AS did, c.description AS ddes, b.id AS oid, b.name AS oname, a.score AS score FROM Table_mapping as a, Table_term as b, Table_domain as c WHERE a.term=b.id AND a.id=c.id AND b.obo="GOBP" AND b.id="GO:0002376" ORDER BY level ASC, score DESC;
	
	$sth = $dbh->prepare('SELECT c.level AS dlvl, c.id AS did, c.description AS ddes, b.id AS oid, b.name AS oname, a.score AS score FROM Table_mapping as a, Table_term as b, Table_domain as c WHERE a.term=b.id AND a.id=c.id AND b.obo=? AND b.id=? ORDER BY level ASC, score DESC;');
	$sth->execute($obo,$term);
	my $json = "";
	if($sth->rows==0){
		return $c->reply->not_found;
	}else{
		my @data;
		while (my @row = $sth->fetchrow_array) {
			my $rec;
			$rec->{dlvl}=$LVL_INFO{$row[0]};
			$rec->{did}="<a href='/dcGO/".$row[0]."/".$row[1]."' target='_blank'>&nbsp;".$row[1]."</a>";
			$rec->{ddes}=$row[2];
			$rec->{oid}=$row[3];
			$rec->{oname}=$row[4];
			$rec->{score}=$row[5];
			
			push @data,$rec;
		}
		print STDERR scalar(@data)."\n";
		$json = encode_json(\@data);
	}
	$sth->finish();
	$c->stash(rec_anno => $json);
	
	#My_dcgo::Controller::Utils::export_to_file("a.json", $json);
	
	My_dcgo::Controller::Utils::DBDisconnect($dbh);
	
	$c->render();
}


# Render template "dcGO_enrichment.html.ep"
sub dcGO_enrichment_1 {
  	my $c = shift;
	
	my $ip = $c->tx->remote_address;
	print STDERR "IP address: $ip\n";
	
	if($c->req->is_limit_exceeded){
		return $c->render(status => 400, json => { message => 'File is too big.' });
	}
	
	my $domain_type = $c->param('domain_type') || 'Pfam'; # by default: Pfam
  	my $domainlist = $c->param('domainlist');
  	my $obo = $c->param('obo') || 'GOMF'; # by default: GOMF
  	
	my $significance_threshold = $c->param('significance_threshold') || 0.05;
	my $min_overlap = $c->param('min_overlap') || 5;
  	
  	# The output json file (default: '')
	my $ajax_txt_file='';
  	# The output html file (default: '')
	my $ajax_rmd_html_file='';
	
	# The output _priority.xlsx file (default: '')
	my $ajax_priority_xlsx_file='';
  	
	# The output _manhattan.pdf file (default: '')
	my $ajax_manhattan_pdf_file='';
  	
  	if(defined($domainlist)){
		my $tmpFolder = $My_dcgo::Controller::Utils::tmpFolder; # public/tmp
		
		# 14 digits: year+month+day+hour+minute+second
		my $datestring = strftime "%Y%m%d%H%M%S", localtime;
		# 2 randomly generated digits
		my $rand_number = int rand 99;
		my $digit16 =$datestring.$rand_number."_".$ip;

		my $input_filename=$tmpFolder.'/'.'data.Domains.'.$digit16.'.txt';
		my $output_filename=$tmpFolder.'/'.'enrichment.Domains.'.$digit16.'.txt';
		my $rscript_filename=$tmpFolder.'/'.'enrichment.Domains.'.$digit16.'.r';
	
		my $my_input="";
		my $line_counts=0;
		foreach my $line (split(/\r\n|\n/, $domainlist)) {
			next if($line=~/^\s*$/);
			$line=~s/\s+/\t/;
			$my_input.=$line."\n";
			
			$line_counts++;
		}
		# at least two lines otherwise no $input_filename written
		if($line_counts >=2){
			My_dcgo::Controller::Utils::export_to_file($input_filename, $my_input);
		}
		
		my $placeholder;
		if(-e '/Users/hfang/Sites/SVN/github/bigdata_fdb'){
			# mac
			$placeholder="/Users/hfang/Sites/SVN/github/bigdata_fdb";
		}elsif(-e '/var/www/bigdata_fdb'){
			# huawei
			$placeholder="/var/www/bigdata_fdb";
		}
		
##########################################
# BEGIN: R
##########################################
my $my_rscript='
#!/home/hfang/R-3.6.2/bin/Rscript --vanilla
#/home/hfang/R-3.6.2/lib/R/library
# rm -rf /home/hfang/R-3.6.2/lib/R/library/00*
# Call R script, either using one of two following options:
# 1) R --vanilla < $rscript_file; 2) Rscript $rscript_file
';

# for generating R function
$my_rscript.='
R_pipeline <- function (input.file="", output.file="", domain.type="", obo="", significance.threshold="", min.overlap="", placeholder="", ...){
	
	sT <- Sys.time()
	
	# for test
	if(0){
		#cd ~/Sites/XGR/dcGO-site
		placeholder <- "/Users/hfang/Sites/SVN/github/bigdata_fdb"
		input.file <- "~/Sites/XGR/dcGO-site/my_dcgo/public/app/examples/Pfam.txt"
		data <- read_delim(input.file, delim="\t", col_names=F) %>% as.data.frame() %>% pull(1)
		significance.threshold <- 0.05
		min.overlap <- 3
		domain.type <- "Pfam"
		obo <- "GOMF"
	}
	
	# read input file
	data <- read_delim(input.file, delim="\t", col_names=F) %>% as.data.frame() %>% pull(1)
	
	if(significance.threshold == "NULL"){
		significance.threshold <- 1
	}else{
		significance.threshold <- as.numeric(significance.threshold)
	}
	
	min.overlap <- as.numeric(min.overlap)

	set <- oRDS(str_c("dcGOR.SET.", domain.type, "2", obo), placeholder=placeholder)
	#background <- set$info %>% unnest(member) %>% distinct(member) %>% pull(member) %>% unique()
	background <- set$domain_info %>% pull(id)
	eset <- oSEA(data, set, background, test="fisher", min.overlap=min.overlap)

	if(class(eset)=="eSET"){
		# *_enrichment.txt
		df_eTerm <- eset %>% oSEAextract() %>% filter(adjp < significance.threshold)
		df_eTerm %>% write_delim(output.file, delim="\t")
		
		# *_enrichment.xlsx
		output.file.enrichment <- gsub(".txt$", ".xlsx", output.file, perl=T)
		df_eTerm %>% openxlsx::write.xlsx(output.file.enrichment)
		#df_eTerm %>% openxlsx::write.xlsx("/Users/hfang/Sites/XGR/dcGO-site/app/examples/dcGO_enrichment.xlsx")
		
		# Dotplot
		message(sprintf("Drawing dotplot (%s) ...", as.character(Sys.time())), appendLF=TRUE)
		gp_dotplot <- df_eTerm %>% mutate(name=str_c(id," (",name,")")) %>% oSEAdotplot(label.top=5, size.title="Number of domains")		
		output.file.dotplot.pdf <- gsub(".txt$", "_dotplot.pdf", output.file, perl=T)
		#output.file.dotplot.pdf <-  "/Users/hfang/Sites/XGR/dcGO-site/app/examples/dcGO_enrichment_dotplot.pdf"
		ggsave(output.file.dotplot.pdf, gp_dotplot, device=cairo_pdf, width=5, height=4)
		output.file.dotplot.png <- gsub(".txt$", "_dotplot.png", output.file, perl=T)
		ggsave(output.file.dotplot.png, gp_dotplot, type="cairo", width=5, height=4)
		# Forest plot
		if(0){
			gp_forest <- df_eTerm %>% mutate(name=str_c(id," (",name,")")) %>% oSEAforest(top=10, colormap="ggplot2.top", legend.direction=c("auto","horizontal","vertical")[3], sortBy=c("or","none")[1])		
			output.file.forest.pdf <- gsub(".txt$", "_forest.pdf", output.file, perl=T)
			#output.file.forest.pdf <-  "/Users/hfang/Sites/XGR/dcGO-site/app/examples/dcGO_enrichment_forest.pdf"
			ggsave(output.file.forest.pdf, gp_forest, device=cairo_pdf, width=5, height=4)
			output.file.forest.png <- gsub(".txt$", "_forest.png", output.file, perl=T)
			ggsave(output.file.forest.png, gp_forest, type="cairo", width=5, height=4)
		}
		
		######################################
		# RMD
		## R at /Users/hfang/Sites/XGR/dcGO-site/pier_app/public
		## but outputs at public/tmp/eV2CG.SNPs.STRING_high.72959383_priority.xlsx
		######################################
		message(sprintf("RMD (%s) ...", as.character(Sys.time())), appendLF=TRUE)
		
		if(1){
		
		eT <- Sys.time()
		runtime <- as.numeric(difftime(strptime(eT, "%Y-%m-%d %H:%M:%S"), strptime(sT, "%Y-%m-%d %H:%M:%S"), units="secs"))
		
		ls_rmd <- list()
		ls_rmd$runtime <- str_c(runtime," seconds")
		ls_rmd$data_input <- set$domain_info %>% semi_join(tibble(id=data), by="id") %>% set_names(c("Identifier","Level","Description"))
		ls_rmd$min_overlap <- min.overlap
		
		ls_rmd$xlsx_enrichment <- gsub("public/", "", output.file.enrichment, perl=T)
		ls_rmd$pdf_dotplot <- gsub("public/", "", output.file.dotplot.pdf, perl=T)
		ls_rmd$png_dotplot <- gsub("public/", "", output.file.dotplot.png, perl=T)
		
		output_dir <- gsub("enrichment.*", "", output.file, perl=T)
		
		## rmarkdown
		if(file.exists("/usr/local/bin/pandoc")){
			Sys.setenv(RSTUDIO_PANDOC="/usr/local/bin")
		}else if(file.exists("/home/hfang/.local/bin/pandoc")){
			Sys.setenv(RSTUDIO_PANDOC="/home/hfang/.local/bin")
		}else{
			message(sprintf("PANDOC is NOT FOUND (%s) ...", as.character(Sys.time())), appendLF=TRUE)
		}
		rmarkdown::render("public/RMD_enrichment.Rmd", bookdown::html_document2(number_sections=F,theme=c("readable","united")[2], hightlight="default"), output_dir=output_dir)

		}
	}
	
	##########################################
}
';

# for calling R function
$my_rscript.="
startT <- Sys.time()

library(tidyverse)

# huawei
vec <- list.files(path='/root/Fang/R', pattern='.r', full.names=T)
ls_tmp <- lapply(vec, function(x) source(x))
# mac
vec <- list.files(path='/Users/hfang/Sites/XGR/Fang/R', pattern='.r', full.names=T)
ls_tmp <- lapply(vec, function(x) source(x))

R_pipeline(input.file=\"$input_filename\", output.file=\"$output_filename\", domain.type=\"$domain_type\", obo=\"$obo\", significance.threshold=\"$significance_threshold\", min.overlap=\"$min_overlap\", placeholder=\"$placeholder\")

endT <- Sys.time()
runTime <- as.numeric(difftime(strptime(endT, '%Y-%m-%d %H:%M:%S'), strptime(startT, '%Y-%m-%d %H:%M:%S'), units='secs'))
message(str_c('\n--- dcGO_enrichment: ',runTime,' secs ---\n'), appendLF=TRUE)
";

# for calling R function
My_dcgo::Controller::Utils::export_to_file($rscript_filename, $my_rscript);
# $input_filename (and $rscript_filename) must exist
if(-e $rscript_filename and -e $input_filename){
    chmod(0755, "$rscript_filename");
    
    my $command;
    if(-e '/home/hfang/R-3.6.2/bin/Rscript'){
    	# galahad
    	$command="/home/hfang/R-3.6.2/bin/Rscript $rscript_filename";
    }else{
    	# mac and huawei
    	$command="/usr/local/bin/Rscript $rscript_filename";
    }
    
    if(system($command)==1){
        print STDERR "Cannot execute: $command\n";
    }else{
		if(! -e $output_filename){
			print STDERR "Cannot find $output_filename\n";
		}else{
			my $tmp_file='';
			
			## notes: replace 'public/' with '/'
			$tmp_file=$output_filename;
			if(-e $tmp_file){
				$ajax_txt_file=$tmp_file;
				$ajax_txt_file=~s/^public//g;
				print STDERR "TXT locates at $ajax_txt_file\n";
			}
			
			##########################
			### for RMD_enrichment.html
			##########################
			$tmp_file=$tmpFolder."/"."RMD_enrichment.html";
			#public/tmp/RMD_eV2CG.html	
			print STDERR "RMD_enrichment (local & original) locates at $tmp_file\n";
			$ajax_rmd_html_file=$tmpFolder."/".$digit16."_RMD_enrichment.html";
			#public/tmp/digit16_RMD_enrichment.html
			print STDERR "RMD_enrichment (local & new) locates at $ajax_rmd_html_file\n";
			if(-e $tmp_file){
				# do replacing
    			$command="mv $tmp_file $ajax_rmd_html_file";
				if(system($command)==1){
					print STDERR "Cannot execute: $command\n";
				}
				$ajax_rmd_html_file=~s/^public//g;
				#/tmp/digit16_RMD_enrichment.html
				print STDERR "RMD_enrichment (server) locates at $ajax_rmd_html_file\n";
			}
			
		}
    }
}else{
    print STDERR "Cannot find $rscript_filename\n";
}
##########################################
# END: R
##########################################
	
	}
	
	# stash $ajax_txt_file;
	$c->stash(ajax_txt_file => $ajax_txt_file);
	
	# stash $ajax_rmd_html_file;
	$c->stash(ajax_rmd_html_file => $ajax_rmd_html_file);

	
  	$c->render();

}


1;
