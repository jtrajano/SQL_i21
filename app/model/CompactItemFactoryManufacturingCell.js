/**
 * Created by LZabala on 1/8/2015.
 */
Ext.define('Inventory.model.CompactItemFactoryManufacturingCell', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemFactoryManufacturingCellId',

    fields: [
        { name: 'intItemFactoryManufacturingCellId', type: 'int'},
        { name: 'intItemFactoryId', type: 'int' },
        { name: 'intManufacturingCellId', type: 'int', allowNull: true },
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'intPreference', type: 'int'},
        { name: 'intSort', type: 'int'},

        { name: 'strCellName', type: 'string'}

    ],

    validators: [
        {type: 'presence', field: 'strCellName'}
    ]
});