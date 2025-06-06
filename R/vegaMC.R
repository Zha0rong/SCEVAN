vegaMC_R <- function(mtx, output_file_name="output", 
                     beta=0.5, min_region_bp_size=1000, correction=FALSE,
                     loss_threshold=-0.2, gain_threshold=0.2, baf=FALSE,
                     loh_threshold=0.75, loh_frequency=0.8, bs=1000,
                     pval_threshold=0.05, html=TRUE, getGenes=TRUE,
                     mart_database="ensembl",
                     ensembl_dataset="hsapiens_gene_ensembl"){
  
  #TODO - this line checks for empty output string and whether it ends in "/".
  # most likely for handling how "run_vegaMC" handles the saving later on.
  # changing the default here to require an input from pipelineCNA would
  # already fix the problem if the default there is changed to be consistent
  # across the package.
  if( output_file_name == "" || 
      substr(output_file_name, 
             nchar(output_file_name), nchar(output_file_name)) == "/" ){
    message("ERROR: Invalid Output File Name")
    return(FALSE)
  }
  n_samples=0
  n_probes=0
  n_chromosomes=0
  
  if(baf){
    baf = 1
  }else{
    baf=0
  }
  
  mtx <- as.matrix(mtx[,-1])
  
  res <- .C("run_vegaMC",
            M=as.double(mtx), 
            row=as.integer(nrow(mtx)), 
            col=as.integer(ncol(mtx)),
            out=as.character(output_file_name),   
            b= as.double(beta),
            mrbs = as.integer(min_region_bp_size),
            losst = as.double(loss_threshold),
            gaint = as.double(gain_threshold),
            ba = as.integer(baf),
            loht = as.double(loh_threshold),
            lohf = as.double(loh_frequency),
            bsp = as.integer(bs),
            ns = as.integer(n_samples),
            np = as.integer(n_probes),
            nc = as.integer(n_chromosomes))
  
  
  n_samples = res$ns
  n_probes = res$np
  n_chromosomes = res$nc
  
  segmentation <- read.table(output_file_name, sep="\t",
                             header=TRUE, as.is=TRUE)
  segmentation[which(is.na(segmentation))] <- 0
  
  if(correction==TRUE){
    segmentation[,6] <- qvalue(as.numeric(segmentation[,6]))
    segmentation[,7] <- qvalue(as.numeric(segmentation[,7]))
    segmentation[,8] <- qvalue(as.numeric(segmentation[,8]))
  }
  segmentation[,6] <- round(as.numeric(segmentation[,6]), 5)
  segmentation[,7] <- round(as.numeric(segmentation[,7]), 5)
  segmentation[,8] <- round(as.numeric(segmentation[,8]), 5)
  
  
  f_l <- 
    as.numeric(segmentation[,9]) * abs(
      as.numeric(segmentation[,13]))/ as.numeric(segmentation[,12 ])
  f_g <- 
    as.numeric(segmentation[,10]) * abs(
      as.numeric(segmentation[,14]))/ as.numeric(segmentation[,12 ])
  f_loh<- 
    as.numeric(segmentation[,11]) * abs(
      as.numeric(segmentation[,15]))/ as.numeric(segmentation[,12 ])
  
  
  segmentation <- cbind(segmentation, f_l, f_g, f_loh)
  segmentation[which(is.na(segmentation))] <- 0
  
  segmentation[,9] <- round(as.numeric(segmentation[,9])*100, 1)
  segmentation[,10] <- round(as.numeric(segmentation[,10])*100, 1)
  segmentation[,11] <- round(as.numeric(segmentation[,11])*100, 1)
  segmentation[,9] <- paste(as.numeric(segmentation[,9]), "%", sep="")
  segmentation[,10] <- paste(as.numeric(segmentation[,10]), "%", sep="")
  segmentation[,11] <- paste(as.numeric(segmentation[,11]), "%", sep="")
  colnames(segmentation)[12:18] <- c("Probe Size", "Loss Mean", "Gain Mean",
                                     "LOH Mean", "Focal-score Loss",
                                     "Focal-score Gain", "Focal-score LOH")
  
  
  #segmentation[,1] <- gsub("X", "23", segmentation[,1])
  #maxINT <- 2147483647
  #ind_overflow <- which(as.numeric(segmentation[,2])<1)
  #segmentation[ind_overflow,2] <- segmentation[ind_overflow,2] + (2 * (maxINT + 1))
  #segmentation[ind_overflow,3] <- segmentation[ind_overflow,3] + (2 * (maxINT + 1))
  
  #TODO - same thing as above here - changing the default output_file_name
  # would allow the user to give a specific output dir to write to
  write.table(segmentation, output_file_name, sep="\t", row.names=FALSE,
              col.names=TRUE, quote=FALSE, eol="\n")
  
  return(segmentation)   
}


#' getBreaksVegaMC Get SCEVAN segmentation of the matrix.
#'
#' @param mtx count matrix
#' @param chr_vect Vector specifying for each gene the chromosome where it is located
#' @param sample sample name (optional)
#' @param beta_vega specifies beta parameter for segmentation, higher beta for more coarse-grained segmentation. (default 0.5) 
#'
#' @return breakpoints
#' @export
#'
#' @examples
getBreaksVegaMC <- function(mtx, chr_vect, sample = "", beta_vega = 0.5, output_dir = "./output"){
  
  res_vega <- vegaMC_R(mtx = mtx, output_file_name = file.path(output_dir, paste0(sample, "vega_output")), beta = beta_vega);
  
  BR <- unlist(lapply(res_vega$Start, function(x) which(chr_vect == x)[1]))
  n <- nrow(mtx)
  BR <- sort(unique(c(1, BR, n)))
  
  return(BR)  
}

