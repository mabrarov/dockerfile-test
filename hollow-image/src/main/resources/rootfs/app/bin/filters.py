# -*- coding: utf-8 -*-

#
# Copyright (c) 2019 Marat Abrarov (abrarov@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


def escape_property_value(text):
    if text is None:
        return text
    return str(text) \
        .replace('\\', '\\\\') \
        .replace(':', '\\:') \
        .replace('\r', '\\r') \
        .replace('\n', '\\n')


def escape_jboss_attribute_expression(text):
    """
    Escapes text to make it safe for usage as value of JBoss configuration attribute which supports
    expression (https://docs.jboss.org/author/display/WFLY10/Expressions)
    """

    if text is None:
        return text
    s = str(text)
    # https://github.com/wildfly/wildfly-core/blob/7.0.0.Final/controller/src/main/java/org/jboss/as/controller/parsing/ParseUtils.java#L615
    open_idx = s.find('${')
    if -1 < open_idx < s.rfind('}'):
        # https://github.com/jbossas/jboss-dmr/blob/1.2.2.Final/src/main/java/org/jboss/dmr/ValueExpressionResolver.java#L78
        return s.replace('$', '$$')
    return s
