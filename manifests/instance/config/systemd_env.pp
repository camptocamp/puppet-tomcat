define tomcat::instance::config::systemd_env (
  $instance,
  $target,
) {

  $split_env = split($title, '=')
  $env_name = $split_env[0]

  $env_val = inline_template('<%= @split_env[1][0] == \'"\' and @split_env[1][-1] == \'"\' ? @split_env[1].slice(1..-2) : @split_env[1] %>')

  shellvar {"${env_name}_${instance}":
    ensure    => present,
    target    => $target,
    variable  => $env_name,
    value     => $env_val,
    uncomment => true,
  }

}
