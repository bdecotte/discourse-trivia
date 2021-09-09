module DiscourseTrivia

  class TriviaBot < StandardError; end

  class TriviaBot

    def self.quiz_topics_title(user_id)
      current_user = User.find_by(id: user_id)
      already_asked = ::JSON.parse(current_user.custom_fields['quiz_posts_asked'])
      last_question = already_asked[already_asked.keys.last]


      result = Post.joins(:topic, topic: :tags).where(tags: { name: "trivia" }).where('post_number > 1').order('random()')

      to_be_asked = Array.new

      result.each do |value|
        if !already_asked.has_value?(value.id)
          to_be_asked.push(value)
        end
      end
#      result = @guardian.filter_allowed_categories(result)

      if !last_question.blank?
        answer_to_last_question = Post.find_by(id: last_question).raw.gsub(/(?>\s|.)*---\n---/, "")
      else
        answer_to_last_question = ""
      end

      if !to_be_asked.empty?
        question = to_be_asked[0].raw.gsub(/---\n---(\s|.)*/, "")
        if !already_asked.has_value?(to_be_asked[0].id)
           already_asked[:"#{already_asked.length + 1}"] = to_be_asked[0].id
        end
      else
        question = "Toutes les questions ont été posées... Pourquoi ne pas participer à leur rédaction ? \n Pour recommencer répondre : recommencer un quiz "
      end


      current_user.custom_fields['quiz_posts_asked'] = ::JSON.generate(already_asked)
      current_user.save_custom_fields
      return "#{answer_to_last_question}\n---\n---\n#{question}"

    end


    def self.ask(opts)

      msg = opts[:message_body].downcase

      user_id = opts[:user_id]

      msg = CGI.unescapeHTML(msg.gsub(/[^a-zA-Z0-9 ]+/, "")).gsub(/[^A-Za-z0-9]/, " ").strip

      if msg.include?('commencer un quiz') || msg.include?('recommencer un quiz')
        current_user = User.find_by(id: user_id)
        current_user.custom_fields['quiz_posts_asked'] = {}
        current_user.save_custom_fields
        return quiz_topics_title(user_id)
      end

      lines = ""
      reply = quiz_topics_title(user_id)
    end
  end
end
