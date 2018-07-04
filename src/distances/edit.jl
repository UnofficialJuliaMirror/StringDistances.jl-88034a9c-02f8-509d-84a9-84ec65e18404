##############################################################################
##
## Find common prefixes (up to lim. -1 means Inf)
##############################################################################

function common_prefix(s1::AbstractString, s2::AbstractString, lim::Integer = -1)
    # in case this loop never happens
    out1 = firstindex(s1)
    out2 = firstindex(s2)
    x1 = iterate(s1)
    x2 = iterate(s2)
    l = 0
    while (x1 != nothing) && (x2 != nothing) && (l < lim || lim < 0)
        ch1, state1 = x1
        ch2, state2 = x2
        ch1 != ch2 && break
        out1 = state1
        out2 = state2
        x1 = iterate(s1, state1)
        x2 = iterate(s2, state2)
        l += 1
    end
    return l, out1, out2
end

##############################################################################
##
## Hamming
##
##############################################################################

function evaluate(dist::Hamming, s1::AbstractString, s2::AbstractString)
    out = 0
    for (ch1, ch2) in zip(s1, s2)
        out += ch1 != ch2
    end
    out += abs(length(s2) - length(s1))
    return out
end

##############################################################################
##
## Levenshtein
## Source: http://blog.softwx.net/2014/12/optimizing-levenshtein-algorithm-in-c.html
##
##############################################################################


struct Levenshtein <: SemiMetric end

function evaluate(dist::Levenshtein, s1::AbstractString, s2::AbstractString)
    # prefix common to both strings can be ignored
    s2, len2, s1, len1 = reorder(s1, s2)
    k, start1, start2 = common_prefix(s1, s2)
    x1 = iterate(s1, start1)
    (x1 == nothing) && return len2 - k
    # distance initialized to first row of matrix
    # => distance between "" and s2[1:i}
    v0 = Array{Int}(undef, len2 - k)
    for i2 in 1:(len2 - k)
        v0[i2] = i2 
    end
    current = 0
    i1 = 0
    while x1 != nothing
        i1 += 1
        ch1, state1 = x1
        left = (i1 - 1)
        current = (i1 - 1)
        i2 = 0
        x2 = iterate(s2, start2)
        while x2 != nothing
            i2 += 1
            ch2, state2 = x2
            #  update
            above, current, left = current, left, v0[i2]
            if ch1 != ch2
                # substitution
                current = min(current + 1,
                                above + 1,
                                left + 1)
            end
            v0[i2] = current
            x2 = iterate(s2, state2)
        end
        x1 = iterate(s1, state1)
    end
    return current
end

##############################################################################
##
## Damerau Levenshtein
## Source: http://blog.softwx.net/2015/01/optimizing-damerau-levenshtein_15.html
##
##############################################################################

struct DamerauLevenshtein <: SemiMetric end

function evaluate(dist::DamerauLevenshtein, s1::AbstractString, s2::AbstractString)
    s2, len2, s1, len1 = reorder(s1, s2)
    # prefix common to both strings can be ignored
    k, state1, start2 = common_prefix(s1, s2)
    x1 = iterate(s1, state1)
    (x1 == nothing) && return len2 - k
    v0 = Array{Int}(undef, len2 - k)
    @inbounds for i2 in 1:(len2 - k)
        v0[i2] = i2
    end
    v2 = Array{Int}(undef, len2 - k)
    current = 0
    i1 = 0
    ch1 = first(s1)
    while (x1 != nothing)
        i1 += 1
        prevch1 = ch1
        ch1, state1 = x1
        x2 = iterate(s2, start2)
        left = (i1 - 1) 
        current = i1 
        nextTransCost = 0
        ch2, = x2
        i2 = 0
        while (x2 != nothing)
            i2 += 1
            prevch2 = ch2
            ch2, state2 = x2
            above = current
            thisTransCost = nextTransCost
            nextTransCost = v2[i2]
            # cost of diagonal (substitution)
            v2[i2] = current = left
            # left now equals current cost (which will be diagonal at next iteration)
            left = v0[i2]
            if ch1 != ch2
                # insertion
                if left < current
                    current = left
                end
                # deletion
                if above < current
                    current = above
                end
                current += 1
                if i1 != 1 && i2 != 1 && ch1 == prevch2 && prevch1 == ch2
                    thisTransCost += 1
                    if thisTransCost < current
                        current = thisTransCost
                    end
                end
            end
            v0[i2] = current
            x2 = iterate(s2, state2)
        end
        x1 = iterate(s1, state1)
    end
    return current
end

##############################################################################
##
## Jaro
## http://alias-i.com/lingpipe/docs/api/com/aliasi/spell/JaroWinklerDistance.html
##############################################################################

struct Jaro <: SemiMetric end

function evaluate(dist::Jaro, s1::AbstractString, s2::AbstractString)
    s2, len2, s1, len1 = reorder(s1, s2)
    # if both are empty, m = 0 so should be 1.0 according to wikipedia. Add this line so that not the case
    len2 == 0 && return 0.0
    maxdist = max(0, div(len2, 2) - 1)
    # count m matching characters
    m = 0 
    flag = fill(false, len2)
    i1 = 0
    startstate2 = firstindex(s2)
    starti2 = 0
    state1 = firstindex(s1)
    i1_match = fill!(Array{Int}(undef, len1), state1)
    x1 = iterate(s1)
    while (x1 != nothing)
        ch1, newstate1 = x1
        i1 += 1
        if starti2 < i1 - maxdist - 1
            startstate2 = nextind(s2, startstate2)
            starti2 += 1
        end 
        i2 = starti2
        x2 = iterate(s2, startstate2)
        while (x2 != nothing) && i2 <= i1 + maxdist
            ch2, state2 = x2
            i2 += 1
            if ch1 == ch2 && !flag[i2] 
                m += 1
                flag[i2] = true
                i1_match[m] = state1
                break
            end
            x2 = iterate(s2, state2) 
        end
        state1 = newstate1
        x1 = iterate(s1, state1)
    end
    # count t transpotsitions
    t = 0
    i1 = 0
    i2 = 0
    for ch2 in s2
        i2 += 1
        if flag[i2]
            i1 += 1
            t += ch2 != iterate(s1, i1_match[i1])[1]
        end
    end
    m == 0.0 && return 1.0
    score = (m / len1 + m / len2 + (m - t/2) / m) / 3.0
    return 1.0 - score
end

jaro(s1::AbstractString, s2::AbstractString) = evaluate(Jaro(), s1, s2)
