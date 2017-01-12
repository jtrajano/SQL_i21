/**
 * Created by FMontefrio on 01/12/2017.
 */
Ext.define('Inventory.model.AdjustItemOwner', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemOwnerId',

    fields: [
        { name: 'intItemOwnerId', type: 'int'},
        { name: 'intItemId', type: 'int'},
        { name: 'intOwnerId', type: 'int', allowNull: true },
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'intSort', type: 'int'},
        { name: 'strCustomerNumber', type: 'string'},
        { name: 'strName', type: 'string'}
    ],

    validators: []    
});