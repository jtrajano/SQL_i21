
Ext.define('Inventory.model.ShipmentChargeTax', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryShipmentChargeTaxId',

    fields: [
        { name: 'intInventoryShipmentChargeTaxId', type: 'int'},
        { name: 'intInventoryShipmentChargeId', type: 'int',
            reference: {
                type: 'Inventory.model.ShipmentCharge',
                inverse: {
                    role: 'tblICInventoryShipmentChargeTaxes',
                    storeConfig: {
                        complete: true,
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/inventoryshipmentchargetax/get'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data'
                            }
                        },
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intTaxGroupId', type: 'int', allowNull: true },
        { name: 'intTaxCodeId', type: 'int', allowNull: true },
        { name: 'intTaxClassId', type: 'int', allowNull: true },
        { name: 'strTaxableByOtherTaxes', type: 'string' },
        { name: 'strCalculationMethod', type: 'string' },
        { name: 'dblRate', type: 'float' },
        { name: 'dblTax', type: 'float' },
        { name: 'dblAdjustedTax', type: 'float' },
        { name: 'intTaxAccountId', type: 'int', allowNull: true },
        { name: 'ysnTaxAdjusted', type: 'boolean' },
        { name: 'ysnTaxOnly', type: 'boolean' },
        { name: 'ysnCheckoffTax', type: 'boolean' },
        { name: 'strTaxCode', type: 'string', auditKey: true },
        { name: 'dblQty', type: 'float' },
        { name: 'dblCost', type: 'float' },               
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true }
    ]
});