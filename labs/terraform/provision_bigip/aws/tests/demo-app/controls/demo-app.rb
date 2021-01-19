# copyright: 2018, The Authors

title "test demo app"

DEMO_APP = input('demo_app')

describe http('http://#{DEMO_APP}',
  its('status') { should cmp 200 }
)
