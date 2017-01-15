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
        MOUSEBUTTON = {left: 0, middle: 1, right: 2}.freeze

        attr_reader :kind

        def initialize(kind, name = nil, primary = true)
          super(name)
          @kind = assert_kind(kind)
          @primary = primary
        end

        def type
          Interactions::POINTER
        end

        def encode
          output = {type: type, id: name}
          params = {primary: primary, pointerType: kind}
          output[:params] = params
          output
        end

        def assert_kind(pointer)
          raise TypeError, "#{pointer.inspect} is not a valid pointer type" unless KIND.key? pointer
          KIND[pointer]
        end

        def create_pointer_move(duration, x, y, element = nil)
          Move.new(self, duration, x, y, element)
        end

        def create_pointer_down(button)
          Press.new(self, Press::DOWN, button)
        end

        def create_pointer_up(button)
          Press.new(self, Press::UP, button)
        end

        class Press < Interaction
          DOWN = :pointerDown
          UP = :pointerUp
          DIRECTIONS = [DOWN, UP].freeze

          def initialize(source, direction, button)
            super(source)
            raise ArgumentError, 'Button number cannot be negative!' unless button >= 0
            @direction = direction
            @button = button
          end

          def assert_direction(direction)
            raise TypeError, "#{direction.inspect} is not a valid pointer type" unless DIRECTIONS.include? direction
            direction
          end

          def encode
            {type: @direction, button: @button}
          end
        end # Press

        class Move < Interaction
          DOWN = :pointerDown
          UP = :pointerUp
          DIRECTIONS = [DOWN, UP].freeze

          def initialize(source, duration, x, y, element = nil)
            super(source)
            raise ArgumentError, 'duration value cannot be negative!' unless duration >= 0
            raise ArgumentError, 'X value cannot be negative!' unless x >= 0
            raise ArgumentError, 'Y value cannot be negative!' unless y >= 0
            @duration = duration
            @x_value = x
            @y_value = y
            @element = element
          end

          def assert_direction(direction)
            raise TypeError, "#{direction.inspect} is not a valid pointer type" unless DIRECTIONS.include? direction
            direction
          end

          def encode
            output = {type: :pointerMove, duration: @duration, x: @x_value, y: @y_value}
            output[:element] = @element if @element
            output
          end
        end # Move
      end # PointerInput
    end
  end
end
