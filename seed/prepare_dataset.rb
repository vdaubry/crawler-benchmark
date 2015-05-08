#!/usr/bin/env ruby

input = File.open("seed/Quantcast-Top-Million.txt")
File.open("seed/top-websites.txt", "w") do |output|
  input.readlines.each do |l|
    #remove line number
    l.gsub!(/\d{1,}\s/, "")
    #add line if it is a domain name
    output.puts l unless l.match(/^[a-z]{2,}\.[a-z]{2,5}/).nil?
  end
end