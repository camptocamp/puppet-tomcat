define tomcat::instance::config::systemd_env (
  $instance,
  $target,
) {

  $split_env = split($title, '=')
  $env_name = $split_env[0]

  if $split_env[1][0] == '"' and $split_env[1][-1] == '"' {
    $env_val = $split_env[1][1,-2]
  } else {
    $env_val = $split_env[1]
  }

  shellvar {"${env_name}_$instance":
    ensure    => present,
    target    => $target,
    variable  => $env_name,
    value     => $env_val,
    uncomment => true,
  }

}
