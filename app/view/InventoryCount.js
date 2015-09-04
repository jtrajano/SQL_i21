/*
 * File: app/view/InventoryCount.js
 *
 * This file was generated by Sencha Architect version 3.2.0.
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

Ext.define('Inventory.view.InventoryCount', {
    extend: 'Ext.window.Window',
    alias: 'widget.inventorycount',

    requires: [
        'Inventory.view.Filter1',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.toolbar.Separator',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Checkbox',
        'Ext.form.field.Number',
        'Ext.grid.Panel',
        'Ext.grid.column.Column',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.toolbar.Paging'
    ],

    height: 773,
    hidden: false,
    minHeight: 625,
    minWidth: 765,
    width: 1048,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Inventory Count',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmInventoryCount',
            margin: -1,
            bodyBorder: false,
            bodyPadding: 5,
            header: false,
            trackResetOnLoad: true,
            layout: {
                type: 'vbox',
                align: 'stretch'
            },
            dockedItems: [
                {
                    xtype: 'toolbar',
                    dock: 'top',
                    width: 588,
                    layout: {
                        type: 'hbox',
                        padding: '0 0 0 1'
                    },
                    items: [
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnNew',
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-new',
                            scale: 'large',
                            text: 'New'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnSave',
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-save',
                            scale: 'large',
                            text: 'Save'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnDelete',
                            width: 55,
                            iconAlign: 'top',
                            iconCls: 'large-delete',
                            scale: 'large',
                            text: 'Delete'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnUndo',
                            width: 55,
                            iconAlign: 'top',
                            iconCls: 'large-undo',
                            scale: 'large',
                            text: 'Undo'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnRefresh',
                            width: 55,
                            iconAlign: 'top',
                            iconCls: 'large-refresh',
                            scale: 'large',
                            text: 'Refresh'
                        },
                        {
                            xtype: 'tbseparator',
                            height: 30
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnFetch',
                            width: 55,
                            iconAlign: 'top',
                            iconCls: 'large-fetch',
                            scale: 'large',
                            text: 'Fetch'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnPrintCountSheets',
                            width: 103,
                            iconAlign: 'top',
                            iconCls: 'large-print',
                            scale: 'large',
                            text: 'Print Count Sheets'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnPrintCountCards',
                            width: 100,
                            iconAlign: 'top',
                            iconCls: 'large-print-labels',
                            scale: 'large',
                            text: 'Print Count Cards'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnLockInventory',
                            width: 95,
                            iconAlign: 'top',
                            iconCls: 'large-lock-closed',
                            scale: 'large',
                            text: 'Lock Inventory'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnEnterCount',
                            width: 72,
                            iconAlign: 'top',
                            iconCls: 'large-commit',
                            scale: 'large',
                            text: 'Enter Count'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnShowVariance',
                            width: 84,
                            iconAlign: 'top',
                            iconCls: 'large-calculate-amount',
                            scale: 'large',
                            text: 'Show Variance'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnQuality',
                            width: 60,
                            iconAlign: 'top',
                            iconCls: 'large-test',
                            scale: 'large',
                            text: 'Quality'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnPost',
                            width: 60,
                            iconAlign: 'top',
                            iconCls: 'large-post',
                            scale: 'large',
                            text: 'Post'
                        },
                        {
                            xtype: 'tbseparator',
                            height: 30
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnClose',
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-close',
                            scale: 'large',
                            text: 'Close'
                        }
                    ]
                },
                {
                    xtype: 'ipagingstatusbar',
                    itemId: 'pagingtoolbar',
                    flex: 1,
                    dock: 'bottom'
                }
            ],
            items: [
                {
                    xtype: 'tabpanel',
                    flex: 1,
                    itemId: 'tabInventoryCount',
                    activeTab: 0,
                    plain: true,
                    items: [
                        {
                            xtype: 'panel',
                            bodyPadding: 5,
                            title: 'Details',
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'container',
                                    layout: 'hbox',
                                    items: [
                                        {
                                            xtype: 'container',
                                            flex: 1,
                                            layout: {
                                                type: 'vbox',
                                                align: 'stretch'
                                            },
                                            items: [
                                                {
                                                    xtype: 'combobox',
                                                    itemId: 'cboCountName',
                                                    fieldLabel: 'Count Name',
                                                    labelWidth: 85
                                                },
                                                {
                                                    xtype: 'container',
                                                    flex: 1,
                                                    margin: '0 0 5 0',
                                                    layout: {
                                                        type: 'hbox',
                                                        align: 'stretch'
                                                    },
                                                    items: [
                                                        {
                                                            xtype: 'checkboxfield',
                                                            itemId: 'chkRecount',
                                                            margin: '0 15 0 0',
                                                            fieldLabel: 'Recount',
                                                            labelWidth: 85
                                                        },
                                                        {
                                                            xtype: 'checkboxfield',
                                                            itemId: 'chkIncludeZeroOnHand',
                                                            fieldLabel: 'Include Zero On Hand',
                                                            labelWidth: 125
                                                        }
                                                    ]
                                                },
                                                {
                                                    xtype: 'combobox',
                                                    itemId: 'txtCountNumber',
                                                    fieldLabel: 'Count No',
                                                    labelWidth: 85
                                                },
                                                {
                                                    xtype: 'combobox',
                                                    itemId: 'cboLocation',
                                                    fieldLabel: 'Location',
                                                    labelWidth: 85
                                                },
                                                {
                                                    xtype: 'combobox',
                                                    itemId: 'cboSubLocation',
                                                    fieldLabel: 'Sub Location',
                                                    labelWidth: 85
                                                }
                                            ]
                                        },
                                        {
                                            xtype: 'container',
                                            flex: 1.2,
                                            margin: '0 0 0 5',
                                            layout: {
                                                type: 'vbox',
                                                align: 'stretch'
                                            },
                                            items: [
                                                {
                                                    xtype: 'combobox',
                                                    itemId: 'cboCategory',
                                                    fieldLabel: 'Category',
                                                    labelWidth: 85
                                                },
                                                {
                                                    xtype: 'combobox',
                                                    itemId: 'cboCommodity',
                                                    fieldLabel: 'Commodity',
                                                    labelWidth: 85
                                                },
                                                {
                                                    xtype: 'combobox',
                                                    itemId: 'cboCountGroup',
                                                    fieldLabel: 'Count Group',
                                                    labelWidth: 85
                                                },
                                                {
                                                    xtype: 'container',
                                                    flex: 1,
                                                    margin: '0 0 5 0',
                                                    layout: {
                                                        type: 'hbox',
                                                        align: 'stretch'
                                                    },
                                                    items: [
                                                        {
                                                            xtype: 'numberfield',
                                                            flex: 1,
                                                            itemId: 'txtCountNumber',
                                                            margin: '0 5 0 0',
                                                            fieldLabel: 'Count No',
                                                            labelWidth: 85,
                                                            hideTrigger: true
                                                        },
                                                        {
                                                            xtype: 'numberfield',
                                                            flex: 1,
                                                            itemId: 'txtCountSeqNumber',
                                                            fieldLabel: 'Count Seq No',
                                                            labelWidth: 85,
                                                            hideTrigger: true
                                                        }
                                                    ]
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtDescription',
                                                    fieldLabel: 'Description',
                                                    labelWidth: 85
                                                }
                                            ]
                                        },
                                        {
                                            xtype: 'container',
                                            flex: 0.8,
                                            margin: '0 0 0 5',
                                            layout: {
                                                type: 'vbox',
                                                align: 'stretch'
                                            },
                                            items: [
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtCountYear',
                                                    fieldLabel: 'Count/Year',
                                                    labelWidth: 99
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtIncludeOnHand',
                                                    fieldLabel: 'Include On Hand',
                                                    labelWidth: 99
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtInventoryType',
                                                    fieldLabel: 'Inventory Type',
                                                    labelWidth: 99
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtCountCard',
                                                    fieldLabel: 'Count Card',
                                                    labelWidth: 99
                                                }
                                            ]
                                        },
                                        {
                                            xtype: 'container',
                                            flex: 0.8,
                                            margin: '0 0 0 5',
                                            layout: {
                                                type: 'vbox',
                                                align: 'stretch'
                                            },
                                            items: [
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtScannedCountEntry',
                                                    fieldLabel: 'Scanned Count Entry',
                                                    labelWidth: 125
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtCountByLots',
                                                    fieldLabel: 'Count by Lots',
                                                    labelWidth: 125
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtRecountMismatch',
                                                    fieldLabel: 'Recount Mismatch',
                                                    labelWidth: 125
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtStatus',
                                                    fieldLabel: 'Status',
                                                    labelWidth: 125
                                                }
                                            ]
                                        }
                                    ]
                                },
                                {
                                    xtype: 'gridpanel',
                                    flex: 1,
                                    itemId: 'grdPhysicalCount',
                                    dockedItems: [
                                        {
                                            xtype: 'toolbar',
                                            dock: 'top',
                                            itemId: 'tlbGridOptions',
                                            layout: {
                                                type: 'hbox',
                                                padding: '0 0 0 1'
                                            },
                                            items: [
                                                {
                                                    xtype: 'button',
                                                    tabIndex: -1,
                                                    itemId: 'btnInsert',
                                                    iconCls: 'small-add',
                                                    text: 'Insert'
                                                },
                                                {
                                                    xtype: 'button',
                                                    tabIndex: -1,
                                                    itemId: 'btnRemove',
                                                    iconCls: 'small-delete',
                                                    text: 'Remove'
                                                },
                                                {
                                                    xtype: 'tbseparator'
                                                },
                                                {
                                                    xtype: 'filter1'
                                                }
                                            ]
                                        }
                                    ],
                                    columns: [
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Item'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            width: 185,
                                            dataIndex: 'string',
                                            text: 'Description'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Category'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Storage Location'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Lot ID'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Lot Alias'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            width: 64,
                                            dataIndex: 'string',
                                            text: 'On Hand'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            width: 71,
                                            dataIndex: 'string',
                                            text: 'Last Cost'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Count Card No.'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            width: 85,
                                            dataIndex: 'string',
                                            text: 'No. of Pallets'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Qty Per Pallet'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Physical Count'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'UOM'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            width: 180,
                                            dataIndex: 'string',
                                            text: 'Physical Count in Stock Unit'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Variance'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Entered By'
                                        }
                                    ],
                                    viewConfig: {
                                        itemId: 'grvPhysicalCount'
                                    },
                                    selModel: {
                                        selType: 'checkboxmodel'
                                    }
                                }
                            ]
                        },
                        {
                            xtype: 'panel',
                            layout: 'fit',
                            title: 'Notes'
                        },
                        {
                            xtype: 'panel',
                            layout: 'fit',
                            title: 'Attachments'
                        }
                    ]
                }
            ]
        }
    ]

});