/**
 * Created by LZabala on 12/22/2014.
 */
Ext.define('Inventory.model.ShipmentItem', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ShipmentItemLot',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryShipmentItemId',

    fields: [
        { name: 'intInventoryShipmentItemId', type: 'int'},
        { name: 'intInventoryShipmentId', type: 'int',
            reference: {
                type: 'Inventory.model.Shipment',
                inverse: {
                    role: 'tblICInventoryShipmentItems',
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
        { name: 'intSourceId', type: 'int', allowNull: true },
        { name: 'intLineNo', type: 'int', allowNull: true },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'dblUnitPrice', type: 'float' },
        { name: 'intTaxCodeId', type: 'int', allowNull: true },
        { name: 'intDockDoorId', type: 'int', allowNull: true },
        { name: 'strNotes', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strWeightUOM', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strReferenceNumber'},
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'dblQuantity'},
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});