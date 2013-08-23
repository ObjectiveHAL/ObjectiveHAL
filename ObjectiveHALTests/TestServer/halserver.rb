# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
Bundler.require

API_VERSION='2013-08-19'

#uuid = UUID.new
#token = uuid.generate
token = SecureRandom.hex

set(:auth) do |*roles|   # <- notice the splat here
  condition do
    unless logged_in? && roles.any? {|role| current_user.in_role? role }
      redirect "/login/", 303
    end
  end
end

def build_link(href, name=nil, title=nil, templated=nil)
  link = Hash.new {0}
  link[:href] = href;
  if name != nil
    link[:name] = name
  end
  if title != nil
    link[:title] = title
  end
  if templated != nil
    link[:templated] = templated
  end

  return link
end

# Returns the service directory
get '/' do
  curies = Array.new
  curies[0] = build_link('http://objectivehal.org/rel/{rel}', 'r', nil, true)

  links = Hash.new {0}
  links[:curies] = curies
  links[:self] = build_link('/')
  links[:authenticate] = build_link('/login')

  services = Hash.new {0}
  services[:_links] = links

  services.to_json
end

post '/login' do
  email = params[:email]
  password = params[:password]
  content_type :json
  { :token => token }.to_json
end

after do
  response['X-Api-Header'] = API_VERSION
end