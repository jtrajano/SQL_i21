/**
 * Created by marahman on 12-09-2014.
 */
Ext.define('Inventory.model.InventoryTag', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intTagId',

    fields: [
        { name: 'intTagId', type: 'int'},
        { name: 'strType', type: 'string', allowNull: false },
        { name: 'strTagNumber', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strMessage', type: 'string'},
        { name: 'ysnHazMat', type: 'boolean'},
        { name: 'intType', type: 'int' }
    ],

    validators: [
        {type: 'presence', field: 'strType'},
        {type: 'presence', field: 'strTagNumber'}
    ]
});
