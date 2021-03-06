require 'spec_helper'

describe 'bareos::job_definition' do

  default_params = {
    :client_name => 'client.example.com',
    :name_suffix => '-fd',
    :jobdef => 'DefaultJob',
    :fileset => '',
    :sched => 'StdSched',
    :accurate => '',
    :order => 'N50',
    :runscript => [],
  }

  prefix = '/etc/bareos/jobs.d/'
  let(:pre_condition) { <<-eot
      class bareos::server {
        $job_file_prefix = '#{prefix}'
      }
      include bareos::server
      eot
  }

  context "normal job" do
    let(:title) { "client.example.com-job" }
    let(:params) { default_params }

    it { should compile.with_all_deps }

    it do
      should contain_file("#{prefix}N50_#{title}.conf")
              .with_content(/Name\s+=\s+"#{title}"/)
              .with_content(/JobDefs\s+=\s+"DefaultJob"/)
              .with_content(/Schedule\s+=\s+"StdSched"/)
              .without_content(/Fileset/)
              .without_content(/RunScript/)
              .without_content(/Accurate/)
              .without_content(/Base/)
    end
  end

  context "service job" do
    let(:title) { "client.example.com/service.example.com-job" }
    let(:params) { default_params.merge({ :fileset => 'service-fset'}) }
    it { should compile.with_all_deps }

    it do
      should contain_file("#{prefix}N50_service.example.com-job.conf")
              .with_content(/Name\s+=\s+"service.example.com-job"/)
              .with_content(/Client\s+=\s+"client.example.com-fd"/)
              .with_content(/Fileset\s+=\s+"service-fset"/)
              .without_content(/RunScript/)
    end
  end

  context "enable accurate" do
    let(:title) { "client.example.com-accurate-job" }
    let(:params) { default_params.merge({ :accurate => true }) }
    it { should compile.with_all_deps }

    it do
      should contain_file("#{prefix}N50_client.example.com-accurate-job.conf")
              .with_content(/Accurate = yes/)
    end
  end

  context "disable accurate" do
    let(:title) { "client.example.com-inaccurate-job" }
    let(:params) { default_params.merge({ :accurate => false }) }
    it { should compile.with_all_deps }

    it do
      should contain_file("#{prefix}N50_client.example.com-inaccurate-job.conf")
              .with_content(/Accurate = no/)
    end
  end

  context "pre script" do
    let(:title) { "client.example.com-pre-job" }
    let(:pre_condition) { <<-eot
      class bareos::server {
        $job_file_prefix = '#{prefix}'
      }
      include bareos::server
      eot
    }
    let(:params) do
      default_params.merge({ :runscript => [ 'command' => 'precommand' ],
                             :order => 'A12'
                           })
    end
    it { should compile.with_all_deps }

    it do
      should contain_file("#{prefix}A12_#{title}.conf")
              .with_content(/Name\s+=\s+"#{title}"/)
              .with_content(/RunScript/)
              .with_content(/Command = "precommand"/)
              .with_content(/Runswhen = before/)
    end
  end

  context "post script" do
    let(:title) { "client.example.com-pre-job" }
    let(:pre_condition) { <<-eot
      class bareos::server {
        $job_file_prefix = '#{prefix}'
      }
      include bareos::server
      eot
    }
    let(:params) {
      default_params.merge(
        {
          :runscript => [
            {
              'command' => ['post1', 'post2'],
              'runswhen' => 'after',
              'abortjobonerror' => true,
            }, {
              'command' => ['post3'],
            }
          ],
        })
    }
    it { should compile.with_all_deps }

    it do
      should contain_file("#{prefix}N50_#{title}.conf")
              .with_content(/Name\s+=\s+"#{title}"/)
              .with_content(/RunScript/)
              .with_content(/Command = "post1"/)
              .with_content(/Command = "post2"/)
              .with_content(/Command = "post3"/)
              .with_content(/Runswhen = after/)
              .with_content(/Abortjobonerror = true/)
    end
  end

  context "base job" do
    let(:title) { "client.example.com-job" }
    let(:params) { default_params.merge({ :base => 'a-base' }) }

    it { should compile.with_all_deps }

    it do
      should contain_file("#{prefix}N50_#{title}.conf")
              .with_content(/Name\s+=\s+"#{title}"/)
              .with_content(/Base\s+=\s+"a-base"/)
              .with_content(/JobDefs\s+=\s+"DefaultJob"/)
              .with_content(/Schedule\s+=\s+"StdSched"/)
              .without_content(/Fileset/)
              .without_content(/RunScript/)
              .without_content(/Accurate/)
    end
  end

end
