require 'rubygems'
require 'open-uri'
require 'csv'

BASE_URL="https://raw.githubusercontent.com/nytimes/covid-19-data/master"
STATES_URL="#{BASE_URL}/us-states.csv"
COUNTIES_URL="#{BASE_URL}/us-counties.csv"
STATE="state"
COUNTY="county"
STAT="deaths"
DATE="date"

def load_url(url)
  csv = CSV.new(open(url), :headers => :first_row)
  headers = nil
  lines = []
  csv.each do |line|
    headers = csv.headers if headers.nil?
    lines << Hash[line]
  end
  lines
end

def get_location(line)
  state = line[STATE]
  county = line[COUNTY]
  if county.nil?
    state
  else
    "#{state}-#{county}"
  end
end

def process_lines(lines)
  cumulative = {}
  daily = {}
  usa = {}
  lines.each do |line|
    date   = line[DATE]
    location  = get_location(line)
    stats = line[STAT].to_i
    next if stats.zero? && cumulative[location].nil?
    today = stats - cumulative.fetch(location, [0]).last
    (cumulative[location] ||= []) << stats
    (daily[location] ||= []) << today
    usa[date] = usa.fetch(date, 0) + today
  end
  [cumulative, daily, usa.to_a.sort.map{|date, stats| stats}]
end

def week_average(sum)
  (sum/7.0).round(2)
end

def week_averages(stats)
  return [0.0] if stats.size < 7
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
  "#{label.ljust(40)} #{stats.map{|d| ('%.2f' % d).rjust(8) }.join(',')}"
end

data = ARGV.include?("county") ? load_url(COUNTIES_URL) : load_url(STATES_URL)

cumulative, daily, usa = process_lines(data)
daily
.map{ |state, stats| [state, current_week(stats)] }
.sort_by{ |state, stats| -stats.last }
.unshift(["USA", current_week(usa)])
.each { |label, stats| puts summarize(label, stats) }
