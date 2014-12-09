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
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intStockUnitMeasureId', type: 'int', allowNull: true},
        { name: 'dblConversionToStock', type: 'float'},
        { name: 'dblConversionFromStock', type: 'float'},
        { name: 'intSort', type: 'int'},

        { name: 'strUnitMeasure', type: 'string'}

    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});