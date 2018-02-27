Ext.define('GlobalComponentEngine.store.MultiCompany', {
    extend: 'Ext.data.Store',
    alias: 'store.frmmulticompany',

    requires: [
        'GlobalComponentEngine.model.MultiCompany'
    ],

    model: 'GlobalComponentEngine.model.MultiCompany',
    storeId: 'MultiCompany',
    pageSize: 50,
    batchActions: true,
    proxy: {
        type: 'rest',
        api: {
            read: './globalcomponentengine/api/multicompany/get',
            create: './globalcomponentengine/api/multicompany/post',
            update: './globalcomponentengine/api/multicompany/put',
            destroy: './globalcomponentengine/api/multicompany/delete'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            allowSingle: false
        }
    }
});