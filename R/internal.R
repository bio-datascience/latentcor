fromZtoX = function(z, type, copula, xp) {
  copula_switch = switch(copula, "no" = function(z) u = z, "expo" = function(z) u = exp(z), "cube" = function(z) u = z^3)
  u = copula_switch(z)
  type_switch = switch(type, "con" = function(u, xp) {x = u; return(x)},
                       "bin" = function(u, xp) {q = quantile(u, xp); x = ifelse(u > q, 1, 0); return(x)},
                       "tru" = function(u, xp) {q = quantile(u, xp); x = ifelse(u > q, u, q) - q; return(x)},
                       "ter" = function(u, xp) {q = quantile(u, cumsum(xp)); x = rep(0, length(u)); x[u > q[1] & u <= q[2]] = 1; x[u > q[2]] = 2; return(x)}
                       #, "qua" = function(u, xp) {q = quantile(u, cumsum(xp)); x = rep(0, length(u)); x[u > q[1] & u <= q[2]] = 1; x[u > q[2] & u <= q[3]] = 2;
                       # x[u > q[3]] = 3; return(x)},
                       # "qui" = function(u, xp) {q = quantile(u, cumsum(xp)); x = rep(0, length(u)); x[u > q[1] & u <= q[2]] = 1; x[u > q[2] & u <= q[3]] = 2;
                       # x[u > q[3] & u <= q[4]] = 3; x[u > q[4]] = 4; return(x)},
                       # "sen" = function(u, xp) {q = quantile(u, cumsum(xp)); x = rep(0, length(u)); x[u > q[1] & u <= q[2]] = 1; x[u > q[2] & u <= q[3]] = 2;
                       # x[u > q[3] & u <= q[4]] = 3; x[u > q[4] & u <= q[5]] = 4; x[u > q[5]] = 5; return(x)},
                       # "sep" = function(u, xp) {q = quantile(u, cumsum(xp)); x = rep(0, length(u)); x[u > q[1] & u <= q[2]] = 1; x[u > q[2] & u <= q[3]] = 2;
                       # x[u > q[3] & u <= q[4]] = 3; x[u > q[4] & u <= q[5]] = 4; x[u > q[5] & u <= q[6]] = 5; x[u > q[6]] = 6; return(x)},
                       # "oct" = function(u, xp) {q = quantile(u, cumsum(xp)); x = rep(0, length(u)); x[u > q[1] & u <= q[2]] = 1; x[u > q[2] & u <= q[3]] = 2;
                       # x[u > q[3] & u <= q[4]] = 3; x[u > q[4] & u <= q[5]] = 4; x[u > q[5] & u <= q[6]] = 5; x[u > q[6] & u <= q[7]] = 6;
                       # x[u > q[7]] = 7; return(x)},
                       # "nov" = function(u, xp) {q = quantile(u, cumsum(xp)); x = rep(0, length(u)); x[u > q[1] & u <= q[2]] = 1; x[u > q[2] & u <= q[3]] = 2;
                       # x[u > q[3] & u <= q[4]] = 3; x[u > q[4] & u <= q[5]] = 4; x[u > q[5] & u <= q[6]] = 5; x[u > q[6] & u <= q[7]] = 6;
                       # x[u > q[7] & u <= q[8]] = 7; x[u > q[8]] = 8; return(x)},
                       # "den" = function(u, xp) {q = quantile(u, cumsum(xp)); x = rep(0, length(u)); x[u > q[1] & u <= q[2]] = 1; x[u > q[2] & u <= q[3]] = 2;
                       # x[u > q[3] & u <= q[4]] = 3; x[u > q[4] & u <= q[5]] = 4; x[u > q[5] & u <= q[6]] = 5; x[u > q[6] & u <= q[7]] = 6;
                       # x[u > q[7] & u <= q[8]] = 7; x[u > q[8] & u <= q[9]] = 8; x[u > q[9]] = 9; return(x)},
                       # "dtr" = function(u, xp) {q = quantile(u, cumsum(xp)); x = ifelse(u > q[1], u, q[1]); x = (ifelse(u < q[2], x, q[2]) - q[1]) / (q[2] - q[1]); return(x)}
                       )
  x = type_switch(u, xp)
  return(x)
}
Kendalltau = function(X) {
  X = na.omit(X)
  n = nrow(X); n0 = n * (n - 1) / 2
  n_X = apply(X, 2, function(x) {n_x(x = x, n)})
  n_X_sqd = sqrt(n0 - n_X)
  K_b = pcaPP::cor.fk(X)
  K_b.lower = K_b[lower.tri(K_b)]
  btoa = n_X_sqd[row(K_b)[lower.tri(K_b)]] * n_X_sqd[col(K_b)[lower.tri(K_b)]] / n0
  K_a.lower = K_b.lower * btoa
  return(K_a.lower)
}

