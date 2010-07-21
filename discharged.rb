require 'open-uri'
require 'pp'

# Calculates the total volume discharged

# Discharge is in cubic feet per second.
class Discharge
  def initialize(line)
    @agency, @site_no, @date, @time, @tz, @discharge = line.split
  end
  def discharge
    @discharge.to_i
  end
end

# I stole this.
def commify(n)
  n.to_s =~ /([^\.]*)(\..*)?/
  int, dec = $1.reverse, $2 ? $2 : ""
  while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
  end
  int.reverse + dec
end

# Fetch data from USGS API
# 
# Returns an array of Discharge events
def fetch_discharge_data
  data_uri = "http://waterdata.usgs.gov/az/nwis/uv?cb_00060=on&format=rdb&period=1&site_no=09512165"
  discharge = []
  open(data_uri) do |f|
    f.each_line do |line|
      next unless line =~ /^USGS/
      discharge << Discharge.new(line)
    end
  end
  discharge
end

# Sums up the reported discharge rates.
#
# Notes:
#   Assumes interval measurements are 15 minutes
#
#   Assumes that the reported discharge rate is uniform 
#   across 15 minutes.
#  
#   Ignores the final entry
# 
# Returns the total volume discharged, numerically formatted
def calculate_total_discharge(discharge)
  total_cubic_feet_discharged = 0
  discharge.each_with_index do |entry, idx|
    if idx == 0
      # 15 minutes = 900 seconds
      total_cubic_feet_discharged += entry.discharge * 900
    elsif idx == discharge.length - 1
      # Skip it. We don't have the next reading yet.
    else
      total_cubic_feet_discharged += entry.discharge * 900
    end
  end
  commify(total_cubic_feet_discharged)
end

sum = calculate_total_discharge(fetch_discharge_data)

puts "Total volume of Tempe Town Lake: 126,779,654 cubic feet" # wikipedia
puts "Total volume discharged        : #{sum} cubic feet"

# Output Wed Jul 21 01:19:16 MST 2010
#
# Total volume of Tempe Town Lake: 126,779,654 cubic feet
# Total volume discharged        : 93,904,200 cubic feet
