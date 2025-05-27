include std/sequence.e

sequence a = {
    {"one", {"red","green","blue"}},
    {"two", {"orange","yellow","pink"}}
}

for i = 1 to length(a) do
    printf(1, "a index[%d][1] is: %s\n", {i, a[i][1]})
    sequence colors = a[i][2]
    for j = 1 to length(colors) do
        printf(1, "a index[%d][%d] is: %s\n", {i, j + 1, colors[j]})
    end for
end for
printf (1, "length of a is: %d\n", length(a))

printf (1, "equal a[1][1] with 'one' %d\n", equal(a[1][1], "one"))
printf (1, "find green in a[1][2] %d\n", find("green", a[1][2]))
printf (1, "find blue in a %d\n", find("blue", a[1][2]))

printf (1, "find one in a %d\n", find("one", a[1]))


--printf(1, "1<>2 = %s", {1 = 2}) -- none of this worked use equal

sequence c = "f"
integer ws = find(c, {" ","\t","\n","\r"}) 
printf(1, "find returned %d\n", {ws})


enum NAME, LINE_NUM, COL_NUM

printf(1, "name: %d line_num: %d, col_num: %d\n", {NAME, LINE_NUM, COL_NUM})


integer x = 5
integer y
if x = 4 then
    printf(1,"integer x = %d\n",{x})
end if

y = equal(x, 4)
printf(1,"bool y = %d\n",{y})
y = equal(x, 5)
printf(1,"bool y = %d\n",{y})


