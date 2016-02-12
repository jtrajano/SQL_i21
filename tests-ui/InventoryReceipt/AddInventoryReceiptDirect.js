/**
 * Created by CCallado on 1/22/2016.
 */



StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /* Scenario 1: Open screen and check default controls' state */
        .login('irelyadmin', 'i21by2015', '01')
        .addFunction(function(next){t.diag("Scenario 1: Open screen and check default controls' state"); next();}).wait(100)
        .expandMenu('Inventory').wait(500)
        .openScreen('Inventory Receipts').wait(3000)
        .checkScreenWindow({alias: 'icinventoryreceipt',title: 'Inventory Receipt',collapse: true,maximize: true,minimize: false,restore: false,close: true}).wait(500)
        .checkSearchToolbarButton({new: true, view: true, openselected: false, openall: false, refresh: true, export: false, close: true}).wait(100)
        .clickButton('#btnNew').wait(200)
        .checkScreenShown('icinventoryreceipt')
        .checkControlVisible([
            '#cboReceiptType'
            ,'#cboVendor'
            ,'#txtVendorName'
            ,'#cboLocation'
            ,'#dtmReceiptDate'
            ,'#cboCurrency'
            ,'#txtReceiptNumber'
            ,'#cboSourceType'
            ,'#txtBillOfLadingNumber'
            ,'#cboReceiver'
            ,'#txtVessel'
            ,'#txtBlanketReleaseNumber'
            ,'#cboShipFrom'
            ,'#cboFreightTerms'
            ,'#cboTaxGroup'
            ,'#txtVendorRefNumber'
            ,'#cboShipVia'
            ,'#txtFobPoint'
            ,'#txtShiftNumber'
            ,'#btnInsertInventoryReceipt'
            ,'#btnViewItem'
            ,'#btnQuality'
            ,'#btnTaxDetails'
            ,'#btnRemoveInventoryReceipt'
            ,'#btnGridLayout'
            ,'#btnInsertCriteria'
            ,'#txtFilterGrid'
        ], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkStatusMessage('Ready')


        /* Scenario 2: Add New Direct Inventory Receipt Lotted Item*/
        .addFunction(function(next){t.diag("Scenario 2: Add New Direct Inventory Receipt Lotted Item"); next();}).wait(100)
        .selectComboRowByFilter('#cboReceiptType','Direct',300, 'strReceiptType').wait(100)
        .selectComboRowByFilter('#cboVendor','0001005057',300, 'intEntityVendorId').wait(100)
        .selectComboRowByFilter('#cboLocation','0001 - Fort Wayne',300, 'intLocationId').wait(100)
        .enterData('#txtBillOfLadingNumber','Test - BOL').wait(100)
        .enterData('#txtVessel','Test Vessel').wait(100)
        .selectComboRowByFilter('#cboFreightTerms','Truck',300, 'intFreightTermId').wait(100)
        .selectComboRowByFilter('#cboTaxGroup','IN SST',300, 'intTaxGroupId').wait(100)
        .enterData('#txtVendorRefNumber','Test Vendor Reftest').wait(100)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0,'strItemNo','asdasdasdasds',500,'strItemNo').wait(100)
        .selectGridComboRowByIndex('#grdInventoryReceipt',0,'cboItem',1)






        .done()
});

