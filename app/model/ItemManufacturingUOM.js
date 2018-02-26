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
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int'},

        { name: 'strUnitMeasure', type: 'string', auditKey: true}
    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});