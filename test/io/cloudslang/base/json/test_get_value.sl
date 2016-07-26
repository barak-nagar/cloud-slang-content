#   (c) Copyright 2015 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
namespace: io.cloudslang.base.json

imports:
  comp: io.cloudslang.base.comparisons

flow:
  name: test_get_value

  inputs:
    - json_before
    - json_path
    - found_value

  workflow:
    - get_value:
        do:
          get_value:
            - json_input: ${ json_before }
            - json_path
        publish:
          - value
        navigate:
          - SUCCESS: test_equality
          - FAILURE: CREATEFAILURE
    - test_equality:
        do:
          comp.equals:
            - first: ${ value }
            - second: ${ found_value }

        navigate:
          - EQUALS: SUCCESS
          - NOT_EQUALS: EQUALITY_FAILURE

  results:
    - SUCCESS
    - EQUALITY_FAILURE
    - CREATEFAILURE
