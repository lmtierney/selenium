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


def test_send_command(driver, pages):
    pages.load('formPage.html')
    url = pages.url('readOnlyPage.html')
    driver.send_command('Page.navigate', url=url)
    assert 'readOnlyPage.html' in driver.current_url


def test_send_command_get_result(driver, pages):
    pages.load('formPage.html')
    result = driver.send_command_get_result('DOM.getDocument')
    assert result['root']['nodeName'] == '#document'
