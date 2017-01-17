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

require 'json'

module Selenium
  module WebDriver

    class W3CActionBuilder
      DEFAULT_MOVE_DURATION = 0.5 # 500 milliseconds

      def initialize(mouse, keyboard, async = false)
        @devices = {
            mouse: mouse,
            keyboard: keyboard
        } # For backwards compatibility, automatically include mouse & keyboard

        @async = async
      end

      def pointer_inputs
        @devices.select { |device| device.type == Interactions::POINTER }
      end

      def key_input
        @devices.find { |device| device.type == Interactions::KEY }
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
      # Performs a modifier key press. Does not release
      # the modifier key - subsequent interactions may assume it's kept pressed.
      # Note that the modifier key is never released implicitly - either
      # #key_up(key) or #send_keys(:null) must be called to release the modifier.
      #
      # Equivalent to:
      #   driver.action.click(element).send_keys(key)
      #   # or
      #   driver.action.click.send_keys(key)
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
      # @param [:shift, :alt, :control, :command, :meta] The key to press.
      # @param [Selenium::WebDriver::Element] element An optional element
      # @raise [ArgumentError] if the given key is not a modifier
      # @return [ActionBuilder] A self reference.
      #

      def key_down(*args)
        [args.shift] if args.first.is_a? Element # Handle this later...
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
      # @param [:shift, :alt, :control, :command, :meta] The modifier key to release.
      # @param [Selenium::WebDriver::Element] element An optional element
      # @raise [ArgumentError] if the given key is not a modifier key
      # @return [ActionBuilder] A self reference.
      #

      def key_up(*args)
        [args.shift] if args.first.is_a? Element # Handle this later...
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
      # @return [ActionBuilder] A self reference.
      #

      def send_keys(*args)
        [args.shift] if args.first.is_a? Element # Handle this later...
        args.last.each do |character|
          key_input.create_key_down(character)
          key_input.create_key_up(character)
        end
        self
      end

      #
      # Clicks (without releasing) in the middle of the given element. This is
      # equivalent to:
      #
      #   driver.action.move_to(element).click_and_hold
      #
      # @example Clicking and holding on some element
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.click_and_hold(el).perform
      #
      # @param [Selenium::WebDriver::Element] element the element to move to and click.
      # @return [ActionBuilder] A self reference.
      #

      def click_and_hold(element = nil, pointer = nil)
        pointer = pointer || primary_pointer
        move_to(element, 0, 0, pointer) if element
        pointer_down(Interactions::PointerInput::BUTTON[:left], pointer)
        self
      end

      #
      # Clicks (without releasing) in the middle of the given element. This is
      # equivalent to:
      #
      #   driver.action.move_to(element).click_and_hold
      #
      # @example Clicking and holding on some element
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.click_and_hold(el).perform
      #
      # @param [Selenium::WebDriver::Element] element the element to move to and click.
      # @return [ActionBuilder] A self reference.
      #

      def pointer_down(button, pointer = nil)
        pointer = pointer || primary_pointer
        move_to(element, 0, 0, pointer) if element
        pointer.create_pointer_down(button)
        synchronize(pointer)
        self
      end

      #
      # Releases the depressed left mouse button at the current mouse location.
      #
      # @example Releasing an element after clicking and holding it
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.click_and_hold(el).release.perform
      #
      # @return [ActionBuilder] A self reference.
      #

      def release(element = nil, pointer = nil) # Why is an element being passed...
        pointer = pointer || primary_pointer
        pointer_up(Interactions::PointerInput::BUTTON[:left], pointer)
        self
      end

      #
      # Releases the depressed left mouse button at the current mouse location.
      #
      # @example Releasing an element after clicking and holding it
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.click_and_hold(el).release.perform
      #
      # @return [ActionBuilder] A self reference.
      #

      def pointer_up(button, pointer = nil)
        pointer = pointer || primary_pointer
        pointer.create_pointer_up(button)
        synchronize(pointer)
        self
      end

      #
      # Clicks in the middle of the given element. Equivalent to:
      #
      #   driver.action.move_to(element).click
      #
      # When no element is passed, the current mouse position will be clicked.
      #
      # @example Clicking on an element
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.click(el).perform
      #
      # @example Clicking at the current mouse position
      #
      #    driver.action.click.perform
      #
      # @param [Selenium::WebDriver::Element] element An optional element to click.
      # @return [ActionBuilder] A self reference.
      #

      def click(element = nil, pointer = nil)
        pointer = pointer || primary_pointer
        move_to(element, 0, 0, pointer) if element
        pointer_down(Interactions::PointerInput::BUTTON[:left], pointer)
        pointer_up(Interactions::PointerInput::BUTTON[:left], pointer)
        self
      end

      #
      # Performs a double-click at middle of the given element. Equivalent to:
      #
      #   driver.action.move_to(element).double_click
      #
      # @example Double click an element
      #
      #    el = driver.find_element(id: "some_id")
      #    driver.action.double_click(el).perform
      #
      # @param [Selenium::WebDriver::Element] element An optional element to move to.
      # @return [ActionBuilder] A self reference.
      #

      def double_click(element = nil, pointer = nil)
        pointer = pointer || primary_pointer
        move_to(element, 0, 0, pointer) if element
        click(element, pointer)
        click(element, pointer)
        self
      end

      #
      # Performs a context-click at middle of the given element. First performs
      # a move_to to the location of the element.
      #
      # @example Context-click at middle of given element
      #
      #   el = driver.find_element(id: "some_id")
      #   driver.action.context_click(el).perform
      #
      # @param [Selenium::WebDriver::Element] element An element to context click.
      # @return [ActionBuilder] A self reference.
      #

      def context_click(element = nil, pointer = nil)
        pointer = pointer || primary_pointer
        move_to(element, 0, 0, pointer) if element
        pointer_down(Interactions::PointerInput::BUTTON[:right], pointer)
        pointer_up(Interactions::PointerInput::BUTTON[:right], pointer)
        self
      end

      #
      # A convenience method that performs click-and-hold at the location of the
      # source element, moves to the location of the target element, then
      # releases the mouse.
      #
      # @example Drag and drop one element onto another
      #
      #   el1 = driver.find_element(id: "some_id1")
      #   el2 = driver.find_element(id: "some_id2")
      #   driver.action.drag_and_drop(el1, el2).perform
      #
      # @param [Selenium::WebDriver::Element] source element to emulate button down at.
      # @param [Selenium::WebDriver::Element] target element to move to and release the
      #   mouse at.
      # @return [ActionBuilder] A self reference.
      #

      def drag_and_drop(source, target, pointer = nil)
        pointer = pointer || primary_pointer
        click_and_hold(source, pointer)
        move_to(target, 0, 0, pointer)
        release(target, pointer)
        self
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

      def move_to(element, right_by = 0, down_by = 0, pointer = nil)
        pointer = pointer || primary_pointer
        # New actions offset is from center of element
        if right_by != 0 || down_by != 0
          size = element.size
          left_offset = (size[:width] / 2).to_i
          top_offset = (size[:height] / 2).to_i
          right_by = -left_offset + right_by
          down_by = -top_offset + down_by
        end
        pointer.create_pointer_move(DEFAULT_MOVE_DURATION, x: right_by, y: down_by, element: element)
        synchronize(key_input)
        self
      end

      #
      # Moves the mouse from its current position (or 0,0) by the given offset.
      # If the coordinates provided are outside the viewport (the mouse will
      # end up outside the browser window) then the viewport is scrolled to
      # match.
      #
      # @example Move the mouse to a certain offset from its current position
      #
      #    driver.action.move_by(100, 100).perform
      #
      # @param [Integer] right_by horizontal offset. A negative value means moving the
      #   mouse left.
      # @param [Integer] down_by vertical offset. A negative value means moving the mouse
      #   up.
      # @return [ActionBuilder] A self reference.
      # @raise [MoveTargetOutOfBoundsError] if the provided offset is outside
      #   the document's boundaries.
      #

      def move_by(right_by, down_by, pointer = nil)
        pointer = pointer || primary_pointer
        pointer.create_pointer_move(DEFAULT_MOVE_DURATION,
                                    x: Integer(right_by),
                                    y: Integer(down_by),
                                    origin: Interactions::PointerMove::POINTER)
        synchronize(pointer)
        self
      end

      #
      # Moves the mouse from its current position (or 0,0) by the given offset.
      # If the coordinates provided are outside the viewport (the mouse will
      # end up outside the browser window) then the viewport is scrolled to
      # match.
      #
      # @example Move the mouse to a certain offset from its current position
      #
      #    driver.action.move_by(100, 100).perform
      #
      # @param [Integer] x horizontal offset. A negative value means moving the
      #   mouse left.
      # @param [Integer] down_by vertical offset. A negative value means moving the mouse
      #   up.
      # @return [ActionBuilder] A self reference.
      # @raise [MoveTargetOutOfBoundsError] if the provided offset is outside
      #   the document's boundaries.
      #

      def move_to_location(x, y, pointer = nil)
        pointer = pointer || primary_pointer
        pointer.create_pointer_move(DEFAULT_MOVE_DURATION,
                                    x: Integer(x),
                                    y: Integer(y),
                                    origin: Interactions::PointerMove::VIEWPORT)
        synchronize(pointer)
        self
      end

      def synchronize(action_device)
        return if @async
        @devices.each { |device| device.create_pause unless device == action_device}
      end

      #
      # Executes the actions added to the builder.
      #

      def perform
        json = @devices.map(&:encode).compact.to_json
        @bridge.send_actions json
        nil
      end

      def clear_all_actions
        @device.each(&:clear_actions)
        @bridge.release_actions
      end
    end # W3CActionBuilder
  end # WebDriver
end # Selenium
