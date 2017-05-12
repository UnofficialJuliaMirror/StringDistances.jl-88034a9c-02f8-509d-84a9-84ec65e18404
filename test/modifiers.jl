
using StringDistances, Base.Test

@test compare(Winkler(Jaro(), 0.1, 0.0), "martha", "marhta") ≈ 0.9611 atol = 1e-4
@test compare(Winkler(Jaro(), 0.1, 0.0), "dwayne", "duane") ≈ 0.84 atol = 1e-4
@test compare(Winkler(Jaro(), 0.1, 0.0), "dixon", "dicksonx") ≈ 0.81333 atol = 1e-4
@test compare(Winkler(Jaro(), 0.1, 0.0), "william", "williams") ≈ 0.975 atol = 1e-4
@test compare(Winkler(Jaro(), 0.1, 0.0), "", "foo") ≈ 0.0 atol = 1e-4
@test compare(Winkler(Jaro(), 0.1, 0.0), "a", "a") ≈ 1.0 atol = 1e-4
@test compare(Winkler(Jaro(), 0.1, 0.0), "abc", "xyz") ≈ 0.0 atol = 1e-4

strings = [
("martha", "marhta"),
("dwayne", "duane") ,
("dixon", "dicksonx"),
("william", "williams"),
("", "foo"),
("a", "a"),
("abc", "xyz"),
("abc", "ccc"),
("kitten", "sitting"),
("saturday", "sunday"),
("hi, my name is", "my name is"),
("alborgów", "amoniak"),
("cape sand recycling ", "edith ann graham"),
( "jellyifhs", "jellyfish"),
("ifhs", "fish"),
("leia", "leela"),
]
solutions = [0.03888889 0.16000000 0.18666667 0.02500000 1.00000000 0.00000000 1.00000000 0.44444444 0.25396825 0.22250000 0.16190476 0.43928571 0.49166667 0.04444444 0.16666667 0.17333333]
for i in 1:length(solutions)
	@test compare(Winkler(Jaro(), 0.1, 0.0), strings[i]...) ≈ (1 - solutions[i]) atol = 1e-4
end




@test compare(Hamming(), "", "abc") ≈ 0.0 atol = 1e-4
@test compare(Hamming(), "acc", "abc") ≈ 2/3 atol = 1e-4
@test compare(Hamming(), "saturday", "sunday") ≈ 1/8 atol = 1e-4

@test compare(QGram(1), "", "abc") ≈ 0.0 atol = 1e-4
@test compare(QGram(1), "abc", "cba") ≈ 1.0 atol = 1e-4
@test compare(QGram(1), "abc", "ccc") ≈ 1/3 atol = 1e-4


@test compare(Partial(RatcliffObershelp()), "New York Yankees",  "Yankees") ≈ 1.0
@test compare(Partial(RatcliffObershelp()), "New York Yankees",  "") ≈ 0.0
@test compare(Partial(RatcliffObershelp()),"mariners vs angels", "los angeles angels at seattle mariners") ≈ 0.444444444444


s = "HSINCHUANG"
@test compare(Partial(RatcliffObershelp()), s, "SINJHUAN") ≈ 0.875
@test compare(Partial(RatcliffObershelp()), s, "LSINJHUANG DISTRIC") ≈ 0.8
@test compare(Partial(RatcliffObershelp()), s, "SINJHUANG DISTRICT") ≈ 0.8
@test compare(Partial(RatcliffObershelp()), s,  "SINJHUANG") ≈ 0.8888888888888

@test compare(Partial(Hamming()), "New York Yankees",  "Yankees") ≈ 1
@test compare(Partial(Hamming()), "New York Yankees",  "") ≈ 1




@test compare(TokenSort(RatcliffObershelp()), "New York Mets vs Atlanta Braves", "Atlanta Braves vs New York Mets")  ≈ 1.0
@test compare(TokenSet(RatcliffObershelp()),"mariners vs angels", "los angeles angels of anaheim at seattle mariners") ≈ 1.0 - 0.09090909090909094


@test compare(TokenSort(RatcliffObershelp()), "New York Mets vs Atlanta Braves", "")  ≈ 0.0
@test compare(TokenSet(RatcliffObershelp()),"mariners vs angels", "") ≈ 0.0


@test compare(TokenMax(RatcliffObershelp()),"mariners vs angels", "") ≈ 0.0



#@test_approx_eq compare(TokenSort(RatcliffObershelp()), graphemeiterator("New York Mets vs Atlanta Braves"), graphemeiterator("Atlanta Braves vs New York Mets"))  1.0
#@test_approx_eq compare(TokenSet(RatcliffObershelp()),graphemeiterator("mariners vs angels"), graphemeiterator("los angeles angels of anaheim at seattle mariners")) 1.0 - 0.09090909090909094
#@test_approx_eq compare(TokenSort(RatcliffObershelp()), graphemeiterator("New York Mets vs Atlanta Braves"), graphemeiterator(""))  0.0
#@test_approx_eq compare(TokenSet(RatcliffObershelp()),graphemeiterator("mariners vs angels"), graphemeiterator("")) 0.0



@test compare(Winkler(Partial(Jaro())),"mariners vs angels", "los angeles angels at seattle mariners") ≈ 0.7378917378917379
@test compare(TokenSet(Partial(RatcliffObershelp())),"mariners vs angels", "los angeles angels at seattle mariners") ≈ 1.0