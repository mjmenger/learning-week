# copyright: 2018, The Authors

title "test demo app"

DEMO_APP = input('demo_app')

control "demo app" do
  impact 1.0
  describe http("http://#{DEMO_APP}") do
    its('status') { should cmp 200 }
  end
end
