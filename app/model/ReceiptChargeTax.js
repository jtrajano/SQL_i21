/**
 * Created by JBalangatan on 10/12/2016.
 */
Ext.define('Inventory.model.ReceiptChargeTax', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptChargeTaxId',

    fields: [
        { name: 'intInventoryReceiptChargeTaxId', type: 'int'},
        { name: 'intInventoryReceiptChargeId', type: 'int',
            reference: {
                type: 'Inventory.model.ReceiptCharge',
                inverse: {
                    role: 'tblICInventoryReceiptChargeTaxes',
                    storeConfig: {
                        complete: true,
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/inventoryreceiptchargetax/get'
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
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'ysnTaxOnly', type: 'boolean' },
        { name: 'ysnCheckoffTax', type: 'boolean' },
        { name: 'strTaxCode', type: 'string' },
        { name: 'dblQty', type: 'float' },
        { name: 'dblCost', type: 'float' },               
        { name: 'intSort', type: 'int', allowNull: true }
    ]
});