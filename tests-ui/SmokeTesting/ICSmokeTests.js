StartTest(function (t) {

    var engine = new iRely.TestEngine(),
        commonSM = Ext.create('SystemManager.CommonSM');


    engine.start(t)

        // LOG IN
        .displayText('Log In').wait(200)
        .addFunction(function (next) {
            commonSM.commonLogin(t, next);
        }).wait(100)
        .waitTillMainMenuLoaded('Login Successful').wait(300)

        //START OF TEST CASE - Opening IC Screens
        .displayText('"======== Scenario 1: Opening Inventory Screens. ========"').wait(300)
        .expandMenu('Inventory').wait(300)
        .markSuccess('Inventory successfully expanded').wait(300)

       
         //Inventory Receipt Screen
        .displayText('"======== 1. Open Inventory Receipt Search Screen Check All Fields ========"').wait(300)
        .openScreen('Inventory Receipts').wait(300)
        .waitTillLoaded('Open Inventory Receipts Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                , view: true
                , openselected: false
                , openall: false
                , refresh: true
                , export: true
                , close: false
            }).wait(200)
        .clickTab('Details').wait(300)
        .waitTillLoaded('Open Inventory Receipts Search Screen Details Tab Successful').wait(200)
        .clickTab('Lots').wait(300)
        .waitTillLoaded('Open Inventory Receipts Search Screen Lots Tab Successful').wait(200)
        .clickTab('Vouchers').wait(300)
        .waitTillLoaded('Open Inventory Receipts Search Screen Vouchers Tab Successful').wait(200)
        .clickTab('Inventory Receipt').wait(300)
        .markSuccess('======== Open Inventory Receipt Search Screen Check All Fields Successful. ========').wait(200)

        //#2
        .displayText('"======== 2. Click New, Check Inventory Receipt Screen Fields.========"').wait(300)
        .clickButton('#btnNew').wait(300)
        .waitTillVisible('icinventoryreceipt','Open New Inventory Receipt Screen Successful',60000).wait(300)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnSearch'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnPrint'
                ,'#btnReceive'
                ,'#btnRecap'
                ,'#btnClose'
                ,'#cboReceiptType'
                ,'#cboSourceType'
                ,'#cboVendor'
                ,'#cboLocation'
                ,'#dtmReceiptDate'
                ,'#cboCurrency'
                ,'#txtReceiptNumber'
                ,'#txtBillOfLadingNumber'
                ,'#cboReceiver'
                ,'#cboFreightTerms'
                ,'#cboTaxGroup'
                ,'#txtVendorRefNumber'
                ,'#cboShipFrom'
                ,'#txtFobPoint'
                ,'#txtShiftNumber'
                ,'#txtBlanketReleaseNumber'
                ,'#cboShipVia'
                ,'#txtVessel'
                ,'#btnInsertInventoryReceipt'
                ,'#btnQuality'
                ,'#btnTaxDetails'
                ,'#btnRemoveInventoryReceipt'
                ,'#btnHelp'
                ,'#btnSupport'
                ,'#btnFieldName'
                ,'#btnEmailUrl'
            ], true).wait(200)
        .checkStatusMessage('Ready')
        .selectComboRowByIndex('#cboReceiptType',3).wait(200)
        .selectComboRowByFilter('#cboVendor', 'ABC Trucking', 500, 'strName', 0).wait(200)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strItemNo', 'CORN', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryReceipt', 0, 'colQtyToReceive', '1000').wait(500)
        .clickButton('#btnRecap').wait(200)
        .waitTillVisible('cmcmrecaptransaction','').wait(500)
        .waitTillLoaded('').wait(500)
        .clickButton('#btnClose').wait(200)
        .markSuccess('======== Click New, Check Inventory Receipt Screen Fields Successful. ========').wait(200)

        .displayText('Open Inventory Receipt Screen Tabs').wait(300)
        .clickTab('#pgeFreightInvoice').wait(300)
        .checkControlVisible(
            [
                '#btnInsertCharge'
                ,'#btnRemoveCharge'
                ,'#btnCalculateCharges'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#colOtherCharge'
                ,'#colOnCostType'
                ,'#colCostMethod'
                ,'#colChargeCurrency'
                ,'#colRate'
                ,'#colChargeUOM'
                ,'#colChargeAmount'
                ,'#colAccrue'
                ,'#colCostVendor'
                ,'#colInventoryCost'
                ,'#colAllocateCostBy'
            ], true).wait(200)
        .clickTab('Incoming Inspection').wait(300)
        .checkControlVisible(
            [
                '#btnSelectAll'
                ,'#btnClearAll'
                ,'#colInspect'
                ,'#colQualityPropertyName'
            ], true).wait(200)
        .clickTab('EDI').wait(300)
        .checkControlVisible(
            [
                '#cboTrailerType'
                ,'#txtTrailerArrivalDate'
                ,'#txtTrailerArrivalTime'
                ,'#txtSealNo'
                ,'#cboSealStatus'
                ,'#txtReceiveTime'
                ,'#txtActualTempReading'
            ], true).wait(200)
        .clickTab('#cfgComments').wait(300)
        .waitTillLoaded('').wait(1000)
        .checkControlVisible(
            [
                '#btnOpenActivity'
                ,'#btnNewEvent'
                ,'#btnNewTask'
                ,'#btnNewComment'
                ,'#btnLogCall'
                ,'#btnSendEmail'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
            ], true).wait(200)
        .clickTab('#pgeAttachments').wait(300)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnAddAttachment'
                ,'#btnOpenAttachment'
                ,'#btnEditAttachment'
                ,'#btnDownloadAttachment'
                ,'#btnDeleteAttachment'
            ], true).wait(200)
        .clickTab('#pgeAuditLog').wait(300)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)
        .clickButton('#btnClose').wait(300)
        .markSuccess('======== Open Inventory Receipt Screen Tabs Successful ========').wait(200)


        //Inventory Shipment Screen
                .displayText('"======== 3. Open Inventory Shipment Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Inventory Shipments').wait(300)
        .waitTillLoaded('Open Inventory Shipment Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                , view: true
                , openselected: false
                , openall: false, refresh: true
                , export: true
                , close: false
            }).wait(200)
        .clickTab('Details').wait(200)
        .waitTillLoaded('Open Inventory Shipment Search Screen Details Tab Successful').wait(200)
        .clickTab('Lots').wait(200)
        .waitTillLoaded('Open Inventory Shipment Search Screen Lots Tab Successful').wait(200)
        .clickTab('Inventory Shipment').wait(200)
        .markSuccess('======== Open Inventory Shipment Search Screen Check All Fields Successful. ========').wait(200)


        //#4
        .displayText('"======== 4. Click New, Check Inventory Shipment Screen Fields. ========"').wait(300)
        .clickButton('#btnNew').wait(300)
        .waitTillVisible('icinventoryshipment','Open New Inventory Shipment Screen Successful').wait(300)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnSearch'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnPrint'
                ,'#btnPrintBOL'
                ,'#btnShip'
                ,'#btnRecap'
                ,'#btnCustomer'
                ,'#btnWarehouseInstruction'
                ,'#btnClose'
                ,'#cboOrderType'
                ,'#cboSourceType'
                ,'#cboCustomer'
                ,'#dtmShipDate'
                ,'#txtReferenceNumber'
                ,'#dtmRequestedArrival'
                ,'#cboFreightTerms'
                ,'#txtShipmentNo'
                ,'#cboShipFromAddress'
                ,'#txtShipFromAddress'
                ,'#cboShipToAddress'
                ,'#txtShipToAddress'
                ,'#txtDeliveryInstructions'
                ,'#txtComments'
                ,'#btnHelp'
                ,'#btnSupport'
                ,'#btnFieldName'
                ,'#btnEmailUrl'
            ], true).wait(200)
        .checkStatusMessage('Ready').wait(200)
        .clickTab('#tabShippingCompany').wait(200)
        .checkControlVisible(['#txtBOLNo', '#txtProNumber', '#cboShipVia', '#txtDriverID','#txtVesselVehicle','#txtSealNumber'], true).wait(200)
        .clickTab('#tabDelivery').wait(200)
        .checkControlVisible(
            [
                '#txtAppointmentTime'
                ,'#dtmDelivered'
                ,'#txtDepartureTime'
                ,'#dtmFreeTime'
                ,'#txtArrivalTime'
                ,'#txtReceivedBy'
                ,'#btnInsertItem'
                ,'#btnViewItem'
                ,'#btnQuality'
                ,'#btnRemoveItem'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)
        .checkControlVisible([], true).wait(200)
        .displayText('Open Inventory Shipment Screen Tabs Check All Fields').wait(200)
        .clickTab('#pgeChargesInvoice').wait(200)
        .checkControlVisible(
            [
                '#btnInsertCharge'
                ,'#btnRemoveCharge'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)
        .clickTab('#pgeComments').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnOpenActivity'
                ,'#btnNewEvent'
                ,'#btnNewTask'
                ,'#btnNewComment'
                ,'#btnLogCall'
                ,'#btnSendEmail'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
            ], true).wait(200)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(200)
        .clickTab('#pgeAttachments').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnAddAttachment'
                ,'#btnOpenAttachment'
                ,'#btnEditAttachment'
                ,'#btnDownloadAttachment'
                ,'#btnDeleteAttachment'
            ], true).wait(200)
        .clickTab('#pgeAuditLog').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(200)

        .clickButton('#btnClose').wait(200)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(300)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventoryshipment').wait(100)
        .markSuccess('======== Click New, Check Inventory Shipment Screen Fields Successful. ========').wait(200)


        //Inventory Transfers Screen
        .displayText('"======== 5. Open Inventory Transfers Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Inventory Transfers').wait(300)
        .waitTillLoaded('Open Inventory Transfer Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                , view: true
                , openselected: false
                , openall: false
                , refresh: true
                , export: true
                , close: false
            }).wait(200)
        .clickTab('Details').wait(200)
        .waitTillLoaded('Open Inventory Transfer Search Screen Details Tab Successful').wait(200)
        .clickTab('Inventory Transfer').wait(200)
        .markSuccess('======== Open Inventory Transfers Search Screen Check All Fields Successful. ========').wait(200)


        //#6
        .displayText('"======== 6. Click New, Check Inventory Transfer Screen Fields. ========"')
        .clickButton('#btnNew').wait(300)
        .waitTillVisible('icinventorytransfer','Open New Inventory Transfer Screen Successful').wait(300)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnSearch'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnPrint'
                ,'#btnPost'
                ,'#btnRecap'
                ,'#btnClose'
                ,'#txtTransferNumber'
                ,'#dtmTransferDate'
                ,'#cboTransferType'
                ,'#cboSourceType'
                ,'#cboTransferredBy'
                ,'#cboFromLocation'
                ,'#cboToLocation'
                ,'#chkShipmentRequired'
                ,'#cboStatus'
                ,'#txtDescription'
                ,'#btnAddItem'
                ,'#btnViewItem'
                ,'#btnRemoveItem'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnHelp'
                ,'#btnSupport'
                ,'#btnFieldName'
                ,'#btnEmailUrl'
            ], true).wait(200)

        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnOpenActivity'
                ,'#btnNewEvent'
                ,'#btnNewTask'
                ,'#btnNewComment'
                ,'#btnLogCall'
                ,'#btnSendEmail'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)

        .clickTab('#pgAttachments').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnAddAttachment'
                ,'#btnOpenAttachment'
                ,'#btnEditAttachment'
                ,'#btnDownloadAttachment'
                ,'#btnDeleteAttachment'
            ], true).wait(200)
        .clickTab('#pgeAuditLog').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(200)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(300)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventorytransfer').wait(100)
        .markSuccess('======== Click New, Check Inventory Transfer Screen Fields Successful. ========').wait(200)


        //Inventory Adjustments Screen
                .displayText('"======== 7. Open Inventory Adjustments Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Inventory Adjustments').wait(300)
        .waitTillLoaded('Open Inventory Adjustments Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                , view: true
                , openselected: false
                , openall: false
                , refresh: true
                , export: true
                , close: false
            }).wait(200)
        .clickTab('Details').wait(200)
        .waitTillLoaded('Open Inventory Adjustments Search Screen Details Tab Successful').wait(200)
        .clickTab('Inventory Adjustment').wait(200)
        .markSuccess('======== Open Inventory Adjustments Search Screen Check All Fields Successful. ========').wait(200)

        //#8
        .displayText('"======== 8. Click New, Check Inventory Adjustment Screen Fields. ========"')
        .clickButton('#btnNew').wait(300)
        .waitTillVisible('icinventoryadjustment','Open New Inventory Adjustment Screen Successful').wait(300)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnSearch'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnPrint'
                ,'#btnPost'
                ,'#btnRecap'
                ,'#btnClose'
                ,'#cboLocation'
                ,'#dtmDate'
                ,'#cboAdjustmentType'
                ,'#txtAdjustmentNumber'
                ,'#txtDescription'
                ,'#btnAddItem'
                ,'#btnViewItem'
                ,'#btnRemoveItem'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnHelp'
                ,'#btnSupport'
                ,'#btnFieldName'
                ,'#btnEmailUrl'
            ], true).wait(200)
        .clickTab('#pgeComments').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnOpenActivity'
                ,'#btnNewEvent'
                ,'#btnNewTask'
                ,'#btnNewComment'
                ,'#btnLogCall'
                ,'#btnSendEmail'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)

        .clickTab('#pgeAttachments').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnAddAttachment'
                ,'#btnOpenAttachment'
                ,'#btnEditAttachment'
                ,'#btnDownloadAttachment'
                ,'#btnDeleteAttachment'
            ], true).wait(200)
        .clickTab('#pgeAudit').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnInsertCriteria'
                , '#txtFilterGrid'
            ], true).wait(200)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(200)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(300)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventoryadjustment').wait(100)
        .markSuccess('======== Click New, Check Inventory Adjustment Screen Fields Successful. ========').wait(200)


        //Inventory Count Screen
                .displayText('"======== 9. Open Inventory Count Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Inventory Count').wait(300)
        .waitTillLoaded('Open Inventory Count Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                , view: true
                , openselected: false
                , openall: false
                , refresh: true
                , export: true
                , close: false
            }).wait(200)
        .markSuccess('Open Inventory Count Search Screen Check All Fields Successful.').wait(200)

        //#10
        .displayText('"======== 10. Click New, Check Inventory Count Screen Fields. ========"')
        .clickButton('#btnNew').wait(300)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnPrintCountSheets'
                ,'#btnClose'
                ,'#cboLocation'
                ,'#cboCategory'
                ,'#cboCommodity'
                ,'#cboCountGroup'
                ,'#dtpCountDate'
                ,'#txtCountNumber'
                ,'#cboSubLocation'
                ,'#cboStorageLocation'
                ,'#txtDescription'
                ,'#btnFetch'
                ,'#chkIncludeZeroOnHand'
                ,'#chkIncludeOnHand'
                ,'#chkScannedCountEntry'
                ,'#chkCountByLots'
                ,'#chkCountByPallets'
                ,'#chkRecountMismatch'
                ,'#chkExternal'
                ,'#chkRecount'
                ,'#txtReferenceCountNo'
                ,'#cboStatus'
                ,'#btnInsert'
                ,'#btnRemove'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)

        .clickTab('#pgeComments').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnOpenActivity'
                ,'#btnNewEvent'
                ,'#btnNewTask'
                ,'#btnNewComment'
                ,'#btnLogCall'
                ,'#btnSendEmail'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)
        .clickTab('#pgeAttachments').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnAddAttachment'
                ,'#btnOpenAttachment'
                ,'#btnEditAttachment'
                ,'#btnDownloadAttachment'
                ,'#btnDeleteAttachment'
            ], true).wait(200)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(200)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(200)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(300)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventorycount').wait(300)


        //#10.1
        .displayText('"======== 10.1. Open New Inventory Count Group Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnCountGroup').wait(200)
        .waitTillVisible('inventorycountgroup','Open New Iinventorycountgroup Screen Successful').wait(300)
        .checkControlVisible(
            [
                '#txtCountGroup'
                ,'#txtCountsPerYear'
                ,'#chkIncludeOnHand'
                ,'#chkScannedCountEntry'
                ,'#chkCountByLots'
                ,'#chkCountByPallets'
                ,'#chkRecountMismatch'
                ,'#chkExternal'
            ], true).wait(200)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('inventorycountgroup').wait(300)
        .markSuccess('Click New, Check Inventory Count Screen Fields Successful.').wait(200)


        //Storage Measurement Reading Screen
                .displayText('"======== 11. Open Storage Measurement Reading Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Storage Measurement Reading').wait(300)
        .waitTillLoaded('Open Storage Measurement Reading Screen Successful').wait(200)
        .markSuccess('======== Open Storage Measurement Reading Search Screen Check All Fields Successful. ========').wait(200)

        //#12
        .displayText('"======== 12. Click New, Storage Measurement Reading Screen Check All Fields. ========"').wait(200)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnSearch'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#cboLocation'
                ,'#dtmDate'
                ,'#txtReadingNumber'
                ,'#btnInsert'
                ,'#btnRemove'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnHelp'
                ,'#btnSupport'
                ,'#btnFieldName'
                ,'#btnEmailUrl'
            ], true).wait(200)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded().wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(300)
        .clickMessageBoxButton('no').wait(300)
        .markSuccess('======== Click New, Check Storage Measurement Reading Screen Fields Successful. ========').wait(200)


        //Item Screen
                .displayText('"======== 13. Open Items Search Screen Check All Fields ========"').wait(200)
        .openScreen('Items').wait(300)
        .waitTillLoaded('Open Items Search Screen Successful').wait(200)
        .clickTab('Locations').wait(200)
        .waitTillLoaded('Open Items Search Screen Locations Tab Successful').wait(200)
        .clickTab('Pricing').wait(200)
        .waitTillLoaded('Open Items Search Screen Pricing Tab Successful').wait(200)
        .clickTab('Item').wait(200)
        .waitTillLoaded('').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                , view: true
                , openselected: false
                , openall: false
                , refresh: true
                , export: true
                , close: false
            }).wait(100)
        .markSuccess('======== Open Items Search Screen Check All Fields Successful. ========').wait(200)

        //#14
        .displayText('"======== 14. Click New, Items Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('icitem','Open New Item Screen Successful').wait(200)
        .checkScreenShown('icitem').wait(200)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnFind'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnDuplicate'
                ,'#btnClose'
                ,'#txtItemNo'
                ,'#cboType'
                ,'#txtShortName'
                ,'#txtDescription'
                ,'#cboManufacturer'
                ,'#cboStatus'
                ,'#cboCommodity'
                ,'#cboLotTracking'
                ,'#cboBrand'
                ,'#txtModelNo'
                ,'#cboCategory'
                ,'#cboTracking'
                ,'#btnInsertUom'
                ,'#btnDeleteUom'
                ,'#btnLoadUOM'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#colDetailDimensionUOM'
                ,'#colDetailVolume'
                ,'#colDetailWeight'
                ,'#colDetailWeightUOM'
                ,'#colDetailMaxQty'
                ,'#btnHelp'
                ,'#btnSupport'
                ,'#btnFieldName'
                ,'#btnEmailUrl'

            ], true).wait(200)
        .checkControlVisible([], true).wait(200)
        .checkControlVisible([], true).wait(200)
        .checkControlVisible([], true).wait(200)
        .checkControlVisible([], true).wait(200)
        .checkStatusMessage('Ready')

        //Setup Tabs
        .clickTab('#cfgSetup').wait(200)
        .checkControlVisible(
            [
                '#btnAddRequiredAccounts'
                ,'#btnInsertGlAccounts'
                ,'#btnDeleteGlAccounts'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)

        .clickTab('#cfgLocation').wait(200)
        .checkControlVisible(
            [
                '#btnAddLocation'
                ,'#btnAddMultipleLocation'
                ,'#btnEditLocation'
                ,'#btnDeleteLocation'
                ,'#cboCopyLocation'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
            ], true).wait(200)

        .clickTab('#cfgSales').wait(200)
        .checkControlVisible(
            [
                '#chkStockedItem'
                ,'#chkDyedFuel'
                ,'#cboBarcodePrint'
                ,'#chkMsdsRequired'
                ,'#txtEpaNumber'
                ,'#chkInboundTax'
                ,'#chkOutboundTax'
                ,'#chkRestrictedChemical'
                ,'#chkFuelItem'
                ,'#pnlRins'
                ,'#cboFuelInspectionFee'
                ,'#cboRinRequired'
                ,'#cboFuelCategory'
                ,'#txtPercentDenaturant'
                ,'#pnlFeed'
                ,'#chkTonnageTax'
                ,'#chkLoadTracking'
                ,'#txtMixOrder'
                ,'#chkHandAddIngredients'
                ,'#cboMedicationTag'
                ,'#cboIngredientTag'
                ,'#txtVolumeRebateGroup'
                ,'#cboPhysicalItem'
                ,'#chkExtendOnPickTicket'
                ,'#chkExportEdi'
                ,'#chkHazardMaterial'
                ,'#chkMaterialFee'
                ,'#chkAutoBlend'
                ,'#txtUserGroupFee'
                ,'#txtWgtTolerance'
                ,'#txtOverReceiveTolerance'
                ,'#txtMaintenanceCalculationMethod'
                ,'#txtMaintenanceRate'
            ], true).wait(200)
        .checkControlVisible([], true).wait(200)
        .checkControlVisible([], true).wait(200)
        .checkControlVisible([], true).wait(200)

        .clickTab('#cfgPOS').wait(200)
        .checkControlVisible(
            [
                '#pnlGeneral'
                ,'#txtNacsCategory'
                ,'#cboWicCode'
                ,'#chkReceiptCommentReq'
                ,'#cboCountCode'
                ,'#pnlInventorySetup'
                ,'#chkLandedCost'
                ,'#txtLeadTime'
                ,'#chkTaxable'
                ,'#txtKeywords'
                ,'#txtCaseQty'
                ,'#dtmDateShip'
                ,'#txtTaxExempt'
                ,'#chkDropShip'
                ,'#pnlCommissionDetail'
                ,'#chkCommissionable'
                ,'#chkSpecialCommission'
                ,'#grdCategory'
                ,'#btnInsertCategories'
                ,'#btnDeleteCategories'
                ,'#colPOSCategoryName'
                ,'#grdServiceLevelAgreement'
                ,'#btnInsertSLA'
                ,'#btnDeleteSLA'
                ,'#colPOSSLAContract'
                ,'#colPOSSLAPrice'
                ,'#colPOSSLAWarranty'
            ], true).wait(200)

        .clickTab('#cfgContract').wait(200)
        .checkControlVisible(
            [
                '#btnInsertContractItem'
                ,'#btnDeleteContractItem'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#grdContractItem'
                ,'#colContractLocation'
                ,'#colContractItemName'
                ,'#colContractOrigin'
                ,'#colContractGrade'
                ,'#colContractGradeType'
                ,'#colContractGarden'
                ,'#colContractYield'
                ,'#colContractTolerance'
                ,'#colContractFranchise'
                ,'#grdDocumentAssociation'
                ,'#btnInsertDocumentAssociation'
                ,'#btnDeleteDocumentAssociation'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#colDocument'
                ,'#grdCertification'
                ,'#btnInsertCertification'
                ,'#btnDeleteCertification'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#colCertification'
            ], true).wait(200)

        .clickTab('#cfgXref').wait(200)
        .waitTillLoaded('').wait(100)
        .checkControlVisible(
            [
                '#grdCustomerXref'
                ,'#colCustomerXrefLocation'
                ,'#colCustomerXrefCustomer'
                ,'#colCustomerXrefProduct'
                ,'#colCustomerXrefDescription'
                ,'#colCustomerXrefPickTicketNotes'
            ], true).wait(200)

        .clickTab('#cfgMotorFuelTax').wait(200)
        .waitTillLoaded('').wait(100)
        .checkControlVisible(
            [
                '#grdCustomerXref'
                ,'#colCustomerXrefLocation'
                ,'#colCustomerXrefCustomer'
                ,'#colCustomerXrefProduct'
                ,'#colCustomerXrefDescription'
                ,'#colCustomerXrefPickTicketNotes'
            ], true).wait(200)

        .clickTab('#cfgOthers').wait(200)
        .waitTillLoaded('').wait(100)
        .checkControlVisible(
            [
                '#txtInvoiceComments'
                ,'#txtPickListComments'
                ,'#chkTankRequired'
                , '#chkAvailableForTm'
                , '#txtDefaultPercentFull'
                ,'#cboPatronage'
                ,'#cboPatronageDirect'
            ], true).wait(200)

        .clickTab('#cfgPricing').wait(200)
        .waitTillLoaded('').wait(100)
        .checkControlVisible(
            [
                '#grdPricingLevel'
                ,'#btnInsertPricingLevel'
                ,'#btnDeletePricingLevel'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)

        .clickTab('Promotional Pricing')
        .waitTillLoaded('').wait(100)

        .clickTab('#cfgStock').wait(200)
        .waitTillLoaded('').wait(100)
        .checkControlVisible(
            [
                '#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)

        .clickTab('#pgeComments').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnOpenActivity'
                , '#btnNewEvent'
                , '#btnNewTask'
                , '#btnNewComment'
                , '#btnLogCall'
                , '#btnSendEmail'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
            ], true).wait(200)
        .clickTab('#pgeAttachments').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnAddAttachment'
                ,'#btnOpenAttachment'
                ,'#btnEditAttachment'
                ,'#btnDownloadAttachment'
                ,'#btnDeleteAttachment'
            ], true).wait(200)
        .clickTab('#pgeAuditLog').wait(200)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(
            [
                '#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(200)
        .clickMessageBoxButton('no').wait(200)
        .checkIfScreenClosed('icitem').wait(200)
        .waitTillLoaded('').wait(200)
        .displayText('Checking item Screen Fields Successful').wait(200)
        .markSuccess('======== Click New, Check Items Screen Fields Successful. ========').wait(200)


        //Commodities Screen
                .displayText('"======== 15. Open Commodities Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Commodities').wait(300)
        .waitTillLoaded('Open Commodities Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                , view: true
                , openselected: false
                , openall: false
                , refresh: true
                , export: true
                , close: false
            }).wait(100)
        .markSuccess('Open Commodities Search Screen Check All Fields Successful.').wait(200)


        //#16
        .displayText('"======== 16. Click New, Commodity Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('iccommodity','Open New Item Screen Successful').wait(200)
        .checkScreenShown('iccommodity').wait(200)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnFind'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#txtCommodityCode'
                ,'#txtDescription'
                ,'#chkExchangeTraded'
                ,'#txtDecimalsOnDpr'
                ,'#cboFutureMarket'
                ,'#txtConsolidateFactor'
                ,'#chkFxExposure'
                ,'#txtPriceChecksMin'
                ,'#txtPriceChecksMax'
                ,'#dtmCropEndDateCurrent'
                ,'#dtmCropEndDateNew'
                ,'#txtEdiCode'
                ,'#cboDefaultScheduleStore'
                ,'#cboDefaultScheduleDiscount'
                ,'#cboScaleAutoDistDefault'
                ,'#btnDeleteUom'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)

        .clickTab('#pgeAttributes').wait(200)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity').wait(100)
        .displayText('Checking Commodity Screen Fields Successful').wait(200)
        .markSuccess('======== Click New, Check Commodity Screen Fields Successful. ========').wait(200)


        //Categories Screen
                .displayText('"======== 17. Open Categories Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Categories').wait(300)
        .waitTillLoaded('Open Categories Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                , view: true
                , openselected: false
                , openall: false
                , refresh: true
                , export: true
                , close: false
            }).wait(100)
        .markSuccess('Open Categories Search Screen Check All Fields Successful.').wait(200)


        //#18
        .displayText('"======== 18. Click New, Category Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnNew').wait(200)
        .waitTillLoaded('Open new Category Screen Successful')
        .checkScreenShown('iccategory').wait(200)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnFind'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#txtCategoryCode'
                ,'#txtDescription'
                ,'#cboInventoryType'
                ,'#cboLineOfBusiness'
                ,'#cboCostingMethod'
                ,'#cboInventoryValuation'
                ,'#txtGlDivisionNumber'
                ,'#chkSalesAnalysisByTon'
                ,'#txtStandardQty'
                ,'#cboStandardUOM'
                ,'#btnInsertTax'
                ,'#btnDeleteTax'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnDeleteUom'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
            ], true).wait(200)

        .clickTab('#pgeLocations').wait(200)
        .checkControlVisible(
            [
                '#btnAddLocation'
                ,'#btnEditLocation'
                ,'#btnDeleteLocation'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
            ], true).wait(200)
        .clickTab('#pgGLAccounts').wait(200)
        .checkControlVisible(
            [
                '#btnAddRequired'
                ,'#btnDeleteGlAccounts'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
            ], true).wait(200)
        .clickTab('#pgeVendorCategory').wait(200)
        .checkControlVisible(
            [
                '#btnDeleteVendorCategoryXref'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnMaximizeGrid'
            ], true).wait(200)
        .clickTab('#pgeManufacturing').wait(200)
        .checkControlVisible(
            [
                '#txtERPItemClass'
                ,'#txtLifeTime'
                ,'#txtBOMItemShrinkage'
                ,'#txtBOMItemUpperTolerance'
                ,'#txtBOMItemLowerTolerance'
                ,'#chkScaled'
                ,'#chkOutputItemMandatory'
                ,'#txtConsumptionMethod'
                ,'#txtBOMItemType'
                ,'#txtShortName'
                ,'#txtLaborCost'
                ,'#txtOverHead'
                ,'#txtPercentage'
                ,'#txtCostDistributionMethod'
                ,'#chkSellable'
                ,'#chkYieldAdjustment'
                ,'#chkTrackedInWarehouse'
            ], true).wait(200)
        .checkControlVisible([ ], true).wait(200)
        .displayText('Check Category Screen Fields Successful')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccategory').wait(100)
        .displayText('Checking Category Screen Fields Successful').wait(200)
        .markSuccess('======== Click New, Check Category Screen Fields Successful. ========').wait(200)


        //#Fuel Types Screen
                .displayText('"======== 19. Open Fuel Types Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Fuel Types').wait(300)
        .waitTillLoaded('Open Fuel Types Search Screen Successful').wait(200)
        .markSuccess('Open Fuel Types Search Screen Check All Fields Successful.').wait(200)


        //#20
        .displayText('"======== 20. Click New, Fuel Types Screen Check All Fields. ========"').wait(200)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnSearch'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#cboFuelCategory'
                ,'#cboFeedStock'
                ,'#txtBatchNo'
                ,'#txtEndingRinGallonsForBatch'
                ,'#txtEquivalenceValue'
                ,'#cboFuelCode'
                ,'#cboProductionProcess'
                ,'#cboFeedStockUom'
                ,'#txtFeedStockFactor'
                ,'#chkRenewableBiomass'
                ,'#txtPercentOfDenaturant'
                ,'#btnHelp'
                ,'#btnSupport'
                ,'#btnFieldName'
                ,'#btnEmailUrl'
            ], true).wait(200)

        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(200)

        //#20.1
        .displayText('"======== 10.1. Open New Fuel Category  Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnFuelCategory').wait(200)
        .waitTillVisible('icfuelcategory','Open New Fuel Category Screen Successful').wait(300)
        .checkControlVisible(
            [
                '#btnSave'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#btnInsert'
                ,'#btnDelete'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#colRinFuelCategoryCode'
                ,'#colDescription'
                ,'#colEquivalenceValue'
            ], true).wait(200)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('icfuelcategory').wait(300)
        .markSuccess('Check New Fuel Category Screen Fields Successful.').wait(200)

        //#20.2
        .displayText('"======== 20.2. Open New Feed Stock  Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnFeedStock').wait(200)
        .waitTillVisible('icfeedstockcode','Open New Feed Stock Screen Successful').wait(300)
        .checkControlVisible(
            [
                '#btnSave'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#btnInsert'
                ,'#btnDelete'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#colRinFeedStockCode'
                ,'#colDescription'
            ], true).wait(200)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('icfeedstockcode').wait(300)
        .markSuccess('Check New Feed Stock Screen Fields Successful.').wait(200)

        //#20.3
        .displayText('"======== 20.3. Open New Fuel Code  Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnFuelCode').wait(200)
        .waitTillVisible('icfuelcode','Open New Fuel Code Screen Successful').wait(300)
        .checkControlVisible(
            [
                '#btnSave'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#btnInsert'
                ,'#btnDelete'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#colRinFuelCode'
                ,'#colDescription'
            ], true).wait(200)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('btnFuelCode').wait(300)
        .markSuccess('Check New Fuel Code Screen Fields Successful.').wait(200)

        //#20.4
        .displayText('"======== 20.4. Open New Production Process  Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnProductionProcess').wait(200)
        .waitTillVisible('icprocesscode','Open New Production Process Screen Successful').wait(300)
        .checkControlVisible(
            [
                '#btnSave'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#btnInsert'
                ,'#btnDelete'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#colRinProcessCode'
                ,'#colDescription'
            ], true).wait(200)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('btnFuelCode').wait(300)
        .markSuccess('Check New Production Process Screen Fields Successful.').wait(200)

        //#20.5
        .displayText('"======== 20.4. Open New Feed Stock UOM  Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnFeedStockUOM').wait(200)
        .waitTillVisible('icfeedstockuom','Open New Production Process Screen Successful').wait(300)
        .checkControlVisible(
            [
                '#btnSave'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#btnInsert'
                ,'#btnDelete'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#colUOM'
                ,'#colRinFeedStockUOMCode'
            ], true).wait(200)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('btnFuelCode').wait(300)
        .markSuccess('Check New Feed Stock UOM  Screen Fields Successful.').wait(200)
        .markSuccess('"======== Click New, Check Fuel Types Screen Fields Successful. ========"').wait(200)


        //#Inventory UOM's Screen
        .displayText('"======== 21. Open Inventory UOMs Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Inventory UOM').wait(300)
        .waitTillLoaded('Open Fuel Types Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                ,view: true
                ,openselected: false
                ,openall: false
                ,refresh: true
                ,export: true
                , close: false
            }).wait(100)
        .markSuccess('======== Open Inventory UOMs Search Screen Check All Fields Successful. ========').wait(200)


        //#22
        .displayText('"======== 22. Click New, Inventory UOM Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnNew').wait(200)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#txtUnitMeasure'
                ,'#txtSymbol'
                ,'#cboUnitType'
                ,'#grdConversion'
                ,'#btnInsertConversion'
                ,'#btnDeleteConversion'
                ,'#btnGridLayout'
                ,'#btnInsertCriteria'
                ,'#txtFilterGrid'
                ,'#btnHelp'
                ,'#btnSupport'
                ,'#btnFieldName'
                ,'#btnEmailUrl'
            ], true).wait(200)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(200)
        .markSuccess('======== Click New, Check Inventory UOM Screen Fields Successful. ========').wait(200)


        //Storage Locations Screen
        .displayText('"======== 23. Open Storage Locations Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Storage Locations').wait(300)
        .waitTillLoaded('Open Fuel Types Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: true
                ,view: true
                ,openselected: false
                ,openall: false
                ,refresh: true
                ,export: true
                ,close: false
            }).wait(100)
        .markSuccess('======== Open IOpen Storage Locations Search Screen Check All Fields Successful. ========').wait(200)


        //#24
        .displayText('"======== 24. Click New, Open Storage Locations Screen Check All Fields. ========"').wait(200)
        .clickButton('#btnNew').wait(200)
        .checkControlVisible(
            [
                '#btnNew'
                ,'#btnSave'
                ,'#btnSearch'
                ,'#btnDelete'
                ,'#btnUndo'
                ,'#btnClose'
                ,'#txtName'
                ,'#txtDescription'
                ,'#cboUnitType'
                ,'#cboLocation'
                ,'#cboSubLocation'
                ,'#cboParentUnit'
                ,'#cboRestrictionType'
                ,'#txtAisle'
                ,'#txtMinBatchSize'
                ,'#txtBatchSize'
                ,'#cboBatchSizeUom'
                ,'#chkAllowConsume'
                ,'#chkAllowMultipleItems'
                ,'#chkAllowMultipleLots'
                ,'#chkMergeOnMove'
                ,'#chkCycleCounted'
                ,'#chkDefaultWarehouseStagingUnit'
                ,'#cboCommodity'
                ,'#txtPackFactor'
                ,'#txtEffectiveDepth'
                ,'#txtUnitsPerFoot'
                ,'#txtResidualUnits'
                ,'#txtSequence'
                ,'#chkActive'
                ,'#txtXPosition'
                ,'#txtYPosition'
                ,'#txtZPosition'
                ,'#btnHelp'
                ,'#btnSupport'
                ,'#btnFieldName'
                ,'#btnEmailUrl'
            ], true).wait(200)
        .checkStatusMessage('Ready').wait(200)
        .clickTab('#pgeMeasurement').wait(200)
        .checkControlVisible(
            [
                '#btnAddMeasurement'
                ,'#btnDeleteMeasurement'
                ,'#colMeasurement'
                ,'#colReadingPoint'
                ,'#colActive'
            ], true).wait(200)
        .clickTab('#pgeItemCategoriesAllowed').wait(200)
        .checkControlVisible(
            [
                '#btnDeleteItemCategoryAllowed'
                ,'#colCategory'
            ], true).wait(200)
        .clickTab('#pgeContainer').wait(200)
        .checkControlVisible(
            [
                '#btnDeleteContainer'
                ,'#colContainer'
                ,'#colExternalSystem'
                ,'#colContainerType'
            ], true).wait(200)
        .clickTab('#pgeSKU').wait(200)
        .checkControlVisible(
            [
                '#btnDeleteSKU'
                ,'#colItem'
                ,'#colSku'
                ,'#colQty'
                ,'#colContainer'
                ,'#colLotSerial'
                ,'#colExpiration'
                ,'#colStatus'
            ], true).wait(200)
        .clickButton('#btnClose').wait(200)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(200)
        .clickMessageBoxButton('no').wait(100)
        .markSuccess('======== Click New, Check Open Storage Screen Fields Successful. ========').wait(200)


        //Stock Details Screen
                .displayText('"======== 25. Open Stock Details Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Stock Details').wait(300)
        .waitTillLoaded('Open Stock Details Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
        {
            new: false
            ,view: false
            ,open: false
            ,openselected: false
            ,openall: false
            ,refresh: true
            ,export: true
            ,close: false
        }).wait(200)
        .clickTab('Storage Bins').wait(200)
        .waitTillLoaded('Open Stock Details Search Screen Details Tab Successful').wait(200)
        .markSuccess('======== Open Stock Details Search Screen Check All Fields Successful. ========').wait(200)


        //Lot Details Screen
        .displayText('"======== 26. Open Lot Details Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Lot Details').wait(300)
        .waitTillLoaded('Open Lot Details Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
        {
            new: false
            ,view: false
            ,open: false
            ,openselected: false
            ,openall: false
            ,refresh: true
            ,export: true
            ,close: false
        }).wait(200)
        .markSuccess('======== Open Lot Details Search Screen Check All Fields Successful. ========').wait(200)


        //Inventory Valuation Screen
        .displayText('"======== 27. Open Inventory Valuation Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Inventory Valuation').wait(300)
        .waitTillLoaded('Open Lot Details Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
        {
            new: false
            ,view: false
            ,open: false
            ,openselected: false
            ,openall: false
            ,refresh: true
            ,export: true
            ,close: false
        }).wait(200)
        .markSuccess('======== Open Inventory Valuation Search Screen Check All Fields Successful. ========').wait(200)


        //Inventory Valuation Screen
        .displayText('"======== 28. Open Inventory Valuation Summary Search Screen Check All Fields. ========"').wait(200)
        .openScreen('Inventory Valuation Summary').wait(300)
        .waitTillLoaded('Open Lot Details Search Screen Successful').wait(200)
        .checkSearchToolbarButton(
            {
                new: false
                ,view: false
                ,open: false
                ,openselected: false
                ,openall: false
                ,refresh: true
                ,export: true
                ,close: false
            }).wait(200)
        .markSuccess('Open Inventory Valuation Summary Search Screen Check All Fields Successful.').wait(200)
        .markSuccess('"======== Open Inventory Screens and Checking Fields done. ========="')



        //ADD MAINTENANCE SCREENS - IC Add Maintenance Records
        .displayText('====== Scenario 1. Add Item ======').wait(300)
        //#1.1 Add Non Lotted Inventory Item
        .openScreen('Items').wait(500)
        .waitTillLoaded('Open Items Search Screen Successful')
        .clickButton('#btnNew').wait(500)
        .waitTillVisible('icitem', 'Open New Item Screen Successful').wait(500)
        .checkScreenShown('icitem').wait(200)
        .checkStatusMessage('Ready')

        .enterData('#txtItemNo', 'NLTI - 05').wait(200)
        //.selectComboRowByIndex('#cboType',0).wait(200)
        .enterData('#txtDescription', 'NLTI - 05').wait(200)
        .selectComboRowByFilter('#cboCategory', 'Grains', 500, 'cboCategory',0).wait(500)
        .selectComboRowByFilter('#cboCommodity', 'Corn', 500, 'strCommodityCode',0).wait(500)
        .selectComboRowByIndex('#cboLotTracking', 2).wait(500)

        .clickButton('#btnLoadUOM').wait(300)
        .waitTillLoaded('Add UOM Successful')

        .clickTab('#cfgSetup').wait(100)
        .clickButton('#btnAddRequiredAccounts').wait(100)
        .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
        .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
        .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
        .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
        .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
        .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
        .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Auto-Variance').wait(100)

        .selectGridComboRowByFilter('#grdGlAccounts', 0, 'strAccountId', '21000-0000-000', 400, 'strAccountId').wait(100)
        .addFunction(function (next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grdGlAccounts = win.down('#grdGlAccounts');
                grdGlAccounts.editingPlugin.completeEdit();
            }
            next();
        }).wait(1000)
        .selectGridComboRowByFilter('#grdGlAccounts', 1, 'strAccountId', '16000-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 2, 'strAccountId', '50000-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 3, 'strAccountId', '40010-0001-006', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 4, 'strAccountId', '16050-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 5, 'strAccountId', '16040-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 6, 'strAccountId', '16010-0000-000', 400, 'strAccountId').wait(100)
        .markSuccess('======== Setup GL Accounts Successful ========').wait(500)

        .clickTab('#cfgLocation').wait(300)
        .clickButton('#btnAddLocation').wait(100)
        .waitTillVisible('icitemlocation', 'Add Item Location Screen Displayed', 60000).wait(500)
        .selectComboRowByFilter('#cboSubLocation', 'Raw Station', 600, 'intSubLocationId',0).wait(100)
        .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 600, 'intStorageLocationId',0).wait(100)
        .selectComboRowByFilter('#cboIssueUom', 'Bushels', 600, 'strUnitMeasure').wait(500)
        .selectComboRowByFilter('#cboReceiveUom', 'Bushels', 600, 'strUnitMeasure').wait(500)
        .selectComboRowByIndex('#cboNegativeInventory', 1).wait(500)
        .clickButton('#btnSave').wait(300)
        .checkStatusMessage('Saved').wait(300)
        .clickButton('#btnClose').wait(300)

        .clickTab('#cfgOthers').wait(500)
        .clickCheckBox('#chkTankRequired', true).wait(300)
        .clickCheckBox('#chkAvailableForTm', true).wait(300)

        .clickTab('#cfgPricing').wait(300)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '10').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '10').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '10').wait(300)
        //.selectGridComboRowByFilter('#grdPricing', 0, 'strPricingMethod', 'Markup Standard Cost', 400, 'strPricingMethod').wait(100)
        .selectGridComboRowByIndex('#grdPricing', 0, 'strPricingMethod',2, 'strPricingMethod').wait(100)
        .enterGridData('#grdPricing', 0, 'dblAmountPercent', '40').wait(300)
        .checkStatusMessage('Edited').wait(200)
        .clickButton('#btnSave').wait(200)
        .checkStatusMessage('Saved').wait(200)
        .displayText('Setup Item Pricing Successful').wait(500)

        .clickButton('#btnClose').wait(300)

        //#1.2 Add Non Lotted Inventory Item
        .clickButton('#btnNew').wait(500)
        .waitTillVisible('icitem', 'Open New Item Screen Successful').wait(500)
        .checkScreenShown('icitem').wait(200)
        .checkStatusMessage('Ready')

        .enterData('#txtItemNo', 'LTI - 04').wait(200)
        //.selectComboRowByIndex('#cboType',0).wait(200)
        .enterData('#txtDescription', 'LTI - 04').wait(200)
        .selectComboRowByFilter('#cboCategory', 'Grains', 500, 'cboCategory',0).wait(500)
        .selectComboRowByFilter('#cboCommodity', 'Corn', 500, 'strCommodityCode',0).wait(500)
        .selectComboRowByIndex('#cboLotTracking', 0).wait(500)

        .clickButton('#btnLoadUOM').wait(300)
        .waitTillLoaded('Add UOM Successful')

        .clickTab('#cfgSetup').wait(100)
        .clickButton('#btnAddRequiredAccounts').wait(100)
        .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
        .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
        .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
        .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
        .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
        .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
        .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Auto-Variance').wait(100)

        .selectGridComboRowByFilter('#grdGlAccounts', 0, 'strAccountId', '21000-0000-000', 400, 'strAccountId').wait(100)
        .addFunction(function (next) {
            var t = this,
                win = Ext.WindowManager.getActive();
            if (win) {
                var grdGlAccounts = win.down('#grdGlAccounts');
                grdGlAccounts.editingPlugin.completeEdit();
            }
            next();
        }).wait(1000)
        .selectGridComboRowByFilter('#grdGlAccounts', 1, 'strAccountId', '16000-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 2, 'strAccountId', '50000-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 3, 'strAccountId', '40010-0001-006', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 4, 'strAccountId', '16050-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 5, 'strAccountId', '16040-0000-000', 400, 'strAccountId').wait(100)
        .selectGridComboRowByFilter('#grdGlAccounts', 6, 'strAccountId', '16010-0000-000', 400, 'strAccountId').wait(100)
        .markSuccess('======== Setup GL Accounts Successful ========').wait(500)

        .clickTab('#cfgLocation').wait(300)
        .clickButton('#btnAddLocation').wait(100)
        .waitTillVisible('icitemlocation', 'Add Item Location Screen Displayed', 60000).wait(500)
        .selectComboRowByFilter('#cboSubLocation', 'Raw Station', 600, 'intSubLocationId',0).wait(100)
        .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 600, 'intStorageLocationId',0).wait(100)
        .selectComboRowByFilter('#cboIssueUom', 'Bushels', 600, 'strUnitMeasure').wait(500)
        .selectComboRowByFilter('#cboReceiveUom', 'Bushels', 600, 'strUnitMeasure').wait(500)
        .selectComboRowByIndex('#cboNegativeInventory', 1).wait(500)
        .clickButton('#btnSave').wait(300)
        .checkStatusMessage('Saved').wait(300)
        .clickButton('#btnClose').wait(300)

        .clickTab('#cfgOthers').wait(500)
        .clickCheckBox('#chkTankRequired', true).wait(300)
        .clickCheckBox('#chkAvailableForTm', true).wait(300)

        .clickTab('#cfgPricing').wait(300)
        .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
        .enterGridData('#grdPricing', 0, 'dblLastCost', '10').wait(300)
        .enterGridData('#grdPricing', 0, 'dblStandardCost', '10').wait(300)
        .enterGridData('#grdPricing', 0, 'dblAverageCost', '10').wait(300)
        //.selectGridComboRowByFilter('#grdPricing', 0, 'strPricingMethod', 'Markup Standard Cost', 400, 'strPricingMethod').wait(100)
        .selectGridComboRowByIndex('#grdPricing', 0, 'strPricingMethod',2, 'strPricingMethod').wait(100)
        .enterGridData('#grdPricing', 0, 'dblAmountPercent', '40').wait(300)
        .checkStatusMessage('Edited').wait(200)
        .clickButton('#btnSave').wait(200)
        .checkStatusMessage('Saved').wait(200)
        .displayText('Setup Item Pricing Successful').wait(500)

        .clickButton('#btnClose').wait(300)

        .markSuccess('======== Add Item Scenarios Done and Successful! ========')


        //#Scenario 2: Add Commodity with UOM
        .displayText('====== Scenario 2. Add Cmmodity ======').wait(300)
        .openScreen('Commodities').wait(500)
        .waitTillLoaded('Open Commodity  Search Screen Successful').wait(200)
        .clickButton('#btnNew').wait(300)
        .waitTillVisible('iccommodity','Open Commodity Screen Successful').wait(300)
        .enterData('#txtCommodityCode','Test Commodity 1').wait(100)
        .enterData('#txtDescription','Test Commodity 1').wait(100)
        .clickCheckBox('#chkExchangeTraded',true).wait(100)
        .enterData('#txtDecimalsOnDpr','6.00').wait(100)
        .enterData('#txtConsolidateFactor','6.00').wait(100)
        .selectGridComboRowByFilter('#grdUom', 0,'strUnitMeasure','LB', 300,'strUnitMeasure').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .selectGridComboRowByFilter('#grdUom', 1,'strUnitMeasure','50 lb bag', 300,'strUnitMeasure').wait(100)
        .clickGridCheckBox('#grdUom', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .markSuccess('Add Commodity with no UOM Setup Successful')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity').wait(300)


        //#Scenario 3: Add Category
        .displayText('====== Scenario 3. Add Category ======').wait(300)
        .openScreen('Categories').wait(500)
        .waitTillLoaded('Open Category Search Screen Successful').wait(200)


        //#3. Add Category - Inventory
        .displayText('====== Scenario 3.1. Create Inventory Type Category ======').wait(300)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('iccategory','Open Category Screen Successful').wait(300)
        .enterData('#txtCategoryCode','Test Inventory Category').wait(300)
        .enterData('#txtDescription','Test Description').wait(300)
        .selectComboRowByIndex('#cboInventoryType',1).wait(200)
        .selectComboRowByIndex('#cboCostingMethod',0,100).wait(300)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 0,'strUnitMeasure','LB', 300,'strUnitMeasure').wait(100)
        .clickButton('#btnSave').wait(300)
        .checkStatusMessage('Saved').wait(300)
        .selectGridComboRowByFilter('#grdUnitOfMeasure', 1,'strUnitMeasure','50 lb bag', 300,'strUnitMeasure').wait(100)
        .clickGridCheckBox('#grdUnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)
        .enterData('#txtStandardQty','100000').wait(300)
        //.selectComboRowByFilter('#cboStandardUOM','LB',500, 'intUOMId',0).wait(100)
        .selectGridComboRowByFilter('#grdTax', 0,'strTaxClass','State Sales Tax (SST)', 300,'strTaxClass').wait(100)
        .clickButton('#btnSave').wait(300)
        .markSuccess('Create Inventory Type Category Successful').wait(500)
        .clickButton('#btnClose').wait(300)


        //Scenarios 4-9 Fuel Types Screen
        //#Scenario 4: Add Fuel Category
        .displayText('====== Scenario 4. Add Fuel Category ======').wait(300)
        .openScreen('Fuel Types').wait(500)
        .waitTillLoaded()
        .clickButton('#btnClose').wait(500)
        .clickButton('#btnFuelCategory').wait(300)
        .enterGridData('#grdGridTemplate', 0, 'colRinFuelCategoryCode', 'Test Fuel Category 1').wait(150)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'Test Description 1').wait(150)
        .enterGridData('#grdGridTemplate', 0, 'colEquivalenceValue', 'Test Equivalence Value 1').wait(150)
        .enterGridData('#grdGridTemplate', 1, 'colRinFuelCategoryCode', 'Test Fuel Category 2').wait(150)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'Test Description 2').wait(150)
        .enterGridData('#grdGridTemplate', 1, 'colEquivalenceValue', 'Test Equivalence Value 2').wait(150)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(1000)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .markSuccess('====== Add Fuel Category Successful ======').wait(300)


        //#Scenario 5: Add Feed Stock
        .displayText('====== Scenario 5. Add Feed Stock ======').wait(300)
        .clickButton('#btnFeedStock').wait(300)
        .enterGridData('#grdGridTemplate', 0, 'colRinFeedStockCode', 'FS01').wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'Feed Stock 01').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colRinFeedStockCode', 'FS02').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'Feed Stock 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockcode').wait(100)
        .markSuccess('====== Add Feed Stock Successful ======').wait(300)


        //#Scenario 6: Add Fuel Code
        .displayText('====== Scenario 6. Add Fuel Code ======').wait(300)
        .clickButton('#btnFuelCode').wait(300)
        .enterGridData('#grdGridTemplate', 0, 'colRinFuelCode', 'F01').wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'Fuel 01').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colRinFuelCode', 'F02').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'Fuel 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('fuelcode').wait(100)
        .markSuccess('====== Add Fuel Code Successful ======').wait(300)


        //#Scenario 7: Add Production Process
        .displayText('====== Scenario 7. Add Production Process ======').wait(300)
        .clickButton('#btnProductionProcess').wait(300)
        .enterGridData('#grdGridTemplate', 0, 'colRinProcessCode', 'PP01').wait(100)
        .enterGridData('#grdGridTemplate', 0, 'colDescription', 'Production Process 01').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colRinProcessCode', 'PP02').wait(100)
        .enterGridData('#grdGridTemplate', 1, 'colDescription', 'Production Process 02').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .clickButton('#btnClose').wait(100)
        .markSuccess('====== Add Production Process Successful ======').wait(300)


        //#Scenario 8: Add Feed Stock UOM
        .displayText('====== Scenario 8. Add Feed Stock UOM ======').wait(300)
        .clickButton('#btnFeedStockUOM').wait(300)
        .selectGridComboRowByFilter('#grdGridTemplate', 0, 'strUnitMeasure', 'LB', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdGridTemplate', 0, 'colRinFeedStockUOMCode', 'LB').wait(100)
        .selectGridComboRowByFilter('#grdGridTemplate', 1, 'strUnitMeasure', 'KG', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdGridTemplate', 1, 'colRinFeedStockUOMCode', 'KG').wait(100)
        .checkStatusMessage('Edited')
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('feedstockuom').wait(100)
        .markSuccess('====== Add Add Feed Stock UOM Successful ======').wait(300)


        //#Scenario 9: Add Fuel Type
        .displayText('====== Scenario 9. Add Fuel Type ======').wait(300)
        .clickButton('#btnNew').wait(300)
        .selectComboRowByFilter('#cboFuelCategory', 'Test Fuel Category 1', 300, 'intRinFuelCategoryId', 0).wait(200)
        .selectComboRowByFilter('#cboFeedStock', 'FS01', 300, 'intRinFeedStockId', 0).wait(200)
        .enterData('#txtBatchNo','10001').wait(100)
        .enterData('#txtEndingRinGallonsForBatch','25').wait(100)
        .checkControlData('#txtEquivalenceValue','Test Equivalence Value 1')
        .selectComboRowByFilter('#cboFuelCode', 'F01', 300, 'intRinFuelId', 0).wait(200)
        .selectComboRowByFilter('#cboProductionProcess', 'PP01', 300, 'intRinProcessId', 0).wait(200)
        .selectComboRowByFilter('#cboFeedStockUom', 'LB', 300, 'intRinFeedStockUOMId', 0).wait(200)
        .enterData('#txtFeedStockFactor','10').wait(200)
        .clickButton('#btnSave').wait(500)
        .clickButton('#btnClose').wait(200)
        .markSuccess('====== Add Add Fuel Type Successful ======').wait(300)


        //#Scenario 10: Inventory UOM
        // 10.1 Add stock UOM first
        .displayText('====== Scenario 10: Inventory UOM ======').wait(300)
        .openScreen('Inventory UOM').wait(500)
        .waitTillLoaded()
        .displayText('====== #1 Add Stock UOM ======').wait(300)
        .clickButton('#btnNew').wait(100)
        .waitTillVisible('icinventoryuom','Open Inventory UOM  Successful').wait(200)
        .checkScreenShown('icinventoryuom').wait(100)
        .enterData('#txtUnitMeasure', 'Pound_1').wait(300)
        .enterData('#txtSymbol', 'Lb_1').wait(300)
        .selectComboRowByIndex('#cboUnitType', 5).wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .displayText('====== Verify Record Added ======').wait(300)
        .clickButton('#btnSearch').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdSearch', 40, 'strUnitMeasure', 'Pound_1').wait(100)
        .checkGridData('#grdSearch', 40, 'strSymbol', 'Lb_1').wait(100)
        .markSuccess('====== Add Stock UOM Successful ======').wait(200)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)

        // 10.2. Add conversion UOMs on each stock UOM
        .displayText('====== Scenario #10.1 Add Conversion UOM> 5 Lb Bag======').wait(300)
        .clickButton('#btnNew').wait(100).wait(100)
        .enterData('#txtUnitMeasure', '5 Lb Bag_1').wait(100)
        .enterData('#txtSymbol', '5 Lb Bag_1').wait(100)
        .selectComboRowByIndex('#cboUnitType', 5).wait(100)
        .selectGridComboRowByFilter('#grdConversion', 0, 'strUnitMeasure', 'Pound_1', 1000).wait(100)
        .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '5').wait(500)
        .clickButton('#btnSave').wait(100)
        .displayText('====== Verify Record Added ======').wait(300)
        .clickButton('#btnSearch').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdSearch', 41, 'strUnitMeasure', '5 Lb Bag_1').wait(100)
        .checkGridData('#grdSearch', 41, 'strSymbol', '5 Lb Bag_1').wait(100)
        .markSuccess('====== Add Conversion UOM> 5 Lb Bag ======').wait(200)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)


        .displayText('====== Scenario #10.2 Add Conversion UOM> 10 Lb Bag======').wait(300)
        .clickButton('#btnNew').wait(100)
        .enterData('#txtUnitMeasure', '10 Lb Bag_1').wait(100)
        .enterData('#txtSymbol', '10 Lb Bag_1').wait(100)
        .selectComboRowByIndex('#cboUnitType', 5).wait(100)
        .selectGridComboRowByFilter('#grdConversion', 0, 'strUnitMeasure', 'Pound_1', 1000).wait(100)
        .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '10').wait(500)
        .clickButton('#btnSave').wait(100)
        .addFunction(function (next) { t.diag("Verify Record Added"); next(); }).wait(100)
        .clickButton('#btnSearch').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdSearch', 42, 'strUnitMeasure', '10 Lb Bag_1').wait(100)
        .checkGridData('#grdSearch', 42, 'strSymbol', '10 Lb Bag_1').wait(100)
        .markSuccess('====== Add Conversion UOM> 10 Lb Bag Successful ======').wait(200)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)


        //#Scenario 11: Add Storage Location

        .displayText('====== Scenario 11. Add Storage Location: Allow bin of the same name to be used in a different Sub Location ======').wait(300)
        .openScreen('Storage Locations').wait(500)
        .waitTillLoaded()
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('icstorageunit','Open Inventory UOM  Successful').wait(200)
        .checkScreenShown('icstorageunit').wait(200)
        .enterData('#txtName','Test SL - SH - 001').wait(100)
        .enterData('#txtDescription','Test SL - SH - 001').wait(100)
        .selectComboRowByFilter('#cboUnitType','Bin',300, 'strStorageUnitType').wait(100)
        .selectComboRowByFilter('#cboLocation','0001 - Fort Wayne',300, 'intLocationId').wait(100)
        .selectComboRowByFilter('#cboSubLocation','Stellhorn',300, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboParentUnit','RM Storage',300, 'intParentStorageLocationId').wait(100)
        .enterData('#txtAisle','Test Aisle').wait(100)
        .clickCheckBox('#chkAllowConsume',true).wait(100)
        .clickCheckBox('#chkAllowMultipleItems',true).wait(100)
        .clickCheckBox('#chkAllowMultipleLots',true).wait(100)
        .clickCheckBox('#chkMergeOnMove',true).wait(100)
        .clickCheckBox('#chkCycleCounted',true).wait(100)
        .clickCheckBox('#chkDefaultWarehouseStagingUnit',true).wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icstorageunit').wait(100)
        .markSuccess('====== Allow bin of the same name to be used in a different Sub Location Successful ======').wait(200)
        .markSuccess('====== Add IC Maintenance Records Successful! Ole! ======')


        //ADD TRANSACTION SCREENS - IC Add Transaction Screens
        .displayText('"======== Scenario 1:  Add Direct IR for NON Lotted Item ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Receipt Screen ========"').wait(500)
        .openScreen('Inventory Receipts').wait(1000)
        .waitTillLoaded('Open Inventory Receipts Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(1000)
        .waitTillVisible('icinventoryreceipt','').wait(1000)
        .markSuccess('Open New Inventory Receipt Screen Successful')

        .displayText('======== #2. Enter/Select Inventory Receipt Details and Check Fields========')
        .selectComboRowByIndex('#cboReceiptType',3).wait(200)
        .selectComboRowByFilter('#cboVendor', 'ABC Trucking', 500, 'strName', 0).wait(200)
        //.selectComboRowByFilter('#cboVendor','0001005057',500, 'intEntityVendorId').wait(500)
        .selectComboRowByIndex('#cboLocation',0).wait(300)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strItemNo', 'NLTI - 05', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryReceipt', 0, 'colQtyToReceive', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colItemSubCurrency', 'USD').wait(300)
        .enterGridData('#grdInventoryReceipt', 0, 'colUnitCost', '10').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colCostUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colWeightUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colGross', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colNet', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colLineTotal', '10000').wait(500)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblGrossWgt').text;
            if (total == 'Gross: 1,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Grossl is incorrect.');
            }
            next();
        }).wait(200)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblNetWgt').text;
            if (total == 'Net: 1,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        }).wait(200)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblTotal').text;
            if (total == 'Total: 10,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        }).wait(200)
        .markSuccess('Enter/Select Inventory Recepit Details and Check Fields Successful')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillVisible('cmcmrecaptransaction','').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapDebit', '10000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '21000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapCredit', '10000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful ========')

        .displayText('======== #4. Post Inventory Receipt ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('')
        .markSuccess('======== Posting of Inventory Receipt Successful ========')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Direct Receipt for Non Lotted Item Successful! ========')



        //Scenario 1.2: Add Direct IR for Lotted Item
        .displayText('"======== Scenario 1.2: Create Direct Inventory Receipt for Lotted Item. ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Receipt Screen ========"').wait(500)
        .waitTillLoaded('Open Inventory Receipts Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(1000)
        .waitTillVisible('icinventoryreceipt','').wait(500)
        .displayText('"======== Open New Inventory Receipt Screen Successful ========"').wait(300)

        .displayText('======== #2. Enter/Select Inventory Recepit Details and Check Fields========')
        .selectComboRowByIndex('#cboReceiptType',3).wait(200)
        .selectComboRowByFilter('#cboVendor', 'ABC Trucking', 500, 'strName', 0).wait(200)
        //.selectComboRowByFilter('#cboVendor','0001005057',500, 'intEntityVendorId').wait(500)
        .selectComboRowByIndex('#cboLocation',0).wait(300)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strItemNo', 'LTI - 04', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryReceipt', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryReceipt', 0, 'colQtyToReceive', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colItemSubCurrency', 'USD').wait(300)
        .enterGridData('#grdInventoryReceipt', 0, 'colUnitCost', '10').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colCostUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colWeightUOM', 'Bushels').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colGross', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colNet', '1000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colLineTotal', '10000').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colSubLocation', 'Raw Station').wait(500)
        .checkGridData('#grdInventoryReceipt', 0, 'colStorageLocation', 'RM Storage').wait(500)

        .enterGridData('#grdLotTracking', 0, 'colLotId', 'LOT-01').wait(500)
        .selectGridComboRowByFilter('#grdLotTracking', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdLotTracking', 0, 'colLotQuantity', '1000').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotGrossWeight', '1000').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotTareWeight', '0').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotNetWeight', '1000').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotWeightUOM', 'Bushels').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotStorageLocation', 'RM Storage').wait(500)

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblGrossWgt').text;
            if (total == 'Gross: 1,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Grossl is incorrect.');
            }
            next();
        }).wait(200)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblNetWgt').text;
            if (total == 'Net: 1,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        }).wait(200)
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                grid = win.down('#grdInventoryReceipt'),
                total = grid.down('#lblTotal').text;
            if (total == 'Total: 10,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        }).wait(200)
        .markSuccess('======== Enter/Select Inventory Recepit Details and Check Fields========')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillVisible('cmcmrecaptransaction','').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapDebit', '10000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '21000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapCredit', '10000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful========')

        .displayText('======== #4. Post Inventory Receipt ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('Inventory Post Successful')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Post Inventory Receipt Successful ========')
        .markSuccess('======== Create Direct Receipt for Lotted Item Successful! ========')


        //Scenario 2:  Add Inventory Shipmnent
        .displayText('"======== Scenario 2.1:  Add Direct IS for NON Lotted Item ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Shipment Screen ========"').wait(500)
        .openScreen('Inventory Shipments').wait(1000)
        .waitTillLoaded('Open Inventory Shipments Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)
        .waitTillVisible('icinventoryshipment','').wait(500)
        .markSuccess('Open New Inventory Shipments Screen Successful')

        .displayText('======== #2. Enter/Select Inventory Shipment Details and Check Fields========')
        .selectComboRowByIndex('#cboOrderType',3).wait(200)
        .selectComboRowByFilter('#cboCustomer', 'Apple Spice Sales', 500, 'strName', 0).wait(200)
        //.selectComboRowByFilter('#cboVendor','0001005057',500, 'intEntityVendorId').wait(500)
        .selectComboRowByFilter('#cboFreightTerms', 'Truck', 500, 'strFreightTerm', 0).wait(200)
        .selectComboRowByIndex('#cboShipFromAddress',0).wait(300)
        .selectComboRowByIndex('#cboShipToAddress',0).wait(300)

        .selectGridComboRowByFilter('#grdInventoryShipment', 0, 'strItemNo', 'NLTI - 05', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryShipment', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryShipment', 0, 'colQuantity', '100').wait(500)
        .enterGridData('#grdInventoryShipment', 0, 'colUnitPrice', '15').wait(500)
        .checkGridData('#grdInventoryShipment', 0, 'colLineTotal', '1500').wait(500)
        .checkGridData('#grdInventoryShipment', 0, 'colOwnershipType', 'Own').wait(500)
        .markSuccess('Enter/Select Inventory Shipment Details and Check Fields Successful')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillVisible('cmcmrecaptransaction','').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapCredit', '1000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '16050-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapDebit', '1000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful ========')

        .displayText('======== #4. Post Inventory Shipment ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('')
        .markSuccess('======== Posting of Inventory Shipment Successful ========')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Direct Shipment for Non Lotted Item Successful! ========')

        //Scenario 2.2:  Add Direct IS for Lotted Item
        .displayText('"======== Scenario 2.2:  Add Direct IS for NON Lotted Item ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Shipment Screen ========"').wait(500)
        .openScreen('Inventory Shipments').wait(1000)
        .waitTillLoaded('Open Inventory Shipments Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)
        .waitTillVisible('icinventoryshipment','').wait(500)
        .markSuccess('Open New Inventory Shipments Screen Successful')

        .displayText('======== #2. Enter/Select Inventory Shipment Details and Check Fields========')
        .selectComboRowByIndex('#cboOrderType',3).wait(200)
        .selectComboRowByFilter('#cboCustomer', 'Apple Spice Sales', 500, 'strName', 0).wait(200)
        //.selectComboRowByFilter('#cboVendor','0001005057',500, 'intEntityVendorId').wait(500)
        .selectComboRowByFilter('#cboFreightTerms', 'Truck', 500, 'strFreightTerm', 0).wait(200)
        .selectComboRowByIndex('#cboShipFromAddress',0).wait(300)
        .selectComboRowByIndex('#cboShipToAddress',0).wait(300)

        .selectGridComboRowByFilter('#grdInventoryShipment', 0, 'strItemNo', 'LTI - 04', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryShipment', 0, 'strUnitMeasure', 'Bushels', 300, 'strUnitMeasure').wait(1000)
        .enterGridData('#grdInventoryShipment', 0, 'colQuantity', '100').wait(500)
        .enterGridData('#grdInventoryShipment', 0, 'colUnitPrice', '15').wait(500)
        .checkGridData('#grdInventoryShipment', 0, 'colLineTotal', '1500').wait(500)
        .checkGridData('#grdInventoryShipment', 0, 'colOwnershipType', 'Own').wait(500)

        .selectGridComboRowByFilter('#grdLotTracking', 0, 'strLotId', 'LOT-01', 300, 'strLotNumber').wait(1000)
        .enterGridData('#grdLotTracking', 0, 'colShipQty', '100').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotUOM', 'Bushels').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colLotWeightUOM', 'Bushels').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colGrossWeight', '100').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colTareWeight', '0').wait(500)
        .checkGridData('#grdLotTracking', 0, 'colNetWeight', '100').wait(500)
        .markSuccess('Enter/Select Inventory Shipment Details and Check Fields Successful')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
       .waitTillVisible('cmcmrecaptransaction','').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapCredit', '1000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '16050-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapDebit', '1000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful ========')

        .displayText('======== #4. Post Inventory Shipment ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('')
        .markSuccess('======== Posting of Inventory Shipment Successful ========')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Direct Shipment for Non Lotted Item Successful! ========')


        //Scenario 3:  Add Inventory Transfers
        .displayText('"======== Scenario 3:  Add Inventory Transfer ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Transfer Screen ========"').wait(500)
        .openScreen('Inventory Transfers').wait(1000)
        .waitTillLoaded('Open Inventory Transfers Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)

        .displayText('======== #2. Enter/Select Inventory Transfer Details and Check Fields========')
        .selectComboRowByFilter('#cboTransferType', 'Location to Location', 500, 'strTransferType', 0).wait(200)
        .selectComboRowByFilter('#cboFromLocation', '0001 - Fort Wayne', 500, 'intFromLocationId', 0).wait(200)
        .selectComboRowByFilter('#cboToLocation', '0001 - Fort Wayne', 500, 'intToLocationId', 0).wait(200)

        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strItemNo', 'LTI - 04', 300, 'strItemNo').wait(500)
        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strFromSubLocationName', 'Raw Station', 300, 'strFromSubLocationName').wait(500)
        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strFromStorageLocationName', 'RM Storage', 300, 'strFromStorageLocationName').wait(500)
        .checkGridData('#grdInventoryTransfer', 0, 'colOwnershipType', 'Own').wait(300)
        .selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strLotNumber', 'LOT-01', 300, 'strLotNumber').wait(500)
        .checkGridData('#grdInventoryTransfer', 0, 'colAvailableUOM', 'Bushels').wait(300)
        .enterGridData('#grdInventoryTransfer', 0, 'colTransferQty', '100').wait(500)
        //.selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strToSubLocationName', 'FG Station', 300, 'strToSubLocationName').wait(500)
        //.selectGridComboRowByFilter('#grdInventoryTransfer', 0, 'strToStorageLocationName', 'FG Storage', 300, 'strToStorageLocationName').wait(500)

        .displayText('======== #3. Post Inventory Transfer ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('Post Successful')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Post Inventory Transfer Successful! ========')


        //Scenario 4: Add Inventory Adjustment
        .displayText('"======== Scenario 4.1:  Add Inventory Adjustment ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Adjustment Screen ========"').wait(500)
        .openScreen('Inventory Adjustments').wait(1000)
        .waitTillLoaded('Open Inventory Transfers Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)

        .displayText('"======== #2 Quantity Change ========"').wait(500)
        .selectComboRowByFilter('#cboLocation', '0001 - Fort Wayne', 500, 'strName', 0).wait(200)
        .selectComboRowByIndex('#cboAdjustmentType',0).wait(300)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strItemNo', 'LTI - 04', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strSubLocation', 'Raw Station', 300, 'strSubLocation').wait(500)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strStorageLocation', 'RM Storage', 300, 'strStorageLocation').wait(500)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strLotNumber', 'LOT-01', 300, 'strLotNumber').wait(500)
        .checkGridData('#grdInventoryAdjustment', 0, 'colUOM', 'Bushels').wait(300)
        .enterGridData('#grdInventoryAdjustment', 0, 'colAdjustByQuantity', '200').wait(500)
        .checkGridData('#grdInventoryAdjustment', 0, 'colUnitCost', '10').wait(300)
        .checkGridData('#grdInventoryAdjustment', 0, 'colNewUnitCost', '10').wait(300)
        .markSuccess('======== Enter Details successful ========')

        .displayText('======== #3. Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillVisible('cmcmrecaptransaction','').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapDebit', '2000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '16040-0001-000').wait(500)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapCredit', '2000').wait(500)
        .markSuccess('======== Open Recap Screen and Check Details Successful========')

        .displayText('======== #4. Post Inventory Adjustment ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('Inventory Post Successful')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Post Inventory Adjustment Successful ========')

        //#4.2 Lot Move
        .clickButton('#btnNew').wait(500)

        .displayText('"======== #4.2 Lot Move ========"').wait(500)
        .selectComboRowByFilter('#cboLocation', '0001 - Fort Wayne', 500, 'strName', 0).wait(200)
        .selectComboRowByIndex('#cboAdjustmentType',7).wait(300)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strItemNo', 'LTI - 04', 300, 'strItemNo').wait(1000)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strSubLocation', 'Raw Station', 300, 'strSubLocation').wait(500)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strStorageLocation', 'RM Storage', 300, 'strStorageLocation').wait(500)
        .selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strLotNumber', 'LOT-01', 300, 'strLotNumber').wait(500)
        .enterGridData('#grdInventoryAdjustment', 0, 'colNewLotNumber', 'LOT-02').wait(500)
        .checkGridData('#grdInventoryAdjustment', 0, 'colUOM', 'Bushels').wait(300)
        .enterGridData('#grdInventoryAdjustment', 0, 'colAdjustByQuantity', '-200').wait(500)
        //.checkGridData('#grdInventoryAdjustment', 0, 'colUnitCost', '10').wait(300)
        //.selectGridComboRowByFilter('#grdInventoryAdjustment', 0, 'strNewStorageLocation', 'RM Bin 1', 300, 'strNewStorageLocation').wait(500)
        //.checkGridData('#grdInventoryAdjustment', 0, 'colNewLocation', '0001 - Fort Wayne').wait(300)
        .checkGridData('#grdInventoryAdjustment', 0, 'colSubLocation', 'Raw Station').wait(300)
        .markSuccess('======== Enter Details successful ========')

        .displayText('======== #6 Open Recap Screen and Check Account IDs and Totlas ========')
        .clickButton('#btnRecap').wait(300)
        .waitTillVisible('cmcmrecaptransaction','').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapAccountId', '16000-0001-000').wait(300)
        .checkGridData('#grdRecapTransaction', 0, 'colRecapCredit', '2000').wait(300)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapAccountId', '16000-0001-000').wait(300)
        .checkGridData('#grdRecapTransaction', 1, 'colRecapDebit', '2000').wait(300)

        .checkGridData('#grdRecapTransaction', 2, 'colRecapAccountId', '16040-0001-000').wait(300)
        .checkGridData('#grdRecapTransaction', 2, 'colRecapDebit', '2000').wait(300)
        .checkGridData('#grdRecapTransaction', 3, 'colRecapAccountId', '16040-0001-000').wait(300)
        .checkGridData('#grdRecapTransaction', 3, 'colRecapCredit', '2000').wait(300)
        .markSuccess('======== Open Recap Screen and Check Details Successful========')

        .displayText('======== #7. Post Inventory Adjustment ========')
        .clickButton('#btnPost').wait(500)
        .waitTillLoaded('Inventory Post Successful')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Post Inventory Adjustment Successful ========')
        .markSuccess('======== Create Quantity Change Adjustment for Lotted Item Successful! ========')


        //Scenario 5: Add Inventory Count
        .displayText('"======== Scenario 5:  Add Inventory Count ========"').wait(500)
        .displayText('"======== #1 Open New Inventory Count Screen ========"').wait(500)
        .openScreen('Inventory Count').wait(500)
        .waitTillLoaded('Open Inventory Count Search Screen Successful').wait(500)
        .clickButton('#btnNew').wait(500)
        .waitTillVisible('inventorycount','').wait(1000)
        .markSuccess('Open New Inventory Count Screen Successful')

        .displayText('======== #2. Enter/Select Inventory Count Details and Check Fields========')
        .selectComboRowByFilter('#cboCategory', 'Grains', 500, 'strCategoryCode', 0).wait(200)
        .selectComboRowByFilter('#cboCommodity', 'Corn', 500, 'strCommodityCode', 0).wait(200)
        .selectComboRowByFilter('#cboSubLocation', 'Raw Station', 500, 'strSubLocationName', 0).wait(200)
        .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 500, 'strName', 0).wait(200)
        .clickCheckBox('#chkIncludeZeroOnHand', true).wait(300)
        .clickCheckBox('#chkIncludeOnHand', true).wait(300)
        .clickCheckBox('#chkScannedCountEntry', true).wait(300)
        .clickCheckBox('#chkCountByLots', true).wait(300)
        .clickCheckBox('#chkCountByPallets', true).wait(300)


        .clickButton('#btnFetch').wait(300)
        .checkGridData('#grdPhysicalCount', 0, 'colItem', 'LTI - 01').wait(200)
        .checkGridData('#grdPhysicalCount', 0, 'colCategory', 'Grains').wait(200)
        .checkGridData('#grdPhysicalCount', 0, 'colSubLocation', 'Raw Station').wait(200)
        .checkGridData('#grdPhysicalCount', 0, 'colStorageLocation', 'RM Storage').wait(200)
        .checkGridData('#grdPhysicalCount', 0, 'colLotNo', 'LOT-01').wait(200)
        .markSuccess('Enter/Select Inventory Count Details and Check Fields Successful')

        .displayText('======== #3. Print Count Sheets ========')
        .clickButton('#btnPrintCountSheets').wait(500)
        .waitTillVisible('search', 'Print Count Sheets Displayed!')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Inventory Count Successful! ========')


        //Scenario 6: Add Storage Measurement Reading
        .displayText('"======== Scenario 6:  Add Storage Measurement Reading ========"').wait(500)
        .displayText('"======== #1 Open New Storage Measurement Reading Screen ========"').wait(500)
        .openScreen('Storage Measurement Reading').wait(500)
        .waitTillLoaded('Open Storage Measurement Reading Search Screen Successful').wait(500)
        //.clickButton('#btnClose').wait(300)
        //.checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        //.clickMessageBoxButton('no').wait(300)
        .clickButton('#btnNew').wait(300)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        .clickMessageBoxButton('no').wait(300)
        .waitTillVisible('storagemeasurementreading','').wait(1000)
        .markSuccess('Open New Storage Measurement Reading Screen Successful')

        .displayText('======== #2. Enter/Select Storage Measurement Reading Details and Check Fields========')
        .selectComboRowByFilter('#cboLocation', '0001 - Fort Wayne', 500, 'strName', 0).wait(200)
        .selectGridComboRowByFilter('#grdStorageMeasurementReading', 0, 'strCommodity', 'Corn', 300, 'strCommodity').wait(500)
        .selectGridComboRowByFilter('#grdStorageMeasurementReading', 0, 'strItemNo', 'CORN', 500, 'strItemNo').wait(500)       
        .selectGridComboRowByFilter('#grdStorageMeasurementReading', 0, 'strStorageLocationName', 'RM Storage', 300, 'strStorageLocationName').wait(500)
        .checkGridData('#grdStorageMeasurementReading', 0, 'colSubLocation', 'Raw Station').wait(200)
        .enterGridData('#grdStorageMeasurementReading', 0, 'colAirSpaceReading', '100').wait(500)
        .enterGridData('#grdStorageMeasurementReading', 0, 'colCashPrice', '15').wait(500)
        .displayText('======== Enter/Select Storage Measurement Reading Details and Check Fields Successful========')


        .displayText('======== #3. Save Storage Measurement Reading ========')
        .clickButton('#btnSave').wait(500)
        .markSuccess('======== Saveing Storage Measurement Reading Successful ========')
        .clickButton('#btnClose').wait(200)
        .waitTillLoaded('')
        .markSuccess('======== Create Storage Measurement Reading Successful! ========')




        .done();
});



