require 'bundler/setup'
require 'sinatra'
require 'aws-sdk'

$LOAD_PATH << File.join(__dir__, 'lib')
require 'circular_message_queue'

AWS.config(region: 'eu-west-1')

# TODO: IAM notwendig
# instance_id = open('http://169.254.169.254/latest/meta-data/instance-id').read
# instance = ec2.instances[instance_id]
# instance.tags.to_h

# TODO: Andere, eigene queue

get '/' do
  content_type 'text/plain'
  "Hello world"
end

post '/' do
  msg = AWS::SNS::Message.new(request.body.read)
  if msg.authentic?
    case msg.type
    when :SubscriptionConfirmation then
      topic = AWS.sns.topics['arn:aws:sns:eu-west-1:505122073500:flo-test']
      topic.confirm_subscription(msg.token)
    when :Notification then
      CircularMessageQueue.new << msg.message
    end
    status 201
  else
    status 400
  end
end

run Sinatra::Application

# passenger start
