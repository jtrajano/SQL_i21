/**
 * Created by marahman on 19-09-2014.
 */
Ext.define('Inventory.model.FeedStockCode', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intRinFeedStockId',

    fields: [
        { name: 'intRinFeedStockId', type: 'int'},
        { name: 'strRinFeedStockCode', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validations: [
        {type: 'presence', field: 'strRinFeedStockCode'}
    ]
});
