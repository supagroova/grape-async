# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec, cmd: 'bundle exec rspec', after_all_pass: false, failed_mode: :focus do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/support/.+$})  { "spec" }
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