n_x = function(x, n) {
  if (length(unique(x) != n)) {
    x.info = rle(sort(x))
    t_x = x.info$lengths[x.info$lengths > 1]
    n_x = sum(t_x * (t_x - 1) / 2)
  } else {
    n_x = 0
  }
  return(n_x)
}

zratios = function(X, types) {
  X = as.matrix(X); out = vector(mode = "list", length = ncol(X))
  for (type in unique(types)) {
    zratios_switch = switch(type, "con" = function(X) zratios = rep(NA, ncol(as.matrix(X))),
                            "bin" = function(X) zratios = colMeans(as.matrix(X == 0)),
                            "tru" = function(X) zratios = colMeans(as.matrix(X == 0)),
                            "ter" = function(X) {X0 = X == 0; X1 = X == 1;
                              zratios = rbind(colMeans(as.matrix(X0)), colMeans(as.matrix(X0 + X1)))
                            out = lapply(seq(ncol(zratios)), function(i) zratios[ , i])
                            return(out)}
                            #, "qua" = function(X) {X0 = X == 0; X1 = X == 1; X2 = X == 2;
                            #   zratios = rbind(colMeans(as.matrix(X0)), colMeans(as.matrix(X0 + X1)), colMeans(as.matrix(X0 + X1 + X2)))
                            # out = lapply(seq(ncol(zratios)), function(i) zratios[ , i])
                            # return(out)},
                            # "qui" = function(X) {X0 = X == 0; X1 = X == 1; X2 = X == 2; X3 = X == 3;
                            #   zratios = rbind(colMeans(as.matrix(X0)), colMeans(as.matrix(X0 + X1)), colMeans(as.matrix(X0 + X1 + X2)),
                            #                   colMeans(as.matrix(X0 + X1 + X2 + X3)))
                            # out = lapply(seq(ncol(zratios)), function(i) zratios[ , i])
                            # return(out)},
                            # "sen" = function(X) {X0 = X == 0; X1 = X == 1; X2 = X == 2; X3 = X == 3; X4 = X == 4;
                            #   zratios = rbind(colMeans(as.matrix(X0)), colMeans(as.matrix(X0 + X1)), colMeans(as.matrix(X0 + X1 + X2)),
                            #                   colMeans(as.matrix(X0 + X1 + X2 + X3)), colMeans(as.matrix(X0 + X1 + X2 + X3 + X4)))
                            # out = lapply(seq(ncol(zratios)), function(i) zratios[ , i])
                            # return(out)},
                            # "sep" = function(X) {X0 = X == 0; X1 = X == 1; X2 = X == 2; X3 = X == 3; X4 = X == 4; X5 = X == 5;
                            #   zratios = rbind(colMeans(as.matrix(X0)), colMeans(as.matrix(X0 + X1)), colMeans(as.matrix(X0 + X1 + X2)),
                            #                   colMeans(as.matrix(X0 + X1 + X2 + X3)), colMeans(as.matrix(X0 + X1 + X2 + X3 + X4)),
                            #                   colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5)))
                            # out = lapply(seq(ncol(zratios)), function(i) zratios[ , i])
                            # return(out)},
                            # "oct" = function(X) {X0 = X == 0; X1 = X == 1; X2 = X == 2; X3 = X == 3; X4 = X == 4; X5 = X == 5; X6 = X == 6;
                            #   zratios = rbind(colMeans(as.matrix(X0)), colMeans(as.matrix(X0 + X1)), colMeans(as.matrix(X0 + X1 + X2)),
                            #                   colMeans(as.matrix(X0 + X1 + X2 + X3)), colMeans(as.matrix(X0 + X1 + X2 + X3 + X4)),
                            #                   colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5)), colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5 + X6)))
                            # out = lapply(seq(ncol(zratios)), function(i) zratios[ , i])
                            # return(out)},
                            # "nov" = function(X) {X0 = X == 0; X1 = X == 1; X2 = X == 2; X3 = X == 3; X4 = X == 4; X5 = X == 5; X6 = X == 6; X7 = X == 7;
                            # zratios = rbind(colMeans(as.matrix(X0)), colMeans(as.matrix(X0 + X1)), colMeans(as.matrix(X0 + X1 + X2)),
                            #                 colMeans(as.matrix(X0 + X1 + X2 + X3)), colMeans(as.matrix(X0 + X1 + X2 + X3 + X4)),
                            #                 colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5)), colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5 + X6)),
                            #                 colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5 + X6 + X7)))
                            # out = lapply(seq(ncol(zratios)), function(i) zratios[ , i])
                            # return(out)},
                            # "den" = function(X) {X0 = X == 0; X1 = X == 1; X2 = X == 2; X3 = X == 3; X4 = X == 4; X5 = X == 5; X6 = X == 6; X7 = X == 7; X8 = X == 8;
                            # zratios = rbind(colMeans(as.matrix(X0)), colMeans(as.matrix(X0 + X1)), colMeans(as.matrix(X0 + X1 + X2)),
                            #                 colMeans(as.matrix(X0 + X1 + X2 + X3)), colMeans(as.matrix(X0 + X1 + X2 + X3 + X4)),
                            #                 colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5)), colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5 + X6)),
                            #                 colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5 + X6 + X7)), colMeans(as.matrix(X0 + X1 + X2 + X3 + X4 + X5 + X6 + X7 + X8)))
                            # out = lapply(seq(ncol(zratios)), function(i) zratios[ , i])
                            # return(out)},
                            # "dtr" = function(X) {X0 = X == 0; X1 = X == 1;
                            # zratios = rbind(colMeans(as.matrix(X0)), 1 - colMeans(as.matrix(X1)))
                            # out = lapply(seq(ncol(zratios)), function(i) zratios[ , i])
                            # return(out)}
                            )
    out[types == type] = zratios_switch(X[ , types == type])
  }
  return(out)
}

