/**
 * Created by LZabala on 10/28/2014.
 */
Ext.define('Inventory.model.CompactItem', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intItemId', type: 'int'},
        { name: 'strItemNo', type: 'string'},
        { name: 'strType', type: 'string'},
        { name: 'strDescription', type: 'string'},
    ]
});