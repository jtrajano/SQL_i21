/**
 * Created by LZabala on 6/10/2015.
 */
Ext.define('Inventory.model.ReceiptCharge', {
    extend: 'iRely.BaseEntity',

    requires: [
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
        { name: 'strContractNumber', type: 'string' }
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
        if (this.get('dblRate') <= 0) {
            if (this.get('strCostMethod') !== 'Amount'){
                errors.add({
                    field: 'dblRate',
                    message: 'Rate must be greater than zero.'
                })
            }
        }
        if (this.get('ysnInventoryCost')) {
            if (iRely.Functions.isEmpty(this.get('strAllocateCostBy'))){
                errors.add({
                    field: 'strAllocateCostBy',
                    message: 'Allocate Cost By cannot be blank when Inventory Cost is checked.'
                })
            }
        }

        var data = this.getAssociatedData();
        var ReceiptVendorId = null;
        if (data) {
            ReceiptVendorId = data.intInventoryReceipt.intVendorEntityId;
        }
        if (this.get('ysnInventoryCost') === true &&
            this.get('ysnPrice') === true &&
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
                field: 'ysnAccrue',
                message: this.get('strItemNo') + ' is shouldered by the receipt vendor and can\'t be added to the item cost.<br>Please correct price or inventory cost checkbox.'
            })
            errors.add({
                field: 'ysnInventoryCost',
                message: this.get('strItemNo') + ' is shouldered by the receipt vendor and can\'t be added to the item cost.<br>Please correct price or inventory cost checkbox.'
            })
        }
        if (this.get('ysnInventoryCost') === true &&
            this.get('ysnPrice') === true &&
            this.get('ysnAccrue') === false &&
            iRely.Functions.isEmpty(this.get('intEntityVendorId')) === true) {
            errors.add({
                field: 'ysnAccrue',
                message: this.get('strItemNo') + ' is shouldered by the receipt vendor and can\'t be added to the item cost.<br>Please correct price or inventory cost checkbox.'
            })
            errors.add({
                field: 'ysnInventoryCost',
                message: this.get('strItemNo') + ' is shouldered by the receipt vendor and can\'t be added to the item cost.<br>Please correct price or inventory cost checkbox.'
            })
        }

        return errors;
    }

});