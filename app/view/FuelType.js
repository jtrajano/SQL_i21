/*
 * File: app/view/FuelType.js
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

Ext.define('Inventory.view.FuelType', {
    extend: 'Ext.window.Window',
    alias: 'widget.fueltype',

    requires: [
        'Inventory.view.FuelTypeViewModel',
        'Inventory.view.StatusbarPaging',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Checkbox',
        'Ext.toolbar.Paging'
    ],

    viewModel: {
        type: 'fueltype'
    },
    height: 465,
    hidden: false,
    maxHeight: 465,
    minHeight: 465,
    minWidth: 455,
    width: 455,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Fuel Types',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            reference: 'frmFuelType',
            autoShow: true,
            height: 350,
            margin: -1,
            width: 450,
            bodyBorder: false,
            bodyPadding: 10,
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
                            reference: 'btnNew',
                            tabIndex: -1,
                            height: 57,
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-new',
                            scale: 'large',
                            text: 'New'
                        },
                        {
                            xtype: 'button',
                            reference: 'btnSave',
                            tabIndex: -1,
                            height: 57,
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-save',
                            scale: 'large',
                            text: 'Save'
                        },
                        {
                            xtype: 'button',
                            reference: 'btnSearch',
                            tabIndex: -1,
                            height: 57,
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-search',
                            scale: 'large',
                            text: 'Search'
                        },
                        {
                            xtype: 'button',
                            reference: 'btnDelete',
                            tabIndex: -1,
                            height: 57,
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-delete',
                            scale: 'large',
                            text: 'Delete'
                        },
                        {
                            xtype: 'button',
                            reference: 'btnUndo',
                            tabIndex: -1,
                            height: 57,
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-undo',
                            scale: 'large',
                            text: 'Undo'
                        },
                        {
                            xtype: 'tbseparator',
                            height: 30
                        },
                        {
                            xtype: 'button',
                            reference: 'btnClose',
                            tabIndex: -1,
                            height: 57,
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
                    reference: 'pagingtoolbar',
                    flex: 1,
                    dock: 'bottom'
                }
            ],
            items: [
                {
                    xtype: 'container',
                    flex: 1.25,
                    margin: '0 5 0 0',
                    width: 1014,
                    layout: {
                        type: 'vbox',
                        align: 'stretch'
                    },
                    items: [
                        {
                            xtype: 'combobox',
                            reference: 'cboFuelType',
                            fieldLabel: 'Fuel Type',
                            labelWidth: 165
                        },
                        {
                            xtype: 'combobox',
                            reference: 'cboFeedStock',
                            fieldLabel: 'Feed Stock',
                            labelWidth: 165
                        },
                        {
                            xtype: 'textfield',
                            reference: 'txtBatchNo',
                            fieldLabel: 'Batch No',
                            labelWidth: 165
                        },
                        {
                            xtype: 'textfield',
                            reference: 'txtEndingRinGallonsForBatch',
                            fieldLabel: 'Ending RIN Gallons for Batch',
                            labelWidth: 165
                        },
                        {
                            xtype: 'combobox',
                            reference: 'cboEquivalenceValue',
                            width: 170,
                            fieldLabel: 'Equivalence Value',
                            labelWidth: 165
                        },
                        {
                            xtype: 'combobox',
                            reference: 'cboFuelCode',
                            width: 170,
                            fieldLabel: 'Fuel Code',
                            labelWidth: 165
                        },
                        {
                            xtype: 'combobox',
                            reference: 'cboProcessCode',
                            width: 170,
                            fieldLabel: 'Process Code',
                            labelWidth: 165
                        },
                        {
                            xtype: 'combobox',
                            reference: 'cboFeedStockUom',
                            width: 170,
                            fieldLabel: 'Feed Stock UOM',
                            labelWidth: 165
                        },
                        {
                            xtype: 'textfield',
                            reference: 'txtFeedStockFactor',
                            fieldLabel: 'Feed Stock Factor',
                            labelWidth: 165
                        },
                        {
                            xtype: 'checkboxfield',
                            reference: 'chkRenewableBiomass',
                            fieldLabel: 'Renewable Biomass',
                            labelWidth: 165
                        },
                        {
                            xtype: 'textfield',
                            reference: 'txtPercentOfDenaturant',
                            fieldLabel: 'Percent of Denaturant',
                            labelWidth: 165
                        },
                        {
                            xtype: 'checkboxfield',
                            reference: 'chkDeductDenaturantFromRin',
                            fieldLabel: 'Deduct Denaturant from RIN',
                            labelWidth: 165
                        }
                    ]
                }
            ]
        }
    ]

});