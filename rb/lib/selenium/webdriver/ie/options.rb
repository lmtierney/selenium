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
    module IE
      class Options
        attr_reader :opts

        KEY = 'se:ieOptions'.freeze
        SCROLL_TOP = 0
        SCROLL_BOTTOM = 1
        CAPABILITIES = {
          ignore_protected_mode_settings: 'ignoreProtectedModeSettings',
          ignore_zoom_level: 'ignoreZoomSetting',
          enable_native_events: 'nativeEvents',
          require_window_focus: 'requireWindowFocus',
          initial_browser_url: 'initialBrowserUrl',
          element_scroll_behavior: 'elementScrollBehavior',
          enable_persistent_hover: 'enablePersistentHover',
          browser_attach_timeout: 'browserAttachTimeout',
          file_upload_dialog_timeout: 'ie.fileUploadDialogTimeout',
          force_create_process_api: 'ie.forceCreateProcessApi',
          force_shell_windows_api: 'ie.forceShellWindowsApi',
          validate_cookie_document_type: 'ie.validateCookieDocumentType',
          browser_command_line_arguments: 'ie.browserCommandLineSwitches',
          use_per_process_proxy: 'ie.usePerProcessProxy',
          ensure_clean_session: 'ie.ensureCleanSession',
          enable_full_page_screenshot: 'ie.enableFullPageScreenshot'
        }.freeze

        CAPABILITIES.keys.each do |key|
          define_method key do
            @opts.fetch(key)
          end

          define_method "#{key}=" do |value|
            @opts[key] = value
          end
        end

        #
        # Create a new Options instance
        #
        # @example
        #   options = Selenium::WebDriver::IE::Options.new(args: ['--host=127.0.0.1'])
        #   driver = Selenium::WebDriver.for :ie, options: options
        #
        # @param [Hash] opts the pre-defined options to create the IE::Options with
        # @option opts [Array<String>] :args List of command-line arguments to use when starting geckodriver
        # @option opts [Profile, String] :profile Encoded profile string or Profile instance
        # @option opts [String, Symbol] :log_level Log level for geckodriver
        # @option opts [Hash] :prefs A hash with each entry consisting of the key of the preference and its value
        # @option opts [Hash] :options A hash for raw options
        #

        def initialize(opts = {})
          @opts = opts
        end

        #
        # Add a new option not yet handled by these bindings.
        #
        # @example
        #   options = Selenium::WebDriver::IE::Options.new
        #   options.add_option(:foo, 'bar')
        #
        # @param [String, Symbol] name Name of the option
        # @param [Boolean, String, Integer] value Value of the option
        #

        def add_additional_option(name, value)
          @opts[name] = value
        end

        #
        # @api private
        #

        def as_json(*)
          opts = {}

          CAPABILITIES.each do |cap, key|
            val = @opts.delete(cap)
            opts[key] = val if val
          end
          opts.merge!(@opts)

          {KEY => opts}
        end
      end # Profile
    end # IE
  end # WebDriver
end # Selenium
