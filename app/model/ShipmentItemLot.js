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
        { name: 'intLotId', type: 'int'},
        { name: 'dblQuantityShipped', type: 'float'},
        { name: 'strWarehouseCargoNumber', type: 'string'},
        { name: 'intSort', type: 'int'},

        { name: 'strLotId', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLotId'},
        {type: 'presence', field: 'dblQuantityShipped'}
    ]
});