<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.util.Properties" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Dockerfile Maven plugin test</title>
</head>
<body>
<%
    final Properties configurationProperties = new Properties();
    final String applicationConfigurationFile = System.getProperty("org.mabrarov.dockerfile-test.application.configuration.file");
    try (final InputStream configurationInput = new FileInputStream(applicationConfigurationFile)) {
        configurationProperties.load(configurationInput);
    }
%>
<%=StringEscapeUtils.escapeHtml4(configurationProperties.getProperty("greeting"))%>
</body>
</html>
