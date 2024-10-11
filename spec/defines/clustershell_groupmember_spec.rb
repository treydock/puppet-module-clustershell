# frozen_string_literal: true

require 'spec_helper'

describe 'clustershell::groupmember' do
  on_supported_os.each do |os, facts|
    context "when #{os}" do
      let(:facts) do
        facts
      end

      let(:title) { 'foo' }

      let(:params) { { group: 'bar' } }

      it { is_expected.to create_clustershell__groupmember('foo') }

      it do
        is_expected.to contain_concat__fragment('clustershell-groups.member foo').with(target: '/etc/clustershell/groups.d/local.cfg',
                                                                                       content: "bar: foo\n",
                                                                                       order: '50',)
      end
    end
  end
end
