require 'spec_helper'

describe 'stepped into mysql_test_default::server on debian-jessie' do
  let(:debian_jessie_sid_default_run) do
    ChefSpec::Runner.new(
      :step_into => 'mysql_service',
      :platform => 'debian',
      :version => 'jessie/sid'
      ) do |node|
      node.set['mysql']['service_name'] = 'debian_jessie_sid_default'
    end.converge('mysql_test_default::server')
  end

  let(:my_cnf_5_5_content_debian_jessie_sid) do
    '[client]
port                           = 3306
socket                         = /var/run/mysqld/mysqld.sock

[mysqld_safe]
socket                         = /var/run/mysqld/mysqld.sock

[mysqld]
user                           = mysql
pid-file                       = /var/run/mysqld/mysql.pid
socket                         = /var/run/mysqld/mysqld.sock
port                           = 3306
datadir                        = /var/lib/mysql

[mysql]
!includedir /etc/mysql/conf.d
'
  end

  before do
    stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
  end

  context 'when using default parameters' do
    it 'creates mysql_service[debian_jessie_sid_default]' do
      expect(debian_jessie_sid_default_run).to create_mysql_service('debian_jessie_sid_default').with(
        :version => '5.5',
        :port => '3306',
        :data_dir => '/var/lib/mysql'
        )
    end

    it 'steps into mysql_service and installs package[debconf-utils]' do
      expect(debian_jessie_sid_default_run).to install_package('debconf-utils')
    end

    it 'steps into mysql_service and creates directory[/var/cache/local/preseeding]' do
      expect(debian_jessie_sid_default_run).to create_directory('/var/cache/local/preseeding').with(
        :owner => 'root',
        :group => 'root',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates template[/var/cache/local/preseeding/mysql-server.seed]' do
      expect(debian_jessie_sid_default_run).to create_template('/var/cache/local/preseeding/mysql-server.seed').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and creates execute[preseed mysql-server]' do
      expect(debian_jessie_sid_default_run).to_not run_execute('preseed mysql-server').with(
        :command => '/usr/bin/debconf-set-selections /var/cache/local/preseeding/mysql-server.seed'
        )
    end

    it 'steps into mysql_service and installs package[mysql-server]' do
      expect(debian_jessie_sid_default_run).to install_package('mysql-server')
    end

    it 'steps into mysql_service and creates service[mysql]' do
      expect(debian_jessie_sid_default_run).to start_service('mysql')
      expect(debian_jessie_sid_default_run).to enable_service('mysql')
    end

    it 'steps into mysql_service and creates directory[/etc/mysql/conf.d]' do
      expect(debian_jessie_sid_default_run).to create_directory('/etc/mysql/conf.d').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates directory[/var/run/mysqld]' do
      expect(debian_jessie_sid_default_run).to create_directory('/var/run/mysqld').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'steps into mysql_service and creates directory[/var/lib/mysql]' do
      expect(debian_jessie_sid_default_run).to create_directory('/var/lib/mysql').with(
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    # mysql data
    it 'steps into mysql_service and creates execute[assign-root-password]' do
      expect(debian_jessie_sid_default_run).to run_execute('assign-root-password').with(
        :command => '/usr/bin/mysqladmin -u root password ilikerandompasswords'
        )
    end

    it 'steps into mysql_service and creates template[/etc/mysql_grants.sql]' do
      expect(debian_jessie_sid_default_run).to create_template('/etc/mysql_grants.sql').with(
        :cookbook => 'mysql',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and creates execute[install-grants]' do
      expect(debian_jessie_sid_default_run).to_not run_execute('install-grants').with(
        :command => '/usr/bin/mysql -u root -pilikerandompasswords < /etc/mysql_grants.sql'
        )
    end

    it 'steps into mysql_service and creates template[/etc/mysql/debian.cnf]' do
      expect(debian_jessie_sid_default_run).to create_template('/etc/mysql/debian.cnf').with(
        :cookbook => 'mysql',
        :source => 'debian/debian.cnf.erb',
        :owner => 'root',
        :group => 'root',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and creates template[/etc/mysql/my.cnf]' do
      expect(debian_jessie_sid_default_run).to create_template('/etc/mysql/my.cnf').with(
        :cookbook => 'mysql',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0600'
        )
    end

    it 'steps into mysql_service and renders file[/etc/mysql/my.cnf]' do
      expect(debian_jessie_sid_default_run).to render_file('/etc/mysql/my.cnf').with_content(my_cnf_5_5_content_debian_jessie_sid)
    end

    it 'steps into mysql_service and creates bash[move mysql data to datadir]' do
      expect(debian_jessie_sid_default_run).to_not run_bash('move mysql data to datadir')
    end
  end
end
