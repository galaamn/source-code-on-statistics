#
# Speed Up R code - Benchmark test on five different codes these have same purpose
# Author: galaa
# Created on 2018/04/03 18:00:00
#

## -----------------------------------------------------------------
## Алгоритм
## -----------------------------------------------------------------

# 1. u1, u2 ~ U(0,1) санамсаргүй тоонууд үүсгэнэ
# 2. u1 < 1/3 бол X = u2 гэж авна
# 3. 1/3 <= u1 < 2/3 бол X = u2^(1/2) гэж авна
# 4. 2/3 <= u1 бол X = u2^(1/3) гэж авна

## -----------------------------------------------------------------
## Үүсгэх санамсаргүй утгын тоо
## -----------------------------------------------------------------

n <- 10000

## -----------------------------------------------------------------
## Кодын янз бүрийн хувилбарууд
## -----------------------------------------------------------------

expressions <- list(
  # Хувилбар №1 - бүх хувьсагч скаляр - хамгийн удаан ажиллана
  "scalar" = expression({
    X <- c()
    for (i in 1:n) {
      u1 <- runif(n = 1)
      u2 <- runif(n = 1)
      if (u1 < 1/3) {
        X[i] <- u2
      } else if (u1 < 2/3) {
        X[i] <- sqrt(u2)
      } else {
        X[i] <- u2 ** (1/3)
      }
    }
  }),
  # Хувилбар №2 - хувьсагчид вектор байх - өмнөхөөс илүү хурдан ажиллана
  "vector" = expression({
    X <- c()
    for (i in 1:n) {
      u <- runif(n = 2)
      if (u[1] < 1/3) {
        X[i] <- u[2]
      } else if (u[1] < 2/3) {
        X[i] <- sqrt(u[2])
      } else {
        X[i] <- u[2] ** (1/3)
      }
    }
  }),
  # Хувилбар №3 - for давталтыг replicate функцээр орлуулах - өмнөхтэй ойролцоо хурдтай ажиллана
  "replicate" = expression({
    X <- replicate(n = n, expr = {
      u <- runif(n = 2)
      if (u[1] < 1/3) {
        X <- u[2]
      } else if (u[1] < 2/3) {
        X <- sqrt(u[2])
      } else {
        X <- u[2] ** (1/3)
      }
      X
    })
  }),
  # Хувилбар №4 - өгөгдлөө матриц гээд apply функц ашиглах - өмнөх хувилбаруудаас хурдан ажиллана
  "apply" = expression({
    U <- matrix(runif(n = n *2), ncol = 2, byrow = TRUE)
    X <- apply(X = U, MARGIN = 1, FUN = function (u) {
      if (u[1] < 1/3) {
        X <- u[2]
      } else if (u[1] < 2/3) {
        X <- sqrt(u[2])
      } else {
        X <- u[2] ** (1/3)
      }
      X
    })
  }),
  # Хувилбар №5 - функц, операторуудын вектор дээрх үйлчлэл ашиглах - хамгийн хурдан ажиллана
  "ifelse" = expression({
    u <- runif(n = n * 2)
    u1 <- u[1:n]
    u2 <- u[-{1:n}]
    X <- ifelse(u1 < 1/3, u2, ifelse(u1 < 2/3, sqrt(u2), u2 ** (1/3)))
  })
)

## -----------------------------------------------------------------
## Хувилбаруудын харьцуулалт
## -----------------------------------------------------------------

# install.packages("rbenchmark")

test <- within(
  do.call(
    what = rbenchmark::benchmark,
    args = c(
      expressions,
      list(
        replications = 100,
        columns = c("test", "elapsed", "relative", "replications"),
        order = "elapsed"
      )
    )
  ),
  {average = elapsed/replications}
)

print(test)