r_sol = function(K, zratio1, zratio2, comb, tol, ratio) {
  bridge_switch = switch(comb, "10" = function(r, zratio1, zratio2){
    # binary and continuous
    de1 = stats::qnorm(zratio1)
    res = as.numeric(4 * fMultivar::pnorm2d(de1, 0, rho = r/sqrt(2)) - 2 * zratio1)
    return(res)
  },
  "11" = function(r, zratio1, zratio2){
    # binary and binary
    de1 = stats::qnorm(zratio1); de2 = stats::qnorm(zratio2)
    res = as.numeric(2 * (fMultivar::pnorm2d(de1, de2, rho = r) - zratio1 * zratio2))
    return(res)
  },
  "20" = function(r, zratio1, zratio2){
    # truncated and continuous
    de1 = stats::qnorm(zratio1)
    mat2 = matrix(c(1, 1/sqrt(2), r/sqrt(2), 1/sqrt(2), 1, r, r/sqrt(2), r, 1), nrow = 3)
    res = as.numeric(-2 * fMultivar::pnorm2d(-de1, 0, rho = 1/sqrt(2)) + 4 * mnormt::pmnorm(c(-de1, 0, 0), mean = rep(0, 3), varcov = mat2))
    return(res)
  },
  "21" = function(r, zratio1, zratio2){
    # truncated and binary
    de1 = stats::qnorm(zratio1); de2 = stats::qnorm(zratio2)
    mat1 = matrix(c(1, -r, 1/sqrt(2), -r, 1, -r/sqrt(2), 1/sqrt(2), -r/sqrt(2), 1), nrow = 3)
    mat2 = matrix(c(1, 0, -1/sqrt(2), 0, 1, -r/sqrt(2), -1/sqrt(2), -r/sqrt(2), 1), nrow = 3)
    res = as.numeric(2 * (1-zratio1) * (zratio2) - 2 * mnormt::pmnorm(c(-de1, de2, 0), mean = rep(0, 3), varcov = mat1)
                     - 2 * mnormt::pmnorm(c(-de1, de2, 0), mean = rep(0, 3), varcov = mat2))
    return(res)
  },
  "22" = function(r, zratio1, zratio2){
    # truncated and truncated
    de1 = stats::qnorm(zratio1); de2 = stats::qnorm(zratio2)
    mat1 = matrix(c(1, 0, 1/sqrt(2), -r/sqrt(2), 0, 1, -r/sqrt(2), 1/sqrt(2), 1/sqrt(2), -r/sqrt(2), 1, -r, -r/sqrt(2), 1/sqrt(2), -r, 1), nrow = 4)
    mat2 = matrix(c(1, r, 1/sqrt(2), r/sqrt(2), r, 1, r/sqrt(2), 1/sqrt(2), 1/sqrt(2), r/sqrt(2), 1, r, r/sqrt(2), 1/sqrt(2), r, 1), nrow = 4)
    res = as.numeric(-2 * mnormt::pmnorm(c(-de1, -de2, 0, 0), mean = rep(0, 4), varcov = mat1)
                     + 2 * mnormt::pmnorm(c(-de1, -de2, 0, 0), mean = rep(0, 4), varcov = mat2))
    return(res)
  },
  "30" = function(r, zratio1, zratio2){
    # ternary and continuous
    de1 = stats::qnorm(zratio1)
    mat = matrix(c(1, 0, r/sqrt(2), 0, 1, -r/sqrt(2), r/sqrt(2), -r/sqrt(2), 1), nrow = 3)
    res = as.numeric(4 * fMultivar::pnorm2d(de1[2], 0, rho = r/sqrt(2)) - 2 * zratio1[2]
                     + 4 * mnormt::pmnorm(c(de1[1], de1[2], 0), mean = rep(0, 3), varcov = mat) - 2 * zratio1[1]*zratio1[2])
    return(res)
  },
  "31" = function(r, zratio1, zratio2){
    # ternary and binary
    de1 = stats::qnorm(zratio1); de2 = stats::qnorm(zratio2)
    mvnpdf = fMultivar::pnorm2d(c(de2, de2), c(de1[2], de1[1]), rho = r)
    res = as.numeric(2 * mvnpdf[1] * (1 - zratio1[1]) - 2 * zratio1[2] * (zratio2 - mvnpdf[2]))
    return(res)
  },
  "32" = function(r, zratio1, zratio2){
    # ternary and truncated
    de1 = stats::qnorm(zratio1); de2 = stats::qnorm(zratio2)
    mat1 = matrix(c(1, 0, 0, 0, 1, r, 0, r, 1), nrow = 3)
    mat2 = matrix(c(1, 0, 0, r/sqrt(2), 0, 1, -r, r/sqrt(2), 0, -r, 1, -1/sqrt(2), r/sqrt(2), r/sqrt(2), -1/sqrt(2), 1), nrow = 4)
    mat3 = matrix(c(1, 0, r, r/sqrt(2), 0, 1, 0, r/sqrt(2), r, 0, 1, 1/sqrt(2), r/sqrt(2), r/sqrt(2), 1/sqrt(2), 1), nrow = 4)
    res = as.numeric(- 2 * (1 - zratio1[1]) * zratio1[2]
                     + 2 * mnormt::pmnorm(c(-de1[1], de1[2], de2), mean = rep(0, 3), varcov = mat1)
                     + 2 * mnormt::pmnorm(c(-de1[1], de1[2], -de2, 0), mean = rep(0, 4), varcov = mat2)
                     + 2 * mnormt::pmnorm(c(-de1[1], de1[2], -de2, 0), mean = rep(0, 4), varcov = mat3))
    return(res)
  },
  "33" = function(r, zratio1, zratio2){
    # ternary and ternary
    de1 = stats::qnorm(zratio1); de2 = stats::qnorm(zratio2)
    mvnpdf = fMultivar::pnorm2d(c(de1[2], -de1[1], de1[2], de1[1]), c(de2[2], -de2[1], de2[1], de2[2]), rho = r)
    res = as.numeric(2 * mvnpdf[1] * mvnpdf[2] - 2 * (zratio1[2] - mvnpdf[3]) * (zratio2[2] - mvnpdf[4]))
    return(res)
  }
  #, "40" = function(r, zratio1, zratio2){
  #   # quaternary and continuous
  #   de1 = stats::qnorm(zratio1)
  #   mat = matrix(c(1, 0, r/sqrt(2), 0, 1, -r/sqrt(2), r/sqrt(2), -r/sqrt(2), 1), nrow = 3)
  #   mvnpdf = mnormt::pmnorm(rbind(c(de1[1], de1[2], 0), c(de1[2], de1[3], 0)), mean = rep(0, 3), varcov = mat)
  #   res = as.numeric(4 * mvnpdf[1] - 2 * zratio1[1]*zratio1[2] + 4 * mvnpdf[2] - 2 * zratio1[2]*zratio1[3]
  #                    + 4 * fMultivar::pnorm2d(de1[3], 0, rho = r/sqrt(2)) - 2 * zratio1[3])
  #   return(res)
  # },
  # "50" = function(r, zratio1, zratio2){
  #   # quinary and continuous
  #   de1 = stats::qnorm(zratio1)
  #   mat = matrix(c(1, 0, r/sqrt(2), 0, 1, -r/sqrt(2), r/sqrt(2), -r/sqrt(2), 1), nrow = 3)
  #   mvnpdf = mnormt::pmnorm(rbind(c(de1[1], de1[2], 0), c(de1[2], de1[3], 0), c(de1[3], de1[4], 0)), mean = rep(0, 3), varcov = mat)
  #   res = as.numeric(4 * mvnpdf[1] - 2 * zratio1[1]*zratio1[2] + 4 * mvnpdf[2] - 2 * zratio1[2]*zratio1[3] + 4 * mvnpdf[3] - 2 * zratio1[3]*zratio1[4]
  #                    + 4 * fMultivar::pnorm2d(de1[4], 0, rho = r/sqrt(2)) - 2 * zratio1[4])
  #   return(res)
  # },
  # "60" = function(r, zratio1, zratio2){
  #   # senary and continuous
  #   de1 = stats::qnorm(zratio1)
  #   mat = matrix(c(1, 0, r/sqrt(2), 0, 1, -r/sqrt(2), r/sqrt(2), -r/sqrt(2), 1), nrow = 3)
  #   mvnpdf = mnormt::pmnorm(rbind(c(de1[1], de1[2], 0), c(de1[2], de1[3], 0), c(de1[3], de1[4], 0), c(de1[4], de1[5], 0)), mean = rep(0, 3), varcov = mat)
  #   res = as.numeric(4 * mvnpdf[1] - 2 * zratio1[1]*zratio1[2] + 4 * mvnpdf[2] - 2 * zratio1[2]*zratio1[3]
  #                    + 4 * mvnpdf[3] - 2 * zratio1[3]*zratio1[4] + 4 * mvnpdf[4] - 2 * zratio1[4]*zratio1[5]
  #                    + 4 * fMultivar::pnorm2d(de1[5], 0, rho = r/sqrt(2)) - 2 * zratio1[5])
  #   return(res)
  # },
  # "70" = function(r, zratio1, zratio2){
  #   # septenary and continuous
  #   de1 = stats::qnorm(zratio1)
  #   mat = matrix(c(1, 0, r/sqrt(2), 0, 1, -r/sqrt(2), r/sqrt(2), -r/sqrt(2), 1), nrow = 3)
  #   mvnpdf = mnormt::pmnorm(rbind(c(de1[1], de1[2], 0), c(de1[2], de1[3], 0), c(de1[3], de1[4], 0), c(de1[4], de1[5], 0), c(de1[5], de1[6], 0)), mean = rep(0, 3), varcov = mat)
  #   res = as.numeric(4 * mvnpdf[1] - 2 * zratio1[1]*zratio1[2] + 4 * mvnpdf[2] - 2 * zratio1[2]*zratio1[3]
  #                    + 4 * mvnpdf[3] - 2 * zratio1[3]*zratio1[4] + 4 * mvnpdf[4] - 2 * zratio1[4]*zratio1[5]
  #                    + 4 * mvnpdf[5] - 2 * zratio1[5]*zratio1[6]
  #                    + 4 * fMultivar::pnorm2d(de1[6], 0, rho = r/sqrt(2)) - 2 * zratio1[6])
  #   return(res)
  # },
  # "80" = function(r, zratio1, zratio2){
  #   # octonary and continuous
  #   de1 = stats::qnorm(zratio1)
  #   mat = matrix(c(1, 0, r/sqrt(2), 0, 1, -r/sqrt(2), r/sqrt(2), -r/sqrt(2), 1), nrow = 3)
  #   mvnpdf = mnormt::pmnorm(rbind(c(de1[1], de1[2], 0), c(de1[2], de1[3], 0), c(de1[3], de1[4], 0), c(de1[4], de1[5], 0), c(de1[5], de1[6], 0), c(de1[6], de1[7], 0)), mean = rep(0, 3), varcov = mat)
  #   res = as.numeric(4 * mvnpdf[1] - 2 * zratio1[1]*zratio1[2] + 4 * mvnpdf[2] - 2 * zratio1[2]*zratio1[3]
  #                    + 4 * mvnpdf[3] - 2 * zratio1[3]*zratio1[4] + 4 * mvnpdf[4] - 2 * zratio1[4]*zratio1[5]
  #                    + 4 * mvnpdf[5] - 2 * zratio1[5]*zratio1[6] + 4 * mvnpdf[6] - 2 * zratio1[6]*zratio1[7]
  #                    + 4 * fMultivar::pnorm2d(de1[7], 0, rho = r/sqrt(2)) - 2 * zratio1[7])
  #   return(res)
  # },
  # "90" = function(r, zratio1, zratio2){
  #   # novenary and continuous
  #   de1 = stats::qnorm(zratio1)
  #   mat = matrix(c(1, 0, r/sqrt(2), 0, 1, -r/sqrt(2), r/sqrt(2), -r/sqrt(2), 1), nrow = 3)
  #   mvnpdf = mnormt::pmnorm(rbind(c(de1[1], de1[2], 0), c(de1[2], de1[3], 0), c(de1[3], de1[4], 0), c(de1[4], de1[5], 0), c(de1[5], de1[6], 0), c(de1[6], de1[7], 0),
  #                                 c(de1[7], de1[8], 0)), mean = rep(0, 3), varcov = mat)
  #   res = as.numeric(4 * mvnpdf[1] - 2 * zratio1[1]*zratio1[2] + 4 * mvnpdf[2] - 2 * zratio1[2]*zratio1[3]
  #                    + 4 * mvnpdf[3] - 2 * zratio1[3]*zratio1[4] + 4 * mvnpdf[4] - 2 * zratio1[4]*zratio1[5]
  #                    + 4 * mvnpdf[5] - 2 * zratio1[5]*zratio1[6] + 4 * mvnpdf[6] - 2 * zratio1[6]*zratio1[7]
  #                    + 4 * mvnpdf[7] - 2 * zratio1[7]*zratio1[8] + 4 * fMultivar::pnorm2d(de1[8], 0, rho = r/sqrt(2)) - 2 * zratio1[8])
  #   return(res)
  # },
  # "100" = function(r, zratio1, zratio2){
  #   # denary and continuous
  #   de1 = stats::qnorm(zratio1)
  #   mat = matrix(c(1, 0, r/sqrt(2), 0, 1, -r/sqrt(2), r/sqrt(2), -r/sqrt(2), 1), nrow = 3)
  #   mvnpdf = mnormt::pmnorm(rbind(c(de1[1], de1[2], 0), c(de1[2], de1[3], 0), c(de1[3], de1[4], 0), c(de1[4], de1[5], 0), c(de1[5], de1[6], 0), c(de1[6], de1[7], 0),
  #                                 c(de1[7], de1[8], 0), c(de1[8], de1[9], 0)), mean = rep(0, 3), varcov = mat)
  #   res = as.numeric(4 * mvnpdf[1] - 2 * zratio1[1]*zratio1[2] + 4 * mvnpdf[2] - 2 * zratio1[2]*zratio1[3]
  #                    + 4 * mvnpdf[3] - 2 * zratio1[3]*zratio1[4] + 4 * mvnpdf[4] - 2 * zratio1[4]*zratio1[5]
  #                    + 4 * mvnpdf[5] - 2 * zratio1[5]*zratio1[6] + 4 * mvnpdf[6] - 2 * zratio1[6]*zratio1[7]
  #                    + 4 * mvnpdf[7] - 2 * zratio1[7]*zratio1[8] + 4 * mvnpdf[8] - 2 * zratio1[8]*zratio1[9]
  #                    + 4 * fMultivar::pnorm2d(de1[9], 0, rho = r/sqrt(2)) - 2 * zratio1[9])
  #   return(res)
  # },
  # "110" = function(r, zratio1, zratio2){
  #    de1 = stats::qnorm(zratio1)
  #    mat1 = matrix(c(1, 0, - r/sqrt(2), 0, 1, r/sqrt(2), - r/sqrt(2), r/sqrt(2), 1), nrow = 3)
  #    mat2 = matrix(c(1, 0, - 1/sqrt(2), 0, 1, - 1/sqrt(2), - 1/sqrt(2), - 1/sqrt(2), 1), nrow = 3)
  #    mat3 = matrix(c(1, 0, - 1/sqrt(2), - r/sqrt(2), 0, 1, - 1/sqrt(2), - r/sqrt(2), - 1/sqrt(2), - 1/sqrt(2), 1, r, - r/sqrt(2), - r/sqrt(2), r, 1), nrow = 4)
  #    res = as.numeric(2 * zratio1[1] * zratio1[2] + 2 - 2 * zratio1[2] - 4 * mnormt::pmnorm(c(de1[1], de1[2], 0), varcov = mat1)
  #                     - 4 * fMultivar::pnorm2d(- de1[2], 0, rho = - r/sqrt(2))
  #                     - 2 * mnormt::pmnorm(c(de1[2], - de1[1], 0), varcov = mat2)
  #                     + 4 * mnormt::pmnorm(c(de1[2], - de1[1], 0, 0), varcov = mat3))
  #    return(res)
  #  }
  )
  K.len = length(K); out = rep(NA, K.len);
  zratio1 = as.matrix(zratio1); zratio2 = as.matrix(zratio2)
  for (i in K.len) {
    f = function(r)(bridge_switch(r = r, zratio1 = zratio1[ , i], zratio2 = zratio2[ , i]) - K[i])^2
    op = tryCatch(optimize(f, lower = -0.999, upper = 0.999, tol = tol)[1], error = function(e) 100)
    if(op == 100) {
      warning("Optimize returned error one of the pairwise correlations, returning NA")
      out[i] = NA
    } else {
      out[i] = unlist(op)
    }
  }
  return(out)
}

