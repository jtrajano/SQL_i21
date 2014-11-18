/**
 * Created by rnkumashi on 19-09-2014.
 */

Ext.define('Inventory.model.FactoryUnitType', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStorageUnitTypeId',

    fields: [
        { name: 'intStorageUnitTypeId', type: 'int'},
        { name: 'strStorageUnitType', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strInternalCode', type: 'string'},
        { name: 'intCapacityUnitMeasureId', type: 'int', allowNull: true},
        { name: 'dblMaxWeight', type: 'float'},
        { name: 'ysnAllowPick', type: 'boolean'},
        { name: 'intDimensionUnitMeasureId', type: 'int', allowNull: true},
        { name: 'dblHeight', type: 'float'},
        { name: 'dblDepth', type: 'float'},
        { name: 'dblWidth', type: 'float'},
        { name: 'intPalletStack', type: 'int'},
        { name: 'intPalletColumn', type: 'int'},
        { name: 'intPalletRow', type: 'int'},

    ],
    validators: [
        {type: 'presence', field: 'strStorageUnitType'}
    ]
});