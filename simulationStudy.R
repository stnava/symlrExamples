library(ANTsR)
compareToJointSVD = TRUE
doCorruption = TRUE
if ( ! exists( "energyType" ) ) energyType = 'regression'
nsub = 100 # number of subjects
npix = round(c(2000,1005,500)/1)  # size of matrices
nk = 10    # n components
mx = 'ica'   # mixing method
nits = 20  # n-iterations
nz = 0       # simulated signal parameter - not sensitive to this choice
nzs = 1.5    # simulated signal parameter - not sensitive to this choice
nzs2 = 1     # simulated signal parameter - not sensitive to this choice
train = c( rep(T,80) ,rep(F,20)) # train and test split
test = !train
nsims = 20 # number of simulation runs
nna = rep( NA, nsims )
simdatafrm = data.frame(
    symMeanCorrs = nna,
    symRSQ = nna,
    svdMeanCorrs = nna,
    svdRSQ = nna,
    prmMeanCorrs = nna,
    prmRSQ = nna
    )
for ( sim in 1:nsims ) {
    outcome = scale( matrix(runif( nsub * nk, nz, nzs2 ),ncol=nk) )
    view1tx = scale(matrix( rnorm( npix[1]  * nk, nz,nzs ), nrow=nk ))
    view2tx = scale(matrix( rnorm( npix[2]  * nk, nz,nzs ), nrow=nk ))
    view3tx = scale(matrix( rnorm( npix[3]  * nk, nz,nzs ), nrow=nk ))
    # here we mix the independent basis matrices with the true signal
    mixmats = diag( nk )
    outcomex=outcome
    reo=3:nk # throw some difference in here
    outcomex[,reo]=sample(outcomex[,reo])
    mat1 = (outcomex %*% mixmats[sample(1:nrow(mixmats)),] %*% view1tx)
    outcomex=outcome
    outcomex[,reo]=sample(outcomex[,reo])
    mat2 = (outcomex %*% mixmats[sample(1:nrow(mixmats)),] %*% view2tx)
    outcomex=outcome
    outcomex[,reo]=sample(outcomex[,reo])
    mat3 = (outcomex %*% mixmats[sample(1:nrow(mixmats)),] %*% view3tx)

    if ( doCorruption ) {
      # corrupt half of matrix 3
      mat3[ ,250:500] = matrix( rnorm( prod(dim(mat3[ ,250:500])), 10, 100 ), nrow=100)
    }

    r1 = cor( mat1 ) # regularization
    cthresh=0.66
    r1[ r1<cthresh] =  0
    r2 = cor( mat2 )
    r2[ r2<cthresh] =  0
    r3 = cor( mat3 )
    r3[ r3<cthresh] =  0
    result = simlr(
      list( vox = mat1[train,], vox2 = mat2[train,], vox3 = mat3[train,] ),
      smoothingMatrices = list( r1, r2, r3 ),
      energyType = energyType,
      initialUMatrix = nk-1 , verbose=T, iterations=nits, mixAlg=mx  )

    p1 = mat1 %*% abs(result$v[[1]])
    p2 = mat2 %*% abs(result$v[[2]])
    p3 = mat3 %*% abs(result$v[[3]])

    temp=data.frame( outc = outcome[,1], P1=p1[,1:2], P2=p2[,1:2], P3=p3[,1:2] )
    mdlsym=lm( outc~.,data=temp[train,])
    summary(mdlsym)
    rsqsym = cor( temp$outc[test], predict(mdlsym,newdata=temp[test,]) )

    # compare to permuted data
    s1 = sample( 1:nsub)
    s2 = sample( 1:nsub)
    s3 = sample( 1:nsub)
    pmat1=mat1[s1,]
    pmat2=mat2[s2,]
    pmat3=mat3[s3,]
    r1p = cor( pmat1 ) # regularization
    cthresh=0.66
    r1p[ r1p<cthresh] =  0
    r2p = cor( pmat2 )
    r2p[ r2p<cthresh] =  0
    r3p = cor( pmat3 )
    r3p[ r3p<cthresh] =  0
    resultp = simlr(list(
      vox = pmat1[train,], vox2 = pmat2[train,], vox3 = pmat3[train,] ),
      smoothingMatrices = list( r1p, r2p, r3p ),
      energyType = energyType,
      initialUMatrix = nk-1 , verbose=T, iterations=nits, mixAlg=mx  )

    p1p = pmat1 %*% abs(resultp$v[[1]])
    p2p = pmat2 %*% abs(resultp$v[[2]])
    p3p = pmat3 %*% abs(resultp$v[[3]])

    temp=data.frame( outc = outcome[,1], p1p[,1:2], p2p[,1:2], p3p[,1:2]   )
    mdlprm=lm( outc~.,data=temp[train,])
    rsqprm = cor( temp$outc[test], predict(mdlprm,newdata=temp[test,]) )

    # compare to SVD
    p1svd = mat1 %*% svd( mat1[train,], nu=0, nv=nk )$v
    p2svd = mat2 %*% svd( mat2[train,], nu=0, nv=nk )$v
    p3svd = mat3 %*% svd( mat3[train,], nu=0, nv=nk )$v
    temp=data.frame( outc = outcome[,1], p1svd[,1:2], p2svd[,1:2], p3svd[,1:2] )

if ( compareToJointSVD ) {
    psvd = cbind( mat1,mat2,mat3) %*%
      svd( cbind( mat1,mat2,mat3), nu=0, nv=nk )$v
    p1svd = psvd[,1:2]
    p2svd = psvd[,3:4]
    p3svd = psvd[,5:6]
    temp=data.frame( outc = outcome[,1], psvd[,1:6] )
}
    mdlsvd=lm( outc~.,data=temp[train,])
    rsqsvd = cor( temp$outc[test], predict(mdlsvd,newdata=temp[test,]) )
simdatafrm[sim,] = c(
  mean(abs(cor( outcome, cbind(p1,p2,p3)))),
  rsqsym,
  mean(abs(cor( outcome, cbind(p1svd,p2svd,p3svd)))),
  rsqsvd,
  mean(abs(cor( outcome, cbind(p1p,p2p,p3p)))),
  rsqprm
  )
  print( simdatafrm[sim,] )
}

