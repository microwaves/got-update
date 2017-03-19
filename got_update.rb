require 'nokogiri'
require 'open-uri'
require 'mail'

class GotUpdate
	attr_reader :mail_options, :mail_from, :recipient, :website, :target_content, :current_content

	def initialize(recipient, website, target_content)
		@mail_options = {
			:address => 'SMTP_SERVER_HOST',
			:port => SMTP_SERVER_PORT,
			:user_name => 'EMAIL_USERNAME',
			:password => 'EMAIL_PASSWORD',
			:authentication => :plain,
			:enable_starttls_auto => true
		}
    setup_mail

    @mail_from = 'MAIL_FROM_ADDRESS'
    @recipient = recipient
    @website = website
    @target_content = target_content
    @current_content = retrieve_content
	end

	def listen!
		while true
			check_for_updates
			sleep 2
		end
	end

	private

  def setup_mail
		Mail.defaults do
			delivery_method :smtp, @mail_options
		end
  end

  def retrieve_content
		Nokogiri::HTML(
      open(@website)
    ).css(@target_content).to_s
  end

	def check_for_updates
    @new_content = retrieve_content

		if @new_content != @current_content
      puts "#####################################"
      puts "#         WEBSITE UPDATED!          #"
      puts "#####################################"

			send_email
			abort
    else
      puts "No updates yet..."
    end
	end

	def send_email
		Mail.deliver do
			to @recipient
			from @mail_from 
			subject "#{@website} got some updates!"
			body "Access #{@website} and check it with your own eyes."
		end
	end
end

#crawler = GotUpdate.new('foobar@xyz.net', 'http://foobar.foo/news', 'div #container ul')
#crawler.listen!
