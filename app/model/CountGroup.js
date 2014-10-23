/**
 * Created by LZabala on 10/23/2014.
 */
Ext.define('Inventory.model.CountGroup', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCountGroupId',

    fields: [
        { name: 'intCountGroupId', type: 'int'},
        { name: 'strCountGroup', type: 'string'},
        { name: 'intSort', type: 'int'}
    ]
});