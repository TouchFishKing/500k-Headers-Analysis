# read the site list file.
require 'csv'
csv = CSV.open('/Users/lizhenanl/headers/top-500k.csv', encoding: 'windows-1251:utf-8')
# set headers.
headers = [
  'ID',
  'Host Name',
  'Server',
  'X-Powered-By',
  'Set-Cookie_Httponly',
  'X-Frame-Options',
  'X-XSS-Protection',
  'X-Content-Type-Options'
]
# open headers in each folder.
CSV do |csv_out|
  csv_out << headers
  csv.each do |row|
    file_name = "/Users/lizhenanl/headers/#{(((row.first.to_i - 1)/100000) + 1) * 100}/#{row.first}.header"
    file = File.open(file_name)
    
    # set hash for each row, key = headers, value = nil.
    results = Hash[headers.zip(Array.new(headers.count,nil))]
    number_of_lines = 0

    file.each do |line|
      number_of_lines += 1
      # deal with encoding error.
      clean_line = line.encode('UTF-8', :invalid => :replace, :undef => :replace)
      # format the file, give values to corresponding keys.
      next unless clean_line.include?(':')
      # check httponly flag in Set-Cookie headers
      if clean_line =~ /(?i)Set-Cookie|httponly/ then 
        results['Set-Cookie_Httponly'] = 'Set'
      end
      # manipulate each line so it can be matched by headers and give values to corresponding keys.
      columns = clean_line.gsub("\r\n",'').split(':')
      
      next unless headers.include?(columns.first)
      out_string = if columns.count > 2
        columns[1..-1].join(':')
      else
        columns[1]
      end

      results[columns[0]] = out_string
    end
    
    # only output the header when the file itself is not empty.
    next unless number_of_lines > 0
    # give Id and Host name value based on the site list file.
    results['ID'] = row.first
    results['Host Name'] = row.last

    # give 'Not set' to each key with nil value.
    def denilise(h)
      h.each_with_object({}) { |(k,v),g|
        g[k] = (Hash === v) ?  denilise(v) : v.nil? ? 'Not Set' : v }
    end
    results_format = denilise(results)
    csv_out << results_format.values
    file.close
  end
end



