/**
 * Created by LZabala on 11/6/2014.
 */
Ext.define('Inventory.model.StorageType', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStorageTypeId',

    fields: [
        { name: 'intStorageTypeId', type: 'int'},
        { name: 'strStorageType', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strStorageType'}
    ]
});