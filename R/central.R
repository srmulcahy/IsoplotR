#' Calculate U-Th-He and fission track central ages and compositions
#'
#' Computes the geometric mean composition of a set of fission track
#' or U-Th-He data or any other kind of heteroscedastic data, and
#' returns the corresponding age and fitting parameters.
#' The central age assumes that the observed age distribution is the
#' combination of two sources of scatter: analytical uncertainty and
#' true geological dispersion.
#' \enumerate{
#' \item For fission track data, the analytical uncertainty is assumed
#' to obey Poisson counting statistics and the geological dispersion
#' is assumed to follow a lognormal distribution.
#' \item For U-Th-He data, the U-Th-(Sm)-He compositions are assumed
#' to follow a logistic normal normal distribution with lognormal
#' measurement  uncertainties.
#' \item For all other data types, both the analytical uncertainties
#' and the true ages are assumed to follow lognormal distributions.
#' }
#' The difference between the central age and the weighted mean age is
#' usually small unless the data are imprecise and/or strongly
#' overdispersed.
#'
#' @param x an object of class \code{UThHe} or \code{fissiontracks},
#'     OR a 2-column matrix with (strictly positive) values and
#'     uncertainties
#' @param alpha cutoff value for confidence intervals
#' @param ... optional arguments
#' @return
#'
#' if \code{x} has class \code{UThHe}, a list containing the
#'     following items:
#'
#' \describe{
#' \item{uvw}{(if the input data table contains Sm) or \strong{uv} (if
#' it doesn't): the geometric mean log[U/He], log[Th/He] (, and
#' log[Sm/He]) composition.}
#'
#' \item{covmat}{the covariance matrix of \code{uvw} or \code{uv}.}
#'
#' \item{mswd}{the reduced Chi-square statistic of data concordance,
#' i.e. \eqn{mswd=SS/df}, where \eqn{SS} is the sum of squares of the
#' log[U/He]-log[Th/He] compositions.}
#'
#' \item{model}{the fitting model.}
#'
#' \item{df}{the degrees of freedom (\eqn{2n-2}) of the fit (only
#' reported if \code{model=1}).}
#'
#' \item{p.value}{the p-value of a Chi-square test with \code{df}
#' degrees of freedom (only reported if \code{model=1}.}
#'
#' \item{tfact}{the \eqn{100(1-\alpha/2)\%} percentile of the t-
#' distribution for \code{df} degrees of freedom (not reported if
#' \code{model=2}.}
#'
#' \item{age}{a three- or four-element vector with:
#'
#' \code{t}: the central age.
#'
#' \code{s[t]}: the standard error of \code{s[t]}.
#'
#' \code{ci[t]}: the \eqn{100(1-\alpha/2)\%} confidence interval for
#' \code{t} for the appropriate number of degrees of freedom.
#'
#' \code{disp[t]}: the \eqn{100(1-\alpha/2)\%} confidence interval
#' enhanced by a factor of \eqn{\sqrt{mswd}} (only reported if
#' \code{model=1}).
#'
#' \code{w}: the geological overdispersion term. If \code{model=3},
#' this is a two-element vector with the standard deviation of the
#' (assumedly) Normal dispersion and the corresponding
#' \eqn{100(1-\alpha/2)\%} confidence interval. If code{model<3}
#' \code{w=0}.
#' }
#'
#' }
#'
#' OR, otherwise:
#'
#' \describe{
#'
#' \item{age}{a three-element vector with:
#'
#' \code{t}: the central age
#'
#' \code{s[t]}: the standard error of \code{s[t]}
#'
#' \code{ci[t]}: the \eqn{100(1-\alpha/2)\%} confidence interval for
#' \code{t} for the appropriate number of degrees of freedom }
#'
#' \item{disp}{a two-element vector with the overdispersion (standard
#' deviation) of the excess scatter, and the corresponding
#' \eqn{100(1-\alpha/2)\%} confidence interval for the appropriate
#' degrees of freedom.}
#'
#' \item{mswd}{the reduced Chi-square statistic of data concordance,
#' i.e. \eqn{mswd=X^2/df}, where \eqn{X^2} is a Chi-square statistic
#' of the EDM data or ages}
#'
#' \item{df}{the degrees of freedom (\eqn{n-2})}
#'
#' \item{p.value}{the p-value of a Chi-square test with \code{df}
#' degrees of freedom}
#' }
#'
#' @seealso \code{\link{weightedmean}}, \code{\link{radialplot}},
#'     \code{\link{helioplot}}
#' @examples
#' data(examples)
#' print(central(examples$UThHe)$age)
#' 
#' @references Galbraith, R.F. and Laslett, G.M., 1993. Statistical
#'     models for mixed fission track ages. Nuclear tracks and
#'     radiation measurements, 21(4), pp.459-470.
#'
#' Vermeesch, P., 2008. Three new ways to calculate average (U-Th)/He
#'     ages. Chemical Geology, 249(3), pp.339-347.
#' 
#' @rdname central
#' @export
central <- function(x,...){ UseMethod("central",x) }
#' @rdname central
#' @export
central.default <- function(x,alpha=0.05,...){
    sigma <- 0.15 # convenient starting value
    zu <- log(x[,1])
    su <- x[,2]/x[,1]
    for (i in 1:30){ # page 100 of Galbraith (2005)
        wu <- 1/(sigma^2+su^2)
        mu <- sum(wu*zu,na.rm=TRUE)/sum(wu,na.rm=TRUE)
        fit <- stats::optimize(eq.6.9,c(0,10),mu=mu,zu=zu,su=su)
        sigma <- fit$minimum
    }
    tt <- exp(mu)
    st <- tt/sqrt(sum(wu,na.rm=TRUE))
    Chi2 <- sum((zu/su)^2,na.rm=TRUE)-(sum(zu/su^2,na.rm=TRUE)^2)/
        sum(1/su^2,na.rm=TRUE)
    out <- list()
    # remove two d.o.f. for mu and sigma
    out$df <- length(zu)-2
    # add back one d.o.f. for the homogeneity test
    out$mswd <- Chi2/(out$df+1)
    out$p.value <- 1-stats::pchisq(Chi2,out$df+1)
    out$age <- c(tt,st,stats::qt(1-alpha/2,out$df)*st)
    out$disp <- c(sigma,stats::qnorm(1-alpha/2)*sigma)
    names(out$age) <- c('t','s[t]','ci[t]')
    names(out$disp) <- c('s','ci')
    out
}
#' @param model choose one of the following statistical models:
#'
#' \code{1}: weighted mean. This model assumes that the scatter
#' between the data points is solely caused by the analytical
#' uncertainty. If the assumption is correct, then the MSWD value
#' should be approximately equal to one. There are three strategies to
#' deal with the case where MSWD>1. The first of these is to assume
#' that the analytical uncertainties have been underestimated by a
#' factor \eqn{\sqrt{MSWD}}. Alternative approaches are described
#' below.
#'
#' \code{2}: unweighted mean. A second way to deal with over- or
#' underdispersed datasets is to simply ignore the analytical
#' uncertainties.
#'
#' \code{3}: weighted mean with overdispersion: instead of attributing
#' any overdispersion (MSWD > 1) to underestimated analytical
#' uncertainties (model 1), one could also attribute it to the
#' presence of geological uncertainty, which manifests itself as an
#' added (co)variance term.
#' 
#' @rdname central
#' @export
central.UThHe <- function(x,alpha=0.05,model=1,...){
    out <- list()
    ns <- nrow(x)
    doSm <- doSm(x)
    fit <- UThHe_logratio_mean(x,model=model,w=0)
    mswd <- mswd_UThHe(x,fit,doSm=doSm)
    fit$tfact <- stats::qt(1-alpha/2,mswd$df)
    if (model==1){
        out <- c(fit,mswd)
        out$age['disp[t]'] <- augment_UThHe_err(out,doSm)
    } else if (model==2){
        out <- fit
    } else {
        w <- get.UThHe.w(x,fit)
        out <- UThHe_logratio_mean(x,model=model,w=w)
        out$w <- c(w,w*stats::qnorm(1-alpha/2))
        names(out$w) <- c('s','ci')
        out$tfact <- fit$tfact
    }
    out$age['ci[t]'] <- out$tfact*out$age['s[t]']
    out
}
#' @param mineral setting this parameter to either \code{apatite} or
#'     \code{zircon} changes the default efficiency factor, initial
#'     fission track length and density to preset values (only affects
#'     results if \code{x$format=2}.)
#' @rdname central
#' @export
central.fissiontracks <- function(x,mineral=NA,alpha=0.05,...){
    out <- list()
    if (x$format<2){
        L8 <- lambda('U238')[1]
        sigma <- 0.15 # convenient starting value
        Nsj <- x$x[,'Ns']
        Ns <- sum(Nsj)
        Nij <- x$x[,'Ni']
        Ni <- sum(Nij)
        num <- (Nsj*Ni-Nij*Ns)^2
        den <- Nsj+Nij
        Chi2 <- sum(num/den)/(Ns*Ni)
        mj <- Nsj+Nij
        pj <- Nsj/mj
        theta <- Ns/sum(mj)
        for (i in 1:30){ # page 49 of Galbraith (2005)
            wj <- mj/(theta*(1-theta)+(mj-1)*(theta*(1-theta)*sigma)^2)
            sigma <- sigma * sqrt(sum((wj*(pj-theta))^2)/sum(wj))
            theta <- sum(wj*pj)/sum(wj)
        }
        tt <- log(1+0.5*L8*(x$zeta[1]/1e6)*x$rhoD[1]*theta/(1-theta))/L8
        st <- tt * sqrt( 1/(sum(wj)*(theta*(1-theta))^2) +
                         (x$rhoD[2]/x$rhoD[1])^2 +
                         (x$zeta[2]/x$zeta[1])^2 )
        # remove two d.o.f. for mu and sigma
        out$df <- length(Nsj)-2
        # add back one d.o.f. for homogeneity test
        out$mswd <- Chi2/(out$df+1)
        out$p.value <- 1-stats::pchisq(Chi2,out$df+1)
        out$age <- c(tt,st,stats::qt(1-alpha/2,out$df)*st)        
        out$disp <- c(sigma,stats::qnorm(1-alpha/2)*sigma)
        names(out$age) <- c('t','s[t]','ci[t]')
        names(out$disp) <- c('s','ci')
    } else if (x$format>1){
        tst <- age(x,exterr=FALSE,mineral=mineral)
        out <- central.default(tst,alpha=alpha)
    }
    out
}