r_ml = function(K, zratio1, zratio2, comb, tol, ratio) {
  ipol_switch = switch(comb, "10" = BCipol, "11" = BBipol, "20" = TCipol, "21" = TBipol, "22" = TTipol,
                       "30" = NCipol, "31" = NBipol, "32" = NTipol, "33" = NNipol)
  zratio1 = as.matrix(zratio1); zratio1.row = nrow(zratio1)
  zratio2 = as.matrix(zratio2); zratio2.row = nrow(zratio2)
  if (zratio1.row > 1) {zratio1[1:(zratio1.row - 1), ] = zratio1[1:(zratio1.row - 1), ] / zratio1[2:zratio1.row, ]}
  if (zratio2.row > 1) {zratio2[1:(zratio2.row - 1), ] = zratio2[1:(zratio2.row - 1), ] / zratio2[2:zratio2.row, ]}
  if (any(is.na(zratio2))) {zratio2 = NULL}
  out = ipol_switch(rbind(K, zratio1, zratio2)) / 10^7
  return(out)
}

r_switch = function(method, K, zratio1, zratio2, comb, tol, ratio){
  out = switch(method, "original" = r_sol,
               "approx" = function(K, zratio1, zratio2, comb, tol, ratio) {
                 bound = bound_switch(comb = comb, zratio1 = zratio1, zratio2 = zratio2); cutoff = abs(K) > ratio * bound
                 if (all(!(cutoff))) {
                   out = r_ml(K = K / bound, zratio1 = zratio1, zratio2 = zratio2, comb = comb, tol = tol, ratio = ratio)
                 } else if (all(cutoff)) {
                   out = r_sol(K = K, zratio1 = zratio1, zratio2 = zratio2, comb = comb, tol = tol, ratio = ratio)
                 } else {
                   out = length(K)
                   out[cutoff] = r_sol(K = K[cutoff], zratio1 = zratio1[ , cutoff], zratio2 = zratio2[ , cutoff], comb = comb, tol = tol, ratio = ratio)
                   out[!(cutoff)] = r_ml(K = K[!(cutoff)] / bound[!(cutoff)], zratio1 = zratio1[ , !(cutoff)], zratio2 = zratio2[ , !(cutoff)], comb = comb, tol = tol, ratio = ratio)
                 }
                 return(out)
               })
  return(out(K, zratio1, zratio2, comb, tol, ratio))
}

