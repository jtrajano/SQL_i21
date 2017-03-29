/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.model.ReceiptItem', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ReceiptItemLot',
        'Inventory.model.ReceiptItemTax',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptItemId',

    fields: [
        { name: 'intInventoryReceiptItemId', type: 'int'},
        { name: 'intInventoryReceiptId', type: 'int',
            reference: {
                type: 'Inventory.model.Receipt',
                inverse: {
                    role: 'tblICInventoryReceiptItems',
                    storeConfig: {
                        complete: true,
                     /*   sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }*/
                    }
                }
            }
        },
        { name: 'intLineNo', type: 'int' },
        { name: 'intOrderId', type: 'int', allowNull: true },
        { name: 'intSourceId', type: 'int', allowNull: true },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intContainerId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'intOwnershipType', type: 'int', allowNull: true },
        { name: 'dblOrderQty', type: 'float' },
        { name: 'dblBillQty', type: 'float' },
        { name: 'dblOpenReceive', type: 'float' },
        { name: 'dblReceived', type: 'float' },
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intCostUOMId', type: 'int', allowNull: true },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblUnitCost', type: 'float' },
        { name: 'dblUnitRetail', type: 'float' },
        { name: 'dblLineTotal', type: 'float' },
        { name: 'intGradeId', type: 'int', allowNull: true },
        { name: 'dblGross', type: 'float' },
        { name: 'dblNet', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strOrderNumber', type: 'string'},
        { name: 'strSourceNumber', type: 'string'},
        { name: 'strItemNo', type: 'string'},
        { name: 'strItemDescription', type: 'string'},
        { name: 'strOwnershipType', type: 'string'},
        { name: 'strLotTracking', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strWeightUOM', type: 'string'},
        { name: 'strSubLocationName', type: 'string'},
        { name: 'strStorageLocationName', type: 'string'},
        { name: 'strUnitType', type: 'string'},
        { name: 'strContainer', type: 'string'},
        { name: 'dblGrossMargin', type: 'float' },
        { name: 'intCommodityId', type: 'int', allowNull: true },
        { name: 'intTaxGroupId', type: 'int', allowNull: true },
        { name: 'intLoadReceive', type: 'int' },
        { name: 'ysnSubCurrency', type: 'boolean', allowNull: true },
        { name: 'strSubCurrency', type: 'string'},
        { name: 'strPricingType', type: 'string'},
        { name: 'strTaxGroup', type: 'string'},        
        { name: 'intForexRateTypeId', type: 'int', allowNull: true },
        { name: 'strForexRateType', type: 'string'},
        { name: 'dblForexRate', type: 'float', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strOwnershipType'},
        {type: 'presence', field: 'strUnitMeasure'},
        {type: 'presence', field: 'dblOpenReceive'}
    ],

    sign: function(n){
        if (Ext.isNumeric(n)){
            return n > 0 ? 1 : n == 0 ? 0 : -1;
        }
        return NaN;
    },

    validateSubAndStorageLocations: function(errors){
        if (this.get('strLotTracking') !== 'No') {
            if (iRely.Functions.isEmpty(this.get('intSubLocationId'))) {
                errors.add({
                    field: 'strSubLocationName',
                    message: 'Storage Location must be present.'
                });
                return false;
            }
            if (iRely.Functions.isEmpty(this.get('intStorageLocationId'))) {
                errors.add({
                    field: 'strStorageLocationName',
                    message: 'Storage Unit must be present.'
                });

                return false;
            }
        }
        return true;
    },

    validateNetQty: function(errors) {
        if (this.get('intWeightUOMId')) {
            if (!Ext.isNumeric(this.get('dblNet'))) {
                errors.add({
                    field: 'dblNet',
                    message: 'Must have a Net Qty when Gross/Net UOM is specified.'
                });
                return false;
            }
            else {
                if (this.get('dblNet') == 0) {
                    errors.add({
                        field: 'dblNet',
                        message: 'Net Qty must be non-zero when Gross/Net UOM is specified.'
                    });
                    return false;
                }

                if (this.sign(this.get('dblOpenReceive')) == 1){
                    if (this.sign(this.get('dblNet')) != 1){
                        errors.add({
                            field: 'dblNet',
                            message: 'Net Qty must be a positive number when Qty to Receive is positive.'
                        });
                        return false;
                    }
                }
                else if (this.sign(this.get('dblOpenReceive')) == -1){
                    if (this.sign(this.get('dblNet')) != -1){
                        errors.add({
                            field: 'dblNet',
                            message: 'Net Qty must be a negative number when Qty to Receive is negative.'
                        });
                        return false;
                    }
                }
            }

            return true;
        }
    },
    
    validateQtyToReceive: function(errors) {
        if (this.get('dblOpenReceive') === 0) {
                errors.add({
                    field: 'dblOpenReceive',
                    message: 'Quantity to Receive must not be equal to zero.'
                });
        }
    },
    
    validateGrossNetUOM: function(errors) {
        if ((this.get('strWeightUOM') === '' && this.get('dblNet') !== 0) || (this.get('strWeightUOM') === '' && this.get('dblGross') !== 0)) {
                errors.add({
                    field: 'strWeightUOM',
                    message: 'Gross/Net UOM must be present since value is specified in Gross or Net.'
                });
        }
    },
    
    validate: function(options) {
        var errors = this.callParent(arguments);

        this.validateSubAndStorageLocations(errors);
        this.validateNetQty(errors);
        this.validateQtyToReceive(errors);
        this.validateGrossNetUOM(errors);
        
        return errors;
    }
});
