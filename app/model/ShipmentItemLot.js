/**
 * Created by LZabala on 12/22/2014.
 */
Ext.define('Inventory.model.ShipmentItemLot', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryShipmentItemLotId',

    fields: [
        { name: 'intInventoryShipmentItemLotId', type: 'int'},
        { name: 'intInventoryShipmentItemId', type: 'int',
            reference: {
                type: 'Inventory.model.ShipmentItem',
                inverse: {
                    role: 'tblICInventoryShipmentItemLots',
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
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'dblQuantityShipped', type: 'float' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblGrossWeight', type: 'float' },
        { name: 'dblTareWeight', type: 'float' },
        { name: 'dblNetWeight', type: 'float',
            persist: false,
            convert: function(value, record){
                return record.get('dblGrossWeight') - record.get('dblTareWeight');
            },
            depends: ['dblGrossWeight', 'dblTareWeight']
        },
        { name: 'strWarehouseCargoNumber', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strLotId', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLotId'},
        {type: 'presence', field: 'dblQuantityShipped'}
    ]
});