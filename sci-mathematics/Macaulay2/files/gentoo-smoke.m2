-- Exercise startup, external mathicgb, Factory, and numeric root finding.
R = QQ[x,y];
I = ideal(x^2-y, y^2-1);
assert(ideal groebnerBasis(I, Strategy => "MGB") == I);
assert(value factor(x^4-1) == x^4-1);
S = QQ[z];
assert(# roots(z^2-1) == 2);
print "PASS: Gentoo M2 startup, Groebner basis, factorization, and roots";
exit 0
