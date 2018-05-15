[![StringDistances](http://pkg.julialang.org/badges/StringDistances_0.5.svg)](http://pkg.julialang.org/?pkg=StringDistances)
[![Build Status](https://travis-ci.org/matthieugomez/StringDistances.jl.svg?branch=master)](https://travis-ci.org/matthieugomez/StringDistances.jl)
[![Coverage Status](https://coveralls.io/repos/matthieugomez/StringDistances.jl/badge.svg?branch=master)](https://coveralls.io/r/matthieugomez/StringDistances.jl?branch=master)

This Julia package computes various distances between strings.

## Syntax
The function `evaluate` return the *litteral distance* between two strings. 

The function `compare` returns  *a similarity score* between two strings. The similarity score is inversely related to the distance, and is always between 0 and 1. A value of 0 being completely different and a value of 1 being completely similar.


```julia
using StringDistances
compare(Hamming(), "martha", "marhta")
#> 0.6666666666666667
compare(QGram(2), "martha", "marhta")
#> 0.4
compare(QGram(2), "martha", "martha")
#> 1.0
```



## Distances

#### Edit Distances
- [Hamming Distance](https://en.wikipedia.org/wiki/Hamming_distance) `Hamming()`
- [Levenshtein Distance](https://en.wikipedia.org/wiki/Levenshtein_distance) `Levenshtein()`
- [Damerau-Levenshtein Distance](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance) `DamerauLevenshtein()`

#### Q-Grams Distances
Q-gram distances compare the set of all substrings of length `q` in each string.
- QGram Distance `Qgram(q)`
- [Cosine Distance](https://en.wikipedia.org/wiki/Cosine_similarity) `Cosine(q)`
- [Jaccard Distance](https://en.wikipedia.org/wiki/Jaccard_index) `Jaccard(q)`
- [Overlap Distance](https://en.wikipedia.org/wiki/Overlap_coefficient) `Overlap(q)`
- [Sorensen-Dice Distance](https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient) `SorensenDice(q)`

#### Others
- [Jaro Distance](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance) `Jaro()`
- [RatcliffObershelp Distance](https://xlinux.nist.gov/dads/HTML/ratcliffObershelp.html) `RatcliffObershelp()`



## Modifiers

The package includes distance "modifiers", that can be applied to any distance.

- [Winkler](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance) boosts the similary score of strings with common prefixes.  The Winkler adjustment was originally defined for the Jaro similarity score but this package defines it for any string distance.

	```julia
	compare(Jaro(), "martha", "marhta")
	#> 0.9444444444444445
	compare(Winkler(Jaro()), "martha", "marhta")
	#> 0.9611111111111111

	compare(QGram(2), "william", "williams")
	#> 0.9230769230769231
	compare(Winkler(QGram(2)), "william", "williams")
	#> 0.9538461538461539
	```

- Modifiers from the Python library [fuzzywuzzy](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) .

	- [Partial](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) returns the maximal similarity score between the shorter string and substrings of the longer string.

		```julia
		compare(Levenshtein(), "New York Yankees", "Yankees")
		#> 0.4375
		compare(Partial(Levenshtein()), "New York Yankees", "Yankees")
		#> 1.0
		```

	- [TokenSort](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) adjusts for differences in word orders by reording words alphabetically. 

		```julia
		compare(RatcliffObershelp(), "mariners vs angels", "angels vs mariners")
		#> 0.44444
		compare(TokenSort(RatcliffObershelp()),"mariners vs angels", "angels vs mariners")
		#> 1.0
		```

	- [TokenSet](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) adjusts for differences in word orders and word numbers by comparing the intersection of two strings with each string.

		```julia
		compare(Jaro(),"mariners vs angels", "los angeles angels at seattle mariners")
		#> 0.559904
		compare(TokenSet(Jaro()),"mariners vs angels", "los angeles angels at seattle mariners")
		#> 0.944444
		```


	- [TokenMax](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) combines scores using the base distance, the `Partial`, `TokenSort` and `TokenSet` modifiers, with penalty terms depending on string lengths.

		```julia
		compare(TokenMax(RatcliffObershelp()),"mariners vs angels", "los angeles angels at seattle mariners")
		#> 0.855
		```

## Which distance should I use?

As a rule of thumb, 
- Standardize strings before comparing them (correct for uppercases, punctuations, whitespaces, accents, abbreviations...)
- Don't use Edit Distances if word order do not matter.
- The distance `Tokenmax(RatcliffObershelp())` is a good default choice.

## References
- [The stringdist Package for Approximate String Matching](https://journal.r-project.org/archive/2014-1/loo.pdf) Mark P.J. van der Loo
- [fuzzywuzzy blog post](http://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/)


