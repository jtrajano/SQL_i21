/*
 * File: app/view/FuelType.js
 *
 * This file was generated by Sencha Architect version 3.5.1.
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

Ext.define('Inventory.view.FuelType', {
    extend: 'Ext.window.Window',
    alias: 'widget.icfueltype',

    requires: [
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Number',
        'Ext.form.field.Checkbox',
        'Ext.toolbar.Paging'
    ],

    height: 470,
    hidden: false,
    width: 481,
    layout: 'fit',
    collapsible: true,
    title: 'Fuel Types',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmFuelType',
            margin: -1,
            ui: 'i21-form',
            bodyPadding: 3,
            trackResetOnLoad: true,
            layout: {
                type: 'vbox',
                align: 'stretch'
            },
            dockedItems: [
                {
                    xtype: 'toolbar',
                    dock: 'top',
                    ui: 'i21-toolbar',
                    width: 588,
                    layout: {
                        type: 'hbox',
                        padding: '0 0 0 1'
                    },
                    items: [
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            itemId: 'btnNew',
                            ui: 'i21-button-toolbar-small',
                            text: 'New'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            itemId: 'btnSave',
                            ui: 'i21-button-toolbar-small',
                            text: 'Save'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            itemId: 'btnSearch',
                            ui: 'i21-button-toolbar-small',
                            text: 'Search'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            itemId: 'btnDelete',
                            ui: 'i21-button-toolbar-small',
                            text: 'Delete'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            itemId: 'btnUndo',
                            ui: 'i21-button-toolbar-small',
                            text: 'Undo'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            itemId: 'btnClose',
                            ui: 'i21-button-toolbar-small',
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
                    itemId: 'tabFuelType',
                    bodyCls: 'i21-tab',
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
                                    flex: 1,
                                    layout: {
                                        type: 'vbox',
                                        align: 'stretch'
                                    },
                                    items: [
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intRinFuelCategoryId',
                                                    dataType: 'int',
                                                    text: 'Fuel Category Id',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strRinFuelCategoryCode',
                                                    dataType: 'string',
                                                    text: 'Fuel Category',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Description',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'strEquivalenceValue',
                                                    dataType: 'string',
                                                    text: 'Equivalence Value',
                                                    flex: 1
                                                }
                                            ],
                                            enableDrillDown: true,
                                            itemId: 'cboFuelCategory',
                                            fieldLabel: 'Fuel Category',
                                            labelWidth: 165,
                                            displayField: 'strRinFuelCategoryCode',
                                            valueField: 'strRinFuelCategoryCode'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intRinFeedStockId',
                                                    dataType: 'int',
                                                    text: 'Feed Stock Id',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strRinFeedStockCode',
                                                    dataType: 'string',
                                                    text: 'Code',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Description',
                                                    flex: 1
                                                }
                                            ],
                                            enableDrillDown: true,
                                            itemId: 'cboFeedStock',
                                            fieldLabel: 'Feed Stock',
                                            labelWidth: 165,
                                            displayField: 'strRinFeedStockCode',
                                            valueField: 'strRinFeedStockCode'
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtBatchNo',
                                            fieldLabel: 'Batch No',
                                            labelWidth: 165,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true,
                                            allowDecimals: false
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtEndingRinGallonsForBatch',
                                            fieldLabel: 'Ending RIN Gallons for Batch',
                                            labelWidth: 165,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true,
                                            allowDecimals: false
                                        },
                                        {
                                            xtype: 'textfield',
                                            itemId: 'txtEquivalenceValue',
                                            width: 170,
                                            fieldLabel: 'Equivalence Value',
                                            labelWidth: 165
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intRinFuelId',
                                                    dataType: 'int',
                                                    text: 'Fuel Code Id',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strRinFuelCode',
                                                    dataType: 'string',
                                                    text: 'Code',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Description',
                                                    flex: 1
                                                }
                                            ],
                                            enableDrillDown: true,
                                            itemId: 'cboFuelCode',
                                            width: 170,
                                            fieldLabel: 'Fuel Code',
                                            labelWidth: 165,
                                            displayField: 'strRinFuelCode',
                                            valueField: 'strRinFuelCode'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intRinProcessId',
                                                    dataType: 'int',
                                                    text: 'Process Id',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strRinProcessCode',
                                                    dataType: 'string',
                                                    text: 'Code',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Description',
                                                    flex: 1
                                                }
                                            ],
                                            enableDrillDown: true,
                                            itemId: 'cboProductionProcess',
                                            width: 170,
                                            fieldLabel: 'Production Process',
                                            labelWidth: 165,
                                            displayField: 'strRinProcessCode',
                                            valueField: 'strRinProcessCode'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intRinFeedStockUOMId',
                                                    dataType: 'int',
                                                    text: 'Feed Stock UOM Id',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'intUnitMeasureId',
                                                    dataType: 'int',
                                                    text: 'UOM Id',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strUnitMeasure',
                                                    dataType: 'string',
                                                    text: 'Unit Measure Id',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'strRinFeedStockUOMCode',
                                                    dataType: 'string',
                                                    text: 'UOM Code',
                                                    flex: 1
                                                }
                                            ],
                                            enableDrillDown: true,
                                            itemId: 'cboFeedStockUom',
                                            width: 170,
                                            fieldLabel: 'Feed Stock UOM',
                                            labelWidth: 165,
                                            displayField: 'strRinFeedStockUOMCode',
                                            valueField: 'strRinFeedStockUOMCode'
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtFeedStockFactor',
                                            fieldLabel: 'Feed Stock Factor',
                                            labelWidth: 165,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkRenewableBiomass',
                                            fieldLabel: 'Renewable Biomass',
                                            labelWidth: 165
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtPercentOfDenaturant',
                                            fieldLabel: 'Percent of Denaturant',
                                            labelWidth: 165,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkDeductDenaturantFromRin',
                                            fieldLabel: 'Deduct Denaturant from RIN',
                                            labelWidth: 165
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});