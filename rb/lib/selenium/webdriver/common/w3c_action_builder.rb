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

    class W3CActionBuilder

      def initialize(mouse, keyboard, async = false)
        @devices = {
            mouse: mouse,
            keyboard: keyboard
        } # For backwards compatibility, automatically include mouse & keyboard

        @actions = []
        @async = async
      end

      def pointer_inputs
        @devices.select { |device| device.is_a? Interactions::PointerInput }
      end

      def key_inputs
        @devices.select { |device| device.is_a? Interactions::KeyInput }
      end

      def add_pointer_input(name, device)
        return TypeError, "#{device.inspect} is not a valid input device" unless device < Interactions::PointerInput
        @devices[name] = device
        set_primary_pointer(name) if device.primary
      end

      def add_key_input(name, device)
        return TypeError, "#{device.inspect} is not a valid input device" unless device < Interactions::PointerInput
        @devices[name] = device
      end

      def set_primary_pointer(key)
        pointer_inputs.each { |name, device| device.primary = false unless name == key }
      end

      def primary_pointer
        pointer_inputs.find(&:primary)
      end

      #
      # Moves the mouse to the middle of the given element. The element is scrolled into
      # view and its location is calculated using getBoundingClientRect.  Then the
      # mouse is moved to optional offset coordinates from the element.
      #
      # Note that when using offsets, both coordinates need to be passed.
      #
      # @example Scroll element into view and move the mouse to it
      #
      #   el = driver.find_element(id: "some_id")
      #   driver.action.move_to(el).perform
      #
      # @example
      #
      #   el = driver.find_element(id: "some_id")
      #   driver.action.move_to(el, 100, 100).perform
      #
      # @param [Selenium::WebDriver::Element] element to move to.
      # @param [Integer] right_by Optional offset from the top-left corner. A negative value means
      #   coordinates right from the element.
      # @param [Integer] down_by Optional offset from the top-left corner. A negative value means
      #   coordinates above the element.
      # @return [ActionBuilder] A self reference.
      #

      def move_to(element, right_by = nil, down_by = nil)
        @actions << if right_by && down_by
                      [:mouse, :move_to, [element, Integer(right_by), Integer(down_by)]]
                    else
                      [:mouse, :move_to, [element]]
                    end

        self
      end
    end # W3CActionBuilder
  end # WebDriver
end # Selenium
