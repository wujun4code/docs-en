def exec(cmd)
  puts cmd
  system cmd
end

task :check_ruby_version do |t|
  raise "Ruby < 1.9" if RUBY_VERSION.include? "1.8"
end

task :render => [:check_ruby_version] do |t|
  exec 'ruby render.rb'
end

task :deploy, [:type] => [] do |t, args|
  case args[:type]
  when "us-w1"
    exec "fab -H ubuntu@us-w1-backend4.leancloud.cn,ubuntu@us-w1-app1.leancloud.cn,ubuntu@us-w1-app2.leancloud.cn deploy_docs:target=us"
  when "cn-n1"
    exec "fab -H ubuntu@web1.avoscloud.com,ubuntu@web2.avoscloud.com,ubuntu@web3.avoscloud.com,ubuntu@web4.avoscloud.com,ubuntu@web5.avoscloud.com,ubuntu@web6.avoscloud.com,ubuntu@web7.avoscloud.com,ubuntu@web8.avoscloud.com deploy_docs:target=cn-n1"
  when "cn-e1"
    exec "fab -H ubuntu@cn-e1-web1,ubuntu@cn-e1-web2,ubuntu@cn-e1-web3 deploy_docs:target=qcloud"
  when "beta"
    exec "fab -H ubuntu@tsdb2.avoscloud.com deploy_docs:target=beta"
  when "cn_stg"
    exec "fab -H ubuntu@cn-stg1.avoscloud.com deploy_docs:target=cn_stg"
  end
end

task :install do |t|
  # exec "gem list | grep -E 'hpricot.*0\.8\.6' > /dev/null || sudo gem install hpricot"
  # exec "npm list -g | grep -E 'doctoc@0\.4\.4' > /dev/null || sudo npm install -g doctoc@0.4.4"
end
