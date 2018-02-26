/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.model.Receipt', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ReceiptItem',
        'Inventory.model.ReceiptCharge',
        'Inventory.model.ReceiptInspection',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptId',

    fields: [
        { name: 'intInventoryReceiptId', type: 'int'},
        { name: 'strReceiptType', type: 'string' },
        { name: 'intSourceType', type: 'int', allowNull: true },
        { name: 'intEntityVendorId', type: 'int', allowNull: true },
        { name: 'intTransferorId', type: 'int', allowNull: true },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'strReceiptNumber', type: 'string', auditKey: true },
        { name: 'dtmReceiptDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intCurrencyId', type: 'int', allowNull: true },
        { name: 'intSubCurrencyCents', type: 'int', allowNull: true },
        { name: 'intBlanketRelease', type: 'int', allowNull: true },
        { name: 'strVendorRefNo', type: 'string' },
        { name: 'strBillOfLading', type: 'string', allowNull: true },
        { name: 'intShipViaId', type: 'int', allowNull: true },
        { name: 'intShipFromId', type: 'int', allowNull: true },
        { name: 'intReceiverId', type: 'int', allowNull: true },
        { name: 'strVessel', type: 'string', allowNull: true  },
        { name: 'intFreightTermId', type: 'int', allowNull: true },
        { name: 'intShiftNumber', type: 'int', allowNull: true },
        //{ name: 'strCalculationBasis', type: 'string' },
        //{ name: 'dblUnitWeightMile', type: 'float' },
        //{ name: 'dblFreightRate', type: 'float' },
        //{ name: 'dblFuelSurcharge', type: 'float' },
        { name: 'dblInvoiceAmount', type: 'float' },
        { name: 'ysnPrepaid', type: 'boolean' },
        { name: 'ysnInvoicePaid', type: 'boolean' },
        { name: 'intCheckNo', type: 'int', allowNull: true },
        { name: 'dtmCheckDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intTrailerTypeId', type: 'int', allowNull: true },
        { name: 'dtmTrailerArrivalDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmTrailerArrivalTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strSealNo', type: 'string', allowNull: true },
        { name: 'strSealStatus', type: 'string', allowNull: true },
        { name: 'dtmReceiveTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dblActualTempReading', type: 'float', allowNull: true },
        { name: 'intShipmentId', type: 'int', allowNull: true },
        { name: 'intTaxGroupId', type: 'int', allowNull: true },
        { name: 'ysnPosted', type: 'boolean' },
        { name: 'intCreatedUserId', type: 'int', allowNull: true },
        { name: 'intEntityId', type: 'int', allowNull: true },
        //{ name: 'dblClaimableWt', type: 'float' },
        { name: 'strWarehouseRefNo', type: 'string', allowNull: true  },
        { name: 'dtmLastFreeWhseDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dblTotalCharge', type: 'float' },
        { name: 'dblTotalChargeTax', type: 'float'},
        { name: 'intItemCount', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'dtmReceiptDate'},
        {type: 'presence', field: 'strReceiptType'},
        {type: 'presence', field: 'intLocationId'},
        {type: 'presence', field: 'intCurrencyId'}
    ],

    validate: function(options) {
        var errors = this.callParent(arguments);
        if (this.get('strReceiptType') === 'Transfer Order') {
            if (iRely.Functions.isEmpty(this.get('intTransferorId'))) {
                errors.add({
                    field: 'intTransferorId',
                    message: 'From Location must be present.'
                })
            }

            if (this.get('intLocationId') === this.get('intTransferorId')) {
                errors.add({
                    field: 'intLocationId',
                    message: 'Value of Location and From Location must be of different.'
                })
            }
        }
        else {
            if (iRely.Functions.isEmpty(this.get('intEntityVendorId'))) {
                errors.add({
                    field: 'intEntityVendorId',
                    message: 'Vendor must be present.'
                })
            }
        }
        return errors;
    }
});