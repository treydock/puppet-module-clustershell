# frozen_string_literal: true

def verify_exact_contents(subject, title, expected_lines)
  content = subject.resource('file', title).send(:parameters)[:content]
  is = content.split("\n").reject { |line| line =~ %r{(^$|^#)} }
  expect(is).to eq expected_lines
end
