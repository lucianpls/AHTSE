# AHTSE
# (Apache HTTPD Tile Server Ecosystem)

AHTSE is a collection of Apache httpd modules that can be used independently or combined to implement high performance and scalable tile services.  While developed mostly for geospatial applications, can be used for any other domain that need fast pan and zoom access to large datasets.  The tile request supported by ATHSE is a REST request which ends with four integer parameters **"/M/Level/Row/Column"**. The _Level - Row - Column_ are the normal tile and pyramid addressing values, while _M_ is a multi-purpose parameter, exposing one or more dimensions of the served dataset. The _M_ parameter is optional, it defaults to zero if the parameter before _Level_ is not a number.

**AHTSE Components**

* *Data Sources*
  * [mrf](https://github.com/lucianpls/mod_mrf)
  * [fractal](https://github.com/lucianpls/mod_fractal_tiles)

* *Processing*
  * [reproject](https://github.com/lucianpls/mod_reproject)
  * [convert](https://github.com/lucianpls/mod_convert)
  * [fill](https://github.com/lucianpls/mod_ahtse_fill)

* *Protocol conversion*
  * [twms](https://github.com/lucianpls/mod_twms)

* *Utilities*
  * [receive](https://github.com/lucianpls/mod_receive)
  * [send file](https://github.com/lucianpls/mod_sfim)
  * [lua](https://github.com/lucianpls/mod_ahtse_lua)
