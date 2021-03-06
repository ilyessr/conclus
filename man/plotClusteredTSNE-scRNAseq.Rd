% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/methods-plot.R
\name{plotClusteredTSNE,scRNAseq-method}
\alias{plotClusteredTSNE,scRNAseq-method}
\alias{plotClusteredTSNE}
\title{plotClusteredTSNE}
\usage{
plotClusteredTSNE(theObject, colorPalette="default",
            PCs=c(4, 6, 8, 10, 20, 40, 50), perplexities=c(30, 40),
            columnName="clusters", savePlot=FALSE, plotPDF=TRUE,
            returnPlot=FALSE, width=6, height=5, onefile=FALSE, widthPNG=800,
            heightPNG=750, silentPlot=FALSE, tSNENb=NA)
}
\arguments{
\item{theObject}{An Object of class scRNASeq for which the count matrix was
normalized (see ?normaliseCountMatrix), tSNE were calculated (see
?generateTSNECoordinates), dbScan was run (see ?runDBSCAN), cells were
clustered (see ?clusterCellsInternal), as clusters themselves (see
?calculateClustersSimilarity).}

\item{colorPalette}{A vector of colors for clusters. Default = "default",
see details.}

\item{PCs}{A vector of first principal components. For example, to take
ranges 1:5 and 1:10 write c(5, 10). Default = c(4, 6, 8, 10, 20, 40, 50).
See ?generateTSNECoordinates for details.}

\item{perplexities}{Numeric scalar defining the perplexity parameter,
see ?Rtsne and ?generateTSNECoordinates for more details. Default = c(30, 40)}

\item{columnName}{Name of the column to color the t-SNE with.
Possible values are clusters, noColor, or state.}

\item{savePlot}{If TRUE, the heatmap is saved in the directory defined in
theObject (?getOutputDirectory) and in the sub-directory
"pictures/tSNE_pictures".}

\item{plotPDF}{If TRUE export heatmap in pdf format, if FALSE export it in
png format. Default=TRUE.}

\item{returnPlot}{Boolean indicating if the pHeatmap object should  be
returned by the function. Default = FALSE.}

\item{width}{Width of the plot in the pdf file. See ?pdf for more details.
Default = 6.}

\item{height}{Height of the plot in the pdf file. See ?pdf for more details.
Default = 5.}

\item{onefile}{Logical: if TRUE allow multiple figures in one file. If FALSE,
generate a file with name containing the page number for each page.
Defaults to FALSE.}

\item{widthPNG}{Width of the png. See ?png for details. Default=800.}

\item{heightPNG}{Height of the png. See ?png for details. Default=750.}

\item{silentPlot}{If TRUE, the plots are not displayed on the current device.
Default=FALSE.}

\item{tSNENb}{Give the number of the tSNE to plot. If NA, all tSNE solutions
are plotted (14 tSNE by default). Default=NA.}
}
\value{
A list of ggplot objects if returnPlot is TRUE.
}
\description{
Plot t-SNE generated with different PCs and perplexities.
It can also use a coloring scheme by clusters or states. The latter is
possible if a 'state' column, representing conditions, is provided in the
columns meta-data.
}
\details{
colorPalette -- A vector of colors for clusters/states or
'default' value. If 'default' is selected, the number of clusters is limited
to 16. If an error message is thrown, re-run the function with your own color
vector.
}
\examples{
## Object scr containing the results of previous steps
load(system.file("extdata/scrFull.Rdat", package="conclus"))

## Plot the heatmap of the similarity matrix
plotClusteredTSNE(scr, tSNENb=1)

}
\seealso{
calculateClustersSimilarity plotCellSimilarity plotCellHeatmap
plotGeneExpression plotClustersSimilarity
}
\author{
Ilyess RACHEDI, based on code by Polina PAVLOVICH and Nicolas DESCOSTES.
}
