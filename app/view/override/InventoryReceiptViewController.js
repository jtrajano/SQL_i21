Ext.define('Inventory.view.override.InventoryReceiptViewController', {
    override: 'Inventory.view.InventoryReceiptViewController',

    config: {
        searchConfig: {
            title:  'Search Inventory Receipt',
            type: 'Inventory.InventoryReceipt',
            api: {
                read: '../Inventory/api/Receipt/SearchReceipts'
            },
            columns: [
                {dataIndex: 'intInventoryReceiptId',text: "Receipt Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1,  dataType: 'string'},
                {dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1,  dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strReceiptType',text: 'Receipt Type', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            cboReceiptType: {
                value: '{current.strReceiptType}',
                store: '{ReceiptTypes}'
            },
            cboReferenceNumber: '{current.intSourceId}',
            cboVendorId: '{current.intVendorId}',
//            txtVendorName: '{current.strVendorName}',
            cboLocation: '{current.intLocationId}',
            dtmReceiptDate: '{current.dtmReceiptDate}',
            cboCurrency: '{current.intCurrencyId}',
            txtReceiptNumber: '{current.strReceiptNumber}',
            txtBlanketReleaseNumber: '{current.intBlanketRelease}',
            txtVendorRefNumber: '{current.strVendorRefNo}',
            txtBillOfLadingNumber: '{current.strBillOfLading}',
            txtProductOrigin: '{current.intProductOrigin}',
            txtReceiver: '{current.strReceiver}',
            txtVessel: '{current.strVessel}',
            cboFreightTerms: '{current.intFreightTermId}',
//            txtFobPoint: '{current.strMessage}',
            txtDeliveryPoint: '{current.strDeliveryPoint}',
            cboAllocateFreight: {
                value: '{current.strAllocateFreight}',
                store: '{AllocateFreights}'
            },
            cboFreightBilledBy: {
                value: '{current.strFreightBilledBy}',
                store: '{FreightBilledBys}'
            },
            txtShiftNumber: '{current.intShiftNumber}',
            txtNotes: '{current.strNotes}',


            // ---- Freight and Invoice Tab
            cboCalculationBasis: {
                value: '{current.strCalculationBasis}',
                store: '{CalculationBasis}'
            },
            txtUnitsWeightMiles: '{current.dblUnitWeightMile}',
            txtFreightRate: '{current.dblFreightRate}',
            txtFuelSurcharge: '{current.dblFuelSurcharge}',
//            txtCalculatedFreight: '{current.strMessage}',
//            txtCalculatedAmount: '{current.strMessage}',
            txtInvoiceAmount: '{current.dblInvoiceAmount}',
//            txtDifference: '{current.strMessage}',
            chkInvoicePaid: '{current.ysnInvoicePaid}',
            txtCheckNo: '{current.intCheckNo}',
            txtCheckDate: '{current.dteCheckDate}',
//            txtInvoiceMargin: '{current.strMessage}',

            // ---- EDI tab
            cboTrailerType: '{current.intTrailerTypeId}',
            txtTrailerArrivalDate: '{current.dteTrailerArrivalDate}',
            txtTrailerArrivalTime: '{current.dteTrailerArrivalTime}',
            txtSealNo: '{current.strSealNo}',
            cboSealStatus: '{current.strSealStatus}',
            txtReceiveTime: '{current.dteReceiveTime}',
            txtActualTempReading: '{current.dblActualTempReading}'

        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Receipt', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding
        });

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intInventoryReceiptId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    }

});