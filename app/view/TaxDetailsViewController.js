/*
 * File: app/view/BrandViewController.js
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

Ext.define('Inventory.view.TaxDetailsViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.ictaxdetails',

    setupContext: function () {
        "use strict";

        var me = this;
        var win = this.getView();
        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: Ext.create('Inventory.store.ReceiptItemTax'),
            singleGridMgr: Ext.create('iRely.grid.Manager', {
                grid: win.down('grid'),
                position: 'none',
                title: 'Tax Details',
                columns: [
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colItemNo',
                        sortable: false,
                        dataIndex: 'strItemNo',
                        text: 'Item No',
                        flex: 1.3
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colTaxGroup',
                        sortable: false,
                        dataIndex: 'strTaxGroup',
                        text: 'Tax Group',
                        flex: 1.5
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colTaxClass',
                        sortable: false,
                        dataIndex: 'strTaxClass',
                        text: 'Tax Class',
                        flex: 1.5
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colTaxCode',
                        sortable: false,
                        dataIndex: 'strTaxCode',
                        text: 'Tax Code',
                        flex: 1.7
                    },
                    {
                        xtype: 'gridcolumn',
                        itemId: 'colCalculationMethod',
                        flex: 1.5,
                        sortable: false,
                        dataIndex: 'strCalculationMethod',
                        text: 'Calculation Method'
                    },
                    {
                        xtype: 'numbercolumn',
                        itemId: 'colRate',
                        flex: 0.75,
                        align: 'right',
                        format: '0,000.00####',
                        dataIndex: 'dblRate',
                        text: 'Rate'
                    },
                    {
                        xtype: 'numbercolumn',
                        itemId: 'colTax',
                        flex: 1.2,
                        align: 'right',
                        format: '0,000.00####',
                        dataIndex: 'dblTax',
                        text: 'Tax Amount'
                    }
                ]
            })
        });
        return win.context;
    },

    show: function (config) {
        "use strict";
        var me = this;
        var win = me.getView();
        var btnSave = win.down('#btnSave');
        var btnUndo = win.down('#btnUndo');
        var btnInsert = win.down('#btnInsert');
        var btnDelete = win.down('#btnDelete');
        btnSave.setHidden(true);
        btnUndo.setHidden(true);
        btnInsert.setHidden(true);
        btnDelete.setHidden(true);

        win.width = 760;
        win.minWidth = 760;
        win.show();

        var context = win.context ? win.context.initialize() : me.setupContext();
        if (config.param.ReceiptId) {
            me.intInventoryReceiptId = config.param.ReceiptId;
            config.filters = [{
                column: 'intInventoryReceiptId',
                value: config.param.ReceiptId
            }];
        }
        else if (config.param.id) {
            me.intInventoryReceiptItemId = config.param.id;
            config.filters = [{
                column: 'intInventoryReceiptItemId',
                value: config.param.id
            }];
        }
        context.data.load({
            filters: config.filters
        });
    }

});