nms=c("symMeanCorrs","svdMeanCorrs","prmMeanCorrs")
h1 = hist( simdatafrm[,nms[1]])
h2 = hist( simdatafrm[,nms[2]])
h3 = hist( simdatafrm[,nms[3]])
myxl=c(0,0.7)
pdf("./perfHistMeanCorr.pdf",width=6,height=4)
plot( h1, col=rgb(0,0,1,1/4), xlim=myxl, main='Simulation data: SyMILR vs SVD vs SyMILR-perm' ,  xlab='Mean Correlation' )
plot( h2, col=rgb(1,0,0,1/4), xlim=myxl, add=T )
plot( h3, col=rgb(0,1,0,1/4), xlim=myxl, add=T )
dev.off()

nms=c("symRSQ","svdRSQ","prmRSQ")
h1 = hist( simdatafrm[,nms[1]])
h2 = hist( simdatafrm[,nms[2]])
h3 = hist( simdatafrm[,nms[3]])
myxl=c(0,1)
pdf("./perfHistRSQ.pdf",width=6,height=4)
plot( h1, col=rgb(0,0,1,1/4), xlim=myxl, main='Simulation data: SyMILR vs SVD vs SyMILR-perm' ,  xlab='RSQ' )
plot( h2, col=rgb(1,0,0,1/4), xlim=myxl, add=T )
plot( h3, col=rgb(0,1,0,1/4), xlim=myxl, add=T )
dev.off()
print(t.test(simdatafrm[,nms[1]],simdatafrm[,nms[2]],paired=T))
print(t.test(simdatafrm$symMeanCorrs,simdatafrm$svdMeanCorrs,paired=T))
