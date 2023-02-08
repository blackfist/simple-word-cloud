# Simple Word Cloud Data Generator


# Execution

`ruby wordcloud.rb [input file name, e.g. sample.txt]`

It will output the top 80 words to your terminal, as well as these files:

1. `out_words-word-first.csv` Simplest output, word then count, e.g. `awesome, 17`
1. `out_pair-word-first-all.csv` Pairs of words with counts, e.g. `"sent email",33`
1. `out_pair-word-first-500-or-more.csv` Subset of #2 where count >= 500 (which can be modified by changing `MINIMUM_COUNT_TO_EXPORT` in `wordcloud.rb`)
1. `out_context.csv` For each word in `in_word_search_context.txt`, provide `WORDS_OF_CONTEXT_TO_SHOW` of context around it. So if "saving" is in `in_word_search_context.txt`, `out_context.csv` might contain `"always remember saving files is",23`

Any of these files can be put into https://www.wordclouds.com/ or another wordcloud generator.

Finally, some wordcloud generators want the count then the word, e.g. `17, awesome`. This format is automatically provided by `out_words-count-first.csv`.


# What are the other files?
* `sample.txt` is a file you can analyze.
* `common_words.txt` is a list of words that you want removed from your output completely.  This is a good place to put words that show up a lot but which are not relevant to your word cloud.
* `substitutions.txt` This is a comma separated file of words that you want changed to something else.  For example, you might not want to count the word `China` and `Chinese` separately.  So you can enter `chinese,china` into that file and all the occurrences of `chinese` will change to `china` and their respective counts will be added together.
* `propers.txt` by default, the script converts every word to lowercase.  This is a list of values that need to be changed after all the processing is done.  This file does not affect word count the way `substitutions.txt` does.  So you might have entries like `fbi,FBI` and `ddos,DDoS`.
* `do_not_singularize.txt` similarly, the script attempts to take plurals (e.g. `cars`) and turn them into singular (e.g. `car`). This file is for words that should NOT have that done to them, e.g. `lbs`, `yes`, `mass`, `plus`, `address`, etc.

# How do I use the output?
Take the output of the script over to https://www.wordclouds.com and paste it into the text box.  Then enjoy your word cloud.
