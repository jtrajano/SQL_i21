StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1. Open IC Screens and check fields.
        .displayText('=====  Scenario 1. Open IC Screens and check fields. ====')
        .displayText('=====  1.1 Open Inventory Receipt and Check Screen Fields ====')
        //IR Search Screen
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strReceiptNumber', text: 'Receipt No'},
            { dataIndex: 'dtmReceiptDate', text: 'Receipt Date'},
            { dataIndex: 'strReceiptType', text: 'Order Type'},
            { dataIndex: 'strVendorName', text: 'Vendor Name'},
            { dataIndex: 'strLocationName', text: 'Location Name'},
            { dataIndex: 'strBillOfLading', text: 'Bill Of Lading No'},
            { dataIndex: 'ysnPosted', text: 'Posted'}
        ])
        .clickTab('Details')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strReceiptNumber', text: 'Receipt No'},
            { dataIndex: 'strReceiptType', text: 'Order Type'},
            { dataIndex: 'ysnPosted', text: 'Posted'},
            { dataIndex: 'strShipFrom', text: 'Ship From'}

        ])
        .clickTab('Lots')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strReceiptNumber', text: 'Receipt No'},
            { dataIndex: 'strReceiptType', text: 'Order Type'}

        ])
        .clickTab('Vouchers')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string' },
            { dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
            { dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string' }
        ])
        //IR New Screen
        .clickTab('Inventory Receipt')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .isControlVisible('tlb',
        [
            'New'
            ,'Save'
            ,'Search'
            ,'Delete'
            ,'Undo'
            ,'Print'
            ,'Receive'
            ,'Recap'
            ,'Close'
        ], true)
        .isControlVisible('cbo',
        [
            'ReceiptType'
            ,'SourceType'
            ,'Vendor'
            ,'Location'
            ,'Currency'
            ,'Receiver'
            ,'FreightTerms'
            ,'TaxGroup'
            ,'ShipFrom'
            ,'ShipVia'
        ], true)
        .isControlVisible('txt',
        [
            ,'ReceiptNumber'
            ,'BillOfLadingNumber'
            ,'VendorRefNumber'
            ,'FobPoint'
            ,'ShiftNumber'
            ,'BlanketReleaseNumber'
            ,'Vessel'
        ], true)
        .isControlVisible('btn',
        [
            ,'InsertInventoryReceipt'
            ,'Quality'
            ,'TaxDetails'
            ,'RemoveInventoryReceipt'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)

        .isControlVisible('col',
        [
            ,'ItemNo'
            ,'Description'
            ,'UOM'
            ,'QtyToReceive'
            ,'ItemSubCurrency'
            ,'UnitCost'
            ,'WeightUOM'
            ,'Gross'
            ,'Net'
            ,'LineTotal'
            ,'Tax'
            ,'SubLocation'
            ,'StorageLocation'
            ,'Grade'
            ,'DiscountSchedule'
            ,'UnitRetail'
            ,'GrossMargin'
            ,'OwnershipType'
            ,'LotTracking'
        ], true)
        //IR Charges Tab
        //.clickTab('FreightInvoice')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('btn',
        [
            'InsertCharge'
            ,'RemoveCharge'
            ,'CalculateCharges'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('col',
        [
            ,'OtherCharge'
            ,'OnCostType'
            ,'CostMethod'
            ,'ChargeCurrency'
            ,'Rate'
            ,'ChargeUOM'
            ,'ChargeAmount'
            ,'Accrue'
            ,'CostVendor'
            ,'InventoryCost'
            ,'AllocateCostBy'
            ,'Price'
            ,'ChargeTax'
        ], true)
        //IR Incoming Inspection Tab
        .clickTab('Incoming Inspection')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'SelectAll'
            ,'ClearAll'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('col',
        [
            ,'Inspect'
            ,'QualityPropertyName'
        ], true)
        //IR EDI Tab
        .clickTab('EDI')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            ,'TrailerArrivalDate'
            ,'TrailerArrivalTime'
            ,'SealNo'
            ,'ReceiveTime'
            ,'ActualTempReading'
        ], true)
        .isControlVisible('cbo',
        [
            'ReceiptType'
            ,'SourceType'
            ,'Vendor'
            ,'Location'
            ,'Currency'
            ,'Receiver'
            ,'FreightTerms'
            ,'TaxGroup'
            ,'ShipFrom'
            ,'ShipVia'
        ], true)
        .isControlVisible('btn',
        [
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        //IR Comments Tab
        //.clickTab('Comments')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            ,'Created'
            ,'Start'
            ,'Category'
        ], true)
        .isControlVisible('btn',
        [
            'OpenActivity'
            ,'NewEvent'
            ,'NewTask'
            ,'NewComment'
            ,'LogCall'
            ,'SendEmail'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        //.clickTab('Attachments')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddAttachment'
            ,'OpenAttachment'
            ,'EditAttachment'
            ,'DownloadAttachment'
            ,'DeleteAttachment'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        //.clickTab('AuditLog')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('btn',
        [
            'InsertCriteria'
        ], true)
        .clickTab('Details')
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','CORN','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 100,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Gross is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblNetWgt').text;
            if (total == 'Net: 100,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-011')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('=====  1.1 Open Inventory Receipt and Check Screen Fields Done ====')


        //Inventory Shipment Search Screen
        .displayText('=====  1.2 Open Inventory Shipments and Check Screen Fields ====')
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strShipmentNumber', text: 'Shipment Number'},
            {dataIndex: 'dtmShipDate', text: 'Ship Date'},
            {dataIndex: 'strOrderType', text: 'Order Type'},
            {dataIndex: 'strSourceType', text: 'Source Type'},
            {dataIndex: 'strCustomerNumber', text: 'Customer'},
            {dataIndex: 'strCustomerName', text: 'Customer Name'},
            {dataIndex: 'ysnPosted', text: 'Posted'}
        ])
        .clickTab('Details')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
//        .verifyGridColumnNames('Search', [
//            {dataIndex: 'strShipmentNumber', text: 'Shipment Number'},
//            {dataIndex: 'dtmShipDate', text: 'Ship Date'},
//            {dataIndex: 'strOrderType', text: 'Order Type'},
//            {dataIndex: 'strSourceType', text: 'Source Type'},
//            {dataIndex: 'strItemNo', text: 'Item No'},
//            {dataIndex: 'strItemDescription', text: 'Description'},
//
//            {dataIndex: 'strOrderNumber', text: 'Order Number'},
//            {dataIndex: 'strSourceNumber', text: 'Source Number'},
//            {dataIndex: 'strUnitMeasure', text: 'Ship UOM'},
//
//            {dataIndex: 'dblQtyToShip', text: 'Quantity'},
//            {dataIndex: 'dblPrice', text: 'Unit Price'},
//            {dataIndex: 'dblLineTotal', text: 'Line Total'}
//
//        ])
        .clickTab('Lots')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
