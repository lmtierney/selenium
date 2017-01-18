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
    module KeyActions

      #
      # Performs a key press. Does not release the key - subsequent interactions may assume it's kept pressed.
      # Note that the modifier key is never released implicitly - either #key_up(key) or #release_actions must be
      # called to release the key.
      #
      # @example Press a key
      #
      #    driver.action.key_down(:control).perform
      #
      # @example Press a key on an element
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.key_down(el, :shift).perform
      #
      # @param [Selenium::WebDriver::Element] element An optional element
      # @param [:shift, :alt, :control, :command, :meta, 'a'] key The key to press.
      # @return [W3CActionBuilder] A self reference.
      #

      def key_down(*args)
        click(args.shift) if args.first.is_a? Element
        key_input.create_key_down(args.last)
        synchronize(key_input)
        self
      end

      #
      # Performs a modifier key release.
      # Releasing a non-depressed modifier key will yield undefined behaviour.
      #
      # @example Release a key
      #
      #   driver.action.key_up(:shift).perform
      #
      # @example Release a key from an element
      #
      #   el = driver.find_element(id: "some_id")
      #   driver.action.key_up(el, :alt).perform
      #
      # @param [Selenium::WebDriver::Element] element An optional element
      # @param [:shift, :alt, :control, :command, :meta, 'a'] key The modifier key to release.
      # @return [W3CActionBuilder] A self reference.
      #

      def key_up(*args)
        click(args.shift) if args.first.is_a? Element
        key_input.create_key_up(args.last)
        synchronize(key_input)
        self
      end

      #
      # Sends keys to the active element. This differs from calling
      # Element#send_keys(keys) on the active element in two ways:
      #
      # * The modifier keys included in this call are not released.
      # * There is no attempt to re-focus the element - so send_keys(:tab) for switching elements should work.
      #
      # @example Send the text "help" to an element
      #
      #   el = driver.find_element(id: "some_id")
      #   driver.action.send_keys(el, "help").perform
      #
      # @example Send the text "help" to the currently focused element
      #
      #   driver.action.send_keys("help").perform
      #
      # @param [Selenium::WebDriver::Element] element An optional element
      # @param [String] keys The keys to be sent.
      # @return [W3CActionBuilder] A self reference.
      #

      def send_keys(*args)
        click(args.shift) if args.first.is_a? Element
        args.last.each_char do |character|
          key_down(character)
          key_up(character)
        end
        self
      end
    end # KeyActions
  end # WebDriver
end # Selenium
