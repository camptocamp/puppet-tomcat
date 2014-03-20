define tomcat::connector::option(
  $connector,
  $key,
  $value,
) {
  concat_fragment { "connector_${connector}+10_${name}":
    content => "           ${key}=\"${value}\"",
  }
}
