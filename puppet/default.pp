# default.pp
node default {
  Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin"}

  # ensures proper ordering of provisioning
  stage { first: before => Stage[main] }
  stage { last: require => Stage[main] }
  class{'site::update_apt': stage => first }
  class{'site::configuration': stage => last }

  include nginx
  include core::basic_dev
  include core::multi_agent
  #include core::mysql5
  #include core::xwindows
  #include site::vcs_work
}
