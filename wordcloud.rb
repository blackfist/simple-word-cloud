require 'csv'

# Configuration
MINIMUM_COUNT_TO_EXPORT = 500 #minimum count for words to be reported on
ROWS_OF_PRETTY_OUTPUT = 80    #only for command line output, you can set to 0
WORDS_OF_CONTEXT_TO_SHOW = 3  #words on each side of the target word

# Check for arguments
if ARGV.count.zero?
    puts "Must provide input URL as the first argument (e.g. intext.txt)"
    return -1
end

######## Load configuration
common_words = File.open('common_words.txt','r').read.encode!('UTF-8','UTF-8', :invalid => :replace).split("\n")
doNotSingularize = File.open('do_not_singularize.txt','r').read.encode!('UTF-8','UTF-8', :invalid => :replace).split("\n")
get_context_for = File.open('in_word_search_context.txt','r').read.encode!('UTF-8','UTF-8', :invalid => :replace).split("\n")

substitutions = {}
CSV.foreach("substitutions.txt") do |line|
    substitutions[line[0]] = line[1].strip
end

propers = {}
CSV.foreach("propers.txt") do |line|
    propers[line[0]] = line[1].strip
end

puts "Configuration: loaded"

######## Load and clean input file
words = File.open(ARGV[0],'r').read.encode!('UTF-8','UTF-8', :invalid => :replace).downcase
TESTING_MODE = ARGV[0].match?(/test/)

#do some substitutions? e.g. san diego to san-diego
words = words.gsub(/(san(ta)?) /,'\1-')

words = words.split
puts "Words: #{words.count}"

# Clean the loaded words
print "Cleaning"
cleaning_start_time = Time.now()

#remove emails and URLs
words.reject!{|c| c.include?("@") || c.match?(/^https?:\/\//) }
print "."

#convert all of the words to lowercase
#remove special characters from the words
words.map!{|c| c.gsub("\n"," ").strip.gsub(/[^a-z0-9\'-]/,'') }
print "."

#plural to singular: if word ends in "s" (e.g. trucks) remove the "s"
words.map!{|c| doNotSingularize.include?(c) || c[-2]=="'s'" ? c : c.gsub(/^(.+)s$/,'\1') }
print "."

# Remove common words and words that are too short/blank
# Remove things that are just numbers, times, weights
words.reject!{|c| c.nil? || common_words.include?(c) || c.length < 3 || c.match?(/^[0-9]+\s?(am|pm|hrs|lbs)?$/) }
puts ". #{Time.now() - cleaning_start_time} seconds"

######### Heart of the program: Count the words, pairs, and context!
counting_start_time = Time.now()
word_counts = Hash.new(0)
pair_counts = Hash.new(0)
context_count = Hash.new(0)
for i in 1..(words.count) do
    #word
    word_counts[ words[i] ] += 1

    #pair
    if i > 0
      pair_counts["#{words[i-1]} #{words[i]}"] += 1
      #puts "#{words[i-1]} #{words[i]}"
    end

    #context
    if WORDS_OF_CONTEXT_TO_SHOW > 0 && get_context_for.include?(words[i])
      portion = ""
      min = [0, i-WORDS_OF_CONTEXT_TO_SHOW].max
      max = [words.count, i+WORDS_OF_CONTEXT_TO_SHOW].min
      for j in min..max do
        portion += words[j] + " "
      end
      context_count[portion] += 1
    end
end
puts "Counting: #{Time.now() - counting_start_time} seconds"

# run the substitutions
substitutions.each do |word,replace|
    word_counts[replace] += word_counts[word]
    word_counts.delete(word)
end

# Change words to proper forms
propers.each do |word,replace|
    word_counts[replace] += word_counts[word]
    word_counts.delete(word)
end

######## Produce output files
output_start_time = Time.now()
word_counts = word_counts.sort_by {|word,count| count}.reverse
out1 = File.open('out_words-word-first.csv','w')
out2 = File.open('out_words-count-first.csv','w')
word_counts.each do |word, count|
    next if count < MINIMUM_COUNT_TO_EXPORT && !TESTING_MODE
    #puts "#{word}:#{count}"
    out1.syswrite("\"#{word}\",#{count}\n")
    out2.syswrite("#{count},\"#{word}\"\n") #count first for wordclouds.com
end
puts "Words: #{word_counts.count} "

pair_counts = pair_counts.sort_by {|word,count| count}.reverse
out3 = File.open('out_pair-word-first-all.csv','w')
out4 = File.open('out_pair-word-first-500-or-more.csv','w')
pair_counts.each do |phrase, count|
    out3.syswrite("#{count},\"#{phrase}\"\n")

    next if count < MINIMUM_COUNT_TO_EXPORT && !TESTING_MODE
    # puts "#{phrase}:#{count}"
    out4.syswrite("#{count},\"#{phrase}\"\n")
end
puts "Pairs: #{pair_counts.count}"

if WORDS_OF_CONTEXT_TO_SHOW > 0
  out5 = File.open('out_context.csv','w')
  context_count.sort_by {|chunk,count| count}.reverse.each do |chunk, count|
      #puts "#{chunk}:#{count}"
      out5.syswrite("\"#{chunk}\",#{count}\n")
  end
  puts "Context chunks: #{word_counts.count} "
end


#testing speed ###############DELETE ME
puts "Output Time: #{Time.now() - output_start_time} seconds"


######## Output top results
puts "Top results:"
report_max_size_word = report_max_size_pair = report_max_count = 0
for i in 1..ROWS_OF_PRETTY_OUTPUT do
  report_max_size_word = [report_max_size_word, word_counts[i][0].length].max
  report_max_size_pair = [report_max_size_pair, pair_counts[i][0].length].max
  report_max_count     = [report_max_count, word_counts[i][1].to_s.length, pair_counts[i][1].to_s.length].max
end

report_max_size_word += 2
report_max_size_pair += 2
for i in 0..ROWS_OF_PRETTY_OUTPUT do
  print word_counts[i][0].ljust(report_max_size_word)
  print word_counts[i][1].to_s.rjust(report_max_count)
  print "\t\t"
  print pair_counts[i][0].ljust(report_max_size_pair)
  puts pair_counts[i][1].to_s.rjust(report_max_count)
end