//        .verifyGridColumnNames('Search', [
//            {dataIndex: 'strShipmentNumber', text: 'Shipment Number'},
//            {dataIndex: 'dtmShipDate', text: 'Ship Date'},
//            {dataIndex: 'strOrderType', text: 'Order Type'},
//            {dataIndex: 'strSourceType', text: 'Source Type'},
//            {dataIndex: 'strItemNo', text: 'Item No'},
//            {dataIndex: 'strItemDescription', text: 'Description'},
//            {dataIndex: 'strLotNumber', text: 'Lot Number'},
//            {dataIndex: 'strSubLocationName', text: 'Sub Location'},
//            {dataIndex: 'strStorageLocationName', text: 'Storage Location'},
//            {dataIndex: 'strLotUOM', text: 'Lot UOM'},
//            {dataIndex: 'dblLotQty', text: 'Lot Qty'},
//            {dataIndex: 'dblGrossWeight', text: 'Gross Wgt'},
//            {dataIndex: 'dblTareWeight', text: 'Tare Wgt'},
//            {dataIndex: 'dblNetWeight', text: 'Net Wgt'}
//        ])
        //New IS Screen
        .clickTab('Inventory Shipment')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .isControlVisible('tlb',
        [
            'New'
            ,'Save'
            ,'Search'
            ,'Delete'
            ,'Undo'
            ,'Print'
            ,'PrintBOL'
            ,'Ship'
            ,'Recap'
            ,'Customer'
            ,'WarehouseInstruction'
            ,'Close'
        ], true)
        .isControlVisible('cbo',
        [
            'OrderType'
            ,'SourceType'
            ,'Customer'
            ,'#cboFreightTerms'
            ,'#cboShipFromAddress'
            ,'#cboShipToAddress'
        ], true)
        .isControlVisible('txt',
        [
            ,'#txtReferenceNumber'
            ,'#txtShipmentNo'
            ,'#txtShipFromAddress'
            ,'#txtShipToAddress'
            ,'#txtDeliveryInstructions'
            ,'#txtComments'
        ], true)
        .isControlVisible('btn',
        [
            'InsertItem'
            ,'ViewItem'
            ,'Quality'
            ,'RemoveItem'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('col',
        [
            ,'ItemNo'
            ,'Description'
            ,'CustomerStorage'
            ,'UOM'
            ,'Quantity'
            ,'UnitPrice'
            ,'UnitCost'
            ,'LineTotal'
            ,'WeightUOM'
            ,'OwenerShipType'
            ,'SubLocation'
            ,'StorageLocation'
            ,'Grade'
            ,'DiscountSchedule'
            ,'DockDoor'
            ,'Notes'
        ], true)
        .isControlVisible('dtm',
        [
            'ShipDate'
            ,'RequestedArrival'
        ], true)
        //IS ShippingCompany Tab
        .waitUntilLoaded()
        .clickTab('Shipping Company')
        .isControlVisible('txt',
        [
            'BOLNo'
            ,'ProNumber'
            ,'DriverID'
            ,'VesselVehicle'
            ,'SealNumber'
        ], true)
        .isControlVisible('cbo',
        [
            , 'ShipVia'
        ], true)

        //IS Delivery Tab
        .clickTab('Delivery')
        .isControlVisible('txt',
        [
            'AppointmentTime'
            ,'Delivered'
            ,'DepartureTime'
            ,'ArrivalTime'
            ,'ReceivedBy'
        ], true)
        .isControlVisible('dtm',
        [
            'FreeTime'
        ], true)

        //IS Charges Tab
        .clickTab('Charges')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('btn',
        [
            'InsertCharge'
            ,'RemoveCharge'
            ,'CalculateCharges'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('col',
        [
            ,'OtherCharge'
            ,'OnCostType'
            ,'CostMethod'
            ,'ChargeCurrency'
            ,'Rate'
            ,'CostUOM'
            ,'ChargeAmount'
            ,'Accrue'
            ,'CostVendor'
            ,'Price'
            ,'AllocatePriceBy'
        ], true)

        //IS Comments Tab
        //.clickTab('Comments')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            ,'Created'
            ,'Start'
            ,'Category'
        ], true)
        .isControlVisible('btn',
        [
            'OpenActivity'
            ,'NewEvent'
            ,'NewTask'
            ,'NewComment'
            ,'LogCall'
            ,'SendEmail'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)

        //IS Attachments Tab
        //.clickTab('Attachments')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddAttachment'
            ,'OpenAttachment'
            ,'EditAttachment'
            ,'DownloadAttachment'
            ,'DeleteAttachment'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)

        //IS Audit Log Tab
        //.clickTab('AuditLog')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('btn',
        [
            'InsertCriteria'
        ], true)
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('=====  1.2 Open Inventory Shipments and Check Screen Fields ====')

        //Inventory Transfers Search Screen
        .displayText('=====  1.3 Open Inventory Transfers and Check Screen Fields ====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strTransferNo', text: 'Transfer No'},
            {dataIndex: 'dtmTransferDate', text: 'Transfer Date'},
            {dataIndex: 'strTransferType', text: 'Transfer Type'},
            {dataIndex: 'strDescription', text: 'Description'},
            {dataIndex: 'strFromLocation', text: 'From Location'},
            {dataIndex: 'strToLocation', text: 'To Location'},
            {dataIndex: 'strStatus', text: 'Status'},
            {dataIndex: 'ysnPosted', text: 'Posted'}
        ])
        .clickTab('Details')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
