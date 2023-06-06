#!/usr/bin/env bats


setup() {
  load "$BATS_PLUGIN_PATH/load.bash"

  # Uncomment the following line to debug stub failures
  # export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty
}

@test "Creates an annotation from a given file" {
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="test_file.test"

  echo "hello world" >> test_file.test

  stub buildkite-agent 'annotate --style "info" : echo Annotation created'

  run "$PWD/hooks/post-command"

  unstub buildkite-agent
  rm test_file.test

  assert_output --partial "Annotation created"
  assert_success
}

@test "Exits cleanly when file doesnt exist " {
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="NOFILE"

  run "$PWD/hooks/post-command"

  assert_output --partial "Annotation file does not exist, Exiting"
  assert_success
}

@test "Exits with 1 when file doesnt exist and must_exist is true " {
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="*999.bats"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_MUST_EXIST="true"

  run "$PWD/hooks/post-command"

  assert_output --partial "Annotation file does not exist, Exiting"
  assert_failure
}

@test "Valid case with append and context" {
  test_file="test_file_context.test"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="${test_file}"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE=success
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_MUST_EXIST=false
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_CONTEXT=test-context
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_APPEND=true

  echo "hello world" >> $test_file

  stub buildkite-agent 'annotate --style "$BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE" --context "$BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_CONTEXT" --append : echo Annotation created'

  run "$PWD/hooks/post-command"

  unstub buildkite-agent
  rm "$test_file"

  assert_output --partial "Annotation created"
  assert_success
}

@test "Invalid style case" {
  test_file="test_file_context.test"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="${test_file}"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE=invalid_style
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_MUST_EXIST=false
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_CONTEXT=test-context
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_APPEND=false

  echo "hello world" >> $test_file

  run "$PWD/hooks/post-command"
  rm "$test_file"

  assert_output --partial "is a non valid style"
  assert_failure
}

@test "Annotation Append without context " {
  test_file="test_file_append.test"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="${test_file}"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE=info
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_MUST_EXIST=false
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_CONTEXT=""
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_APPEND=true

  echo "hello world" >> $test_file
  stub buildkite-agent 'annotate --style "$BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE" --append : echo Annotation created'

  run "$PWD/hooks/post-command"

  unstub buildkite-agent
  rm "$test_file"

  assert_output --partial "Annotation created"
  assert_success
}

@test "Annotation Append with 'file_name' as context' " {
  test_file="test_file_context_file_name.test"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="${test_file}"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE=info
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_MUST_EXIST=false
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_CONTEXT="file_name"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_APPEND=true

  echo "hello world" >> $test_file
  echo "hello world" >> "diff_${test_file}_asdfa.txt"
  stub buildkite-agent 'annotate --style "$BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE" --context "$BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH" --append : echo Annotation created with context $BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH'

  run "$PWD/hooks/post-command"

  unstub buildkite-agent
  rm "$test_file"
  rm "diff_${test_file}_asdfa.txt"

  assert_output --partial "Annotation created with context $BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH"
  assert_success
}

@test "Multiple files: Annotation Append with 'file_name' as context' " {
  test_file="test_file_context_file_name.test"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="${test_file}"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE=info
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_MUST_EXIST=false
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_CONTEXT="file_name"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_APPEND=true

  echo "hello world" >> "${test_file}_1.txt"
  echo "hello world" >> "${test_file}_2.txt"
  echo "hello world" >> "${test_file}_3.txt"
  echo "hello world" >> "${test_file}_4.txt"
  echo "hello world" >> "Not_include_${test_file}_5.txt"

  stub buildkite-agent 'annotate --style "$BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE" --context "${BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH}_1.txt" --append : echo Annotation created'
  stub buildkite-agent 'annotate --style "$BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE" --context "${BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH}_2.txt" --append : echo Annotation created'
  stub buildkite-agent 'annotate --style "$BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE" --context "${BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH}_3.txt" --append : echo Annotation created'
  stub buildkite-agent 'annotate --style "$BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_STYLE" --context "${BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH}_4.txt" --append : echo Annotation created'

  run "$PWD/hooks/post-command"

  unstub buildkite-agent

  rm "${test_file}_1.txt"
  rm "${test_file}_2.txt"
  rm "${test_file}_3.txt"
  rm "${test_file}_4.txt"
  rm "Not_include_${test_file}_5.txt"

  assert_output --partial "1 Annotation created for"
  assert_output --partial "2 Annotation created for"
  assert_output --partial "3 Annotation created for"
  assert_output --partial "4 Annotation created for"
  refute_output "Not_include_"
  assert_output --partial "Annotation created - Done"
  assert_success
}
