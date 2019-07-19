#
# Copyright:: Copyright 2019, Chef Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module RuboCop
  module Cop
    module Chef
      # Use secure Github and Gitlab URLs for source_url and issues_url
      #
      # @example
      #
      #   # bad
      #   depends 'build-essential'
      #   include_recipe 'build-essential::default'
      #   include_recipe 'build-essential'
      #
      #   # good
      #   build_essential 'install compilation tools'
      class UseBuildEssentialResource < Cop
        MSG = 'Use the build_essential resource instead of the legacy build-essential recipe'.freeze

        def_node_matcher :build_essential_recipe_usage?, <<-PATTERN
          (send nil? {:depends :include_recipe} (str {"build-essential" "build-essential::default"}))
        PATTERN

        def on_send(node)
          build_essential_recipe_usage?(node) do
            add_offense(node, location: :expression, message: MSG, severity: :refactor)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if node.method_name == :include_recipe
              corrector.replace(node.loc.expression, "build_essential 'install compilation tools'")
            else # metadata depends
              corrector.remove(node.loc.expression)
            end
          end
        end
      end
    end
  end
end
