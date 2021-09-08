# name: discourse-trivia
# about: a plugin that adds a bot that can ask some questions and their respective answers, picked in tagged topics
# version: 0.1
# authors: benjamin_d
# credits: come from the frotz discourse plugin by merefield


require_relative 'lib/bot'
require_relative 'lib/triviabot'
require_relative 'lib/reply_creator'

enabled_site_setting :discourse_trivia_enabled

after_initialize do

  User.register_custom_field_type('quiz_posts_asked', :json)
  register_editable_user_custom_field :quiz_posts_asked if defined? register_editable_user_custom_field
  register_editable_user_custom_field quiz_posts_asked: {} if defined? register_editable_user_custom_field
  add_to_serializer(:user, :quiz_posts_asked, false) { object.custom_fields['quiz_posts_asked'] }

  load File.expand_path('../jobs/triviabot_reply_job.rb', __FILE__)

  DiscourseEvent.on(:post_created) do |*params|
    post, opts, user = params

    if SiteSetting.discourse_trivia_enabled

      bot_username = SiteSetting.trivia_bot_user
      bot_user = User.find_by(username: bot_username)

      if (user.id != bot_user.id) && post.reply_count = 0
        bot = DiscourseTrivia::Bot.new
        bot.on_post_created(post)
      end

    end
  end

end
