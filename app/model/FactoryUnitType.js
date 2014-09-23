/**
 * Created by rnkumashi on 19-09-2014.
 */

Ext.define('Inventory.model.FactoryUnitType', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intUnitTypeId',

    fields: [
        { name: 'intUnitTypeId', type: 'int'},
        { name: 'strUnitType', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strInternalCode', type: 'string'},
        { name: 'intCapacityUnitMeasureId', type: 'int'},
        { name: 'dblMaxWeight', type : 'float'},
        { name: 'ysnAllowPick', type : 'string'},
        { name: 'intDimensionUnitMeasureId', type : 'int'},
        { name: 'dblHeight', type : 'float'},
        { name: 'dblDepth', type : 'float'},
        { name: 'dblWidth', type : 'float'},
        { name: 'intPalletStack', type : 'int'},
        { name: 'intPalletColumn', type : 'int'},
        { name: 'intPalletRow', type: 'int'}

    ],
    validators: [
        {type: 'presence', field: 'strUnitType'}
    ]
});