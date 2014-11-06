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
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemManufacturingUOMs',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'intSort', type: 'int'},
    ],

    validators: [
        {type: 'presence', field: 'intUnitMeasureId'}
    ]
});