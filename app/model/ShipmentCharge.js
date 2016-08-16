/**
 * Created by LZabala on 8/6/2015.
 */
Ext.define('Inventory.model.ShipmentCharge', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryShipmentChargeId',

    fields: [
        { name: 'intInventoryShipmentChargeId', type: 'int'},
        { name: 'intInventoryShipmentId', type: 'int',
            reference: {
                type: 'Inventory.model.Shipment',
                inverse: {
                    role: 'tblICInventoryShipmentCharges',
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
        { name: 'intContractId', type: 'int', allowNull: true },
        { name: 'intChargeId', type: 'int', allowNull: true },
        { name: 'strCostMethod', type: 'string' },
        { name: 'dblRate', type: 'float' },
        { name: 'dblExchangeRate', type: 'float' },
        { name: 'intCostUOMId', type: 'int', allowNull: true },
        { name: 'dblAmount', type: 'float' },
        { name: 'strAllocatePriceBy', type: 'string' },
        { name: 'strCostBilledBy', type: 'string' },
        { name: 'intEntityVendorId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strAllocatePriceBy'}
    ]
});