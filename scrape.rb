require 'rubygems'
require 'bundler/setup'

# Stuff in the bundle. Require manually for simplicity.
require 'mechanize'

# Stuff from stdlib
require 'logger'
require 'csv'

$logger = Logger.new($stdout)

def get_links!
  agent = Mechanize.new
  agent.log = $logger
  agent.user_agent_alias = 'Mac Safari'

  page = agent.get('https://news.ycombinator.com')

  relevant_links = page.links.select do |link|
    klass = link.node.parent.attributes['class']
    next false unless klass
    klass.value == 'title'
  end

  relevant_links.each_with_index.map { |link, idx| { position: idx + 1, title: link.text, href: link.attributes['href'] } }
end

CSV.open("links.csv", "wb") do |csv|
  csv << %w(period position title href)

  loop do
    period = Time.now
    links = get_links!

    links.each do |link|
      csv << [period, link[:position], link[:title], link[:href]]
    end

    # Wait 5 minutes.
    sleep(5 * 60)
  end
end
