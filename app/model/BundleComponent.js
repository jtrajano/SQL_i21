/**
 * Created by LZabala on 10/15/2015.
 */
Ext.define('Inventory.model.BundleComponent', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemBundleId',

    fields: [
        { name: 'intItemBundleId', type: 'int' },
        { name: 'intItemId', type: 'int' },
        { name: 'strItemNo', type: 'string', auditKey: true },
        { name: 'strItemDescription', type: 'string' },
        { name: 'intBundleItemId', type: 'int', allowNull: true },
        { name: 'strComponent', type: 'string' },
        { name: 'strComponentDescription', type: 'string' },
        { name: 'strDescription', type: 'string' },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblConversionFactor', type: 'float' },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'dblUnit', type: 'float' },
        { name: 'dblPrice', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true }
    ]
});