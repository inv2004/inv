# Introduction #
_draft_

You can find more tests here: http://code.google.com/p/inv/source/browse/#svn/trunk/spl2/spl_tests

| **Example** | **Result** | **Description** |
|:------------|:-----------|:----------------|
| sum 1 2     | num 3      | 1 + 2           |
| sum 1,sum 2 3 | num 6      | 1 + (2 + 3), the same is: sum 1 (sum 2 3) |
| sum 1,sum 2,sum 3 4 | num 10     | 1 + (2 + (3 + 4)), the same is: sum 1 (sum 2 (sum 3 4)) |
| (a\*b\*sum a b) | num->num->num<sup>*1</sup> | function which makes a + b for (a, b) parameters |
| incr 5\*incr:sum 1 | num 6      | define function incr, function with num parameter, which returns num of parameter + 1. apply it to 5 |
| sum 1       | num->num   | function waiting for num parameter to return num result |
| (f\*sum 1,f 2 3) | (num->num)->num | function with parameter f where f is a function with (num,num) parameters, see **1**|
| elist       | list [.md](.md) | empty list      |
| j 1,j 2,j 3,elist (j is join1 now) | list [1,2,3] | join 3 to empty list, result is `list [3]`, join 2 to `list [3]`, result is `list [2,3]`, join 1 to `list [2,3]` |
| (sum a b\*a:1\*b:2) | num 3      | sum a b where a = 1 and b = 2 |
| (head l\*l:j 3,j 2,j 1,elist) (j is join1 now) | num 3      | head value from list [3,2,1]|
| (tail l\*l:j 3,j 2,j 1,elist) (j is join1 now) | list [3,2] | tail values from list [3,2,1] |
| pair 1 'one' | pair (1, "num") | pair container for 1 (num) and "one" (string) |
| if (eq x 1) {'one'}#if (eq x 2) {'two'}#'other' **x:3**| 'other'    | if 1 equals x then execute lazy expr 'one' else execute next if expr |
| if (eq x 1) {'one'}#if (eq x 2) {'two'} {'other'} **x:3**| ...        | !!! there is a star befor x:3  |
| ...         |

1: num->num->num is a function with two parameters of type num and result num (the last type is sequence), example: sum, mul, minus, divide.<br>
<blockquote>example: sum is the function of type num->num->num, if we do <code>sum 1</code> is returns function of type num->num, if we add num 2 parameter to function <code>sum 1</code>, the result type is num<i></blockquote></i>

<i>draft</i>