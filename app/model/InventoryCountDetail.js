/**
 * Created by LZabala on 10/22/2015.
 */
Ext.define('Inventory.model.InventoryCountDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryCountDetailId',

    fields: [
        { name: 'intInventoryCountDetailId', type: 'int' },
        { name: 'intInventoryCountId', type: 'int',
            reference: {
                type: 'Inventory.model.InventoryCount',
                inverse: {
                    role: 'tblICInventoryCountDetails',
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
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'dblSystemCount', type: 'float' },
        { name: 'dblLastCost', type: 'float' },
        { name: 'strCountLine', type: 'string' },
        { name: 'dblPallets', type: 'float' },
        { name: 'dblQtyPerPallet', type: 'float' },
        { name: 'dblPhysicalCount', type: 'float' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'ysnRecount', type: 'boolean' },
        { name: 'intEntityUserSecurityId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string' },
        { name: 'strItemDescription', type: 'string' },
        { name: 'strLotTracking', type: 'string' },
        { name: 'strCategory', type: 'string' },
        { name: 'strLocationName', type: 'string' },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'strLotNumber', type: 'string' },
        { name: 'strLotAlias', type: 'string' },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'dblPhysicalCountStockUnit', type: 'int' },
        { name: 'dblVariance', type: 'float' },
        { name: 'strUserName', type: 'string' }
    ],

    validators: [
        { type: 'presence', field: 'strItemNo' }
    ]
});