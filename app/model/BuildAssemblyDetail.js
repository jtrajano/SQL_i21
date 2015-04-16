/**
 * Created by LZabala on 4/15/2015.
 */
Ext.define('Inventory.model.BuildAssemblyDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryAdjustmentDetailId',

    fields: [
        { name: 'intBuildAssemblyDetailId', type: 'int' },
        { name: 'intBuildAssemblyId', type: 'int',
            reference: {
                type: 'Inventory.model.BuildAssembly',
                inverse: {
                    role: 'tblICBuildAssemblyDetails',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'dblCost', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string' },
        { name: 'strUnitMeasure', type: 'string' }
    ],

    validators: [
        { type: 'presence', field: 'strItemNo' },
        { type: 'presence', field: 'strUnitMeasure' }
    ]
});