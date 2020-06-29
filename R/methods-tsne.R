.checkParamTsne <- function(theObject, randomSeed, cores, PCs, perplexities, 
		writeOutput){
	
	## Test the normalized count matrix
	sceObject <- getSceNorm(theObject)
	
	if(all(dim(sceObject) == c(0,0)))
		stop("The 'scRNAseq' object that you're using with ",
				"'generateTSNECoordinates' function doesn't have its ",
				"'sceNorm' slot updated. Please use 'normaliseCountMatrix'",
				" on the object before.")
	
	## Check parameters
	if(!is.numeric(randomSeed))
		stop("'randomSeed' parameter should be an integer.")
	
	## Check cores argument
	if(!is.numeric(cores))
		stop("'cores' parameter should be an integer")
	
	## Check PCs argument
	if(!is.numeric(PCs))
		stop("'PCs' parameter should be a vector of numeric.")
	
	## Check perplexities argument
	if(!is.numeric(perplexities))
		stop("'perplexities' parameter should be a vector of numeric.")
	
	## Check writeOutput argument
	if(!is.logical(writeOutput))
		stop("'writeOutput' parameter should be a boolean.")
	
	return(sceObject)
}


#' .buildingTsneObjects
#' 
#' @description 
#' This internal function builds a list of tSNE object. The function is used in
#' generateTSNECoordinates to update the tsneList slot of theObject with 
#' \code{setTSNEList(theObject) <-}.
#'
#' @param PCs Vector of first principal components. For example, to take ranges 
#' 1:5 and 1:10 write c(5, 10). Default = c(4, 6, 8, 10, 20, 40, 50)
#' @param perplexities A vector of perplexity (t-SNE parameter). 
#' Default = c(30, 40).
#' @param experimentName Name of the analysis accessed from a scRNASeq object 
#' with \code{getExperimentName}.
#' @param TSNEres Result of the function scater::runTSNE that is called in the
#' internal function .getTSNEresults.
#' @keywords internal
#'
#' @return Returns a list of Tsne objects.
#' @noRd
.buildingTsneObjects <- function(PCs, perplexities, experimentName, TSNEres){
	
	return(sapply(seq_len(length(PCs)*length(perplexities)), function(i, PCA, 
							perp){
						
						name <- paste0(experimentName, '_tsne_coordinates_', i, 
								"_" , PCA[i], "PCs_", perp[i], "perp")
						
						tSNEObj <- Tsne(name = name, 
								coordinates = as.matrix(TSNEres[1, i][[1]]), 
								perplexity = perp[i],  
								pc  = PCA[i])
						
						return(tSNEObj)
						
					}, rep(PCs, length(perplexities)), 
					rep(perplexities, each=length(PCs))))
	
}


#' .writeOutputTsne
#' 
#' @description 
#' Export the tSNE coordinates to an output folder if the parameter 
#' \code{writeOutput} of the method \code{generateTSNECoordinates} is TRUE.
#'
#' @param theObject An Object of class scRNASeq for which the count matrix was
#' normalized. See ?normaliseCountMatrix.
#' @param PCs Vector of first principal components. For example, to take ranges 
#' 1:5 and 1:10 write c(5, 10). Default = c(4, 6, 8, 10, 20, 40, 50)
#' @param perplexities A vector of perplexity (t-SNE parameter). 
#' Default = c(30, 40).
#' @param experimentName Name of the analysis accessed from a scRNASeq object 
#' with \code{getExperimentName}.
#' @param TSNEres Result of the function scater::runTSNE that is called in the
#' internal function .getTSNEresults.
#' 
#' @keywords internal
#'
#' @return Nothing. Write tSNE coordinates to the output directory in the sub-
#' directory tsnes.
#' @noRd
.writeOutputTsne <- function(theObject, PCs, perplexities, experimentName, 
		TSNEres){
	
	dataDirectory <- getOutputDirectory(theObject)
	tSNEDirectory <- "tsnes"
	
	invisible(sapply(seq_len(length(PCs)*length(perplexities)), function(i, PCA, 
							perp){
						
						name <- paste0(experimentName, '_tsne_coordinates_', i, 
								"_" , PCA[i], "PCs_", perp[i], "perp")
						
						write.table(TSNEres[1, i][[1]], 
								file = file.path(dataDirectory, tSNEDirectory,
										paste0(name, ".tsv")), quote=FALSE, 
								sep='\t')
						
						
					}, rep(PCs, length(perplexities)), 
					rep(perplexities, each=length(PCs))))
	
	initialisePath(dataDirectory)
	outputDir <- file.path(dataDirectory, tSNEDirectory)
	filesList <- list.files(outputDir, pattern="_tsne_coordinates_")
	deletedFiles <- sapply(filesList, function(fileName) 
				file.remove(file.path(outputDir, fileName)))
	saveRDS(TSNEres, file=file.path(dataDirectory, "output_tables",
					paste0(experimentName, "_tSNEResults.rds")))
	
}


