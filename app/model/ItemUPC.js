/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemUPC', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemUPCId',

    fields: [
        { name: 'intItemUPCId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemUPCs',
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
        { name: 'dblUnitQty', type: 'float'},
        { name: 'strUPCCode', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'intUnitMeasureId'}
    ]
});