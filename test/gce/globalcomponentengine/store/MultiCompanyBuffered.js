Ext.define('GlobalComponentEngine.store.MultiCompanyBuffered', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.frmmulticompanybuffered',

    requires: [
        'GlobalComponentEngine.model.MultiCompany'
    ],

    model: 'GlobalComponentEngine.model.MultiCompany',
    storeId: 'MultiCompanyBuffered',
    pageSize: 50,
    batchActions: true,
    proxy: {
        type: 'rest',
        api: {
            read: './globalcomponentengine/api/multicompany/search'
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