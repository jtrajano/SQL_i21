/**
 * Created by LZabala on 6/10/2015.
 */
Ext.define('Inventory.model.ReceiptCharge', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ReceiptChargeTax',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptChargeId',

    fields: [
        { name: 'intInventoryReceiptChargeId', type: 'int', allowNull: true },
        { name: 'intInventoryReceiptId', type: 'int',
            reference: {
                type: 'Inventory.model.Receipt',
                inverse: {
                    role: 'tblICInventoryReceiptCharges',
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
   //     { name: 'intContractDetailId', type: 'int', allowNull: true },
        { name: 'intChargeId', type: 'int', allowNull: true },
        { name: 'ysnInventoryCost', type: 'boolean' },
        { name: 'strCostMethod', type: 'string' },
        { name: 'dblRate', type: 'float' },
        { name: 'intCostUOMId', type: 'int', allowNull: true },
        { name: 'dblAmount', type: 'float' },
        { name: 'strAllocateCostBy', type: 'string' },
        { name: 'ysnAccrue', type: 'boolean' },
        { name: 'intEntityVendorId', type: 'int', allowNull: true },
        { name: 'ysnPrice', type: 'boolean' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string' },
        { name: 'strItemDescription', type: 'string' },
        { name: 'strCostUOM', type: 'string' },
        { name: 'strUnitType', type: 'string' },
        { name: 'strVendorId', type: 'string' },
        { name: 'strVendorName', type: 'string' },
        { name: 'strContractNumber', type: 'string' },

   /*     { name: 'intCurrencyId', type: 'int', allowNull: true },
        { name: 'strCurrency', type: 'string' },
        { name: 'dblExchangeRate', type: 'float', allowNull: true  },
        { name: 'intCent', type: 'int', allowNull: true },*/
        { name: 'ysnSubCurrency', type: 'boolean', allowNull: true  },
        { name: 'dblTax', type: 'float' },
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strCostMethod'}
    ],

    validate: function(options) {
        var errors = this.callParent(arguments);
        if (this.get('strCostMethod') === 'Per Unit') {
            if (!this.get('intCostUOMId')) {
                errors.add({
                    field: 'strCostUOM',
                    message: 'UOM is required for Per Unit Cost Method.'
                })
            }
        }

        if (
            this.get('dblRate') <= 0 && 
            this.get('strCostMethod') !== 'Amount'        
        ) {
            errors.add({
                field: 'dblRate',
                message: 'Rate must be greater than zero.'
            })
        }

        if (
            this.get('strCostMethod') === 'Amount' && 
            ( Ext.isNumeric(this.get('dblAmount')) ? this.get('dblAmount') === 0 : false )
        ) {
            errors.add({
                field: 'dblAmount',
                message: 'Amount must have a value.'
            })
        }

        if (this.get('ysnInventoryCost')) {
            if (iRely.Functions.isEmpty(this.get('strAllocateCostBy'))){
                errors.add({
                    field: 'strAllocateCostBy',
                    message: 'Allocate Cost By cannot be blank when Inventory Cost is checked.'
                })
            }
        }

        if (this.joined.length > 0) {
            var data = this.joined[0].associatedEntity;
            var ReceiptVendorId = null;
            if (data) {
                ReceiptVendorId = data.get('intEntityVendorId');
            }
            if (this.get('ysnPrice') === true &&
                this.get('ysnAccrue') === true &&
                iRely.Functions.isEmpty(this.get('intEntityVendorId')) !== true &&
                this.get('intEntityVendorId') === ReceiptVendorId) {
                errors.add({
                    field: 'ysnAccrue',
                    message: this.get('strItemNo') + '  is both a payable and deductible to the bill of the same vendor.<br>Please correct the accrue or price checkbox.'
                })
                errors.add({
                    field: 'ysnPrice',
                    message: this.get('strItemNo') + '  is both a payable and deductible to the bill of the same vendor.<br>Please correct the accrue or price checkbox.'
                })
            }

            if (this.get('ysnInventoryCost') === true &&
                this.get('ysnPrice') === true &&
                this.get('ysnAccrue') === true &&
                iRely.Functions.isEmpty(this.get('intEntityVendorId')) !== true &&
                this.get('intEntityVendorId') !== ReceiptVendorId) {
                errors.add({
                    field: 'ysnPrice',
                    message: 'Cannot add expense ' + this.get('strItemNo') + ' to Inventory and pass it on to the vendor.<br>Change Inventory Cost or Price setup.'
                })
                errors.add({
                    field: 'ysnInventoryCost',
                    message: 'Cannot add expense ' + this.get('strItemNo') + ' to Inventory and pass it on to the vendor.<br>Change Inventory Cost or Price setup.'
                })
            }
            if (this.get('ysnInventoryCost') === true &&
                this.get('ysnPrice') === true &&
                this.get('ysnAccrue') === false &&
                iRely.Functions.isEmpty(this.get('intEntityVendorId')) === true) {
                errors.add({
                    field: 'ysnAccrue',
                    message: 'Cannot add expense ' + this.get('strItemNo') + ' to Inventory and pass it on to the vendor.<br>Change Inventory Cost or Price setup.'
                })
                errors.add({
                    field: 'ysnInventoryCost',
                    message: 'Cannot add expense ' + this.get('strItemNo') + ' to Inventory and pass it on to the vendor.<br>Change Inventory Cost or Price setup.'
                })
            }
        }
        return errors;
    }

});