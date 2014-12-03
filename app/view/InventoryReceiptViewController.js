/*
 * File: app/view/InventoryReceiptViewController.js
 *
 * This file was generated by Sencha Architect version 3.1.0.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 5.0.x library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 5.0.x. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('Inventory.view.InventoryReceiptViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.inventoryreceipt',

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
                store: '{receiptTypes}'
            },
            cboReferenceNumber: '{current.intSourceId}',
            cboVendor: {
                value: '{current.intVendorId}',
                store: '{vendor}'
            },
            txtVendorName: '{current.strVendorName}',
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
            dtmReceiptDate: '{current.dtmReceiptDate}',
            cboCurrency: {
                value: '{current.intCurrencyId}',
                store: '{currency}'
            },
            txtReceiptNumber: '{current.strReceiptNumber}',
            txtBlanketReleaseNumber: '{current.intBlanketRelease}',
            txtVendorRefNumber: '{current.strVendorRefNo}',
            txtBillOfLadingNumber: '{current.strBillOfLading}',
            cboProductOrigin: {
                value: '{current.intProductOrigin}',
                store: '{country}'
            },
            txtReceiver: '{current.intReceiverId}',
            txtVessel: '{current.strVessel}',
            cboFreightTerms: {
                value: '{current.intFreightTermId}',
                store: '{freightTerm}'
            },
            txtFobPoint: '{current.strFobPoint}',
            txtDeliveryPoint: '{current.strDeliveryPoint}',
            cboAllocateFreight: {
                value: '{current.strAllocateFreight}',
                store: '{allocateFreights}'
            },
            cboFreightBilledBy: {
                value: '{current.strFreightBilledBy}',
                store: '{freightBilledBys}'
            },
            txtShiftNumber: '{current.intShiftNumber}',
            txtNotes: '{current.strNotes}',


            grdInventoryReceipt: {
                colItemNo: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{items}'
                    }
                },
                colDescription: 'strItemDescription',
                colSubLocation: '',
                colLotTracking: '',
                colQtyOrdered: '',
                colOpenReceive: '',
                colReceived: '',
                colUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{itemUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryReceipt.selection.intItemId}'
                        }]
                    }
                },
                colPackages: 'intNoPackages',
                colPackageType: {
                    dataIndex: 'strPackName',
                    editor: {
                        store: '{itemPackType}'
                    }
                },
                colUnitCost: 'dblUnitCost',
                colUnitRetail: 'dblUnitRetail'
            },


            // ---- Freight and Invoice Tab
            cboCalculationBasis: {
                value: '{current.strCalculationBasis}',
                store: '{calculationBasis}'
            },
            txtUnitsWeightMiles: '{current.dblUnitWeightMile}',
            txtFreightRate: '{current.dblFreightRate}',
            txtFuelSurcharge: '{current.dblFuelSurcharge}',
//            txtCalculatedFreight: '{current.strMessage}',
//            txtCalculatedAmount: '{current.strMessage}',
            txtInvoiceAmount: '{current.dblInvoiceAmount}',
//            txtDifference: '{current.strMessage}',
            chkInvoicePaid: '{current.ysnInvoicePaid}',
            txtCheckNo: {
                value: '{current.intCheckNo}',
                readOnly: '{!current.ysnInvoicePaid}'
            },
            txtCheckDate: {
                value: '{current.dteCheckDate}',
                readOnly: '{!current.ysnInvoicePaid}'
            },
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

        var grdInventoryReceipt = win.down('#grdInventoryReceipt'),
            grdLotTracking = win.down('#grdLotTracking');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.mvvm.attachment.Manager', {
                type: 'Inventory.Receipt',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryReceiptItems',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdInventoryReceipt,
                        deleteButton : grdInventoryReceipt.down('#btnDeleteInventoryReceipt')
                    }),
                    details: [
                        {
                            key: 'tblICInventoryReceiptItemLots',
                            component: Ext.create('iRely.mvvm.grid.Manager', {
                                grid: grdLotTracking,
                                deleteButton : grdLotTracking.down('#btnDeleteInventoryReceipt')
                            })
                        }
                    ]
                }
            ]
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
    },

    createRecord: function(config, action) {
        var me = this;
        var today = new Date();
        var record = Ext.create('Inventory.model.Receipt');
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);

        record.set('dtmReceiptDate', today);
        record.set('dtmReceiptDate', today);
        action(record);
    },

    onVendorSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) current.set('strVendorName', records[0].get('strName'));
    },

    onFreightTermSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) current.set('strFobPoint', records[0].get('strFobPoint'));
    },

    onReceiptItemSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colItemNo')
        {
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
        }
        else if (combo.column.itemId === 'colUOM')
        {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
        else if (combo.column.itemId === 'colPackageType')
        {
            current.set('intPackTypeId', records[0].get('intPackTypeId'));
        }
    },

    init: function(application) {
        this.control({
            "#cboVendor": {
                select: this.onVendorSelect
            },
            "#cboFreightTerms": {
                select: this.onFreightTermSelect
            },
            "#cboItem": {
                select: this.onReceiptItemSelect
            },
            "#cboItemUOM": {
                select: this.onReceiptItemSelect
            },
            "#cboItemPackType": {
                select: this.onReceiptItemSelect
            }
        })
    }

});
