# AHTSE
# Apache HTTPD Tile Server Ecosystem

AHTSE is a collection of Apache httpd modules that can be used independently or combined to implement high performance and scalable tile services. 
While developed for geospatial applications, AHTSE can be used for other domains that need fast pan and zoom access to large datasets.
The main AHTSE common feature that provides interoperability is the tile request format. The tile request supported by ATHSE is a REST request 
which ends with four integer values, path encoded as **"../M/Level/Row/Column"**, called an **MLRC** address.  The _Level - Row - Column_ 
values are the usual tile and pyramid addressing values, while _M_ is a server defined, multi-purpose value, exposing one or more extra dimensions 
of the served dataset. The _M_ parameter is the only optional one, it defaults to zero if the parameter before _Level_ is not a number.

**AHTSE Components**

|Type|Name|Function|
|-|-|-|
|*Common*|**[libahtse](https://github.com/lucianpls/libahtse)**|common code, shared by AHTSE modules. Includes raster formats codecs and provides AHTSE configuration file parsing and frequently used procedures|
|*Sources*|**[mrf](https://github.com/lucianpls/mod_mrf)**|Serves tiles from an MRF file|
||**[ecache](https://github.com/lucianpls/mod_ecache)**|Serves tiles from an esri bundle cache (V2), can cache other tile services|
||**[fractal](https://github.com/lucianpls/mod_fractal_tiles)**|**INCOMPLETE** Generates tiles of a fractal as a test source|
|*Transformations*|**[retile](https://github.com/lucianpls/mod_retile)**|Projection, tile grid and scale, format change|
||**[convert](https://github.com/lucianpls/mod_convert)**|Data values and type conversions|
||**[fillin](https://github.com/lucianpls/mod_fillin)**|Fill in missing tiles by oversampling lower resolution levels. It can be used to fill in sparse datasets, or to add oversampled levels.|
||**[pngmod](https://github.com/lucianpls/mod_pngmod)**|PNG manipulation module, without a full transcode|
|*Protocol*|**[twms](https://github.com/lucianpls/mod_twms)**|Converts requests from tWMS protocol to AHTSE style|
|*Utilities*|**[receive](https://github.com/lucianpls/mod_receive)**|Subrequest filter that enables passing tile data between AHTSE components|
||**[conditonal send file](https://github.com/lucianpls/mod_sfim)**|Used for protocol handshake files, it responds with the content from a static file to requests matching specific patterns|
||**[lua](https://github.com/lucianpls/mod_ahtse_lua)**|Allows AHTSE modules to be extended with Lua scripts|
