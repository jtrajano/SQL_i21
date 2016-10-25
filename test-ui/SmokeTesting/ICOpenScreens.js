StartTest(function (t) {

    var engine = new iRely.TestEngine(),
        commonSM = Ext.create('SystemManager.CommonSM');
        //commonIC = Ext.create('Inventory.CommonIC');

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
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(200)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventoryreceipt').wait(100)
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


        //Inventory Valuation Summary Screen
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
        .done();
});



