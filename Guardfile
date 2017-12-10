guard(
  :minitest,
  all_on_start: false,
  all_after_pass: false,
  cli: '',
  test_folders: %w(lib),
  include: %w(),
  test_file_patterns: %w[*.rb],
  spring: false,
  zeus: false,
  drb: false,
  bundler: true,
  rubygems: false,
  env: {},
  all_env: {},
  autorun: true,
) do
  watch(%r{^lib/(.*)\.rb$})
end