//        .verifyGridColumnNames('Search', [
//            {dataIndex: 'strTransferNo', text: 'TransferNo'},
//            {dataIndex: 'strItemNo', text: 'ItemNo'},
//            {dataIndex: 'strItemDescription', text: 'ItemDescription'},
//            {dataIndex: 'strSourceNumber', text: 'SourceNumber'},
//            {dataIndex: 'strLotTracking', text: 'LotTracking'},
//            {dataIndex: 'strLotNumber', text: 'LotNumber'},
//            {dataIndex: 'strLifeTimeType', text: 'LifeTimeType'},
//            {dataIndex: 'intFromSubLocationId', text: 'FromSubLocationId'},
//            {dataIndex: 'strFromSubLocationName', text: 'FromSubLocationName'},
//            {dataIndex: 'intToSubLocationId', text: 'ToSubLocationId'},
//            {dataIndex: 'strToSubLocationName', text: 'ToSubLocationName'},
//            {dataIndex: 'strUnitMeasure', text: 'UnitMeasure'},
//            {dataIndex: 'dblItemUOMCF', text: 'ItemUOMCF'},
//            {dataIndex: 'strWeightUOM', text: 'WeightUOM'},
//            {dataIndex: 'dblWeightUOMCF', text: 'WeightUOMCF'},
//            {dataIndex: 'strAvailableUOM', text: 'AvailableUOM'}
//        ])

        .clickTab('Inventory Transfer')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .isControlVisible('tlb',
        [
            'New'
            ,'Save'
            ,'Search'
            ,'Delete'
            ,'Undo'
            ,'Print'
            ,'Post'
            ,'Recap'
            ,'Close'
        ], true)
        .isControlVisible('cbo',
        [
            'TransferType'
            ,'SourceType'
            ,'TransferredBy'
            ,'FromLocation'
            ,'ToLocation'
            ,'Status'
        ], true)
        .isControlVisible('txt',
        [
            'TransferNumber'
            ,'Description'
            ,'FilterGrid'
        ], true)
        .isControlVisible('dtm',
        [
            'TransferDate'
        ], true)
        .isControlVisible('btn',
        [
            ,'AddItem'
            ,'ViewItem'
            ,'RemoveItem'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)

        //IT Comments Tab
        //.clickTab('Comments')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            ,'Created'
            ,'Start'
            ,'Category'
        ], true)
        .isControlVisible('btn',
        [
            'OpenActivity'
            ,'NewEvent'
            ,'NewTask'
            ,'NewComment'
            ,'LogCall'
            ,'SendEmail'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)

        //IT Attachments Tab
        //.clickTab('Attachments')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddAttachment'
            ,'OpenAttachment'
            ,'EditAttachment'
            ,'DownloadAttachment'
            ,'DeleteAttachment'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)

        //IT Audit Log Tab
        //.clickTab('AuditLog')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('btn',
        [
            'InsertCriteria'
        ], true)
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('=====  1.3 Open Inventory Transfers and Check Screen Fields Done====')


        //Inventory Adjustments Search Screen
        .displayText('=====  1.4 Open Inventory Adjustments and Check Screen Fields ====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [

            {dataIndex: 'strLocationName', text: 'Location Name'},
            {dataIndex  : 'dtmAdjustmentDate', text: 'Adjustment Date'},
            {dataIndex: 'intAdjustmentType', text: 'Adjustment Type'},
            {dataIndex: 'strAdjustmentType', text: 'Adjustment Type'},
            {dataIndex: 'strAdjustmentNo', text: 'Adjustment No'},
            {dataIndex: 'strDescription', text: 'Description'},
            {dataIndex: 'ysnPosted', text: 'Posted'}
        ])
        .clickTab('Details')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .clickTab('Inventory Adjustment')
        .waitUntilLoaded()

        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .isControlVisible('tlb',
        [
            'New'
            ,'Save'
            ,'Search'
            ,'Delete'
            ,'Undo'
            ,'Print'
            ,'Post'
            ,'Recap'
            ,'Close'
        ], true)
        .isControlVisible('cbo',
        [
            ,'#cboLocation'
            ,'#cboAdjustmentType'
        ], true)
        .isControlVisible('txt',
        [
            'AdjustmentNumber'
            ,'Description'
            ,'FilterGrid'
        ], true)
        .isControlVisible('dtm',
        [
            'Date'
        ], true)
        //IA Comments Tab
        //.clickTab('Comments')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            ,'Created'
            ,'Start'
            ,'Category'
        ], true)
        .isControlVisible('btn',
        [
            'OpenActivity'
            ,'NewEvent'
            ,'NewTask'
            ,'NewComment'
            ,'LogCall'
            ,'SendEmail'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)

        //IA Attachments Tab
        //.clickTab('Attachments')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddAttachment'
            ,'OpenAttachment'
            ,'EditAttachment'
            ,'DownloadAttachment'
            ,'DeleteAttachment'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)

        //IA Audit Log Tab
        //.clickTab('AuditLog')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('btn',
        [
            'InsertCriteria'
        ], true)
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('=====  1.4 Open Inventory Adjustments and Check Screen Fields Done ====')


        //Inventory Count Search Screen
        .displayText('=====  1.5 Open Inventory Count and Check Screen Fields ====')
        .clickMenuScreen('Inventory Count','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strCountNo', text: 'Count No'},
            {dataIndex: 'strLocationName', text: 'Location'},
            {dataIndex: 'strCategory', text: 'Category'},
            {dataIndex: 'strCommodity', text: 'Commodity'},
            {dataIndex: 'strCountGroup', text: 'Count Group'},
            {dataIndex: 'dtmCountDate', text: 'Count Date'},
            {dataIndex: 'strSubLocationName', text: 'Sub Location'},
            {dataIndex: 'strStorageLocationName', text: 'Storage Location'},
            {dataIndex: 'strStatus', text: 'Status'}

        ])
        .clickButton('New')
        .waitUntilLoaded('')
        .isControlVisible('tlb',
        [
            'New'
            ,'Save'
            ,'Delete'
            ,'Undo'
            ,'PrintCountSheets'
            ,'Close'
        ], true)
        .isControlVisible('cbo',
        [
            'Location'
            ,'Category'
            ,'Commodity'
            ,'CountGroup'
            ,'SubLocation'
            ,'StorageLocation'
            ,'Status'
        ], true)
        .isControlVisible('chk',
        [
            'IncludeZeroOnHand'
            ,'IncludeOnHand'
            ,'ScannedCountEntry'
            ,'CountByLots'
            ,'CountByPallets'
            ,'RecountMismatch'
            ,'External'
            ,'Recount'
        ], true)
        .isControlVisible('txt',
        [
            'CountNumber'
            ,'Description'
            ,'ReferenceCountNo'
            ,'FilterGrid'
        ], true)
        .isControlVisible('btn',
        [
            'Fetch'
            ,'Insert'
            ,'Remove'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('col',
        [
            'Item'
            ,'Description'
            ,'Category'
            ,'SubLocation'
            ,'StorageLocation'
            ,'SystemCount'
            ,'LastCost'
            ,'CountLineNo'
            ,'PhysicalCount'
            ,'UOM'
            ,'PhysicalCountStockUnit'
            ,'Variance'
            ,'Recount'
            ,'EnteredBy'
        ], true)


        //IC Comments Tab
        //.clickTab('Comments')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            ,'Created'
            ,'Start'
            ,'Category'
        ], true)
        .isControlVisible('btn',
        [
            'OpenActivity'
            ,'NewEvent'
            ,'NewTask'
            ,'NewComment'
            ,'LogCall'
            ,'SendEmail'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)

        //IC Attachments Tab
        //.clickTab('Attachments')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddAttachment'
            ,'OpenAttachment'
            ,'EditAttachment'
            ,'DownloadAttachment'
            ,'DeleteAttachment'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('=====  1.5 Open Inventory Count and Check Screen Fields Done====')


        //Inventory Storage Measurement Reading Screen
        .displayText('=====  1.6 Open Storage Measurement Reading and Check Screen Fields ====')

        .clickMenuScreen('Storage Measurement Reading','Screen')
        .waitUntilLoaded()
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strLocationName',text: 'Location'},
            {dataIndex: 'dtmDate', text: 'Date'},
            {dataIndex: 'strReadingNo', text: 'Reading No'}
        ])
        .clickButton('New')
        .waitUntilLoaded()
        .isControlVisible('tlb',
        [
            'New'
            ,'Save'
            ,'Search'
            ,'Delete'
            ,'Undo'
            ,'Close'
        ], true)
        .isControlVisible('txt',
        [
            'ReadingNumber'
            ,'FilterGrid'
        ], true)
        .isControlVisible('cbo',
        [
            'Location'
        ], true)
        .isControlVisible('dtm',
        [
            ,'Date'
        ], true)
        .isControlVisible('btn',
        [
            'Insert'
            ,'Remove'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('col',
        [
            'Commodity'
            ,'Item'
            ,'StorageLocation'
            ,'SubLocation'
            ,'EffectiveDepth'
            ,'AirSpaceReading'
            ,'CashPrice'
            ,'DiscountSchedule'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('=====  1.6 Open Storage Measurement Reading and Check Screen Fields Done====')



        //Inventory Items Screen
        .displayText('=====  1.7 Open Items and Check Screen Fields ====')
        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
//        .verifyGridColumnNames('Search', [
//            {dataIndex: 'strItemNo', text: 'Item No'},
//            {dataIndex: 'strType', text: 'Type'},
//            {dataIndex: 'strDescription', text: 'Description'},
//            {dataIndex: 'strStatus', text: 'Status'},
//            {dataIndex: 'strTracking', text: 'Inv Valuation'},
//            {dataIndex: 'strLotTracking', text: 'Lot Tracking'},
//            {dataIndex: 'strCategory', text: 'Category'},
//            {dataIndex: 'strCommodity', text: 'Commodity'},
//            {dataIndex: 'strManufacturer', text: 'Manufacturer'}
//        ])
        .clickTab('Locations')
        .waitUntilLoaded()
//        .verifyGridColumnNames('Search', [
//            {dataIndex: 'strItemNo', text: 'Item No'},
//            {dataIndex: 'strItemDescription', text: 'Item Description'},
//            {dataIndex: 'strLocationName', text: 'Location Name'},
//            {dataIndex: 'strVendorId', text: 'Vendor Id'},
//            {dataIndex: 'strVendorName', text: 'Vendor Name'},
//            {dataIndex: 'strDescription', text: 'Description'},
//            {dataIndex: 'strCostingMethod', text: 'Costing Method'},
//            {dataIndex: 'strAllowNegativeInventory', text: 'Allow Negative Inventory'},
//            {dataIndex: 'strSubLocationName', text: 'SubLocation'},
//            {dataIndex: 'strStorageLocationName', text: 'Storage Location'},
//            {dataIndex: 'strIssueUOM', text: 'Issue UOM'}
//        ])
        .clickTab('Pricing')
        .waitUntilLoaded()
//        .verifyGridColumnNames('Search', [
//            {dataIndex: 'strItemNo', text: 'Item No'},
//            {dataIndex: 'strDescription', text: 'Description'},
//            {dataIndex: 'strUpcCode', text: 'Upc Code'},
//            {dataIndex: 'strLongUPCCode', text: 'Long UPC Code'},
//            {dataIndex: 'strLocationName', text: 'Location Name'},
//            {dataIndex: 'strUnitMeasure', text: 'Unit Measure'},
//            {dataIndex: 'dblUnitQty', text: 'Unit Qty'},
//            {dataIndex: 'dblAmountPercent', text: 'Amount/Percent'},
//            {dataIndex: 'dblSalePrice', text: 'Sale Price'},
//            {dataIndex: 'strPricingMethod', text: 'Pricing Method'},
//            {dataIndex: 'dblLastCost', text: 'Last Cost'},
//            {dataIndex: 'dblStandardCost', text: 'Standard Cost'},
//            {dataIndex: 'dblAverageCost', text: 'Average Cost'}
//
//        ])
        .clickTab('Item')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icitem')
        .isControlVisible('tlb',
        [
            'New'
            ,'Save'
            ,'Search'
            ,'Delete'
            ,'Undo'
            ,'Duplicate'
            ,'Close'
        ], true)
        .isControlVisible('txt',
        [
            'ItemNo'
            ,'ShortName'
            ,'Description'
            ,'ModelNo'
            ,'FilterGrid'
        ], true)
        .isControlVisible('cbo',
        [
            'Type'
            ,'Manufacturer'
            ,'Status'
            ,'Commodity'
            ,'LotTracking'
            ,'Brand'
            ,'Category'
            ,'Tracking'
        ], true)
        .isControlVisible('btn',
        [
            'InsertUom'
            ,'DeleteUom'
            ,'LoadUOM'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('col',
        [
            'DetailUnitMeasure'
            ,'DetailUnitQty'
            ,'DetailShortUPC'
            ,'DetailUpcCode'
            ,'StockUnit'
            ,'AllowPurchase'
            ,'AllowSale'
            ,'DetaiLength'
            ,'DetailWidth'
            ,'DetailHeight'
            ,'DetailDimensionUOM'
            ,'DetailVolume'
            ,'DetailVolumeUOM'
            ,'DetailWeight'
            ,'DetailWeightUOM'
            ,'DetailMaxQty'
        ], true)
        //Item Setup Tab - GL Accounts
        .clickTab('Setup')
        .isControlVisible('cfg',
        [
            'Location'
            ,'Sales'
            ,'POS'
            ,'Contract'
            ,'Xref'
            ,'MotorFuelTax'
            ,'Others'
        ], true)
        .isControlVisible('btn',
        [
            'AddRequiredAccounts'
            ,'InsertGlAccounts'
            ,'DeleteGlAccounts'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('col',
        [
            'GLAccountCategory'
            ,'GLAccountId'
            ,'Description'
        ], true)
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        //Item Setup Tab - Location
        .clickTab('Location')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddLocation'
            ,'AddMultipleLocation'
            ,'EditLocation'
            ,'DeleteLocation'
            ,'CopyLocation'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('col',
        [
            'LocationLocation'
            ,'LocationPOSDescription'
            ,'LocationVendor'
            ,'LocatioCostingMethod'
        ], true)
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        //Item Setup Tab - Sales
        .clickTab('Sales')
        .waitUntilLoaded()
        .isControlVisible('chk',
        [
            'StockedItem'
            ,'DyedFuel'
            ,'MsdsRequired'
            ,'InboundTax'
            ,'OutboundTax'
            ,'RestrictedChemical'
            ,'FuelItem'
            ,'TonnageTax'
            ,'LoadTracking'
            ,'HandAddIngredients'
            ,'ExtendOnPickTicket'
            ,'ExportEdi'
            ,'HazardMaterial'
            ,'MaterialFee'
            ,'AutoBlend'
        ], true)
        .isControlVisible('txt',
        [
            'EpaNumber'
            ,'PercentDenaturant'
            ,'MixOrder'
            ,'VolumeRebateGroup'
            ,'UserGroupFee'
            ,'WgtTolerance'
            ,'OverReceiveTolerance'
            ,'MaintenanceCalculationMethod'
            ,'MaintenanceRate'
        ], true)
        .isControlVisible('cbo',
        [
            'BarcodePrint'
            ,'FuelInspectionFee'
            ,'RinRequired'
            ,'FuelCategory'
            ,'MedicationTag'
            ,'IngredientTag'
            ,'PhysicalItem'
        ], true)
        //Items - Point of Sale Tab
        .clickTab('Point of Sale')
        .waitUntilLoaded()
        .isControlVisible('pnl',
        [
            'General'
            ,'InventorySetup'
            ,'CommissionDetail'
        ], true)
        .isControlVisible('txt',
        [
            'NacsCategory'
            ,'LeadTime'
            ,'Keywords'
            ,'CaseQty'
            ,'TaxExempt'
        ], true)
        .isControlVisible('cbo',
        [
            'CountCode'
        ], true)
        .isControlVisible('chk',
        [
            'ReceiptCommentReq'
            ,'LandedCost'
            ,'Taxable'
            ,'DropShip'
            ,'Commissionable'
            ,'SpecialCommission'
        ], true)
        .isControlVisible('dtm',
        [
            'DateShip'
        ], true)
        .isControlVisible('dtm',
        [
            'POSCategoryName'
            ,'POSSLAContract'
            ,'POSSLAPrice'
            ,'POSSLAWarranty'
        ], true)
        .isControlVisible('btn',
        [
            'InsertCategories'
            ,'DeleteCategories'
            ,'InsertSLA'
            ,'DeleteSLA'
        ], true)
        //Items - Contract Item Tab
        .clickTab('Contract Item')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'InsertContractItem'
            ,'DeleteContractItem'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'InsertDocumentAssociation'
            ,'DeleteDocumentAssociation'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'InsertCertification'
            ,'DeleteCertification'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            ,'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'ContractLocation'
            ,'ContractItemName'
            ,'ContractOrigin'
            ,'ContractGrade'
            ,'ContractGradeType'
            ,'ContractGarden'
            ,'ContractYield'
            ,'ContractTolerance'
            ,'ContractFranchise'
            ,'Document'
            ,'Certification'
        ], true)
        //Items - Xref Tab
        .clickTab('Xref')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'InsertContractItem'
            ,'DeleteContractItem'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            ,'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            ,'CustomerXrefLocation'
            ,'CustomerXrefCustomer'
            ,'CustomerXrefProduct'
            ,'CustomerXrefDescription'
            ,'CustomerXrefPickTicketNotes'
            ,'VendorXrefLocation'
            ,'VendorXrefVendor'
            ,'VendorXrefProduct'
            ,'VendorXrefDescription'
            ,'VendorXrefConversionFactor'
            ,'VendorXrefUnitMeasure'
        ], true)
        //Items - Motor Fuel Tax Tab
        .clickTab('Motor Fuel Tax')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'InsertContractItem'
            ,'DeleteContractItem'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            ,'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            ,'MFTTaxAuthorityCode'
            ,'MFTTaxDescription'
            ,'MFTProductCode'
            ,'MFTProductCodeDescription'
            ,'MFTProductCodeGroup'
        ], true)
        //Items - Others Tab
        .clickTab('Other')
        .waitUntilLoaded()
        .isControlVisible('pnl',
        [
            'Comments'
            ,'TankManagement'
            ,'Patronage'
        ], true)
        .isControlVisible('txt',
        [
            'InvoiceComments'
            ,'PickListComments'
            ,'DefaultPercentFull'
        ], true)
        .isControlVisible('chk',
        [
            'TankRequired'
            , 'AvailableForTm'
        ], true)
        .isControlVisible('cbo',
        [
            'Patronage'
            ,'PatronageDirect'
        ], true)
        //Items - Pricing Tab
        .clickTab('Pricing')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'InsertPricingLevel'
            ,'DeletePricingLevel'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            ,'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'PricingLocation'
            ,'PricingLastCost'
            ,'PricingStandardCost'
            ,'PricingAverageCost'
            ,'PricingMethod'
            ,'PricingAmount'
            ,'PricingMSRP'

            ,'PricingLevelLocation'
            ,'PricingLevelPriceLevel'
            ,'PricingLevelUOM'
            ,'PricingLevelUPC'
            ,'PricingLevelUnits'
            ,'PricingLevelMin'
            ,'PricingLevelMax'
            ,'PricingLevelMethod'
            ,'PricingLevelAmount'
            ,'PricingLevelUnitPrice'
            ,'PricingLevelCommissionOn'
            ,'PricingLevelCommissionRate'

        ], true)
        //Items - Stock Tab
        .clickTab('Stock')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            ,'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'StockLocation'
            ,'StockUOM'
            ,'StockOnOrder'
            ,'StockInTransitInbound'
            ,'StockOnHand'
            ,'StockInTransitOutbound'
            ,'StockBackOrder'
            ,'StockCommitted'
            ,'StockOnStorage'
            ,'StockConsignedPurchase'
            ,'StockConsignedSale'
            ,'StockReserved'
            ,'StockAvailable'
        ], true)
        //Items Comments Tab
        //.clickTab('Comments')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            ,'Created'
            ,'Start'
            ,'Category'
        ], true)
        .isControlVisible('btn',
        [
            'OpenActivity'
            ,'NewEvent'
            ,'NewTask'
            ,'NewComment'
            ,'LogCall'
            ,'SendEmail'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        //Items Attachments Tab
        //.clickTab('Attachments')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddAttachment'
            ,'OpenAttachment'
            ,'EditAttachment'
            ,'DownloadAttachment'
            ,'DeleteAttachment'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        //Items AuditLog Tab
        //.clickTab('AuditLog')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('btn',
        [
            'InsertCriteria'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('=====  1.7 Open Items and Check Screen Fields Done====')


        //Inventory Commodities Screen
        .displayText('=====  1.8 Open Commodities and Check Screen Fields ====')
        .clickMenuScreen('Commodities','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strCommodityCode', text: 'Commodity Code'},
            {dataIndex: 'strDescription', text: 'Description'}
        ])
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .isControlVisible('btn',
        [
            'New'
            ,'Save'
            ,'Find'
            ,'Delete'
            ,'Undo'
            ,'Close'
            ,'DeleteUom'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            'CommodityCode'
            ,'Description'
            ,'DecimalsOnDpr'
            ,'ConsolidateFactor'
            ,'PriceChecksMin'
            ,'PriceChecksMax'
            ,'EdiCode'
            ,'FilterGrid'
        ], true)
        .isControlVisible('chk',
        [
            'ExchangeTraded'
            ,'FxExposure'
        ], true)
        .isControlVisible('cbo',
        [
            'FutureMarket'
            ,'DefaultScheduleStore'
            ,'DefaultScheduleDiscount'
            ,'ScaleAutoDistDefault'
        ], true)
        .isControlVisible('dtm',
        [
            'CropEndDateCurrent'
            ,'CropEndDateNew'
        ], true)
        .clickTab('Attribute')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'DeleteOrigins'
            ,'MoveUpOrigins'
            ,'MoveDownOrigins'
            ,'GridLayout'
            ,'DeleteProductTypes'
            ,'MoveUpProductTypes'
            ,'MoveDownProductTypes'
            ,'DeleteRegions'
            ,'MoveUpRegions'
            ,'MoveDownRegions'
            ,'DeleteClasses'
            ,'MoveUpClasses'
            ,'MoveDownClasses'
            ,'DeleteSeasons'
            ,'MoveUpSeasons'
            ,'MoveDownSeasons'
            ,'DeleteGrades'
            ,'MoveUpGrades'
            ,'MoveDownGrades'
            ,'DeleteProductLines'
            ,'MoveUpProductLines'
            ,'MoveDownProductLines'
        ], true)
        .isControlVisible('col',
        [
            'Origin'
            ,'ProductType'
            ,'Region'
            ,'ClassVariant'
            ,'Season'
            ,'Grade'
            ,'ProductLine'
            ,'DeltaHedge'
            ,'DeltaPercent'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  1.8 Open Commodities and Check Screen Fields Done ====')


        //Inventory Fuel Types Screen
        .displayText('=====  1.9 Open Fuel Types and Check Screen Fields ====')
        .clickMenuScreen('Categories','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strCategoryCode', text: 'Category Code'},
            {dataIndex: 'strDescription', text: 'Description'},
            {dataIndex: 'strInventoryType', text: 'Inventory Type'}
        ])
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .isControlVisible('btn',
        [
            'New'
            ,'Save'
            ,'Find'
            ,'Delete'
            ,'Undo'
            ,'Close'
            ,'InsertTax'
            ,'DeleteTax'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'DeleteUom'
            ,'ridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            'CategoryCode'
            ,'Description'
            ,'GlDivisionNumber'
            ,'SalesAnalysisByTon'
            ,'StandardQty'
            ,'FilterGrid'
        ], true)
        .isControlVisible('cbo',
        [
            'InventoryType'
            ,'LineOfBusiness'
            ,'CostingMethod'
            ,'InventoryValuation'
            ,'StandardUOM'
        ], true)
        //Categories Location tab
        .clickTab('Locations')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddLocation'
            ,'EditLocation'
            ,'DeleteLocation'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
        ], true)
        .isControlVisible('txt',
        [
            ,'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'LocationId'
            ,'LocationCashRegisterDept'
            ,'LocationTargetGrossProfit'
            ,'LocationTargetInventoryCost'
            ,'LocationCostInventoryBOM'
        ], true)
        //Categories GL Accounts tab
        .clickTab('GL Accounts')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddRequired'
            ,'DeleteGlAccounts'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
        ], true)
        .isControlVisible('txt',
        [
            ,'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'AccountCategory'
            ,'AccountId'
            ,'AccountDescription'
        ], true)
        //Categories Vendor Category Xref tab
        .clickTab('Vendor Category Xref')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'DeleteVendorCategoryXref'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
        ], true)
        .isControlVisible('col',
        [
            'VendorLocation'
            ,'VendorId'
            ,'VendorDepartment'
            ,'VendorAddOrderUPC'
            ,'VendorUpdateExisting'
            ,'VendorAddNew'
            ,'VendorUpdatePrice'
            ,'VendorFamily'
            ,'VendorOrderClass'
        ], true)
        //Categories Manufacturing tab
        .clickTab('Vendor Category Xref')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'ERPItemClass'
            ,'LifeTime'
            ,'BOMItemShrinkage'
            ,'BOMItemUpperTolerance'
            ,'BOMItemLowerTolerance'
            ,'ConsumptionMethod'
            ,'BOMItemType'
            ,'ShortName'
            ,'LaborCost'
            ,'OverHead'
            ,'Percentage'
            ,'CostDistributionMethod'
        ], true)
        .isControlVisible('chk',
        [
            'Scaled'
            ,'OutputItemMandatory'
            ,'Sellable'
            ,'YieldAdjustment'
            ,'TrackedInWarehouse'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()


        //Inventory Fuel Types Screen
        .displayText('=====  1.10 Open Fuel Types and Check Screen Fields ====')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strRinFuelTypeCodeId', text: 'Fuel Type'},
            {dataIndex: 'strRinFeedStockId', text: 'Feed Stock'},
            {dataIndex: 'strRinFuelId', text: 'Fuel Code'},
            {dataIndex: 'strRinProcessId', text: 'Process Code'}
        ])
        .clickButton('New')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'New'
            ,'Save'
            ,'Search'
            ,'Delete'
            ,'Undo'
            ,'Close'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('cbo',
        [
            'FuelCategory'
            ,'FeedStock'
            ,'FuelCode'
            ,'ProductionProcess'
            ,'FeedStockUom'
        ], true)
        .isControlVisible('txt',
        [
            'BatchNo'
            ,'EndingRinGallonsForBatch'
            ,'EquivalenceValue'
            ,'FeedStockFactor'
            ,'PercentOfDenaturant'
            ,'FilterGrid'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()


        //Inventory Fuel Category Screen
        .displayText('=====  1.11 Open Fuel Category and Check Screen Fields ====')
        .clickButton('FuelCategory')
        .waitUntilLoaded('icfuelcategory')
        .isControlVisible('btn',
        [
            'Save'
            ,'Undo'
            ,'Close'
            ,'Insert'
            ,'Delete'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'RinFuelCategoryCode'
            ,'Description'
            ,'EquivalenceValue'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  1.11 Open Fuel Category and Check Screen Fields Done ====')


        //Inventory Feed Stock Screen
        .displayText('=====  1.12 Open Feed Stock and Check Screen Fields ====')
        .clickButton('FeedStock')
        .waitUntilLoaded('icfeedstockcode')
        .isControlVisible('btn',
        [
            'Save'
            ,'Undo'
            ,'Close'
            ,'Insert'
            ,'Delete'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'RinFeedStockCode'
            ,'Description'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  1.12 Open Feed Stock and Check Screen Fields Done ====')

        //Inventory Fuel Code Screen
        .displayText('=====  1.13 Open Fuel Code and Check Screen Fields ====')
        .clickButton('FuelCode')
        .waitUntilLoaded('icfuelcode')
        .isControlVisible('btn',
        [
            'Save'
            ,'Undo'
            ,'Close'
            ,'Insert'
            ,'Delete'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'RinFuelCode'
            ,'Description'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  1.13 Open Fuel Code and Check Screen Fields Done ====')


        //Inventory Production Process Screen
        .displayText('=====  1.14 Open Production Process and Check Screen Fields ====')
        .clickButton('ProductionProcess')
        .waitUntilLoaded('icprocesscode')
        .isControlVisible('btn',
        [
            'Save'
            ,'Undo'
            ,'Close'
            ,'Insert'
            ,'Delete'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'RinProcessCode'
            ,'Description'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  1.14 Open Production Process and Check Screen Fields Done====')

        //Inventory Feed Stock UOM Screen
        .displayText('=====  1.15 Open Feed Stock UOM and Check Screen Fields ====')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .isControlVisible('btn',
        [
            'Save'
            ,'Undo'
            ,'Close'
            ,'Insert'
            ,'Delete'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'UOM'
            ,'RinFeedStockUOMCode'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  1.15 Open Feed Stock UOM and Check Screen Fields ====')


        //Inventory Storage Locations Screen
        .displayText('=====  1.16 Open Storage Locations and Check Screen Fields ====')
        .clickMenuScreen('Storage Locations','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strName', text: 'Name'},
            {dataIndex: 'strDescription', text: 'Description'},
            {dataIndex: 'strStorageUnitType', text: 'Storage Unit Type'},
            {dataIndex: 'strLocationName', text: 'Location'},
            {dataIndex: 'strSubLocationName', text: 'Sub Location'},
            {dataIndex: 'strParentStorageLocationName', text: 'Parent Unit'},
            {dataIndex: 'strRestrictionCode', text: 'Restriction Type'}
        ])
        .clickButton('New')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'New'
            ,'Save'
            ,'Search'
            ,'Delete'
            ,'Undo'
            ,'Close'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('txt',
        [
            'Name'
            ,'Description'
            ,'Aisle'
            ,'MinBatchSize'
            ,'BatchSize'
            ,'PackFactor'
            ,'EffectiveDepth'
            ,'UnitsPerFoot'
            ,'ResidualUnits'
            ,'Sequence'
            ,'XPosition'
            ,'YPosition'
            ,'ZPosition'
        ], true)
        .isControlVisible('cbo',
        [
            'UnitType'
            ,'Location'
            ,'SubLocation'
            ,'ParentUnit'
            ,'RestrictionType'
            ,'BatchSizeUom'
            ,'Commodity'
        ], true)
        .isControlVisible('chk',
        [
            'AllowConsume'
            ,'AllowMultipleItems'
            ,'AllowMultipleLots'
            ,'MergeOnMove'
            ,'CycleCounted'
            ,'DefaultWarehouseStagingUnit'
        ], true)

        //Storage Location Measurement Tab
        .clickTab('Measurement')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddMeasurement'
            ,'DeleteMeasurement'
        ], true)
        .isControlVisible('col',
        [
            'Measurement'
            ,'ReadingPoint'
            ,'Active'
        ], true)

        //Storage Location Item Categories Allowed Tab
        .clickTab('Item Categories Allowed')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'DeleteItemCategoryAllowed'
        ], true)
        .isControlVisible('col',
        [
            'Category'
        ], true)

        //Storage Location Container Tab
        .clickTab('Container')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'DeleteContainer'
        ], true)
        .isControlVisible('col',
        [
            'Container'
            ,'ExternalSystem'
            ,'ContainerType'
            ,'LastUpdateby'
            ,'LastUpdateOn'
        ], true)

        //Storage Location SKU Tab
        .clickTab('SKU')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            '#btnDeleteSKU'
        ], true)
        .isControlVisible('col',
        [
            'Item'
            ,'Sku'
            ,'Qty'
            ,'Container'
            ,'LotSerial'
            ,'Expiration'
            ,'Status'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('=====  1.16 Open Storage Locations and Check Screen Fields ====')


        //Open Inventory Stock Details
        .displayText('=====  1.17 Open Stock Details and Check Screen Fields ====')
        .clickMenuScreen('Stock Details','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({new: false, open: false, openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strItemNo', text: 'Item No'},
            { dataIndex: 'strDescription', text: 'Description'},
            { dataIndex: 'strType', text: 'Item Type'},
            { dataIndex: 'strCategoryCode', text: 'Category'},
            { dataIndex: 'strLocationName', text: 'Location Name'},
            { dataIndex: 'dblUnitOnHand', text: 'On Hand'},
            { dataIndex: 'dblOnOrder', text: 'On Order'},
            { dataIndex: 'dblOrderCommitted', text: 'Committed'},
            { dataIndex: 'dblUnitReserved', text: 'Reserved'},
            { dataIndex: 'dblInTransitInbound', text: 'In Transit Inbound'},
            { dataIndex: 'dblInTransitOutbound', text: 'In Transit Outbound'},
            { dataIndex: 'dblUnitStorage', text: 'On Storage'},
            { dataIndex: 'dblConsignedPurchase', text: 'Consigned Purchase'},
            { dataIndex: 'dblConsignedSale', text: 'Consigned Sale'},
            { dataIndex: 'dblAvailable', text: 'Available'},
            { dataIndex: 'dblReorderPoint', text: 'Reorder Point'},
            { dataIndex: 'dblLastCost', text: 'Last Cost'},
            { dataIndex: 'dblAverageCost', text: 'Average Cost'},
            { dataIndex: 'dblStandardCost', text: 'Standard Cost'},
            { dataIndex: 'dblSalePrice', text: 'Retail Price'},
            { dataIndex: 'dblExtendedCost', text: 'Extended Cost'}
        ])
        .clickTab('Storage Bins')
        .waitUntilLoaded()
        .displayText('=====  1.17 Open Stock Details and Check Screen Fields Done====')

        //Open Inventory Lot Details
        .displayText('=====  1.18 Open Lot Details and Check Screen Fields ====')
        .clickMenuScreen('Lot Details','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({new: false, open: false, openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strItemNo', text: 'Item No'},
            { dataIndex: 'strItemDescription', text: 'Description'},
            { dataIndex: 'strLocationName', text: 'Location Name'},
            { dataIndex: 'strSubLocationName', text: 'Sub Location'},
            { dataIndex: 'strStorageLocation', text: 'Storage Location'},
            { dataIndex: 'strLotNumber', text: 'Lot Number'},
            { dataIndex: 'dblQty', text: 'Quantity'},
            { dataIndex: 'dblWeight', text: 'Weight'},
            { dataIndex: 'strItemUOM', text: 'UOM'},
            { dataIndex: 'dblWeightPerQty', text: 'Weight Per Qty'},
            { dataIndex: 'dblLastCost', text: 'Last Cost'}

        ])
        .displayText('=====  1.18 Open Lot Details and Check Screen Fields Done====')


        //Open Inventory Valuation
        .displayText('=====  1.19 Open Inventory Valuation and Check Screen Fields ====')
        .clickMenuScreen('Inventory Valuation','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({new: false, open: false, openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strItemNo', text: 'Item No'},
            { dataIndex: 'strItemDescription', text: 'Description'},
            { dataIndex: 'strCategory', text: 'Category'},
            { dataIndex: 'strStockUOM', text: 'Stock UOM'},
            { dataIndex: 'strLocationName', text: 'Location'},
            { dataIndex: 'strSubLocationName', text: 'Sub Location'},
            { dataIndex: 'strStorageLocationName', text: 'Storage Location'},
            { dataIndex: 'strBOLNumber', text: 'BOL Number'},
            { dataIndex: 'strEntity', text: 'Entity'},
            { dataIndex: 'strLotNumber', text: 'Lot Number'},
            { dataIndex: 'strAdjustedTransaction', text: 'Adjusted Transaction'},
            { dataIndex: 'strCostingMethod', text: 'Costing Method'},
            { dataIndex: 'dtmDate', text: 'Date'},
            { dataIndex: 'strTransactionType', text: 'Transaction Type'},
            { dataIndex: 'strTransactionId', text: 'Transaction Id'},
            { dataIndex: 'dblBeginningQtyBalance', text: 'Begin Qty'},
            { dataIndex: 'dblQuantityInStockUOM', text: 'Qty'},
            { dataIndex: 'dblRunningQtyBalance', text: 'Running Qty'},
            { dataIndex: 'dblCostInStockUOM', text: 'Cost'},
            { dataIndex: 'dblBeginningBalance', text: 'Begin Value'},
            { dataIndex: 'dblValue', text: 'Value'},
            { dataIndex: 'dblRunningBalance', text: 'Running Value'},
            { dataIndex: 'strBatchId', text: 'Batch Id'}
        ])
        .displayText('=====  1.19 Open Inventory Valuation and Check Screen Fields Done====')

        //Open Inventory Valuation Summary
        .displayText('=====  1.20 Open Inventory Valuation Summary and Check Screen Fields ====')
        .clickMenuScreen('Inventory Valuation Summary','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({new: false, open: false, openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strItemNo', text: 'Item No'},
            { dataIndex: 'strItemDescription', text: 'Description'},
            { dataIndex: 'strLocationName', text: 'Location'},
            { dataIndex: 'strSubLocationName', text: 'Sub Location'},
            { dataIndex: 'dblValue', text: 'Value'},
            { dataIndex: 'dblLastCost', text: 'Last Cost'},
            { dataIndex: 'dblStandardCost', text: 'Standard Cost'},
            { dataIndex: 'dblAverageCost', text: 'Average Cost'}
        ])
        .displayText('=====  1.20 Open Inventory Valuation Summary and Check Screen Fields Done====')

        //region Scenario 2. Add Maintenance Screens
        .displayText('=====   Scenario 2. Add Maintenance Screens ====')
        //region Scenario 2.1: Add Storage Locations
        .displayText('===== Scenario 2.1: Add Storage Locations =====')
        .clickMenuScreen('Storage Locations','Screen')
        .clickButton('New')
        .waitUntilLoaded('icstorageunit')
        .enterData('Text Field','Name','ICSmoke - SL')
        .enterData('Text Field','Description','ICSmoke - SL')
        .selectComboBoxRowValue('UnitType', 'Bin', 'UnitType',0)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('ParentUnit', 'RM Storage', 'ParentUnit',0)
        .enterData('Text Field','Aisle','Test Aisle - 01')
        .clickCheckBox('AllowConsume', true)
        .clickCheckBox('AllowMultipleItems', true)
        .clickCheckBox('AllowMultipleLots', true)
        .clickCheckBox('CycleCounted', true)
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 2.1: Add Storage Locations Done=====')


        //region Scenario 2.2. Add Inventory UOM
        .displayText('===== Scenario 2.2. Add Inventory UOM =====')
        .clickMenuScreen('Inventory UOM','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Smoke_LB')
        .enterData('Text Field','Symbol','Test_LB')
        .selectComboBoxRowNumber('UnitType',6,0)
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Smoke 5 LB bag')
        .enterData('Text Field','Symbol','Smoke 5 LB bag')
        .selectComboBoxRowNumber('UnitType',7,0)
        .selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('Conversion', 1, 'dblConversionToStock', '5')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Smoke 10 LB bag')
        .enterData('Text Field','Symbol','Smoke 10 LB bag')
        .selectComboBoxRowNumber('UnitType',7,0)
        .selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('Conversion', 1, 'dblConversionToStock', '10')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion

        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Smoke KG')
        .enterData('Text Field','Symbol','Smoke KG')
        .selectComboBoxRowNumber('UnitType',6,0)
        .selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('Conversion', 1, 'dblConversionToStock', '2.20462')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 2.2. Add Inventory UOM Done=====')
        //endregion

        //region Scenario 2.3: Add New Fuel Type, Fuel Category, Feed Stock, Fuel Code, Production Process, Feed Stock UOM
        //Fuel Category
        .displayText('===== Scenario 2.3: Add New Fuel Type, Fuel Category, Feed Stock, Fuel Code, Production Process, Feed Stock UOM =====')
        .clickMenuScreen('Fuel Types','Screen')
        .clickButton('Close')
        .clickButton('FuelCategory')
        .waitUntilLoaded('icfuelcategory')
        .enterGridData('GridTemplate', 1, 'colRinFuelCategoryCode', 'ICSmokeFuelCategory')
        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFuelCategoryDesc')
        .enterGridData('GridTemplate', 1, 'colEquivalenceValue', 'ICSmokeFuelCategory_EV')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //Feed Stock
        .clickButton('FeedStock')
        .waitUntilLoaded('')
        .enterGridData('GridTemplate', 1, 'colRinFeedStockCode', 'ICSmokeFeedStock')
        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFeedStockDesc')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //FuelCode
        .clickButton('FuelCode')
        .waitUntilLoaded('icfuelcode')
        .enterGridData('GridTemplate', 1, 'colRinFuelCode', 'ICSmokeFuelCode')
        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFuelCodeDesc')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //Production Process
        .clickButton('ProductionProcess')
        .waitUntilLoaded('icprocesscode')
        .enterGridData('GridTemplate', 1, 'colRinProcessCode', 'ICSmokeProductionProcess')
        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeProductionProcessDesc')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //Feed Stock UOM
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridComboBoxRowValue('GridTemplate',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('GridTemplate', 1, 'colRinFeedStockUOMCode', 'Test UOM Code 1')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //Fuel Type
        .clickButton('New')
        .selectComboBoxRowValue('FuelCategory', 'ICSmokeFuelCategory', 'FuelCategory',0)
        .selectComboBoxRowValue('FeedStock', 'ICSmokeFeedStock', 'FeedStock',0)
        .enterData('Text Field','BatchNo','1')
        .verifyData('Text Field','EquivalenceValue','ICSmokeFuelCategory_EV')
        .selectComboBoxRowValue('FuelCode', 'ICSmokeFuelCode', 'FuelCode',0)
        .selectComboBoxRowValue('ProductionProcess', 'ICSmokeProductionProcess', 'ProductionProcess',0)
        .selectComboBoxRowValue('FeedStockUom', 'Smoke_LB', 'FeedStockUom',0)
        .enterData('Text Field','FeedStockFactor','10')
        .clickCheckBox('RenewableBiomass', true)
        .enterData('Text Field','PercentOfDenaturant','25')
        .clickCheckBox('DeductDenaturantFromRin', true)
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 2.4: Add Category
        .displayText('===== Scenario 2.4: Add Category =====')
        .clickMenuScreen('Categories','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Smoke Inventory Category')
        .enterData('Text Field','Description','Test Inventory Category')
        .selectComboBoxRowNumber('InventoryType',2,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 0,'strUnitMeasure', 'Smoke_LB', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','Smoke 5 LB bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Smoke 10 LB bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','Smoke KG','strUnitMeasure')

        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '5')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '10')
        .verifyGridData('UnitOfMeasure', 4, 'colDetailUnitQty', '2.20462')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Inventory')
        .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Cost of Goods')
        .verifyGridData('GlAccounts', 4, 'colAccountCategory', 'Sales Account')
        .verifyGridData('GlAccounts', 5, 'colAccountCategory', 'Inventory In-Transit')
        .verifyGridData('GlAccounts', 6, 'colAccountCategory', 'Inventory Adjustment')
        .verifyGridData('GlAccounts', 7, 'colAccountCategory', 'Auto-Variance')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 7, 'strAccountId', '16010-0000-000', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 2.4: Add Category Done =====')
        //endregion

        //region Scenario 2.5: Add Commodity
        .displayText('===== Scenario 2.5: Add Commodity =====')
        .clickMenuScreen('Commodities','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .enterData('Text Field','CommodityCode','Smoke Commodity')
        .enterData('Text Field','Description','Test Smoke Commodity')
        .clickCheckBox('ExchangeTraded',true)
        .enterData('Text Field','DecimalsOnDpr','6.00')
        .enterData('Text Field','ConsolidateFactor','6.00')

        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .clickGridCheckBox('Uom', 0,'strUnitMeasure', 'Smoke_LB', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','Smoke 5 LB bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Smoke 10 LB bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','Smoke KG','strUnitMeasure')

        .verifyGridData('Uom', 1, 'colUOMUnitQty', '1')
        .verifyGridData('Uom', 2, 'colUOMUnitQty', '5')
        .verifyGridData('Uom', 3, 'colUOMUnitQty', '10')
        .verifyGridData('Uom', 4, 'colUOMUnitQty', '2.20462')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 2.5: Add Commodity Done =====')
        //endregion

        //region Scenario 2.6: Add Lotted Item
        .displayText('===== Scenario 2.6: Add Lotted Item =====')
        .clickMenuScreen('Items','Screen')
        .clickButton('New')
        .waitUntilLoaded('icitem')
        .enterData('Text Field','ItemNo','Smoke - LTI - 01')
        .enterData('Text Field','Description','Smoke - LTI - 01 Lotted Item Manual')
        .selectComboBoxRowValue('Category', 'Smoke Inventory Category', 'Category',0)
        .selectComboBoxRowValue('Commodity', 'Smoke Commodity', 'Commodity',0)
        .selectComboBoxRowNumber('LotTracking',1,0)
        .verifyData('Combo Box','Tracking','Lot Level')

        .displayText('===== Setup Item UOM=====')
        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','Smoke 5 LB bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Smoke 10 LB bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','Smoke KG','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 0,'strUnitMeasure', 'Smoke_LB', 'ysnStockUnit', true)
        .waitUntilLoaded('')

        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '5')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '10')
        .verifyGridData('UnitOfMeasure', 4, 'colDetailUnitQty', '2.20462')


        .displayText('===== Setup Item GL Accounts=====')
        .clickTab('Setup')
        .clickButton('AddRequiredAccounts')
        .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
        .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
        .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
        .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
        .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
        .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')
        .verifyGridData('GlAccounts', 7, 'colGLAccountCategory', 'Auto-Variance')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 7, 'strAccountId', '16010-0000-000', 'strAccountId')

        .displayText('===== Setup Item Location=====')
        .clickTab('Location')
        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'ICSmoke - SL', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'Smoke_LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'Smoke_LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .displayText('===== Setup Item Pricing=====')
        .clickTab('Pricing')
        .waitUntilLoaded('')
        .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
        .enterGridData('Pricing', 1, 'dblLastCost', '10')
        .enterGridData('Pricing', 1, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
        .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

        .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
        .enterGridData('Pricing', 2, 'dblLastCost', '10')
        .enterGridData('Pricing', 2, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
        .enterGridData('Pricing', 2, 'dblAmountPercent', '40')
        .clickButton('Save')
        .clickButton('Close')
        .displayText('===== Scenario 2.6: Add Lotted Item Done=====')
        //endregion



        //region Scenario 2.7: Add Non Lotted Item -
        .displayText('===== Scenario 2.7: Add Non Lotted Item - =====')
        .clickButton('New')
        .waitUntilLoaded('icitem')
        .enterData('Text Field','ItemNo','Smoke - NLTI - 01')
        .enterData('Text Field','Description','Smoke - NLTI - 01 Non Lotted Item')
        .selectComboBoxRowValue('Category', 'Smoke Inventory Category', 'Category',0)
        .selectComboBoxRowValue('Commodity', 'Smoke Commodity', 'Commodity',0)
        .selectComboBoxRowNumber('LotTracking',3,0)
        .verifyData('Combo Box','Tracking','Item Level')

        .displayText('===== Setup Item UOM=====')
        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','Smoke 5 LB bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Smoke 10 LB bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','Smoke KG','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 0,'strUnitMeasure', 'Smoke_LB', 'ysnStockUnit', true)
        .waitUntilLoaded('')

        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '5')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '10')
        .verifyGridData('UnitOfMeasure', 4, 'colDetailUnitQty', '2.20462')


        .displayText('===== Setup Item GL Accounts=====')
        .clickTab('Setup')
        .clickButton('AddRequiredAccounts')
        .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
        .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
        .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
        .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
        .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
        .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')
        .verifyGridData('GlAccounts', 7, 'colGLAccountCategory', 'Auto-Variance')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 7, 'strAccountId', '16010-0000-000', 'strAccountId')

        .displayText('===== Setup Item Location=====')
        .clickTab('Location')
        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'ICSmoke - SL', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'Smoke_LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'Smoke_LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .displayText('===== Setup Item Pricing=====')
        .clickTab('Pricing')
        .waitUntilLoaded('')
        .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
        .enterGridData('Pricing', 1, 'dblLastCost', '10')
        .enterGridData('Pricing', 1, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
        .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

        .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
        .enterGridData('Pricing', 2, 'dblLastCost', '10')
        .enterGridData('Pricing', 2, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
        .enterGridData('Pricing', 2, 'dblAmountPercent', '40')
        .clickButton('Save')
        .clickButton('Close')
        .displayText('===== Scenario 2.7: Add Non Lotted Item Done =====')
        .displayText('=====   Add Maintenance Screens Done ====')
        //endregion


        //region Scenario 3. Add IC Transactions
        .displayText('=====   Scenario 3. Add IC Transactions ====')

        //region Scenario 3.1: Add Direct IR for Non Lotted Item
        .displayText('=====  Scenario 3.1: Add Direct IR for Non Lotted Item =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 100,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Gross is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblNetWgt').text;
            if (total == 'Net: 100,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000000')
        .clickButton('Post')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Non Lotted Item Done=====')

        //region Scenario 3.2. Create Direct Inventory Receipt for Lotted Item
        .displayText('=====  Scenario 3.2. Create Direct IR for Lotted Item  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'ICSmoke - SL')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100000')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'Smoke_LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'ICSmoke - SL')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 100,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Gross is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblNetWgt').text;
            if (total == 'Net: 100,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000000')
        .clickButton('Post')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Lotted Item=====')


        //region Scenario 3.3. Create Direct Inventory Shipment for Non Lotted Item
        .displayText('=====  Scenario 3.3. Create Direct Inventory Shipment for Non Lotted Item  =====')
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryShipment', 1, 'colQuantity', '100')


        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryShipment', 1, 'colStorageLocation', 'ICSmoke - SL')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')


        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
        //endregion

        //region Scenario 3.4. Create Direct Inventory Shipment for Lotted Item
        .displayText('=====  Scenario 3.4. Create Direct Inventory Shipment for Lotted Item  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryShipment', 1, 'colQuantity', '100')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryShipment', 1, 'colStorageLocation', 'ICSmoke - SL')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')

        .selectGridComboBoxRowValue('LotTracking',1,'strLotId','LOT-01','strLotId')
        .enterGridData('LotTracking', 1, 'colShipQty', '100')
        .verifyGridData('LotTracking', 1, 'colLotUOM', 'Smoke_LB')
        .verifyGridData('LotTracking', 1, 'colGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'Smoke_LB')

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
        //endregion


        //region Scenario 3.5. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location
        .displayText('===== Scenario 3.5. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location =====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        //.waitUntilLoaded()
        //.verifyMessageBox('iRely i21','Changing Location will clear ALL Sub Locations and Storage Locations. Do you want to continue?','yesno','question')
        //.clickMessageBoxButton('yes')
        //.waitUntilLoaded('')
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','ICSmoke - SL','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'Smoke_LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16000-0002-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Not Required Done =====')
        //endregion


//        //region Scenario 3.6. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location
//        .displayText('===== Scenario 3.6. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location=====')
//        .clickMenuScreen('Inventory Transfers','Screen')
//        .waitUntilLoaded()
//        .clickButton('New')
//        .waitUntilLoaded('icinventorytransfer')
//        .verifyData('Combo Box','TransferType','Location to Location')
//        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
//        .verifyData('Combo Box','SourceType','None')
//        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
//        .enterData('Text Field','Description','Test Transfer')
//
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - LTI - 01','strItemNo')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','ICSmoke - SL','strFromStorageLocationName')
//        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
//        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'Smoke_LB')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
//        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')
//
//        .clickButton('Recap')
//        .waitUntilLoaded('cmcmrecaptransaction')
//        .waitUntilLoaded('')
//        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
//        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
//        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16000-0002-000')
//        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
//        .clickButton('Post')
//        .waitUntilLoaded('')
//        .addResult('Successfully Posted',1500)
//        .waitUntilLoaded('')
//        .clickButton('Close')
//        .waitUntilLoaded('')
//        .displayText('===== Create Inventory Transfer for Lotted Item Shipment Not Required Done =====')
//        //endregion



        //region Scenario 3.7. Inventory Adjustment Quantity Change Non Lotted Item
        .displayText('===== Scenario 3.7. Inventory Adjustment Quantity Change Non Lotted Item=====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '100')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16040-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Not Required Done =====')
        //endregion

        //region Scenario 3.8. Inventory Adjustment Quantity Change Lotted Item
        .displayText('===== Scenario 3.8. Inventory Adjustment Quantity Change Lotted Item=====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strSubLocation','Raw Station','strSubLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strStorageLocation','ICSmoke - SL','strStorageLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strLotNumber','LOT-01','strLotNumber')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '100')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16040-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Not Required Done =====')
        //endregion




        //region Scenario 9. Inventory Count - Lock Inventory
        .displayText('===== Scenario  9. Inventory Count - Lock Inventory =====')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'Gas', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'Gasoline', 'Commodity',1)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .verifyGridData('PhysicalCount', 1, 'colItem', '87G')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('PrintCountSheets')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .isControlVisible('tlb',
        [
            'PrintVariance'
            , 'LockInventory'
            , 'Post'
            , 'Recap'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','87G','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Gallon','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Gallon')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('Recap')
        .waitUntilLoaded('')
        .addResult('Clicking Recap',5000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','Inventory Count is ongoing for Item 87G and is locked under Location 0001 - Fort Wayne.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .displayText('===== Scenario 8. Inventory Count - Lock Inventory Done =====')
//        //endregion

        //region Scenario 9. Add new Storage Measurement Reading with 1 item only.
        .displayText('===== Scenario 1. Add new Storage Measurement Reading with 1 item only. ====')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .waitUntilLoaded()
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','Smoke Commodity','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','ICSmoke - SL','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Add new Storage Measurement Reading with 1 item only Done. ====')


        .displayText('=====  Add IC Transactions Done====')
        .done();

})