define tomcat::env(
  $instance,
  $key,
  $value,
) {
  concat_fragment { "setenv.sh_${instance}+02_${name}":
    content => "export ${key}=\"${value}\"",
  }
}
