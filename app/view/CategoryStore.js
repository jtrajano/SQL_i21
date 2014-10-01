/*
 * File: app/view/CategoryStore.js
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

Ext.define('Inventory.view.CategoryStore', {
    extend: 'Ext.window.Window',
    alias: 'widget.categorystore',

    requires: [
        'Inventory.view.CategoryStoreViewModel',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.field.Checkbox',
        'Ext.form.field.Number',
        'Ext.form.field.Date',
        'Ext.toolbar.Paging'
    ],

    viewModel: {
        type: 'categorystore'
    },
    height: 415,
    hidden: false,
    maxHeight: 415,
    minHeight: 415,
    minWidth: 675,
    width: 675,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Category Store',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            height: 350,
            itemId: 'frmCategoryStore',
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
                            itemId: 'btnSearch',
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-search',
                            scale: 'large',
                            text: 'Search'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnDelete',
                            width: 45,
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
                    xtype: 'container',
                    layout: {
                        type: 'hbox',
                        align: 'stretch'
                    },
                    items: [
                        {
                            xtype: 'container',
                            flex: 1.1,
                            margin: '0 5 0 0 ',
                            width: 346,
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtStore',
                                    fieldLabel: 'Store',
                                    labelWidth: 165
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtCashRegisterDepartment',
                                    fieldLabel: 'Cash Register Department',
                                    labelWidth: 165
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkUpdatePricesOnPbImports',
                                    fieldLabel: 'Update Prices on PB Imports',
                                    labelWidth: 165
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkDefaultUseTaxFlag1',
                                    fieldLabel: 'Default Use Tax Flag 1',
                                    labelWidth: 165
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkDefaultUseTaxFlag2',
                                    fieldLabel: 'Default Use Tax Flag 2',
                                    labelWidth: 165
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkDefaultUseTaxFlag3',
                                    fieldLabel: 'Default Use Tax Flag 3',
                                    labelWidth: 165
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkDefaultUseTaxFlag4',
                                    fieldLabel: 'Default Use Tax Flag 4',
                                    labelWidth: 165
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkDefaultBlueLaw1',
                                    fieldLabel: 'Default Blue Law 1',
                                    labelWidth: 165
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkDefaultBlueLaw2',
                                    fieldLabel: 'Default Blue Law 2',
                                    labelWidth: 165
                                },
                                {
                                    xtype: 'container',
                                    margin: '0 0 5 0',
                                    layout: {
                                        type: 'hbox',
                                        align: 'stretch'
                                    }
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            flex: 1,
                            margin: '0 1 0 5',
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'numberfield',
                                    itemId: 'txtDefaultNucleusGroupId',
                                    fieldLabel: 'Default Nucleus Group ID',
                                    labelWidth: 165,
                                    hideTrigger: true
                                },
                                {
                                    xtype: 'numberfield',
                                    itemId: 'txtTargetGrossProfitPercent',
                                    fieldLabel: 'Target Gross Profit %',
                                    labelWidth: 160,
                                    hideTrigger: true
                                },
                                {
                                    xtype: 'numberfield',
                                    itemId: 'txtTargetInventoryAtCost',
                                    fieldLabel: 'Target Inventory at Cost',
                                    labelWidth: 160,
                                    hideTrigger: true
                                },
                                {
                                    xtype: 'numberfield',
                                    itemId: 'txtCostOfInventoryAtBom',
                                    fieldLabel: 'Cost of Inventory at BOM',
                                    labelWidth: 160,
                                    hideTrigger: true
                                },
                                {
                                    xtype: 'numberfield',
                                    itemId: 'txtLowGrossMarginPercentAlert',
                                    fieldLabel: 'Low Gross Margin % Alert',
                                    labelWidth: 160,
                                    hideTrigger: true
                                },
                                {
                                    xtype: 'numberfield',
                                    itemId: 'txtHighGrossMarginPercentAlert',
                                    fieldLabel: 'High Gross Margin % Alert',
                                    labelWidth: 160,
                                    hideTrigger: true
                                },
                                {
                                    xtype: 'datefield',
                                    itemId: 'dtmLastInventoryLevelEntry',
                                    fieldLabel: 'Last Inventory Level Entry',
                                    labelWidth: 160
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});