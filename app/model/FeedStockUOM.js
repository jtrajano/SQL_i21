/**
 * Created by marahman on 19-09-2014.
 */
Ext.define('Inventory.model.FeedStockUom', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intRinFeedStockUOMId',

    fields: [
        { name: 'intRinFeedStockUOMId', type: 'int'},
        { name: 'strRinFeedStockUOM', type: 'string'},
        { name: 'strRinFeedStockUOMCode', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validations: [
        {type: 'presence', field: 'strRinFeedStockUOM'}
    ]
});
