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
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intOwnerId', type: 'int', allowNull: true },
        { name: 'ysnDefault', type: 'boolean', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'strCustomerNumber', type: 'string', allowNull: true },
        { name: 'strName', type: 'string', allowNull: true }
    ]
});