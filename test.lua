local testTable = {}
for i = 1, 10 do
	table.insert( testTable, { a = i} )
end

testTable[4].deleteMe = true

for i, j in ipairs( testTable ) do
	if j.deleteMe then
		table.remove(testTable, i)
		i = i - 1
	else
		j.touched = true
	end
end

for i, j in ipairs( testTable ) do
	print(i, j.a, j.touched)
end


--testTable[3]