class tomcat::juli::debian (
  $tomcat_home        = $tomcat::params::home,
  $tomcat_src_version = $tomcat::params::src_version
) inherits ::tomcat::params {

  $url =[
    $tomcat::params::sources_src,
    "tomcat-${tomcat::version}",
    "v${tomcat_src_version}",
    'bin'
  ]

  $baseurl = inline_template('<%=@url.join("/")%>')

  file { "${tomcat_home}/extras/":
    ensure  => directory,
  }

  archive::download { 'tomcat-juli.jar':
    url         => "${baseurl}/extras/tomcat-juli.jar",
    digest_url  => "${baseurl}/extras/tomcat-juli.jar.md5",
    digest_type => 'md5',
    src_target  => "${tomcat_home}/extras/",
    require     => File["${tomcat_home}/extras/"],
  }

  archive::download { 'tomcat-juli-adapters.jar':
    url         => "${baseurl}/extras/tomcat-juli-adapters.jar",
    digest_url  => "${baseurl}/extras/tomcat-juli-adapters.jar.md5",
    digest_type => 'md5',
    src_target  => "${tomcat_home}/extras/",
    require     => File["${tomcat_home}/extras/"],
  }

  file { "${tomcat_home}/bin/tomcat-juli.jar":
    ensure  => link,
    target  => "${tomcat_home}/extras/tomcat-juli.jar",
    require => Archive::Download['tomcat-juli.jar'],
  }

  file { "${tomcat_home}/lib/tomcat-juli-adapters.jar":
    ensure  => link,
    target  => "${tomcat_home}/extras/tomcat-juli-adapters.jar",
    require => Archive::Download['tomcat-juli-adapters.jar'],
  }

}
