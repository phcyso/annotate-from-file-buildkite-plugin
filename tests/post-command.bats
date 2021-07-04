#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following line to debug stub failures
export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Creates an annotation from a given file" {
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="test_file.test"

  echo "hello world" >> test_file.test

  stub buildkite-agent 'annotate "--style \"info\"" : echo Annotation created'

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Annotation created"

  unstub buildkite-agent
  rm test_file.test
}

@test "Exits cleanly when file doesnt exist " {
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="NOFILE"

   run "$PWD/hooks/post-command"

   assert_success
   assert_output --partial "Annotation file does not exist, Exiting"

}

@test "Exits with 1 when file doesnt exist and must_exist is true " {
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_PATH="*.bats"
  export BUILDKITE_PLUGIN_ANNOTATE_FROM_FILE_MUST_EXIST="true"

  run "$PWD/hooks/post-command"

  assert_failure
  assert_output --partial "Annotation file does not exist, Exiting"

}
