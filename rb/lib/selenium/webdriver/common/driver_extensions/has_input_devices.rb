# encoding: utf-8
#
# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

module Selenium
  module WebDriver
    #
    # @api private
    #

    module DriverExtensions
      module HasInputDevices
        #
        # @return [ActionBuilder]
        # @api public
        #

        def action(async = false)
          if @bridge.class < Remote::W3CBridge
            W3CActionBuilder.new @bridge,
                                 Interactions::PointerInput.new(:mouse, name: 'mouse', primary: true),
                                 Interactions::KeyInput.new('keyboard'), async
          else
            ActionBuilder.new Mouse.new(@bridge), Keyboard.new(@bridge)
          end
        end

        #
        # @api private
        #

        def mouse
          warn <<-DEPRECATE.gsub(/\n +| {2,}/, ' ').freeze
            [DEPRECATION] `driver.mouse` is deprecated with w3c implementation. Instead use 
            driver.action.<command>.perform
          DEPRECATE
          Mouse.new @bridge
        end

        #
        # @api private
        #

        def keyboard
          warn <<-DEPRECATE.gsub(/\n +| {2,}/, ' ').freeze
            [DEPRECATION] `driver.keyboard` is deprecated with w3c implementation. Instead use 
            driver.action.<command>.perform
          DEPRECATE
          Keyboard.new @bridge
        end
      end # HasInputDevices
    end # DriverExtensions
  end # WebDriver
end # Selenium