get.UThHe.w <- function(x,fit){
    mswd <- mswd_UThHe(x,fit,doSm=doSm(x))$mswd
    wrange <- c(0,sqrt(mswd))
    stats::optimize(UThHe_misfit,interval=wrange,x=x,model=3)$minimum
}

UThHe_logratio_mean <- function(x,model=1,w=0){
    out <- average_uvw(x,model=model,w=w)
    out$model <- model
    out$w <- w
    out$age <- rep(NA,3)
    names(out$age) <- c('t','s[t]','ci[t]')
    if (doSm(x)){
        cc <- uvw2UThHe(out$uvw,out$covmat)
        out$age[c('t','s[t]')] <- get.UThHe.age(cc['U'],cc['sU'],
                                                cc['Th'],cc['sTh'],
                                                cc['He'],cc['sHe'],
                                                cc['Sm'],cc['sSm'])
    } else {
        cc <- uv2UThHe(out$uvw,out$covmat)
        out$age[c('t','s[t]')] <-
            get.UThHe.age(cc['U'],cc['sU'],
                          cc['Th'],cc['sTh'],
                          cc['He'],cc['sHe'])
    }
    out
}

average_uvw <- function(x,model=1,w=0){
    out <- list()
    doSm <- doSm(x)
    if (doSm(x)){
        nms <- c('u','v','w')
        uvw <- UThHe2uvw(x)
        init <- rep(0,3)
    } else {
        nms <- c('u','v')
        uvw <- UThHe2uv(x)
        init <- rep(0,2)
    }
    if (model==2){
        out$uvw <- apply(uvw,2,mean)
        out$covmat <- cov(uvw)/(nrow(uvw)-1)
    } else {
        fit <- stats::optim(init,SS.UThHe.uvw,method='BFGS',
                            hessian=TRUE,x=x,w=w)
        out$uvw <- fit$par
        out$covmat <- solve(fit$hessian)
    }
    names(out$uvw) <- nms
    colnames(out$covmat) <- nms
    rownames(out$covmat) <- nms
    out
}

