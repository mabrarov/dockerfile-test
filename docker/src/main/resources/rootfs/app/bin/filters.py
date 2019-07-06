#!/usr/bin/env python

# -*- coding: utf-8 -*-


def escape_property_value(text):
    if text is None:
        return text
    return str(text) \
        .replace('\\', '\\\\') \
        .replace(':', '\\:') \
        .replace('\r', '\\r') \
        .replace('\n', '\\n')
