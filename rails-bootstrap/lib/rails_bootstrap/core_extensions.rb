module Rails
  module Generators
    module Actions
      RECIPES_ROOT = '/Users/urfolomeus/workspaces/ruby/pairing-config/rails-bootstrap/recipes/'
      TEMPLATES_ROOT = File.join(RECIPES_ROOT, '..', 'templates')
      FILES_ROOT = File.join(RECIPES_ROOT, '..', 'files')

      def bootstrap(required, optional=[])
        recipes = compile_recipe_list(required, optional)

        execute_recipes(recipes)

        inside app_name do
          run 'bundle install'
        end

        execute_strategies

        rake "db:create", :env => 'development'
        rake "db:migrate", :env => 'development'
        rake "db:test:prepare"

        # commit to git
        git :add => "."
        git :commit => "-m 'final initial commit'"

        say <<-eos
          ============================================================================
          Your new Rails application is ready to go.

          Don't forget to scroll up for important messages from installed generators.
        eos
      end

      def compile_recipe_list(required, optional)
        recipes = required
        optional.each do |recipe|
          recipes << recipe if yes?("Would you like to apply the #{ActiveSupport::Inflector.humanize(File.basename(recipe, ".rb"))} recipe? [no]")
        end
        recipes
      end

      def after_bundler(delay=0, p=nil, &block)
        @after_bundler ||= Hash.new { |hash, key| hash[key] = [] }
        @after_bundler[delay] << (p || block)
      end

      def after_readme(&block)
        @after_readme ||= []
        @after_readme << block
      end

      def add_view(source, destination)
        get(
          File.join(FILES_ROOT, 'views', source),
          File.join('app', 'views', destination)
        )
      end

      def add_generator(name)
        get(
          File.join(FILES_ROOT, 'generators', "#{name}_generator.rb"),
          File.join('lib', 'generators', "#{name}_generator.rb")
        )
      end

      def add_to_readme(section, text)
        after_readme do
          inject_into_file 'README.md', :after => "## #{section}\n\n" do
            "#{text}\n\n"
          end
        end
      end

      def execute_recipes(recipes)
        recipes.each do |recipe|
          execute_recipe(recipe)
        end
      end

      def execute_recipe(recipe)
        recipe = File.join(RECIPES_ROOT, recipe) unless recipe.include?(RECIPES_ROOT)
        recipe << ".rb" unless recipe.include?(".rb")
        apply recipe
      end

      def execute_strategies
        @after_bundler.keys.sort.map {|k| @after_bundler[k]}.flatten.each {|strategy| strategy.call }
      end
    end
  end
end