# the MSWD calculation does not use Sm
mswd_UThHe <- function(x,fit,doSm=FALSE){
    out <- list()
    if (doSm) nd <- 3
    else nd <- 2
    SS <- SS.UThHe.uvw(fit$uvw[1:nd],x,w=fit$w)
    out$df <- nd*(length(x)-1)
    out$mswd <- SS/out$df
    out$p.value <- 1-stats::pchisq(SS,out$df)
    out
}
UThHe_misfit <- function(w,x,model=1){
    fit <- UThHe_logratio_mean(x,model=model,w=w)
    abs(mswd_UThHe(x,fit,doSm=doSm(x))$mswd-1)
}

augment_UThHe_err <- function(fit,doSm){
    if (doSm){
        cco <- uvw2UThHe(fit$uvw,fit$mswd*fit$covmat)
        out <- fit$tfact*get.UThHe.age(cco['U'],cco['sU'],
                                       cco['Th'],cco['sTh'],
                                       cco['He'],cco['sHe'],
                                       cco['Sm'],cco['sSm'])[2]
    } else {
        cco <- uv2UThHe(fit$uvw,fit$mswd*fit$covmat)
        out <- fit$tfact*get.UThHe.age(cco['U'],cco['sU'],
                                       cco['Th'],cco['sTh'],
                                       cco['He'],cco['sHe'])[2]
    }
    out
}

eq.6.9 <- function(sigma,mu,zu,su){
    wu <- 1/(sigma^2+su^2)
    (1-sum((wu*(zu-mu))^2,na.rm=TRUE)/sum(wu,na.rm=TRUE))^2
}
