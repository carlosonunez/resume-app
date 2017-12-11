#!/usr/bin/env ruby
<<<<<<< HEAD

# Helpers used by Rake to do stuff, like deploy to ECS.
module RakeHelpers
  # Helpers for AWS.
  module AWS
    # Helpers for AWS ECS, Amazon's custom container orchestration platform.
    module ECS
      def self.generate_task_json!
        raise IOError,"ecs_task_template.json is missing. Please provide it." \
          unless File.exist? "ecs_task_template.json"
      end
    end
  end
end
=======
#!/usr/bin/env ruby

# Helpers used by Rake to do stuff, like deploy to ECS.
module RakeHelpers
  # Helpers for AWS.
  module AWS
    # Helpers for AWS ECS, Amazon's custom container orchestration platform.
    module ECS
      def self.generate_task_json!
        raise IOError,"ecs_task_template.json is missing. Please provide it." \
          unless File.exist? "ecs_task_template.json"
      end
    end
  end
end
