package My_dcgo;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $self = shift;
	
	$ENV{MOJO_REVERSE_PROXY} = 1;
	$self->config(
		hypnotoad => {
			listen  => ['http://*:3010'],
			workers => 8,
			keep_alive_timeout => 300,
			websocket_timeout => 600,
			proxy => 1
		}
	);
	
	# Documentation browser under "/perldoc"
  	$self->plugin('PODRenderer');
  	#$self->plugin('PODViewer');

  	# Router
  	my $r = $self->routes;
	
	# Template names are expected to follow the template.format.handler scheme, with template defaulting to controller/action or the route name, format defaulting to html and handler to ep
	
  	# Normal route to controller
  	## Home
  	$r->get('/')->to(template=>'index', controller=>'action', action=>'index');
  	
  	## dcGO (and typos)
	$r->get('/dcGO')->to(template=>'index', controller=>'action', action=>'index');
	$r->get('/dcgo')->to(template=>'index', controller=>'action', action=>'index');
	$r->get('/DCGO')->to(template=>'index', controller=>'action', action=>'index');

  	## help
  	$r->get('/dcGO/help')->to(template=>'dcGO_help', format=>'html', handler=>'ep', controller=>'action', action=>'index_default');

	## manual (see Action.pm -> sub booklet -> redirect_to)
	## so that '/dcGO/manual' equivalent to '/dcGObooklet/index.html' (located at my_dcgo/public/dcGObooklet/index.html)
  	$r->get('/dcGO/manual')->to(controller=>'action', action=>'booklet');


  	#############################################
  	#Restrictive placeholders (http://mojolicious.org/perldoc/Mojolicious/Guides/Tutorial#Placeholders)
  	#$r -> get('/dcGO/:def/:ont/:did' => [def=>['sf','fa','supra','pfam'],ont=>qr/\w+/,did=>qr/\S+/]) -> to(template=>'def_ont_did', format=>'html', handler=>'ep', controller=>'action', action=>'def_ont_did');
  	
  	if(0){
  		# per domain
  		$r -> get('/dcGO/:level/:domain' => [level=>['SCOPsf','SCOPfa','Pfam','InterPro'],domain=>qr/\S+/]) -> to(template=>'dcGO_level_domain', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_level_domain');
		# per term
  		$r -> get('/dcGO/:obo/:term' => [level=>['GOBP','GOMF','GOCC','DO','HPO','MPO'],term=>qr/\S+/]) -> to(template=>'dcGO_obo_term', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_obo_term');
  		
		# crosslink
		$r -> get('/dcGO/crosslink') -> to(template=>'dcGO_crosslink', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_crosslink', post_flag=>0);
		$r -> post('/dcGO/crosslink') -> to(template=>'dcGO_crosslink', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_crosslink', post_flag=>1);	
  		
  	}else{
  		# per domain
  		$r -> get('/dcGO/:level/:domain' => [level=>['sf','fa','pfam','interpro'],domain=>qr/\S+/]) -> to(template=>'dcGO_level_domain', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_level_domain');
		# per term
  		$r -> get('/dcGO/:obo/:term' => [obo=>['GOBP','GOMF','GOCC','DO','MONDO','HPO','MPO','KEGG','REACTOME','EFO','MSIGDB','DGIdb','Bucket','WPO','FPO','FAN','ZAN','APO','PANTHER','WKPATH','MITOPATH','CTF','TRRUST'],term=>qr/\S+/]) -> to(template=>'dcGO_obo_term', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_obo_term');
		# enrichment
		$r->get('/dcGO/enrichment')->to(template=>'dcGO_enrichment', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_enrichment', post_flag=>0);
		$r->post('/dcGO/enrichment')->to(template=>'dcGO_enrichment', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_enrichment', post_flag=>1);
		
		# ontology hie
  		$r -> get('/dcGO/hie/:obo/:term' => [level=>['GOBP','GOMF','GOCC','DO','MONDO','HPO','MPO','KEGG','REACTOME','EFO','MSIGDB','DGIdb','Bucket','WPO','FPO','FAN','ZAN','APO','PANTHER','WKPATH','MITOPATH','CTF','TRRUST'],term=>qr/\S+/]) -> to(template=>'dcGO_hie_obo_term', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_hie_obo_term');
  		
  		#$r -> get('/dcGO/hie') -> to(template=>'dcGO_hie', format=>'html', handler=>'ep', controller=>'action', action=>'index_default');
  		$r -> get('/dcGO/hie') -> to(template=>'dcGO_hie', format=>'html', handler=>'ep', controller=>'action', action=>'dcGO_hie');
  	
  	}
  	
}

1;

