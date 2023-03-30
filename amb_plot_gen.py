import matplotlib.pyplot as plt
import os
import sys

# The idea is through some format, Ambience can pass X and Y axis data or request graph format.
# format idea "key:value", ...
argc = len(sys.argv)
data = {}
city = sys.argv[1]
city = city.title()
for i in range(2, argc):
    # split key from value
    tList = sys.argv[i].split(':')
    data.update({tList[0]: int(tList[1])})
    
sortedD = dict(sorted(data.items(), key=lambda item: item[1]))
print(sortedD)
# sort dictionary
# get list of keys and values from ordered dictionary
data_keys = list(data.keys())
data_values = list(data.values())


# actually make the bar graph now (note the order of letters and values)
for key in data:
    plt.bar(key, data[key], label=key, width=0.5, bottom=0)
plt.legend()

plt.title(label="Five day, three hour weather forecast by frequency of " +city)
plt.xlabel("Weather Type")
plt.ylabel("Weather frequency (3 hour intervals)")
plt.savefig("dataGen.pdf")
#uncomment below for rapid testing
#plt.show()
