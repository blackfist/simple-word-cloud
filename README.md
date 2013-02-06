# Simple Word Cloud Data Generator

This is a really simple script I wrote when I wanted to make a word cloud using Wordle but needed something more advanced than what I got from the UI.  It's written in ruby so all you have to do is type ruby wordcloud.rb and you'll get your data.

# What is with these extra files?
* intext.txt is the file that contains the text you want to analyze.  Put your raw text in there. This repo comes with some text you can play with.
* common\_words.txt is a list of words that you want removed from you output completely.  This is a good place to put words that show up a lot but which are not relevant to your word cloud.
* substitutions.txt This is a comma separated file of words that you want changed to something else.  For example, you might not want to count the word China and Chinese separately.  So you can enter chinese,china into that file and all the occurences of chinese will change to china and their respective counts will be added together.
propers.txt by default, the script converts every word to lowercase.  This is a list of values that need to be changed after all the processing is done.  This file does not affect word count the way substitutions.txt does.  So you might have entries like fbi,FBI and ddos,DDoS.

# How do I use the output?
Take the output of the script over to http://www.wordle.net/advanced and paste it into the text box.  Then enjoy your word cloud.

