define tomcat::instance::config::systemd_env (
  $instance,
  $target,
) {

  $split_env = split($title, '=')
  $env_name = $split_env[0]

  $raw_env_val = inline_template('<%= (@split_env[1..-1]).join("=") %>')
  $env_val = inline_template('<%= (@raw_env_val[0] == \'"\' and @raw_env_val[-1] == \'"\') ? @raw_env_val.slice(1..-2) : @raw_env_val %>')

  shellvar {"${env_name}_${instance}":
    ensure    => present,
    target    => $target,
    variable  => $env_name,
    value     => $env_val,
    uncomment => true,
  }

}
