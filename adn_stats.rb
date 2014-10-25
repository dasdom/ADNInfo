require 'json'

def check_usage
  unless ARGV.length == 1
    puts "Usage: adn_stats <app.net json file>"
    exit
  end
end

if $0 == __FILE__
  check_usage

  string = File.open(ARGV[0]).read

  data = JSON.parse(string)

  #puts data[0]

  sources = {}
  mentions = {}

  number_of_long_posts = 0
  number_of_original_posts = 0

  data.each do | element |
    number_of_posts = sources[element["source"]["name"]]
    number_of_posts = number_of_posts ? number_of_posts+1 : 1;
    sources[element["source"]["name"]] = number_of_posts

    mentions_in_post = element["entities"]["mentions"]
    mentions_in_post.each do | mention |
      number_of_mentions = mentions[mention["name"]]
      number_of_mentions = number_of_mentions ? number_of_mentions+1 : 1;
      mentions[mention["name"]] = number_of_mentions
    end
    #puts number_of_posts
    text = element["text"]
    if text and text.length > 140
      number_of_long_posts = number_of_long_posts + 1
    end
    if not (text =~ /@\w/)
      number_of_original_posts = number_of_original_posts + 1
    end
  end

  #puts sources.methods

  total_posts = 0

  puts "\nYou have used the following clients:"
  sorted_source = sources.invert
  sorted_source.sort.reverse_each do | key, value |
    puts key.to_s.rjust(10) + " #{value}"
    total_posts = total_posts + key
  end
  puts "----------------------------------------------"
  puts total_posts.to_s.rjust(10) + " total"

  puts "\nYou have posted #{number_of_long_posts} posts which couldn't have been tweeted (>140 characters)."
  puts "#{number_of_original_posts} of your #{total_posts} post didn't mention another user."

  puts "\nYou have mentioned the following people:"
  sorted_mentions = mentions.invert
  sorted_mentions.sort.reverse_each do | key, value |
    puts key.to_s.rjust(10) + " #{value}"
  end

end
