#   (c) Copyright 2016 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
####################################################

namespace: io.cloudslang.cloud.amazon_aws.regions

imports:
  lists: io.cloudslang.base.lists
  strings: io.cloudslang.base.strings

flow:
  name: test_describe_regions

  inputs:
    - provider: 'amazon'
    - endpoint: 'https://ec2.amazonaws.com'
    - identity:
        required: false
    - credential:
        required: false
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - delimiter:
        required: false
    - debug_mode:
        default: 'false'
        required: false

  workflow:
    - describe_regions:
        do:
          describe_regions:
            - provider
            - endpoint
            - identity
            - credential
            - proxy_host
            - proxy_port
            - delimiter
            - debug_mode
        publish:
          - return_result
          - return_code
          - exception
        navigate:
          - SUCCESS: check_result
          - FAILURE: LIST_REGION_FAILURE

    - check_result:
        do:
          lists.compare_lists:
            - list_1: ${[str(exception), int(return_code)]}
            - list_2: ['', 0]
        navigate:
          - SUCCESS: check_default_region_exist
          - FAILURE: CHECK_RESULT_FAILURE

    - check_default_region_exist:
        do:
          strings.string_occurrence_counter:
            - string_in_which_to_search: ${return_result}
            - string_to_find: 'us-east-1'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: CHECK_DEFAULT_REGION_FAILURE

  results:
    - SUCCESS
    - LIST_REGION_FAILURE
    - CHECK_RESULT_FAILURE
    - CHECK_DEFAULT_REGION_FAILURE