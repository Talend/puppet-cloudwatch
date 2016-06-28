module Puppet::Parser::Functions
  newfunction(:prefixes) do |args|
    results, tmp = []
    data = args[0].split('/')
    data.length.times do |counter|
      if tmp.empty?
        results << data.join('/')
        tmp =  data[0...-1]
      else
         results << tmp[0...-1].join('/')
      end
      puts results
    end
  end
end