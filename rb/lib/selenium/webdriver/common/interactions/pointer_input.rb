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

require 'securerandom'

module Selenium
  module WebDriver
    module Interactions
      class PointerInput < InputDevice
        KIND = {mouse: :mouse, pen: :pen, touch: :touch}.freeze
        BUTTON = {left: 0, middle: 1, right: 2}.freeze
        SUBTYPES = {down: :pointerDown, up: :pointerUp, move: :pointerMove, cancel: :pointerCancel, pause: :pause}.freeze

        attr_reader :kind
        attr_accessor :primary

        def initialize(kind, name: nil, primary: true)
          super(name)
          @kind = assert_kind(kind)
          @primary = primary
        end

        def type
          Interactions::POINTER
        end

        def encode
          return nil if no_actions
          output = {type: type, id: name, actions: @actions.map(&:encode)}
          params = {primary: primary, pointerType: kind}
          output[:parameters] = params
          output
        end

        def assert_kind(pointer)
          raise TypeError, "#{pointer.inspect} is not a valid pointer type" unless KIND.key? pointer
          KIND[pointer]
        end

        def create_pointer_move(duration: 0, x: 0, y: 0, element: nil, origin: nil)
          add_action(PointerMove.new(self, duration, x, y, element, origin))
        end

        def create_pointer_down(button)
          add_action(PointerPress.new(self, Press::DOWN, button))
        end

        def create_pointer_up(button)
          add_action(PointerPress.new(self, Press::UP, button))
        end

        def create_pause
          add_action(Pause.new(self))
        end

        def create_pointer_cancel
          add_action(PointerCancel.new(self))
        end
      end

      class PointerPress < Interaction
        DOWN = PointerInput::SUBTYPES[:down]
        UP = PointerInput::SUBTYPES[:up]
        DIRECTIONS = [DOWN, UP].freeze

        def initialize(source, direction, button)
          super(source)
          raise ArgumentError, 'Button number cannot be negative!' unless button >= 0
          @direction = direction
          @button = button
        end

        def type
          @direction
        end

        def assert_direction(direction)
          raise TypeError, "#{direction.inspect} is not a valid button direction" unless DIRECTIONS.include? direction
          direction
        end

        def encode
          {type: type, button: @button}
        end
      end # Press

      class PointerMove < Interaction
        VIEWPORT = :viewport
        POINTER = :pointer
        ORIGINS = [VIEWPORT, POINTER].freeze

        def initialize(source, duration, x, y, element, origin)
          super(source)
          raise ArgumentError, 'duration value cannot be negative!' unless duration >= 0
          raise ArgumentError, 'X value cannot be negative!' unless x >= 0
          raise ArgumentError, 'Y value cannot be negative!' unless y >= 0
          @duration = duration
          @x_offset = x
          @y_offset = y
          @element = element
          @origin = origin
        end

        def type
          PointerInput::SUBTYPES[:move]
        end

        def assert_direction(direction)
          raise TypeError, "#{direction.inspect} is not a valid pointer type" unless DIRECTIONS.include? direction
          direction
        end

        def encode
          output = {type: type, duration: @duration, x: @x_offset, y: @y_offset}
          output[:origin] = @element if @element
          output[:origin] = @origin if @origin
          output
        end
      end # Move

      class PointerCancel < Interaction
        def type
          PointerInput::SUBTYPES[:cancel]
        end

        def encode
          {type: type}
        end
      end # Cancel
    end
  end
end
