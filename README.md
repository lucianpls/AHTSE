# AHTSE
# (Apache HTTPD Tile Server Ecosystem)

AHTSE is a collection of Apache httpd modules that can be used independently or combined to implement high performance and scalable tile services.  While developed for geospatial applications, can be used for any other domain that need fast pan and zoom access to large datasets.  
The AHTSE common feature that provides interoperability is the tile request.  The tile request supported by ATHSE is a REST request which ends with four integer parameters **"/M/Level/Row/Column"**.  The _Level - Row - Column_ parameters are the usual tile and pyramid addressing values, while _M_ is a multi-purpose parameter, exposing one or more extra dimensions of the served dataset. The _M_ parameter is the only optional one, it defaults to zero if the parameter before _Level_ is not a number.

**AHTSE Components**

* *Common*
  * [libahtse](https://github.com/lucianpls/libahtse)
    * common code, shared by other ahtse components
    * JPEG, JPEG12 and PNG encoding and deconding
    * AHTSE configuration file parsing
    
* *Sources*
  * [mrf](https://github.com/lucianpls/mod_mrf)
    * Serves tiles from an MRF file
  * [ecache](https://github.com/lucianpls/mod_ecache)
    * Serves tiles from an esri bundle cache (V2)
    * Can cache other tile services in an esri bundle cache format
  * [fractal](https://github.com/lucianpls/mod_fractal_tiles)
    * **INCOMPLETE**
    * Generates tiles of a fractal

* *Transformation*
  * [reproject](https://github.com/lucianpls/mod_reproject)
    * Projection changes, tile grid and scale changes and tile format changes
  * [convert](https://github.com/lucianpls/mod_convert)
    * Format, data type conversions
  * [fill](https://github.com/lucianpls/mod_ahtse_fill)
    * **INCOMPLETE**
    * Fill in missing tiles by oversampling lower resolution levels
  * [ahtse_png](https://github.com/lucianpls/mod_ahtse_png)
    * A PNG header manipulation module

* *Protocol conversion*
  * [twms](https://github.com/lucianpls/mod_twms)
    * Converts requests from tWMS protocol to AHTSE style

* *Utilities*
  * [receive](https://github.com/lucianpls/mod_receive)
    * Subrequest filter that enables passing data between AHTSE components
  * [send file](https://github.com/lucianpls/mod_sfim)
    * Used for protocol files, it responds with a static file to pattern matching requests
  * [lua](https://github.com/lucianpls/mod_ahtse_lua)
    * Allows AHTSE modules to be extended with Lua scripts
