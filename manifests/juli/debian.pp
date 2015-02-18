class tomcat::juli::debian {

  $url =[
    $tomcat::sources_src,
    "tomcat-${tomcat::version}",
    "v${tomcat::src_version}",
    'bin',
  ]

  $baseurl = inline_template('<%=@url.join("/")%>')

  $require = $::tomcat::sources ? {
    true => undef,
    false  => Package['tomcat'],
  }

  file { "${tomcat::home}/extras/":
    ensure  => directory,
    require => $require,
  }

  archive::download { 'tomcat-juli.jar':
    url         => "${baseurl}/extras/tomcat-juli.jar",
    digest_url  => "${baseurl}/extras/tomcat-juli.jar.md5",
    digest_type => 'md5',
    src_target  => "${tomcat::home}/extras/",
    require     => File["${tomcat::home}/extras/"],
  }

  archive::download { 'tomcat-juli-adapters.jar':
    url         => "${baseurl}/extras/tomcat-juli-adapters.jar",
    digest_url  => "${baseurl}/extras/tomcat-juli-adapters.jar.md5",
    digest_type => 'md5',
    src_target  => "${tomcat::home}/extras/",
    require     => File["${tomcat::home}/extras/"],
  }

  file { "${tomcat::home}/bin/tomcat-juli.jar":
    ensure  => link,
    target  => "${tomcat::home}/extras/tomcat-juli.jar",
    require => Archive::Download['tomcat-juli.jar'],
  }

  file { "${tomcat::home}/lib/tomcat-juli-adapters.jar":
    ensure  => link,
    target  => "${tomcat::home}/extras/tomcat-juli-adapters.jar",
    require => Archive::Download['tomcat-juli-adapters.jar'],
  }

}
