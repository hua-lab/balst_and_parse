sub blast_parse {

    use strict;
    use warnings;
    use Bio::SearchIO;
    use Bio::DB::Fasta;

    my ($query_file, $blast_db)=@_;
    my $query_db=Bio::DB::Fasta->new($query_file);
    my $query_db_index=$query_file.".index";
    my @query_ids=$query_db->ids;
    
    my @query_ids_sort=sort{$a cmp $b}@query_ids;

    my @hit_ident_aligns;

    LINE: foreach my $query_id(@query_ids_sort){
 
        my $query_obj=$query_db->get_Seq_by_id($query_id);
        my $query_seq=$query_obj->seq;

        my $seq=">".$id_query."\n".$query_seq."\n";

        open BLAST,">blast.fa";
        print BLAST $seq;
        close BLAST;

        system ("blastx -query  blast.fa -db  $blast_db -evalue 1e-5 -out blast_fa_blastx -num_threads 4");
        
        # Go through BLAST reports one by one 

        my $report = new Bio::SearchIO(        
                     -file=>'blast_fa_blastx',
                     -format => "blast"
                    ); 

            
        while(my $result = $report->next_result){
        
                my $query_name=$result->query_name;
   
                if (! $result->hits()){
                
                    my $no_hit=$query_name,"\t","no_hit";
                    push(@hit_ident_aligns,$no_hit);
                    next LINE;

                }else{

                    while(my $hit=$result->next_hit){

                        while(my $hsp=$hit->next_hsp){
                            my $query_name=$result
                            my $hit_name=$hit->name;
                            my $hit_length=$hit->hit_length();
                            my $align_len=$hsp->length ('hit');
                            my $align_ratio=$align_len/$hit0_length;
                            my $percent_identity=$hsp->percent_identity;
                            my $hit_ident_align=$query_name."\t".$percent_identity."\t".$align_ratio."\t".$hit_name;        
                            push(@hit_ident_aligns,$hit_ident_align);
                                                      }
                                                      
                                                    }                                  
                         }

             } 

          unlink  $query_db_index;
          unlink "blast.fa";
          unlink "blast_fa_blastx";

        }

    return @hit_ident_aligns;

    }

1;
