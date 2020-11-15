<%--
  ~ Copyright (c) 2019 Marat Abrarov (abrarov@gmail.com)
  ~
  ~ Licensed under the Apache License, Version 2.0 (the "License");
  ~ you may not use this file except in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~     http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing, software
  ~ distributed under the License is distributed on an "AS IS" BASIS,
  ~ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~ See the License for the specific language governing permissions and
  ~ limitations under the License.
  --%><%@
page import="org.apache.commons.text.StringEscapeUtils" %><%@
page import="java.io.FileInputStream" %><%@
page import="java.io.InputStream" %><%@
page import="java.util.Properties" %><%@
page contentType="text/html;charset=UTF-8" %><html>
<head>
    <title>Docker Maven plugin test</title>
</head>
<body><%
    final Properties configurationProperties = new Properties();
    final String applicationConfigurationFile = System.getProperty("org.mabrarov.dockerfile-test.application.configuration.file");
    try (final InputStream configurationInput = new FileInputStream(applicationConfigurationFile)) {
        configurationProperties.load(configurationInput);
    }
%>
<%=StringEscapeUtils.escapeHtml4(configurationProperties.getProperty("greeting"))%>
</body>
</html>
