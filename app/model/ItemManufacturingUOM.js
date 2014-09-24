/**
 * Created by LZabala on 9/24/2014.
 */
Ext.define('Inventory.model.ItemManufacturingUOM', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemManufacturingUOMId',

    fields: [
        { name: 'intItemManufacturingUOMId', type: 'int'},
        { name: 'intItemId', type: 'int'},
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'intSort', type: 'int'}
    ]
});