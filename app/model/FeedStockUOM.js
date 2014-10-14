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
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'strRinFeedStockUOMCode', type: 'string'},
        { name: 'intSort', type: 'int'},

        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intUnitMeasureId'}
    ]
});
