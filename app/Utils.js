Ext.define('Inventory.Utils', {
    name: 'utils',
    alternateClassName: 'ic.utils',

    statics: {
        ajax: function (options) {
            /* Defaults method to 'GET' when method is not defined. */
            if(!options.method)
                options.method = "get";
            /* Inserts or overrides the Authorization header key-value pair when method is 'POST'. */
            if(options.method.toLowerCase() === "post") {
                if(!options.headers)
                    options.headers = { };
                options.headers.Authorization = iRely.Functions.createIdentityToken(app.UserName, app.Password, app.Company, app.UserId, app.EntityId);
            }
            var o = Rx.Observable.defer(() => Ext.Ajax.request(options));
            return o;
        }
    }
});
