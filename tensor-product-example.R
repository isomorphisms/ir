# IR tensor-product examples.
# ⊗ is the Kronecker product, matching R's existing %x% operator.
# R's %o% remains the outer product.

A ← matrix(c(1, 2,
             3, 4), nrow = 2, byrow = TRUE)

B ← matrix(c(0, 5,
             6, 7), nrow = 2, byrow = TRUE)

A ⊗ B

expected ← matrix(c(0,  5,  0, 10,
                     6,  7, 12, 14,
                     0, 15,  0, 20,
                    18, 21, 24, 28),
                   nrow = 4, byrow = TRUE)

stopifnot(
    identical(A ⊗ B, expected),
    identical(A ⊗ B, A %x% B),
    identical(A ⊗ B, kronecker(A, B))
)

# Column-vector example: |0> ⊗ |1>.
e0 ← matrix(c(1, 0), ncol = 1)
e1 ← matrix(c(0, 1), ncol = 1)
expected_basis ← matrix(c(0, 1, 0, 0), ncol = 1)

stopifnot(identical(e0 ⊗ e1, expected_basis))
