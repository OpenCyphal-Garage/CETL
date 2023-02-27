#
# This treats the doxygen build for CETL as a standalone program. In
# reality the docs target is a doxygen build configured just for this project.
#


find_package(Doxygen QUIET)
find_program(TAR tar)

# +---------------------------------------------------------------------------+
# | DOXYGEN
# +---------------------------------------------------------------------------+

#
# :function: create_docs_target
# Create a target that generates documentation.
#
# :param str ARG_DOCS_TARGET_NAME:  The name to give the target created by this function.
#                                   This is also used as a prefix for sub-targets also
#                                   generated by this function.
# :param bool ARG_ADD_TO_ALL:       If true the target is added to the default build target.
#
function (create_docs_target ARG_DOCS_TARGET_NAME ARG_ADD_TO_ALL)

    set(DOXYGEN_SOURCE ${CETLVAST_PROJECT_ROOT}/doc_source)
    set(DOXYGEN_RDOMAIN org.opencyphal)
    set(DOXYGEN_RDOMAIN_W_PROJECT org.opencyphal.cetl)
    set(DOXYGEN_PROJECT_NAME "CETL")
    set(DOXYGEN_PROJECT_BRIEF "Cyphal Embedded Template Library is a C++ shim library used by C++ Cyphal projects.")
    set(DOXYGEN_OUTPUT_DIRECTORY_PARENT ${CMAKE_BINARY_DIR})
    set(DOXYGEN_OUTPUT_DIRECTORY ${DOXYGEN_OUTPUT_DIRECTORY_PARENT}/docs)
    set(DOXYGEN_CONFIG_FILE ${DOXYGEN_OUTPUT_DIRECTORY}/doxygen.config)

    file(GLOB_RECURSE DOXYGEN_INPUT_LIST
        LIST_DIRECTORIES false
        RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
        CONFIGURE_DEPENDS
        ${CETLVAST_PROJECT_ROOT}/include/*.h
    )

    list(APPEND DOXYGEN_INPUT_LIST "${CETLVAST_PROJECT_ROOT}/README.md")
    list(APPEND DOXYGEN_INPUT_LIST "${CETLVAST_PROJECT_ROOT}/SECURITY.md")
    list(JOIN DOXYGEN_INPUT_LIST "\\\n    " DOXYGEN_INPUT )
    set(DOXYGEN_MAINPAGE "\"${CETLVAST_PROJECT_ROOT}/README.md\"")
    set(DOXYGEN_CETLVAST_VERSION $ENV{GITHUB_SHA})
    set(DOXYGEN_CETLVAST_INCLUDE_PREFIX_STRIP "\"${CETLVAST_PROJECT_ROOT}/include\"")

    # +-----------------------------------------------------------------------+
    # | HTML (BOOTSTRAPPED)
    # +-----------------------------------------------------------------------+
    set(DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_SOURCE}/doxygen-bootstrapped/doxy-boot.js ${DOXYGEN_SOURCE}/doxygen-bootstrapped/jquery.smartmenus.js ${DOXYGEN_SOURCE}/doxygen-bootstrapped/addons/bootstrap/jquery.smartmenus.bootstrap.js ${DOXYGEN_SOURCE}/doxygen-bootstrapped/addons/bootstrap/jquery.smartmenus.bootstrap.css ${DOXYGEN_SOURCE}/.nojekyll")
    set(DOXYGEN_HTML_STYLESHEET ${DOXYGEN_OUTPUT_DIRECTORY}/customdoxygen.css)
    set(DOXYGEN_HTML_HEADER ${DOXYGEN_OUTPUT_DIRECTORY}/header.html)
    set(DOXYGEN_HTML_FOOTER ${DOXYGEN_OUTPUT_DIRECTORY}/footer.html)
    set(DOXYGEN_IMAGE_PATH ${DOXYGEN_OUTPUT_DIRECTORY}/doc_source/images)
    set(DOXYGEN_LOGO ${DOXYGEN_OUTPUT_DIRECTORY}/doc_source/images/html/opencyphal_logo.svg)
    set(DOXYGEN_TAGFILES "${DOXYGEN_OUTPUT_DIRECTORY}/cppreference-doxygen-web.tag.xml=http://en.cppreference.com/w/")

    file(COPY ${DOXYGEN_SOURCE}/cppreference-doxygen-web.tag.xml DESTINATION ${DOXYGEN_OUTPUT_DIRECTORY})
    file(COPY ${DOXYGEN_SOURCE}/images DESTINATION ${DOXYGEN_OUTPUT_DIRECTORY}/doc_source)

    configure_file(${DOXYGEN_SOURCE}/header.html
                    ${DOXYGEN_OUTPUT_DIRECTORY}/header.html
                )
    configure_file(${DOXYGEN_SOURCE}/footer.html
                    ${DOXYGEN_OUTPUT_DIRECTORY}/footer.html
                )
    configure_file(${DOXYGEN_SOURCE}/doxygen-bootstrapped/customdoxygen.css
                    ${DOXYGEN_OUTPUT_DIRECTORY}/customdoxygen.css
                )
    configure_file(${DOXYGEN_SOURCE}/doxygen.ini
                    ${DOXYGEN_CONFIG_FILE}
                )

    add_custom_command(OUTPUT ${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html
                                ${DOXYGEN_OUTPUT_DIRECTORY}/latex/refman.tex
                        COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_CONFIG_FILE}
                        DEPENDS ${DOXYGEN_CONFIG_FILE} ${DOXYGEN_INPUT_LIST}
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                        COMMENT "Generating intermediate documentation."
                    )

    add_custom_target(${ARG_DOCS_TARGET_NAME}-html DEPENDS ${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html)

    add_custom_command(OUTPUT ${DOXYGEN_OUTPUT_DIRECTORY}/html.gz
                        COMMAND ${TAR} -vzcf docs/html.gz docs/html/
                        DEPENDS ${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html
                        WORKING_DIRECTORY ${DOXYGEN_OUTPUT_DIRECTORY_PARENT}
                        COMMENT "Creating html tarball."
                    )

    if (ARG_ADD_TO_ALL)
        add_custom_target(${ARG_DOCS_TARGET_NAME} ALL DEPENDS ${DOXYGEN_OUTPUT_DIRECTORY}/html.gz)
    else()
        add_custom_target(${ARG_DOCS_TARGET_NAME} DEPENDS ${DOXYGEN_OUTPUT_DIRECTORY}/html.gz)
    endif()

endfunction(create_docs_target)


include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(docs
    REQUIRED_VARS DOXYGEN_FOUND
)