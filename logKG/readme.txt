This package implements the Bayesian updates for l2 regularized logistic regression, together with different policies to perform sequential decision making. 

Comparison.m is the main function that compares there different policies (EPLR, logKG and VM). “logKG.m” is the knowledge gradient policy under logistic belief models. “maxW.m” implements the fast update after Laplace approximation, which reduces the optimization to a 1-d root finding problem. Algorithm details can be found in: 

Wang, Y., Wang, C. and Powell, W., 2016. The knowledge gradient for sequential decision making with stochastic binary feedbacks. In Proceedings of The 33rd International Conference on Machine Learning (pp. 1138-1147).


