require 'rubygems'
require 'open-uri'
require 'csv'

URL="https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv"

def process(url)
  cumulative = {}
  daily = {}
  usa = {}
  CSV.new(open(url), :headers => :first_row).each do |line|
    date   = line[0]
    state  = line[1]
    stats = line[4].to_i
    next if stats.zero? && cumulative[state].nil?
    today = stats - cumulative.fetch(state, [0]).last
    (cumulative[state] ||= []) << stats
    (daily[state] ||= []) << today
    usa[date] = usa.fetch(date, 0) + today
  end
  [cumulative, daily, usa.to_a.sort.map{|date, stats| stats}]
end

def week_average(sum)
  (sum/7.0).round(2)
end

def week_averages(stats)
  return ['insuffient data'] if stats.size < 7
  week     = stats.take(7)
  sum      = week.sum
  averages = [week_average(sum)]
  stats.drop(7).each do |next_day|
    sum -= week.shift
    sum += next_day
    week << next_day
    averages << week_average(sum)
  end
  averages
end

def current_week(stats)
  week_averages(stats).reverse.take(7).reverse
end

def summarize(label, stats)
  "#{label.ljust(25)} #{stats.map{|d| ('%.2f' % d).rjust(8) }.join(',')}"
end

cumulative, daily, usa = process(URL)
daily
.map{ |state, stats| [state, current_week(stats)] }
.sort_by{ |state, stats| -stats.last }
.unshift(["USA", current_week(usa)])
.each { |label, stats| puts summarize(label, stats) }
