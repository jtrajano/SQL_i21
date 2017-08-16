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
        { name: 'intCountGroupId', type: 'int', allowNull: true },
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
        { name: 'strLotNo', type: 'string' },
        { name: 'strLotAlias', type: 'string' },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'dblConversionFactor', type: 'float' },
        { name: 'dblQtyReceived', type: 'float' },
        { name: 'dblQtySold', type: 'float' },
        { name: 'dblPhysicalCountStockUnit', type: 'float',
            persist: false,
            convert: function(value, record){
                var dblPhysicalCount = iRely.Functions.isEmpty(record.get('dblPhysicalCount')) ? 0 : record.get('dblPhysicalCount');
                var dblConversionFactor = iRely.Functions.isEmpty(record.get('dblConversionFactor')) ? 0 : record.get('dblConversionFactor');
                var dblPhysicalCountStockUnit = dblPhysicalCount * dblConversionFactor;
                return dblPhysicalCountStockUnit;
            },
            depends: ['dblPhysicalCount', 'dblConversionFactor']},
        { name: 'dblVariance', type: 'float' ,
            persist: false,
            convert: function(value, record){
                var dblPhysicalCount = iRely.Functions.isEmpty(record.get('dblPhysicalCount')) ? 0 : record.get('dblPhysicalCount');
                var dblSystemCount = iRely.Functions.isEmpty(record.get('dblSystemCount')) ? 0 : record.get('dblSystemCount');
                var dblVariance = dblPhysicalCount - dblSystemCount;

                if(record.get('intCountGroupId')) {
                    var dblQtyReceived = iRely.Functions.isEmpty(record.get('dblQtyReceived')) ? 0 : record.get('dblQtyReceived');
                    var dblQtySold = iRely.Functions.isEmpty(record.get('dblQtySold')) ? 0 : record.get('dblQtySold');
                    dblVariance = dblPhysicalCount - (dblSystemCount + dblQtyReceived - dblQtySold);
                }
                return dblVariance;
            },
            depends: ['dblPhysicalCount', 'dblSystemCount', 'dblQtyReceived', 'dblQtySold']},
        { name: 'strUserName', type: 'string' }
    ],

    validators: [
        { type: 'presence', field: 'intItemUOMId' },
        { type: 'presence', field: 'strUnitMeasure' },
        { type: 'presence', field: 'strItemNo' }
    ]
});