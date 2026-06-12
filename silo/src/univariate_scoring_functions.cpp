#include <Rcpp.h>
#include <string>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector binary_score(LogicalVector coll, int S = 0) {
    int N = coll.size();
    int B = sum(coll);

    bool relative = S > 0;

    if (relative && (B > S)) {
        throw std::domain_error("S is smaller than sum(coll) (S: " + std::to_string(S) + ", B: " + std::to_string(B) +
                                ", N: " + std::to_string(N) + ")");
    }

    double W = relative ? S : N;

    return (NumericVector)coll / W;
}

// [[Rcpp::export]]
NumericVector shannon_evenness(IntegerVector coll, int S = 0, bool subset = false) {
    std::multiset<int> coll_set(coll.begin(), coll.end());

    int N = coll.size();
    int B = (std::set<int>(coll_set.begin(), coll_set.end())).size();

    bool relative = S > 0;

    if (relative && (B > S)) {
        throw std::domain_error("S is smaller than |set(coll)|");
        throw std::domain_error("S is smaller than |set(coll)| (S: " + std::to_string(S) +
                                ", |set(coll)|: " + std::to_string(B) + ", N: " + std::to_string(N) + ")");
    }

    NumericVector shannon_value(N);

    double log_W = relative ? log(S) : (subset ? log(N) : log(B));

    for (int i = 0; i < N; i++) {
        if (B > 1) {
            double c = coll_set.count(coll[i]);
            double p = c / N;
            double log_p = log(p) / log_W;

            shannon_value[i] = (-p * log_p) / c;
        } else {
            shannon_value[i] = 0.0;
        }
    }

    return shannon_value;
}
