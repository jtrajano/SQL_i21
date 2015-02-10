/**
 * Created by LZabala on 2/9/2015.
 */
Ext.define('Inventory.model.PackedUOM', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    fields: [
        { name: 'intUnitMeasureConversionId', type: 'int', allowNull: true },
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'strUnitType', type: 'string' },
        { name: 'strSymbol', type: 'string' },
        { name: 'intStockUnitMeasureId', type: 'int', allowNull: true },
        { name: 'strConversionUOM', type: 'string' },
        { name: 'dblConversionFromStock', type: 'float' },
        { name: 'dblConversionToStock', type: 'float' }
    ]
});