#' generateTSNECoordinates
#'
#' @description 
#' The function generates several t-SNE coordinates based on given perplexity 
#' and ranges of PCs. The final number of t-SNE plots is 
#' length(PCs)*length(perplexities).
#'
#' @usage 
#' generateTSNECoordinates(theObject, randomSeed=42, cores=1, 
#' 				PCs=c(4, 6, 8, 10, 20, 40, 50), perplexities=c(30,40), 
#' 				writeOutput = FALSE)
#' 
#' @param theObject An Object of class scRNASeq for which the count matrix was
#' normalized. See ?normaliseCountMatrix.
#' @param randomSeed  Default is 42. Seeds used to generate the tSNE.
#' @param cores Maximum number of jobs that CONCLUS can run in parallel. 
#' Default is 1.
#' @param PCs Vector of first principal components. For example, to take ranges 
#' 1:5 and 1:10 write c(5, 10). Default = c(4, 6, 8, 10, 20, 40, 50)
#' @param perplexities A vector of perplexity (t-SNE parameter). See details. 
#' Default = c(30, 40)
#' @param writeOutput If TRUE, write the tsne parameters to the output directory
#'  defined in theObject. Default = FALSE.
#' 
#' @aliases generateTSNECoordinates
#' 
#' @details
#' Generates an object of fourteen (by default) tables with tSNE coordinates. 
#' Fourteen because it will vary seven values of principal components 
#' *PCs=c(4, 6, 8, 10, 20, 40, 50)* and two values of perplexity 
#' *perplexities=c(30, 40)* in all possible combinations. The chosen values of 
#' PCs and perplexities can be changed if necessary. We found that this 
#' combination works well for sc-RNA-seq datasets with 400-2000 cells. If you 
#' have 4000-9000 cells and expect more than 15 clusters, we recommend to take 
#' more first PCs and higher perplexity, for example, 
#' *PCs=c(8, 10, 20, 40, 50, 80, 100)* and *perplexities=c(200, 240)*. For 
#' details about perplexities parameter see ‘?Rtsne’.
#' 
#' @author 
#' Ilyess RACHEDI, based on code by Polina PAVLOVICH and Nicolas DESCOSTES.
#' 
#' @rdname 
#' generateTSNECoordinates-scRNAseq
#' 
#' @return 
#' An object of class scRNASeq with its tSNEList slot updated. Also writes 
#' coordinates in "dataDirectory/tsnes" subfolder if the parameter writeOutput 
#' is TRUE.
#' 
#' @examples
#' experimentName <- "Bergiers"
#' countMatrix <- matrix(sample(seq_len(40), size=4000, replace = TRUE), 
#' nrow=20, ncol=200)
#' outputDirectory <- "./"
#' columnsMetaData <- read.delim(
#' file.path("extdata/Bergiers_colData_filtered.tsv"))
#' 
#' ## Create the initial object
#' scr <- scRNAseq(experimentName = experimentName, 
#'                 countMatrix     = countMatrix, 
#'                 species         = "mouse",
#'                 outputDirectory = outputDirectory)
#' 
#' ## Normalize and filter the raw counts matrix
#' scrNorm <- normaliseCountMatrix(scr, coldata = columnsMetaData)
#' 
#' ## Compute the tSNE coordinates
#' scrTsne <- generateTSNECoordinates(scrNorm, cores=5)
#' 
#' @seealso
#' normaliseCountMatrix
#' 
#' @exportMethod
setMethod(
		
		f = "generateTSNECoordinates",
		
		signature = "scRNAseq",
		
		definition = function(theObject, randomSeed=42, cores=1, 
				PCs=c(4, 6, 8, 10, 20, 40, 50), perplexities=c(30,40), 
				writeOutput = FALSE){
			
			## Check the Object
			validObject(theObject)
			
			## Check method parameters
			sceObject <- .checkParamTsne(theObject, randomSeed, cores, PCs, 
					perplexities, writeOutput)
			
			message("Running TSNEs using ", cores, " cores.")
			TSNEres <- .getTSNEresults(theObject, Biobase::exprs(sceObject),
					cores=cores, PCs=PCs, perplexities=perplexities, 
					randomSeed=randomSeed)
			
			message("Building TSNEs objects.")
			experimentName <- getExperimentName(theObject)
			setTSNEList(theObject) <- .buildingTsneObjects(PCs, perplexities, 
					experimentName, TSNEres)
			
			
			if(writeOutput)
				.writeOutputTsne(theObject, PCs, perplexities, experimentName, 
						TSNEres)
			
			return(theObject)
		})