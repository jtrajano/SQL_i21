Ext.define('Inventory.Utils', {
    name: 'utils',
    alternateClassName: 'ic.utils',

    statics: {
        ajax: function (options) {
            /* Prevent SQL injection attacks by sanitizing all the concatenated parameters in the URL path and place them to the param property of the ajax configuration. */
            var urlObject = ic.utils.getUrlObject(options.url);
            if(urlObject && urlObject.search) {
                options.url = options.url.replace(urlObject.search, '');
                options.params = _.extend(options.params, urlObject.searchObject);
            }
            /* Defaults method to 'GET' when method is not defined. */
            if (!options.method)
                options.method = "get";
            /* Inserts or overrides the Authorization header key-value pair when method is 'POST'. */
            if (options.method.toLowerCase() === "post") {
                if (!options.headers)
                    options.headers = {};
                options.headers.Authorization = iRely.Functions.createIdentityToken(app.UserName, app.Password, app.Company, app.UserId, app.EntityId);
            }
            var o = Rx.Observable.defer(function() { return Ext.Ajax.request(options); });
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
        }
    }
});
