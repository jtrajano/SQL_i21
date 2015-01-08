/**
 * Created by LZabala on 1/8/2015.
 */
Ext.define('Inventory.model.CompactItemFactory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemFactoryId',

    fields: [
        { name: 'intItemFactoryId', type: 'int'},
        { name: 'intItemId', type: 'int' },
        { name: 'intFactoryId', type: 'int', allowNull: true },
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'}
    ]
});