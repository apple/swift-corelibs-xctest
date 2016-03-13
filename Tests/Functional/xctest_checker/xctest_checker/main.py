#!/usr/bin/env python
# xctest_checker/main.py - Entry point for xctest_checker -*- python -*-
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See http://swift.org/LICENSE.txt for license information
# See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

from __future__ import absolute_import

import argparse

from . import compare


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('actual', help='A path to a file containing the '
                                       'actual output of an XCTest run.')
    parser.add_argument('expected', help='A path to a file containing the '
                                         'expected output of an XCTest run.')
    parser.add_argument('-p', '--check-prefix',
                        default='// CHECK: ',
                        help='%(prog)s checks actual output against expected '
                             'output. By default, %(prog)s only checks lines '
                             'that are prefixed with "%(default)s". This '
                             'option can be used to change that '
                             'prefix.')
    args = parser.parse_args()
    compare.compare(args.actual, args.expected, args.check_prefix)


if __name__ == '__main__':
    main()
