/**
 * Created by CCallado on 9/26/2016.
 */
StartTest(function (t) {

    var engine = new iRely.TestEngine(),
        commonSM = Ext.create('SystemManager.CommonSM');
        //commonIC = Ext.create('Inventory.CommonIC');

    engine.start(t)



        // LOG IN
        .displayText('Log In').wait(500)
        .addFunction(function (next) {
            commonSM.commonLogin(t, next);
        }).wait(100)
        .waitTillMainMenuLoaded('Login Successful').wait(500)


        //START OF TEST CASE - Opening IC Screens
        .displayText('"======== Scenario 1: Opening Inventory Screens. ========"').wait(1000)
        .expandMenu('Inventory').wait(1000)
        .markSuccess('Inventory successfully expanded').wait(500)


        //# 1Inventory Receipt Screen

        .displayText('"======== 1. Open Inventory Receipt Search Screen Check All Fields ========"').wait(500)
        .openScreen('Inventory Receipts').wait(1000)
        .waitTillLoaded('Open Inventory Receipts Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Details').wait(500)
        .waitTillLoaded('Open Inventory Receipts Search Screen Details Tab Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Lots').wait(500)
        .waitTillLoaded('Open Inventory Receipts Search Screen Lots Tab Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Vouchers').wait(500)
        .waitTillLoaded('Open Inventory Receipts Search Screen Vouchers Tab Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Inventory Receipt').wait(500)
        .markSuccess('======== Open Inventory Receipt Search Screen Check All Fields Successful. ========').wait(500)

        //#2
        .displayText('"======== 2. Click New, Check Inventory Receipt Screen Fields.========"').wait(1000)
        .clickButton('#btnNew').wait(1000)
        .waitTillVisible('icinventoryreceipt','Open New Inventory Receipt Screen Successful',60000).wait(1000)
        .checkControlVisible(['#btnNew', '#btnSave', '#btnSearch', '#btnDelete', '#btnUndo','#btnPrint','#btnReceive','#btnRecap','#btnClose'], true).wait(500)
        .checkControlVisible(['#cboReceiptType', '#cboSourceType', '#cboVendor', '#cboLocation', '#dtmReceiptDate', '#cboCurrency','#txtReceiptNumber'], true).wait(500)
        .checkControlVisible(['#txtBillOfLadingNumber', '#cboReceiver', '#cboFreightTerms', '#cboTaxGroup'], true).wait(500)
        .checkControlVisible(['#txtVendorRefNumber', '#cboShipFrom', '#txtFobPoint', '#txtShiftNumber'], true).wait(500)
        .checkControlVisible(['#txtBlanketReleaseNumber', '#cboShipVia', '#txtVessel'], true).wait(500)
        .checkControlVisible(['#btnInsertInventoryReceipt', '#btnQuality', '#btnTaxDetails','#btnRemoveInventoryReceipt'], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .checkStatusMessage('Ready')
        .markSuccess('======== Click New, Check Inventory Receipt Screen Fields Successful. ========').wait(500)

        .displayText('Open Inventory Receipt Screen Tabs').wait(500)
        .clickTab('#pgeFreightInvoice').wait(500)
        .checkControlVisible(['#btnInsertCharge', '#btnRemoveCharge', '#btnCalculateCharges', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#colOtherCharge', '#colOnCostType', '#colCostMethod', '#colChargeCurrency', '#colRate', '#colChargeUOM','#colChargeAmount','#colAccrue','#colCostVendor','#colInventoryCost','#colAllocateCostBy'], true).wait(500)
        .clickTab('Incoming Inspection').wait(500)
        .checkControlVisible(['#btnSelectAll', '#btnClearAll', '#colInspect', '#colQualityPropertyName'], true).wait(500)
        .clickTab('EDI').wait(500)
        .checkControlVisible(['#cboTrailerType', '#txtTrailerArrivalDate', '#txtTrailerArrivalTime', '#txtSealNo', '#cboSealStatus', '#txtReceiveTime','#txtActualTempReading'], true).wait(500)
        .clickTab('#cfgComments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnOpenActivity', '#btnNewEvent', '#btnNewTask', '#btnNewComment', '#btnLogCall', '#btnSendEmail','#btnGridLayout','#btnInsertCriteria','#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)
        .clickTab('#pgeAttachments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnAddAttachment', '#btnOpenAttachment', '#btnEditAttachment', '#btnDownloadAttachment', '#btnDeleteAttachment'], true).wait(500)
        .clickTab('#pgeAuditLog').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .clickButton('#btnClose').wait(500)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventoryreceipt').wait(100)
        .markSuccess('======== Open Inventory Receipt Screen Tabs Successful ========').wait(500)


        //#3 Inventory Shipment Screen
        .displayText('"======== 3. Open Inventory Shipment Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Inventory Shipments').wait(1000)
        .waitTillLoaded('Open Inventory Shipment Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Details').wait(500)
        .waitTillLoaded('Open Inventory Shipment Search Screen Details Tab Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Lots').wait(500)
        .waitTillLoaded('Open Inventory Shipment Search Screen Lots Tab Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Inventory Shipment').wait(500)
        .markSuccess('======== Open Inventory Shipment Search Screen Check All Fields Successful. ========').wait(500)


        //#4
        .displayText('"======== 4. Click New, Check Inventory Shipment Screen Fields. ========"').wait(1000)
        .clickButton('#btnNew').wait(1000)
        .waitTillVisible('icinventoryshipment','Open New Inventory Shipment Screen Successful').wait(1000)
        .checkControlVisible(['#btnNew', '#btnSave', '#btnSearch', '#btnDelete', '#btnUndo','#btnPrint','#btnPrintBOL','#btnShip', '#btnRecap','#btnCustomer','#btnWarehouseInstruction','#btnClose'], true).wait(500)
        .checkControlVisible(['#cboOrderType', '#cboSourceType', '#cboCustomer', '#dtmShipDate', '#txtReferenceNumber', '#dtmRequestedArrival', '#cboFreightTerms','#txtShipmentNo'], true).wait(500)
        .checkControlVisible(['#cboShipFromAddress', '#txtShipFromAddress', '#cboShipToAddress','#txtShipToAddress','#txtDeliveryInstructions','#txtComments'], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .checkStatusMessage('Ready').wait(200)
        .clickTab('#tabShippingCompany').wait(500)
        .checkControlVisible(['#txtBOLNo', '#txtProNumber', '#cboShipVia', '#txtDriverID','#txtVesselVehicle','#txtSealNumber'], true).wait(500)
        .clickTab('#tabDelivery').wait(500)
        .checkControlVisible(['#txtAppointmentTime', '#dtmDelivered', '#txtDepartureTime', '#dtmFreeTime','#txtArrivalTime','#txtReceivedBy'], true).wait(500)
        .checkControlVisible(['#btnInsertItem', '#btnViewItem', '#btnQuality', '#btnRemoveItem','#btnGridLayout','#btnInsertCriteria','#txtFilterGrid'], true).wait(500)
        .displayText('Open Inventory Shipment Screen Tabs Check All Fields').wait(500)
        .clickTab('#pgeChargesInvoice').wait(500)
        .checkControlVisible(['#btnInsertCharge', '#btnRemoveCharge', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .clickTab('#pgeComments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnOpenActivity', '#btnNewEvent', '#btnNewTask', '#btnNewComment', '#btnLogCall', '#btnSendEmail','#btnGridLayout', '#btnInsertCriteria','#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .clickTab('#pgeAttachments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnAddAttachment', '#btnOpenAttachment', '#btnEditAttachment', '#btnDownloadAttachment', '#btnDeleteAttachment'], true).wait(500)
        .clickTab('#pgeAuditLog').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)

        .clickButton('#btnClose').wait(500)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventoryshipment').wait(100)
        .markSuccess('======== Click New, Check Inventory Shipment Screen Fields Successful. ========').wait(500)



        //#5 Inventory Transfers Screen

        .displayText('"======== 5. Open Inventory Transfers Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Inventory Transfers').wait(1000)
        .waitTillLoaded('Open Inventory Transfer Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Details').wait(500)
        .waitTillLoaded('Open Inventory Transfer Search Screen Details Tab Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Inventory Transfer').wait(500)
        .markSuccess('======== Open Inventory Transfers Search Screen Check All Fields Successful. ========').wait(500)


        //#6
        .displayText('"======== 6. Click New, Check Inventory Transfer Screen Fields. ========"')
        .clickButton('#btnNew').wait(1000)
        .waitTillVisible('icinventorytransfer','Open New Inventory Transfer Screen Successful').wait(1000)
        .checkControlVisible(['#btnNew', '#btnSave', '#btnSearch', '#btnDelete', '#btnUndo','#btnPrint','#btnPost','#btnRecap','#btnClose'], true).wait(500)
        .checkControlVisible(['#txtTransferNumber', '#dtmTransferDate', '#cboTransferType', '#cboSourceType', '#cboTransferredBy', '#cboFromLocation', '#cboToLocation','#chkShipmentRequired','#cboStatus','#txtDescription'], true).wait(500)
        .checkControlVisible(['#btnAddItem', '#btnViewItem', '#btnRemoveItem', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .clickTab('#pgeComments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnOpenActivity', '#btnNewEvent', '#btnNewTask', '#btnNewComment', '#btnLogCall', '#btnSendEmail','#btnGridLayout', '#btnInsertCriteria','#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .clickTab('#pgAttachments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnAddAttachment', '#btnOpenAttachment', '#btnEditAttachment', '#btnDownloadAttachment', '#btnDeleteAttachment'], true).wait(500)
        .clickTab('#pgeAuditLog').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(500)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventorytransfer').wait(100)
        .markSuccess('======== Click New, Check Inventory Transfer Screen Fields Successful. ========').wait(500)




        //#7 Inventory Adjustments Screen

        .displayText('"======== 7. Open Inventory Adjustments Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Inventory Adjustments').wait(1000)
        .waitTillLoaded('Open Inventory Adjustments Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Details').wait(500)
        .waitTillLoaded('Open Inventory Adjustments Search Screen Details Tab Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Inventory Adjustment').wait(500)
        .markSuccess('======== Open Inventory Adjustments Search Screen Check All Fields Successful. ========').wait(500)

        //#8
        .displayText('"======== 8. Click New, Check Inventory Adjustment Screen Fields. ========"')
        .clickButton('#btnNew').wait(1000)
        .waitTillVisible('icinventoryadjustment','Open New Inventory Adjustment Screen Successful').wait(1000)
        .checkControlVisible(['#btnNew', '#btnSave', '#btnSearch', '#btnDelete', '#btnUndo','#btnPrint','#btnPost','#btnRecap','#btnClose'], true).wait(500)
        .checkControlVisible(['#cboLocation', '#dtmDate', '#cboAdjustmentType', '#txtAdjustmentNumber', '#txtDescription'], true).wait(500)
        .checkControlVisible(['#btnAddItem', '#btnViewItem', '#btnRemoveItem', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .clickTab('#pgeComments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnOpenActivity', '#btnNewEvent', '#btnNewTask', '#btnNewComment', '#btnLogCall', '#btnSendEmail','#btnGridLayout', '#btnInsertCriteria','#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .clickTab('#pgeAttachments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnAddAttachment', '#btnOpenAttachment', '#btnEditAttachment', '#btnDownloadAttachment', '#btnDeleteAttachment'], true).wait(500)
        .clickTab('#pgeAudit').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(500)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventoryadjustment').wait(100)
        .markSuccess('======== Click New, Check Inventory Adjustment Screen Fields Successful. ========').wait(500)



        //#9 Inventory Count Screen
        .displayText('"======== 9. Open Inventory Count Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Inventory Count').wait(1000)
        .waitTillLoaded('Open Inventory Count Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .markSuccess('Open Inventory Count Search Screen Check All Fields Successful.').wait(500)

        //#10
        .displayText('"======== 10. Click New, Check Inventory Count Screen Fields. ========"')
        .clickButton('#btnNew').wait(1000)
        .checkControlVisible(['#btnNew', '#btnSave', '#btnDelete', '#btnUndo','#btnPrintCountSheets', '#btnClose'], true).wait(500)
        .checkControlVisible(['#cboLocation', '#cboCategory', '#cboCommodity', '#cboCountGroup', '#dtpCountDate'], true).wait(500)
        .checkControlVisible(['#txtCountNumber', '#cboSubLocation', '#cboStorageLocation', '#txtDescription', '#btnFetch'], true).wait(500)
        .checkControlVisible(['#chkIncludeZeroOnHand', '#chkIncludeOnHand', '#chkScannedCountEntry', '#chkCountByLots', '#chkCountByPallets'], true).wait(500)
        .checkControlVisible(['#chkRecountMismatch', '#chkExternal', '#chkRecount', '#txtReferenceCountNo', '#cboStatus'], true).wait(500)
        .checkControlVisible(['#btnInsert', '#btnRemove','#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid' ], true).wait(500)
        .clickTab('#pgeComments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnOpenActivity', '#btnNewEvent', '#btnNewTask', '#btnNewComment', '#btnLogCall', '#btnSendEmail','#btnGridLayout', '#btnInsertCriteria','#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .clickTab('#pgeAttachments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnAddAttachment', '#btnOpenAttachment', '#btnEditAttachment', '#btnDownloadAttachment', '#btnDeleteAttachment'], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(500)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        .clickMessageBoxButton('no').wait(300)
        .checkIfScreenClosed('icinventorycount').wait(300)


        //#10.1
        .displayText('"======== 10.1. Open New Inventory Count Group Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnCountGroup').wait(500)
        .waitTillVisible('inventorycountgroup','Open New Iinventorycountgroup Screen Successful').wait(1000)
        .checkControlVisible(['#txtCountGroup', '#txtCountsPerYear', '#chkIncludeOnHand', '#chkScannedCountEntry', '#chkCountByLots','#chkCountByPallets', '#chkRecountMismatch','#chkExternal'], true).wait(500)
        .clickButton('#btnClose').wait(500)
        .checkIfScreenClosed('inventorycountgroup').wait(300)
        .markSuccess('Click New, Check Inventory Count Screen Fields Successful.').wait(500)


        //#11 Storage Measurement Reading Screen

        .displayText('"======== 11. Open Storage Measurement Reading Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Storage Measurement Reading').wait(1000)
        .waitTillLoaded('Open Storage Measurement Reading Screen Successful').wait(500)
        .clickButton('#btnNew').wait(200)
        .waitTillLoaded('Open New Storage Measurement Reading Screen Successful').wait(1000)
        .markSuccess('======== Open Storage Measurement Reading Search Screen Check All Fields Successful. ========').wait(500)

        //#12
        .displayText('"======== 12. Click New, Storage Measurement Reading Screen Check All Fields. ========"').wait(500)
        .checkControlVisible(['#btnNew', '#btnSave', '#btnSearch','#btnDelete', '#btnUndo', '#btnClose'], true).wait(500)
        .checkControlVisible(['#cboLocation', '#dtmDate', '#txtReadingNumber'], true).wait(500)
        .checkControlVisible(['#btnInsert', '#btnRemove','#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid' ], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(500)
        .waitTillLoaded().wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(1000)
        .clickMessageBoxButton('no').wait(1000)
        .markSuccess('======== Click New, Check Storage Measurement Reading Screen Fields Successful. ========').wait(500)


        //#13 Item Screen

        .displayText('"======== 13. Open Items Search Screen Check All Fields ========"').wait(500)
        .openScreen('Items').wait(1000)
        .waitTillLoaded('Open Items Search Screen Successful').wait(500)
        .clickTab('Locations').wait(500)
        .waitTillLoaded('Open Items Search Screen Locations Tab Successful').wait(500)
        .clickTab('Pricing').wait(500)
        .waitTillLoaded('Open Items Search Screen Pricing Tab Successful').wait(500)
        .checkScreenWindow({ alias: 'icitems', title: 'Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true }).wait(1000)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(100)
        .markSuccess('======== Open Items Search Screen Check All Fields Successful. ========').wait(500)

        //#14
        .displayText('"======== 14. Click New, Items Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
        .checkScreenShown('icitem').wait(500)
        .checkControlVisible(['#btnNew', '#btnSave', '#btnFind', '#btnDelete', '#btnUndo','#btnDuplicate','#btnClose'], true).wait(500)
        .checkControlVisible(['#txtItemNo', '#cboType', '#txtShortName', '#txtDescription', '#cboManufacturer','#cboStatus','#cboCommodity','#cboLotTracking','#cboBrand','#txtModelNo','#cboCategory','#cboTracking'], true).wait(500)
        .checkControlVisible(['#btnInsertUom', '#btnDeleteUom', '#btnLoadUOM', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        //.checkControlVisible(['#colDetailUnitMeasure','#coLDetailUnitQty', '#coLDetailShortUPC','#colDetailUpcCode', '#coLStockUnit', '#colAllowPurchase','#colDetailLength','#colDetailWidth','#colDetailHeight' ], true).wait(500)
        .checkControlVisible(['#colDetailDimensionUOM', '#colDetailVolume', '#colDetailWeight', '#colDetailWeightUOM', '#colDetailMaxQty'], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .checkStatusMessage('Ready')
        //Setup Tabs
        .clickTab('#cfgSetup').wait(500)
        .checkControlVisible(['#btnAddRequiredAccounts', '#btnInsertGlAccounts', '#btnDeleteGlAccounts', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)

        .clickTab('#cfgLocation').wait(500)
        .checkControlVisible(['#btnAddLocation', '#btnAddMultipleLocation', '#btnEditLocation', '#btnDeleteLocation', '#cboCopyLocation', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)

        .clickTab('#cfgSales').wait(500)
        .checkControlVisible(['#chkStockedItem', '#chkDyedFuel', '#cboBarcodePrint', '#chkMsdsRequired', '#txtEpaNumber', '#chkInboundTax', '#chkOutboundTax', '#chkRestrictedChemical','#chkFuelItem'], true).wait(500)
        .checkControlVisible(['#pnlRins', '#cboFuelInspectionFee', '#cboRinRequired', '#cboFuelCategory', '#txtPercentDenaturant'], true).wait(500)
        .checkControlVisible(['#pnlFeed', '#chkTonnageTax', '#chkLoadTracking', '#txtMixOrder', '#chkHandAddIngredients','#cboMedicationTag', '#cboIngredientTag','#txtVolumeRebateGroup'], true).wait(500)
        .checkControlVisible(['#cboPhysicalItem', '#chkExtendOnPickTicket', '#chkExportEdi', '#chkHazardMaterial', '#chkMaterialFee','#chkAutoBlend','#txtUserGroupFee','#txtWgtTolerance','#txtOverReceiveTolerance','#txtMaintenanceCalculationMethod','#txtMaintenanceRate'], true).wait(500)

        .clickTab('#cfgPOS').wait(500)
        .checkControlVisible(['#pnlGeneral', '#txtNacsCategory', '#cboWicCode', '#chkReceiptCommentReq', '#cboCountCode'], true).wait(500)
        .checkControlVisible(['#pnlInventorySetup', '#chkLandedCost', '#txtLeadTime', '#chkTaxable', '#txtKeywords','#txtCaseQty','#dtmDateShip','#txtTaxExempt','#chkDropShip'], true).wait(500)
        .checkControlVisible(['#pnlCommissionDetail', '#chkCommissionable', '#chkSpecialCommission'], true).wait(500)
        .checkControlVisible(['#grdCategory', '#btnInsertCategories', '#btnDeleteCategories', '#colPOSCategoryName'], true).wait(500)
        .checkControlVisible(['#grdServiceLevelAgreement', '#btnInsertSLA', '#btnDeleteSLA', '#colPOSSLAContract', '#colPOSSLAPrice','#colPOSSLAWarranty'], true).wait(500)

        .clickTab('#cfgContract').wait(500)
        .checkControlVisible(['#btnInsertContractItem', '#btnDeleteContractItem','#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid' ], true).wait(500)
        .checkControlVisible(['#grdContractItem','#colContractLocation', '#colContractItemName','#colContractOrigin', '#colContractGrade', '#colContractGradeType','#colContractGarden','#colContractYield','#colContractTolerance','#colContractFranchise' ], true).wait(500)
        .checkControlVisible(['#grdDocumentAssociation','#btnInsertDocumentAssociation', '#btnDeleteDocumentAssociation','#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid','#colDocument' ], true).wait(500)
        .checkControlVisible(['#grdCertification','#btnInsertCertification', '#btnDeleteCertification','#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid','#colCertification' ], true).wait(500)

        .clickTab('#cfgXref').wait(500)
        .waitTillLoaded('').wait(100)
        //.checkControlVisible(['#btnInsertCustomerXrf', '#btnDeleteCustomerXrf','#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid' ], true).wait(500)
        .checkControlVisible(['#grdCustomerXref','#colCustomerXrefLocation', '#colCustomerXrefCustomer','#colCustomerXrefProduct', '#colCustomerXrefDescription', '#colCustomerXrefPickTicketNotes' ], true).wait(500)
        //.checkControlVisible(['#btnInsertVendorXrf', '#btnDeleteVendorXrf','#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid' ], true).wait(500)
        //.checkControlVisible(['#grdVendorrXref','#colVendorXrefLocation', '#colVendorXrefVendor','#colVendorXrefProduct', '#colVendorXrefDescription', '#colVendorXrefConversionFactor','#colVendorXrefUnitMeasure' ], true).wait(500)

        .clickTab('#cfgMotorFuelTax').wait(500)
        .waitTillLoaded('').wait(100)
        //.checkControlVisible(['#btnInsertCustomerXrf', '#btnDeleteCustomerXrf','#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid' ], true).wait(500)
        .checkControlVisible(['#grdCustomerXref','#colCustomerXrefLocation', '#colCustomerXrefCustomer','#colCustomerXrefProduct', '#colCustomerXrefDescription', '#colCustomerXrefPickTicketNotes' ], true).wait(500)

        .clickTab('#cfgOthers').wait(500)
        .waitTillLoaded('').wait(100)
        .checkControlVisible(['#txtInvoiceComments', '#txtPickListComments','#chkTankRequired', '#chkAvailableForTm', '#txtDefaultPercentFull','#cboPatronage','#cboPatronageDirect' ], true).wait(500)

        .clickTab('#cfgPricing').wait(500)
        .waitTillLoaded('').wait(100)
        //.checkControlVisible(['#btnInsertPricing', '#btnDeletePricing','#btnGridLayout', '#btnInsertCriteria', '#txtFilterField' ], true).wait(500)
        .checkControlVisible(['#grdPricingLevel', '#btnInsertPricingLevel','#btnDeletePricingLevel', '#btnGridLayout', '#btnInsertCriteria','#txtFilterGrid' ], true).wait(500)

        .clickTab('Promotional Pricing')
        .waitTillLoaded('').wait(100)

        .clickTab('#cfgStock').wait(500)
        .waitTillLoaded('').wait(100)
        .checkControlVisible(['#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid' ], true).wait(500)

        //.clickTab('#cfgCommodity').wait(500)
        //.checkControlVisible(['#txtGaShrinkFactor', '#cboOrigin','#cboProductType', '#cboRegion', '#cboSeason','#cboClass','#cboProductLine','#cboGrade','#cboMarketValuation' ], true).wait(500)
       //.checkControlVisible(['#btnInsertCommodityCost','#btnDeleteCommodityCost','#btnGridLayout', '#btnInsertCriteria', '#txtFilterField' ], true).wait(500)

        .clickTab('#pgeComments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnOpenActivity', '#btnNewEvent', '#btnNewTask', '#btnNewComment', '#btnLogCall', '#btnSendEmail','#btnGridLayout','#btnInsertCriteria','#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)
        .clickTab('#pgeAttachments').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnAddAttachment', '#btnOpenAttachment', '#btnEditAttachment', '#btnDownloadAttachment', '#btnDeleteAttachment'], true).wait(500)
        .clickTab('#pgeAuditLog').wait(500)
        .waitTillLoaded('').wait(200)
        .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(500)
        .clickMessageBoxButton('no').wait(500)
        .checkIfScreenClosed('icitem').wait(500)
        .waitTillLoaded('').wait(500)
        .displayText('Checking item Screen Fields Successful').wait(500)
        .markSuccess('======== Click New, Check Items Screen Fields Successful. ========').wait(500)


        //#15 Commodities Screen

        .displayText('"======== 15. Open Commodities Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Commodities').wait(1000)
        .waitTillLoaded('Open Commodities Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(100)
        .markSuccess('Open Commodities Search Screen Check All Fields Successful.').wait(500)


        //#16
        .displayText('"======== 16. Click New, Commodity Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnNew').wait(200)
        .waitTillVisible('iccommodity','Open New Item Screen Successful').wait(500)
        .checkScreenShown('iccommodity').wait(500)
        .checkControlVisible(['#btnNew', '#btnSave','#btnFind', '#btnDelete', '#btnUndo','#btnClose' ], true).wait(500)
        .checkControlVisible(['#txtCommodityCode', '#txtDescription','#chkExchangeTraded', '#txtDecimalsOnDpr', '#cboFutureMarket','#txtConsolidateFactor','#chkFxExposure','#txtPriceChecksMin','#txtPriceChecksMax' ], true).wait(500)
        .checkControlVisible(['#dtmCropEndDateCurrent', '#dtmCropEndDateNew','#txtEdiCode', '#cboDefaultScheduleStore', '#cboDefaultScheduleDiscount','#cboScaleAutoDistDefault'], true).wait(500)
        .checkControlVisible(['#btnDeleteUom', '#btnGridLayout','#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .clickTab('#pgeAttributes').wait(500)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity').wait(100)
        .displayText('Checking Commodity Screen Fields Successful').wait(500)
        .markSuccess('======== Click New, Check Commodity Screen Fields Successful. ========').wait(500)


        //#17 Categories Screen

        .displayText('"======== 17. Open Categories Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Categories').wait(1000)
        .waitTillLoaded('Open Categories Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(100)
        .markSuccess('Open Categories Search Screen Check All Fields Successful.').wait(500)


        //#18
        .displayText('"======== 18. Click New, Category Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnNew').wait(200)
        .waitTillLoaded('Open new Category Screen Successful')
        .checkScreenShown('iccategory').wait(500)
        .checkControlVisible(['#btnNew', '#btnSave','#btnFind', '#btnDelete', '#btnUndo','#btnClose' ], true).wait(500)
        .checkControlVisible(['#txtCategoryCode', '#txtDescription','#cboInventoryType', '#cboLineOfBusiness', '#cboCostingMethod' ], true).wait(500)
        .checkControlVisible(['#cboInventoryValuation','#txtGlDivisionNumber','#chkSalesAnalysisByTon','#txtStandardQty','#cboStandardUOM' ], true).wait(500)
        .checkControlVisible(['#btnInsertTax', '#btnDeleteTax','#btnGridLayout','#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#btnDeleteUom', '#btnGridLayout','#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .clickTab('#pgeLocations').wait(500)
        .checkControlVisible(['#btnAddLocation', '#btnEditLocation', '#btnDeleteLocation','#btnGridLayout','#btnInsertCriteria','#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)
        .clickTab('#pgGLAccounts').wait(500)
        .checkControlVisible(['#btnAddRequired', '#btnDeleteGlAccounts', '#btnGridLayout','#btnInsertCriteria','#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)
        .clickTab('#pgeVendorCategory').wait(500)
        .checkControlVisible(['#btnDeleteVendorCategoryXref', '#btnGridLayout','#btnInsertCriteria','#txtFilterGrid','#btnMaximizeGrid'], true).wait(500)
        .clickTab('#pgeManufacturing').wait(500)
        .checkControlVisible(['#txtERPItemClass', '#txtLifeTime','#txtBOMItemShrinkage', '#txtBOMItemUpperTolerance', '#txtBOMItemLowerTolerance','#chkScaled','#chkOutputItemMandatory','#txtConsumptionMethod' ], true).wait(500)
        .checkControlVisible(['#txtBOMItemType', '#txtShortName','#txtLaborCost', '#txtOverHead', '#txtPercentage','#txtCostDistributionMethod','#chkSellable','#chkYieldAdjustment', '#chkTrackedInWarehouse' ], true).wait(500)
        .displayText('Check Category Screen Fields Successful')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccategory').wait(100)
        .displayText('Checking Category Screen Fields Successful').wait(500)
        .markSuccess('======== Click New, Check Category Screen Fields Successful. ========').wait(500)



        //#19 Fuel Types Screen
        .displayText('"======== 19. Open Fuel Types Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Fuel Types').wait(1000)
        .waitTillLoaded('Open Fuel Types Search Screen Successful').wait(500)
        .markSuccess('Open Fuel Types Search Screen Check All Fields Successful.').wait(500)


        //#20
        .displayText('"======== 20. Click New, Fuel Types Screen Check All Fields. ========"').wait(500)
        .checkControlVisible(['#btnNew', '#btnSave', '#btnSearch','#btnDelete', '#btnUndo', '#btnClose'], true).wait(500)
        .checkControlVisible(['#cboFuelCategory', '#cboFeedStock', '#txtBatchNo', '#txtEndingRinGallonsForBatch'], true).wait(500)
        .checkControlVisible(['#txtEquivalenceValue','#cboFuelCode', '#cboProductionProcess','#cboFeedStockUom','#txtFeedStockFactor','#chkRenewableBiomass','#txtPercentOfDenaturant'], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(500)

        //#20.1
        .displayText('"======== 10.1. Open New Fuel Category  Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnFuelCategory').wait(500)
        .waitTillVisible('icfuelcategory','Open New Fuel Category Screen Successful').wait(1000)
        .checkControlVisible(['#btnSave', '#btnUndo', '#btnClose'], true).wait(500)
        .checkControlVisible(['#btnInsert', '#btnDelete', '#btnGridLayout','#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#colRinFuelCategoryCode', '#colDescription', '#colEquivalenceValue'], true).wait(500)
        .clickButton('#btnClose').wait(500)
        .checkIfScreenClosed('icfuelcategory').wait(300)
        .markSuccess('Check New Fuel Category Screen Fields Successful.').wait(500)

        //#20.2
        .displayText('"======== 20.2. Open New Feed Stock  Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnFeedStock').wait(500)
        .waitTillVisible('icfeedstockcode','Open New Feed Stock Screen Successful').wait(1000)
        .checkControlVisible(['#btnSave', '#btnUndo', '#btnClose'], true).wait(500)
        .checkControlVisible(['#btnInsert', '#btnDelete', '#btnGridLayout','#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#colRinFeedStockCode', '#colDescription'], true).wait(500)
        .clickButton('#btnClose').wait(500)
        .checkIfScreenClosed('icfeedstockcode').wait(300)
        .markSuccess('Check New Feed Stock Screen Fields Successful.').wait(500)

        //#20.3
        .displayText('"======== 20.3. Open New Fuel Code  Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnFuelCode').wait(500)
        .waitTillVisible('icfuelcode','Open New Fuel Code Screen Successful').wait(1000)
        .checkControlVisible(['#btnSave', '#btnUndo', '#btnClose'], true).wait(500)
        .checkControlVisible(['#btnInsert', '#btnDelete', '#btnGridLayout','#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#colRinFuelCode', '#colDescription'], true).wait(500)
        .clickButton('#btnClose').wait(500)
        .checkIfScreenClosed('btnFuelCode').wait(300)
        .markSuccess('Check New Fuel Code Screen Fields Successful.').wait(500)

        //#20.4
        .displayText('"======== 20.4. Open New Production Process  Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnProductionProcess').wait(500)
        .waitTillVisible('icprocesscode','Open New Production Process Screen Successful').wait(1000)
        .checkControlVisible(['#btnSave', '#btnUndo', '#btnClose'], true).wait(500)
        .checkControlVisible(['#btnInsert', '#btnDelete', '#btnGridLayout','#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#colRinProcessCode', '#colDescription'], true).wait(500)
        .clickButton('#btnClose').wait(500)
        .checkIfScreenClosed('btnFuelCode').wait(300)
        .markSuccess('Check New Production Process Screen Fields Successful.').wait(500)

        //#20.5
        .displayText('"======== 20.4. Open New Feed Stock UOM  Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnFeedStockUOM').wait(500)
        .waitTillVisible('icfeedstockuom','Open New Production Process Screen Successful').wait(1000)
        .checkControlVisible(['#btnSave', '#btnUndo', '#btnClose'], true).wait(500)
        .checkControlVisible(['#btnInsert', '#btnDelete', '#btnGridLayout','#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#colUOM', '#colRinFeedStockUOMCode'], true).wait(500)
        .clickButton('#btnClose').wait(500)
        .checkIfScreenClosed('btnFuelCode').wait(300)
        .markSuccess('Check New Feed Stock UOM  Screen Fields Successful.').wait(500)
        .markSuccess('"======== Click New, Check Fuel Types Screen Fields Successful. ========"').wait(500)


        //#21Inventory OM's Screen

        .displayText('"======== 21. Open Inventory UOMs Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Inventory UOM').wait(1000)
        .waitTillLoaded('Open Fuel Types Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(100)
        .markSuccess('======== Open Inventory UOMs Search Screen Check All Fields Successful. ========').wait(500)


        //#22
        .displayText('"======== 22. Click New, Inventory UOM Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnNew').wait(500)
        .checkControlVisible(['#btnNew', '#btnSave','#btnDelete', '#btnUndo', '#btnClose'], true).wait(500)
        .checkControlVisible(['#txtUnitMeasure', '#txtSymbol', '#cboUnitType'], true).wait(500)
        .checkControlVisible(['#grdConversion','#btnInsertConversion', '#btnDeleteConversion', '#btnGridLayout','#btnInsertCriteria', '#txtFilterGrid'], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .checkStatusMessage('Ready').wait(200)
        .clickButton('#btnClose').wait(500)
        .markSuccess('======== Click New, Check Inventory UOM Screen Fields Successful. ========').wait(500)


        //23 Storage Locations Screen

        .displayText('"======== 23. Open Storage Locations Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Storage Locations').wait(1000)
        .waitTillLoaded('Open Fuel Types Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(100)
        .markSuccess('======== Open IOpen Storage Locations Search Screen Check All Fields Successful. ========').wait(500)


        //#24
        .displayText('"======== 24. Click New, Open Storage Locations Screen Check All Fields. ========"').wait(500)
        .clickButton('#btnNew').wait(500)
        .checkControlVisible(['#btnNew', '#btnSave', '#btnSearch','#btnDelete', '#btnUndo', '#btnClose'], true).wait(500)
        .checkControlVisible(['#txtName', '#txtDescription', '#cboUnitType', '#cboLocation', '#cboSubLocation', '#cboParentUnit', '#cboRestrictionType','#txtAisle', '#txtMinBatchSize', '#txtBatchSize', '#cboBatchSizeUom'], true).wait(500)
        .checkControlVisible(['#chkAllowConsume', '#chkAllowMultipleItems', '#chkAllowMultipleLots', '#chkMergeOnMove', '#chkCycleCounted', '#chkDefaultWarehouseStagingUnit'], true).wait(500)
        .checkControlVisible(['#cboCommodity', '#txtPackFactor', '#txtEffectiveDepth', '#txtUnitsPerFoot', '#txtResidualUnits'], true).wait(500)
        .checkControlVisible(['#txtSequence', '#chkActive', '#txtXPosition', '#txtYPosition', '#txtZPosition'], true).wait(500)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true).wait(500)
        .checkStatusMessage('Ready').wait(200)
        .clickTab('#pgeMeasurement').wait(500)
        .checkControlVisible(['#btnAddMeasurement', '#btnDeleteMeasurement', '#colMeasurement','#colReadingPoint','#colActive'], true).wait(500)
        .clickTab('#pgeItemCategoriesAllowed').wait(500)
        .checkControlVisible(['#btnDeleteItemCategoryAllowed', '#colCategory'], true).wait(500)
        .clickTab('#pgeContainer').wait(500)
        .checkControlVisible(['#btnDeleteContainer', '#colContainer', '#colExternalSystem','#colContainerType'], true).wait(500)
        .clickTab('#pgeSKU').wait(500)
        .checkControlVisible(['#btnDeleteSKU', '#colItem', '#colSku','#colQty','#colContainer','#colLotSerial', '#colExpiration', '#colStatus'], true).wait(500)
        .clickButton('#btnClose').wait(500)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question').wait(500)
        .clickMessageBoxButton('no').wait(100)
        .markSuccess('======== Click New, Check Open Storage Screen Fields Successful. ========').wait(500)


        //25 Stock Details Screen
        .displayText('"======== 25. Open Stock Details Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Stock Details').wait(1000)
        .waitTillLoaded('Open Stock Details Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: false, view: false, open: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .clickTab('Storage Bins').wait(500)
        .waitTillLoaded('Open Stock Details Search Screen Details Tab Successful').wait(500)
        .markSuccess('======== Open Stock Details Search Screen Check All Fields Successful. ========').wait(500)


        //#26 Lot Details Screen

        .displayText('"======== 26. Open Lot Details Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Lot Details').wait(1000)
        .waitTillLoaded('Open Lot Details Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: false, view: false, open: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .markSuccess('======== Open Lot Details Search Screen Check All Fields Successful. ========').wait(500)


        //#27 Inventory Valuation Screen

        .displayText('"======== 27. Open Inventory Valuation Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Inventory Valuation').wait(1000)
        .waitTillLoaded('Open Lot Details Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: false, view: false, open: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .markSuccess('======== Open Inventory Valuation Search Screen Check All Fields Successful. ========').wait(500)


        //28 Inventory Valuation Screen
        .displayText('"======== 28. Open Inventory Valuation Summary Search Screen Check All Fields. ========"').wait(500)
        .openScreen('Inventory Valuation Summary').wait(1000)
        .waitTillLoaded('Open Lot Details Search Screen Successful').wait(500)
        .checkSearchToolbarButton({ new: false, view: false, open: false, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(500)
        .markSuccess('Open Inventory Valuation Summary Search Screen Check All Fields Successful.').wait(500)

        .markSuccess('"======== Open Inventory Screens and Checking Fields done. ========="').wait(500)


        .done();
});



