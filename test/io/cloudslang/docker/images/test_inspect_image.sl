# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
# The Apache License is available at
# http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#!!
#! @description: Workflow to test docker get_all_images operation.
#! @input host: Docker machine host
#! @input port: Docker machine port
#! @input username: Docker machine username
#! @input password: Docker machine password
#! @input image_name: Docker image name to inspect
#! @result SUCCESS: get_all_images performed successfully
#! @result FAILURE: get_all_images finished with an error
#! @result DOWNLOAD_FAILURE: prerequest error - could not download dockerimage
#! @result VERIFY_FAILURE: fails ro verify downloaded images
#! @result DELETE_FAILURE: fails to delete downloaded image
#! @result MACHINE_IS_NOT_CLEAN: prerequest fails - machine is not clean
#!!#
####################################################
namespace: io.cloudslang.docker.images

imports:
  strings: io.cloudslang.base.strings
  linux: io.cloudslang.base.os.linux
  maintenance: io.cloudslang.docker.maintenance


flow:
  name: test_inspect_image
  inputs:
    - host
    - port:
        required: false
    - username
    - password
    - image_name
  workflow:
    - clear_docker_host_prereqeust:
         do:
           maintenance.clear_host:
             - docker_host: ${ host }
             - port
             - docker_username: ${ username }
             - docker_password: ${ password }
         navigate:
           - SUCCESS: pull_image
           - FAILURE: MACHINE_IS_NOT_CLEAN

    - pull_image:
        do:
          pull_image:
            - host
            - port
            - username
            - password
            - image_name
        navigate:
          - SUCCESS: inspect_image
          - FAILURE: DOWNLOAD_FAILURE

    - inspect_image:
        do:
          inspect_image:
            - host
            - port
            - username
            - password
            - image_name
        publish:
            - standard_out
        navigate:
          - SUCCESS: verify_output
          - FAILURE: FAILURE

    - verify_output:
        do:
          strings.string_occurrence_counter:
            - string_in_which_to_search: ${ standard_out }
            - string_to_find: "/hello"
        navigate:
          - SUCCESS: clear_after
          - FAILURE: VERIFY_FAILURE

    - clear_after:
        do:
          clear_images:
            - host
            - port
            - username
            - password
            - images: ${ image_name }
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: DELETE_FAILURE

  results:
    - SUCCESS
    - FAILURE
    - DOWNLOAD_FAILURE
    - VERIFY_FAILURE
    - DELETE_FAILURE
    - MACHINE_IS_NOT_CLEAN
