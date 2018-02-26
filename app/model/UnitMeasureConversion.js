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
        { 
            name: 'intUnitMeasureId', 
            type: 'int',
            reference: {
                type: 'Inventory.model.UnitMeasure',
                inverse: {
                    role: 'tblICUnitMeasureConversions',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/unitmeasure/getuomconversion'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },                      
                        sorters: {
                            direction: 'ASC',
                            property: 'intUnitMeasureConversionId'
                        }
                    }
                }
            }},
        { name: 'intStockUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblConversionToStock', type: 'float' },
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strStockUOM', type: 'string', auditKey: true}
    ],

    validators: [
        {type: 'presence', field: 'strStockUOM'},
        {type: 'presence', field: 'dblConversionToStock'}
    ]
});