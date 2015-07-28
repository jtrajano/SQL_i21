/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.model.ReceiptItemTax', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptItemTaxId',

    fields: [
        { name: 'intInventoryReceiptItemTaxId', type: 'int'},
        { name: 'intInventoryReceiptItemId', type: 'int',
            reference: {
                type: 'Inventory.model.ReceiptItem',
                inverse: {
                    role: 'tblICInventoryReceiptItemTaxes',
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
        { name: 'intTaxGroupMasterId', type: 'int', allowNull: true },
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
        { name: 'ysnSeparateOnInvoice', type: 'boolean' },
        { name: 'ysnCheckoffTax', type: 'boolean' },
        { name: 'strTaxCode', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'intTaxCodeId'}
    ]
});