/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.model.Container', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intContainerId',

    fields: [
        { name: 'intContainerId', type: 'int'},
        { name: 'intExternalSystemId', type: 'int', allowNull: true},
        { name: 'strContainerId', type: 'string'},
        { name: 'intContainerTypeId', type: 'int', allowNull: true},
        { name: 'intStorageLocationId', type: 'int', allowNull: true},
        { name: 'strLastUpdateBy', type: 'string'},
        { name: 'dtmLastUpdateOn', type: 'date', allowNull: true, dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strContainerId'},
        {type: 'presence', field: 'intContainerTypeId'}

    ]
});