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
        { name: 'strReceiptNumber', type: 'string' },
        { name: 'dtmReceiptDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intCurrencyId', type: 'int', allowNull: true },
        { name: 'intSubCurrencyCents', type: 'int', allowNull: true },
        { name: 'intBlanketRelease', type: 'int' },
        { name: 'strVendorRefNo', type: 'string' },
        { name: 'strBillOfLading', type: 'string' },
        { name: 'intShipViaId', type: 'int', allowNull: true },
        { name: 'intShipFromId', type: 'int', allowNull: true },
        { name: 'intReceiverId', type: 'int', allowNull: true },
        { name: 'strVessel', type: 'string' },
        { name: 'intFreightTermId', type: 'int', allowNull: true },
        { name: 'intShiftNumber', type: 'int' },
        { name: 'strCalculationBasis', type: 'string' },
        { name: 'dblUnitWeightMile', type: 'float' },
        { name: 'dblFreightRate', type: 'float' },
        { name: 'dblFuelSurcharge', type: 'float' },
        { name: 'dblInvoiceAmount', type: 'float' },
        { name: 'ysnPrepaid', type: 'boolean' },
        { name: 'ysnInvoicePaid', type: 'boolean' },
        { name: 'intCheckNo', type: 'int', allowNull: true },
        { name: 'dtmCheckDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intTrailerTypeId', type: 'int', allowNull: true },
        { name: 'dtmTrailerArrivalDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmTrailerArrivalTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strSealNo', type: 'string' },
        { name: 'strSealStatus', type: 'string' },
        { name: 'dtmReceiveTime', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dblActualTempReading', type: 'float' },
        { name: 'intShipmentId', type: 'int', allowNull: true },
        { name: 'intTaxGroupId', type: 'int', allowNull: true },
        { name: 'ysnPosted', type: 'boolean' },
        { name: 'intCreatedUserId', type: 'int', allowNull: true },
        { name: 'intEntityId', type: 'int', allowNull: true },
        { name: 'dblClaimableWt', type: 'float' },
        { name: 'strWarehouseRefNo', type: 'string' },
        { name: 'dtmLastFreeWhseDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' }
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