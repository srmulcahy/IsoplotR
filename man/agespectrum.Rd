% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/agespectrum.R
\name{agespectrum}
\alias{agespectrum}
\alias{agespectrum.default}
\alias{agespectrum.ArAr}
\title{Plot a (40Ar/39Ar) release spectrum}
\usage{
agespectrum(x, ...)

\method{agespectrum}{default}(x, alpha = 0.05, plateau = TRUE,
  plateau.col = rgb(0, 1, 0, 0.5), non.plateau.col = rgb(0, 1, 1, 0.5),
  sigdig = 2, line.col = "red", lwd = 2, title = TRUE,
  xlab = "cumulative fraction", ylab = "age [Ma]", ...)

\method{agespectrum}{ArAr}(x, alpha = 0.05, plateau = TRUE,
  plateau.col = rgb(0, 1, 0, 0.5), non.plateau.col = rgb(0, 1, 1, 0.5),
  sigdig = 2, exterr = TRUE, line.col = "red", lwd = 2, i2i = FALSE,
  ...)
}
\arguments{
\item{x}{a three-column matrix whose first column gives the amount
    of \eqn{^{39}}Ar in each aliquot, and whose second and third
    columns give the age and its uncertainty.

OR

an object of class \code{ArAr}}

\item{...}{optional parameters to the generic \code{plot} function}

\item{alpha}{the confidence limits of the error bars/boxes and
confidence intervals.}

\item{plateau}{logical flag indicating whether a plateau age should
be calculated. If \code{plateau=TRUE}, the function will
compute the weighted mean of the largest succession of steps
that yield values passing the Chi-square test for age
homogeneity.  If \code{TRUE}, returns a list with plateau
parameters.}

\item{plateau.col}{the fill colour of the rectangles used to mark
the steps belonging to the age plateau.}

\item{non.plateau.col}{if \code{plateau=TRUE}, the steps that do
NOT belong to the plateau are given a different colour.}

\item{sigdig}{the number of significant digits of the numerical
values reported in the title of the graphical output (only used
if \code{plateau=TRUE}).}

\item{line.col}{colour of the isochron line}

\item{lwd}{line width}

\item{title}{add a title to the plot?}

\item{xlab}{x-axis label}

\item{ylab}{y-axis label}

\item{exterr}{propagate the external (decay constant and
calibration factor) uncertainties?}

\item{i2i}{`isochron to intercept':
calculates the initial (aka `inherited',
`excess', or `common') \eqn{^{40}}Ar/\eqn{^{36}}Ar ratio from
an isochron fit. Setting \code{i2i} to \code{FALSE} uses the
default values stored in \code{settings('iratio',...)}}
}
\value{
if \code{plateau=TRUE}, returns a list with the following
    items:

\describe{
\item{mean}{a 3-element vector with:

\code{x}: the plateau mean

\code{s[x]}: the estimated standard deviation of \code{x}

\code{ci[x]}: the 100(1-\eqn{\alpha})\% confidence interval of
\code{t} for the appropriate degrees of freedom
}

\item{disp}{a 2-element vector with:

\code{s}: the standard deviation of the overdispersion

\code{ci}: the 100(1-\eqn{\alpha})\% confidence interval of
the overdispersion for the appropriate degrees of freedom
}

\item{df}{the degrees of freedom for the weighted mean plateau fit}

\item{mswd}{the mean square of the weighted deviates of the plateau}

\item{p.value}{the p-value of a Chi-square test with \eqn{df=n-2}
degrees of freedom, where \eqn{n} is the number of steps in the
plateau and 2 degrees of freedom have been removed to estimate the
mean and the dispersion.}

\item{fract}{the fraction of \eqn{^{39}}Ar contained in the
plateau}

\item{tfact}{the t-factor for \code{df} degrees of freedom
evaluated at \eqn{100(1-\alpha/2)}\% confidence}

\item{plotpar}{plot parameters for the weighted mean (see
\code{\link{weightedmean}}), which are not used in the age
spectrum}

\item{i}{indices of the steps that are retained for the plateau age
calculation}

}
}
\description{
Produces a plot of boxes whose widths correspond to the cumulative
amount of \eqn{^{39}}Ar (or any other volume proxy), and whose
heights express the analytical uncertainties.  Only propagates the
analytical uncertainty associated with decay constants and
J-factors after computing the plateau composition. \code{IsoplotR}
defines the `plateau age' as the weighted mean age of the longest
sequence (in terms of cumulative \eqn{^{39}}Ar content) of
consecutive heating steps that pass the modified Chauvenet
criterion (see \code{\link{weightedmean}}.  Note that this
definition is different (and simpler) than the one used by
\code{Isoplot} (Ludwig, 2003). However, it is important to mention
that all definitions of an age plateau are heuristic by nature and
should not be used for quantitative inference.
}
\examples{
data(examples)
agespectrum(examples$ArAr,ylim=c(0,80))
}
\references{
Ludwig, K. R. User's manual for Isoplot 3.00: a
    geochronological toolkit for Microsoft Excel. Berkeley
    Geochronology Center Special Pulication, 2003.
}
\seealso{
\code{\link{weightedmean}}
}
