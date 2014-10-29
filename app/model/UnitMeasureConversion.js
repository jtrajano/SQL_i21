/**
 Created by LZabala on 10/29/2014.
 */

Ext.define('Inventory.model.UnitMeasureConversion', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intUnitMeasureConversionId',

    fields: [
        { name: 'intUnitMeasureConversionId', type: 'int'},
        { name: 'intUnitMeasureId', type: 'int',
            reference: {
                type: 'Inventory.model.UnitMeasure',
                inverse: {
                    role: 'tblICUnitMeasureConversions',
                    storeConfig: {
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intStockUnitMeasureId', type: 'int', allowNull: true},
        { name: 'dblConversionToStock', type: 'float'},
        { name: 'dblConversionFromStock', type: 'float'},
        { name: 'intSort', type: 'int'},
    ],

    validators: [
        {type: 'presence', field: 'intStockUnitMeasureId'}
    ]
});