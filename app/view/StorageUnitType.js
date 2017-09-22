/*
 * File: app/view/StorageUnitType.js
 *
 * This file was generated by Sencha Architect version 4.2.2.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 6.5.x Classic library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 6.5.x Classic. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('Inventory.view.StorageUnitType', {
    extend: 'Ext.window.Window',
    alias: 'widget.icstorageunittype',

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

    height: 385,
    hidden: false,
    minHeight: 385,
    minWidth: 637,
    width: 637,
    layout: 'fit',
    collapsible: true,
    title: 'Storage Unit Type',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmStorageUnitType',
            margin: -1,
            ui: 'i21-form',
            bodyPadding: 3,
            trackResetOnLoad: true,
            layout: {
                type: 'hbox',
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
                            itemId: 'btnNew',
                            tabIndex: -1,
                            ui: 'i21-button-toolbar-small',
                            text: 'New'
                        },
                        {
                            xtype: 'button',
                            itemId: 'btnSave',
                            tabIndex: -1,
                            ui: 'i21-button-toolbar-small',
                            text: 'Save'
                        },
                        {
                            xtype: 'button',
                            itemId: 'btnSearch',
                            tabIndex: -1,
                            ui: 'i21-button-toolbar-small',
                            text: 'Search'
                        },
                        {
                            xtype: 'button',
                            itemId: 'btnDelete',
                            tabIndex: -1,
                            ui: 'i21-button-toolbar-small',
                            text: 'Delete'
                        },
                        {
                            xtype: 'button',
                            itemId: 'btnUndo',
                            tabIndex: -1,
                            ui: 'i21-button-toolbar-small',
                            text: 'Undo'
                        },
                        {
                            xtype: 'button',
                            itemId: 'btnClose',
                            tabIndex: -1,
                            ui: 'i21-button-toolbar-small',
                            text: 'Close'
                        }
                    ]
                },
                {
                    xtype: 'ipagingstatusbar',
                    dock: 'bottom',
                    itemId: 'pagingtoolbar',
                    flex: 1
                }
            ],
            items: [
                {
                    xtype: 'tabpanel',
                    flex: 1,
                    itemId: 'tabStorageUnitType',
                    bodyCls: 'i21-tab',
                    activeTab: 0,
                    plain: true,
                    items: [
                        {
                            xtype: 'panel',
                            bodyPadding: 5,
                            title: 'Details',
                            layout: {
                                type: 'hbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'panel',
                                    flex: 1,
                                    itemId: 'pnlDetail',
                                    margin: '0 5 0 0',
                                    bodyPadding: 10,
                                    title: 'Details',
                                    layout: {
                                        type: 'vbox',
                                        align: 'stretch'
                                    },
                                    items: [
                                        {
                                            xtype: 'textfield',
                                            itemId: 'txtName',
                                            fieldLabel: 'Name',
                                            labelWidth: 90
                                        },
                                        {
                                            xtype: 'textfield',
                                            itemId: 'txtDescription',
                                            fieldLabel: 'Description',
                                            labelWidth: 90
                                        },
                                        {
                                            xtype: 'combobox',
                                            itemId: 'cboInternalCode',
                                            fieldLabel: 'Internal Code',
                                            labelWidth: 90,
                                            displayField: 'strInternalCode',
                                            valueField: 'strInternalCode'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intUnitMeasureId',
                                                    dataType: 'numeric',
                                                    text: 'Unit Measure ID',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strUnitMeasure',
                                                    dataType: 'string',
                                                    text: 'Capacity',
                                                    flex: 1
                                                }
                                            ],
                                            itemId: 'cboCapacityUom',
                                            fieldLabel: 'Capacity UOM',
                                            labelWidth: 90,
                                            displayField: 'strUnitMeasure',
                                            valueField: 'intUnitMeasureId'
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtMaxWeight',
                                            fieldLabel: 'Max. Weight',
                                            labelWidth: 90,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkAllowsPicking',
                                            fieldLabel: 'Allows Picking',
                                            labelWidth: 90
                                        }
                                    ]
                                },
                                {
                                    xtype: 'panel',
                                    flex: 1,
                                    itemId: 'pnlDimension',
                                    margin: '0 0 0 5',
                                    bodyPadding: 10,
                                    title: 'Dimensions',
                                    layout: {
                                        type: 'vbox',
                                        align: 'stretch'
                                    },
                                    items: [
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intUnitMeasureId',
                                                    dataType: 'numeric',
                                                    text: 'Unit Measure ID',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strUnitMeasure',
                                                    dataType: 'string',
                                                    text: 'Dimension',
                                                    flex: 1
                                                }
                                            ],
                                            itemId: 'cboDimensionUom',
                                            fieldLabel: 'Dimension UOM',
                                            labelWidth: 98,
                                            displayField: 'strUnitMeasure',
                                            valueField: 'intUnitMeasureId'
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtHeight',
                                            fieldLabel: 'Height',
                                            labelWidth: 98,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtDepth',
                                            fieldLabel: 'Depth',
                                            labelWidth: 98,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtWidth',
                                            fieldLabel: 'Width',
                                            labelWidth: 98,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtPalletStack',
                                            fieldLabel: 'Pallet Stack',
                                            labelWidth: 98,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true,
                                            allowDecimals: false
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtPalletColumns',
                                            fieldLabel: 'Pallet Columns',
                                            labelWidth: 98,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true,
                                            allowDecimals: false
                                        },
                                        {
                                            xtype: 'numberfield',
                                            quantityField: true,
                                            itemId: 'txtPalletRows',
                                            fieldLabel: 'Pallet Rows',
                                            labelWidth: 98,
                                            fieldStyle: 'text-align:right',
                                            hideTrigger: true,
                                            allowDecimals: false
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