# AHTSE
# (Apache HTTPD Tile Server Ecosystem)

AHTSE is a collection of Apache httpd modules that can be used independently or combined to implement high performance and scalable tile services.  While developed for geospatial applications, can be used for any other domain that need fast pan and zoom access to large datasets.  
The AHTSE common feature that provides interoperability is the tile request.  The tile request supported by ATHSE is a REST request which ends with four integer parameters **"/M/Level/Row/Column"**.  The _Level - Row - Column_ parameters are the usual tile and pyramid addressing values, while _M_ is a multi-purpose parameter, exposing one or more extra dimensions of the served dataset. The _M_ parameter is the only optional one, it defaults to zero if the parameter before _Level_ is not a number.

**AHTSE Components**

* *Source*
  * [mrf](https://github.com/lucianpls/mod_mrf)
    * Serves tiles from an MRF file
  * [fractal](https://github.com/lucianpls/mod_fractal_tiles)
    * **INCOMPLETE**
    * Generates tiles of a fractal

* *Transformation*
  * [reproject](https://github.com/lucianpls/mod_reproject)
    * Projection changes, tile grid and scale changes and also format changes
  * [convert](https://github.com/lucianpls/mod_convert)
    * Format, data type conversions
  * [fill](https://github.com/lucianpls/mod_ahtse_fill)
    * **INCOMPLETE**
    * Fill in missing tiles by oversampling lower resolution levels

* *Protocol conversion*
  * [twms](https://github.com/lucianpls/mod_twms)
    * Converts requests from tWMS protocol to AHTSE standard

* *Utilities*
  * [receive](https://github.com/lucianpls/mod_receive)
    * Subrequest filter that enables passing data between AHTSE components
  * [send file](https://github.com/lucianpls/mod_sfim)
    * Used for protocol files, it sends a static file as the response for requests matching one or more URL patterns
  * [lua](https://github.com/lucianpls/mod_ahtse_lua)
    * Allows AHTSE modules to be extended with Lua scripts
