Ext.define('Inventory.Utils', {
    name: 'utils',
    alternateClassName: 'ic.utils',

    statics: {
        Math: { 
            round: function(number, precision) {
                if (!Ext.isNumeric(number)) return; 
                precision = Ext.isNumeric(precision) ? precision : 0; 

                return Number(Math.round(number+'e'+precision)+'e-'+precision); // 1.9768564574630487e+21e-12
            },
            roundWithPrecision: function(number, precision) {
                return parseFloat(numeral(number).format(ic.utils.Number.getPrecisionPattern('0.[', precision, ']')))
            },

            // Math.trunc is not supported by PhantomJs and IE so it needs to be polyfilled.
            truncate: function(v) {
                v = +v;
                if (!isFinite(v)) return v;
                
                return (v - v % 1)   ||   (v < 0 ? -0 : v === 0 ? v : 0);
            },
        },

        Date: {
            getDuration: function(valueInSeconds) {
                if(!valueInSeconds || valueInSeconds < 0)
                    valueInSeconds = 0;
                if(valueInSeconds < 1)
                    return ic.utils.Math.round((valueInSeconds * 1000.0), 2).toString().concat("<em>ms</em>");    
                else if(valueInSeconds >= 60 && valueInSeconds < 3600)    
                    return ic.utils.Math.round((valueInSeconds / 60.0), 2).toString().concat("<em>m</em>");    
                else if (valueInSeconds >= 3600 && valueInSeconds < 216000)
                    return ic.utils.Math.round(((valueInSeconds / 60.0) / 60.0), 2).toString().concat("<em>h</em>");
                else if (valueInSeconds >= 5184000)
                    return ic.utils.Math.round((((valueInSeconds / 60.0) / 60.0)) / 24, 2).toString().concat("<em>d</em>");
                else
                    return ic.utils.Math.round((valueInSeconds), 2).toString().concat("<em>s</em>");
            }
        },

        Number: {
            format: function(number, pattern) {
                return numeral(number).format(pattern);
            },
            formatAccounting: function(number, decimals) {
                return numeral(number).format(ic.utils.Number.getPrecisionPattern('(0,0.', decimals, ')'));
            },
            formatPercentage: function(number) {
                return numeral(number).format('0%');
            },
            getPrecisionPattern: function(prefix, precision, suffix) {
                var zeroes = "";
                for(var i = 0; i < precision; i++) {
                    zeroes += "0";
                }
                var pattern = prefix + zeroes + suffix;
                return pattern;
            }
        },

        Uom: {
            convertQtyBetweenUOM: function (sourceUOMConversionFactor, targetUOMConversionFactor, qty) {
                var result = 0;
        
                if (sourceUOMConversionFactor === targetUOMConversionFactor) {
                    result = qty;
                }
                else if (targetUOMConversionFactor !== 0) {
                    result = (sourceUOMConversionFactor * qty) / targetUOMConversionFactor;
                }
        
                //return Math.round(result, 12);
                return ic.utils.Math.roundWithPrecision(result, 12); 
            }
        },
        
        nullOrDefault: function(value, defaultValue) {
            return value ? value : defaultValue;
        },

        ajax: function (options) {
            /* Prevent SQL injection attacks by sanitizing all the concatenated parameters in the URL path and place them to the param property of the ajax configuration. */
            if(!options.forceUrlParams) {
                var urlObject = ic.utils.getUrlObject(options.url);
                if (urlObject && urlObject.search) {
                    options.url = options.url.replace(urlObject.search, '');
                    options.params = _.extend(options.params ? options.params : {}, urlObject.searchObject);
                }

                // Apply dynamic filters
                if(options.filters) {
                    options.params = _.extend(options.params ? options.params : {}, { filter: iRely.Functions.encodeFilters(options.filters) })
                }
            }
            /* Defaults method to 'GET' when method is not defined. */
            if (!options.method)
                options.method = "get";
            
            /**
             * @deprecated Is now supported by the Framework
             * Inserts or overrides the Authorization header key-value pair when method is 'POST'.
             */
            if (options.method.toLowerCase() === "post") {
                if (!options.headers)
                    options.headers = {};
                // options.headers.Authorization = iRely.Functions.createIdentityToken(app.UserName, app.Password, app.Company, app.UserId, app.EntityId); // Old
                // options.headers.Authorization = iRely.Configuration.Security.AuthToken;
            }
            var o = Rx.Observable.defer(function () { return Ext.Ajax.request(options); });
            return o;
        },

        getUrlObject: function (url) {
            var parser = document.createElement('a'),
                searchObject = {},
                queries, split, i;
            // Let the browser do the work
            parser.href = url;
            // Convert query string to object
            queries = parser.search.replace(/^\?/, '').split('&');
            for (i = 0; i < queries.length; i++) {
                split = queries[i].split('=');
                searchObject[split[0]] = split[1];
            }
            return {
                protocol: parser.protocol,
                host: parser.host,
                hostname: parser.hostname,
                port: parser.port,
                pathname: parser.pathname,
                search: parser.search,
                searchObject: searchObject,
                hash: parser.hash
            };
        },

        writeCSV: function (columns, data, alias, filename) {
            var result = "",
                headers = columns;

            // Set headers.
            headers = _.map(headers, function(x) { return (x.toString().replace(/,/g, "")); });
            headers = _.map(headers, function(x) {
                var xy = _.findWhere(alias, { field: x });
                if(xy)
                    return xy.column;
                return x;
            });

            var rows = _.map(data, function(x) { return (x.join(",")); });
            // Ready data for reading.
            result = headers.join(",") + "\n" + rows.join("\n");

            ic.utils.setCsvFile(result, filename);
        },

        jsonArrayToCSVMapping: function (data) {
            var mapped = _.map(data, function (x) {
                var m = _.values(x);
                var z = _.map(m, function (y) {
                    return y.toString().replace(/,/g, "");
                });
                return z;
            });
            var columns = [];
            if (data && data.length > 0)
                columns = _.keys(_.first(data));
            return {
                data: mapped,
                columns: columns
            };
        },

        setCsvFile: function (data, fileName, fileType) {
            // Set objects for file generation.
            var blob, url, a, extension;

            // Get time stamp for fileName.
            var stamp = new Date().getTime();

            // Set MIME type and encoding.
            fileType = (fileType || "text/csv;charset=UTF-8");
            extension = fileType.split("/")[1].split(";")[0];
            // Set file name.
            fileName = (fileName || "csv_file_" + stamp + "." + extension);

            // Set data on blob.
            blob = new Blob([data], { type: fileType });

            // Set view.
            if (blob) {
                // Read blob.
                url = window.URL.createObjectURL(blob);

                // Create link.
                a = document.createElement("a");
                // Set link on DOM.
                document.body.appendChild(a);
                // Set link's visibility.
                a.style = "display: none";
                // Set href on link.
                a.href = url;
                // Set file name on link.
                a.download = fileName;

                // Trigger click of link.
                a.click();

                // Clear.
                window.URL.revokeObjectURL(url);
            } else {
                // Handle error.
            }
        },

        baseUrl: './inventory/api',
        getEndpoint: function(resource) {
            return ic.utils.baseUrl + '/' + resource;
        }
    }
});
