# covid-19
Simple program to extract COVID-19 stats from the New York Times data set.

This program retrieves data in real-time from:

https://github.com/nytimes/covid-19-data

Specifically the State dataset at:

https://github.com/nytimes/covid-19-data/blob/master/us-states.csv

The data is stored as a cumulative totals.
The program, covid-19.rb, reverse engineers that to generate daily fatality totals.
Then computes a seven day average for the last seven days.
The rationale being that some days might have reporting quirks
(e.g. more cases might be reported on mondays as they were reported late from the weekend)
so a seven day average smooths those quirks out.
