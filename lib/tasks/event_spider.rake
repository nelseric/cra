require 'nokogiri'
require 'open-uri'

task :event_spider => :environment do
  # build the competition list, the format changed in 2007 to the current one,
  # TODO: make the last year the current year, or as far as these records go.
  (2010..2011).each do
  |year|
    p year
    if Season.find_by_year(year) == nil then
      season = Season.create(:year => year)
    end
    doc = Nokogiri::HTML(open("https://my.usfirst.org/myarea/index.lasso?event_type=FRC&year=#{year}"))
    links = doc.css("a")
    comps = links.map { |link| "https://my.usfirst.org/myarea/index.lasso#{link["href"]}" }
    comps = comps.select { |c| c.match(/event_details/) != nil }
    # now that we have the links to the detail pages, we will now get the links to the match history pages
    comps.each do
    |link|
      doc = Nokogiri::HTML(open(link))
      event = event_subtype = location = registered_teams = nil
      doc.css("tr").each do
      |line|
        data = line.css('td')
        if data.size == 2
          case data[0].content
            when "Event"
              event = data[1].content.chomp
            when "Event Subtype"
              event_subtype = data[1].content
            when "Registered Teams"
              registered_teams = data[1].content.chomp
          end
        end
      end
      if Competition.find(:year => year,
                          :event => event) == nil then
        comp = Competition.create(:year => year,
                                  :event => event,
                                  :event_subtype => event_subtype,
                                  :registered_teams => registered_teams)
      end
      puts "{#{event}} {#{event_subtype}} {#{registered_teams}}"
    end
  end
end