/**
 * Created by LZabala on 11/7/2014.
 */
Ext.define('Inventory.model.CompactCommodity', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityId',

    fields: [
        { name: 'intCommodityId', type: 'int'},
        { name: 'strCommodityCode', type: 'string'},
        { name: 'strDescription', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strCommodityCode'}
    ]
});