bound_switch = function(comb, zratio1, zratio2) {
  out = switch(comb, "10" = function(zratio1, zratio2){2 * zratio1 * (1 - zratio1)},
         "11" = function(zratio1, zratio2){2 * pmin(zratio1, zratio2)*(1-pmax(zratio1, zratio2))},
         "20" = function(zratio1, zratio2){1 - zratio1^2},
         "21" = function(zratio1, zratio2){2 * pmax(zratio2, 1 - zratio2) * (1 - pmax(zratio2, 1 - zratio2, zratio1))},
         "22" = function(zratio1, zratio2){1 - pmax(zratio1, zratio2)^2},
         "30" = function(zratio1, zratio2){2 * (zratio1[1] * (1 - zratio1[1]) + (1 - zratio1[2]) * (zratio1[2] - zratio1[1]))},
         "31" = function(zratio1, zratio2){2 * pmin(zratio1[1] * (1 - zratio1[1]) + (1 - zratio1[2]) * (zratio1[2] - zratio1[1]), zratio2 * (1 - zratio2))},
         "32" = function(zratio1, zratio2){1 - pmax(zratio1[1], zratio1[2] - zratio1[1], 1 - zratio1[2], zratio2)^2},
         "33" = function(zratio1, zratio2){2 * pmin(zratio1[1] * (1 - zratio1[1]) + (1 - zratio1[2]) * (zratio1[2] - zratio1[1]),
                                                    zratio2[1] * (1 - zratio2[1]) + (1 - zratio2[2]) * (zratio2[2] - zratio2[1]))})
  return(out(zratio1, zratio2))
}

