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
        { name: 'intContractDetailId', type: 'int', allowNull: true },
        { name: 'intChargeId', type: 'int', allowNull: true },
        { name: 'strCostMethod', type: 'string' },
        { name: 'dblRate', type: 'float' },
        { name: 'dblExchangeRate', type: 'float' },
        { name: 'intCostUOMId', type: 'int', allowNull: true },
        { name: 'dblAmount', type: 'float' },
        { name: 'strAllocatePriceBy', type: 'string' },
        { name: 'strCostBilledBy', type: 'string' },
        { name: 'intEntityVendorId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'strCurrency', type: 'string'},
        { name: 'intForexRateTypeId', type: 'int', allowNull: true },
        { name: 'strForexRateType', type: 'string'},
        { name: 'dblForexRate', type: 'float', allowNull: true }                
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strAllocatePriceBy'},
        {type: 'presence', field: 'strCurrency'}
    ],

      validate: function(options) {
        var errors = this.callParent(arguments);
        if (this.get('strCostMethod') === 'Per Unit') {
            if (!this.get('intCostUOMId')) {
                errors.add({
                    field: 'strCostUOM',
                    message: 'UOM is required for Per Unit Price Method.'
                })
            }
        }

        if (
            this.get('dblRate') === 0 && 
            this.get('strCostMethod') !== 'Amount'        
        ) {
            errors.add({
                field: 'dblRate',
                message: 'Rate must have a value.'
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

         if (this.joined.length > 0) {
            var data = this.joined[0].associatedEntity;
            var ShipmentCustomerId = null;
            if (data) {
                ShipmentCustomerId = data.get('intEntityCustomerId');
            }
            if (this.get('ysnAccrue') === true) {
                if (iRely.Functions.isEmpty(this.get('intEntityVendorId'))) {
                    errors.add({
                        field: 'strVendorName',
                        message: 'Vendor for Other Charge Item ' + this.get('strItemNo') + '  is required to accrue.'
                    })
                }

                if (this.get('intEntityVendorId') === ShipmentCustomerId) {
                    errors.add({
                        field: 'strVendorName',
                        message: 'Cannot accrue to a customer. Select a third party vendor.'
                    })
                }
            }
        }

        return errors;
    }

});