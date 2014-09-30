/*
 * File: app/view/ItemPricing.js
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

Ext.define('Inventory.view.ItemPricing', {
    extend: 'Ext.window.Window',
    alias: 'widget.itempricing',

    requires: [
        'Inventory.view.ItemPricingViewModel',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Checkbox',
        'Ext.toolbar.Paging'
    ],

    viewModel: {
        type: 'itempricing'
    },
    height: 315,
    hidden: false,
    maxHeight: 315,
    minHeight: 315,
    minWidth: 650,
    width: 650,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Item Pricing',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            height: 350,
            itemId: 'frmItemPricing',
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
                        align: 'stretch',
                        padding: 5
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
                                    xtype: 'textfield',
                                    itemId: 'txtLocation',
                                    fieldLabel: 'Location',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtRetailPrice',
                                    fieldLabel: 'Sale Price',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtRetailPrice1',
                                    fieldLabel: 'Retail Price',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtWolesalePrice',
                                    fieldLabel: 'Wholesale Price',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtLargeVolumePrice',
                                    fieldLabel: 'Large Volume Price',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtMsrp',
                                    fieldLabel: 'MSRP',
                                    labelWidth: 110
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            flex: 1,
                            margin: '0 0 0 5',
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboPricingMethod',
                                    fieldLabel: 'Pricing Method',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtLastCost',
                                    fieldLabel: 'Last Cost',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtStandardCost',
                                    fieldLabel: 'Standard Cost',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtAverageCost',
                                    fieldLabel: 'Average Cost',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtEndofMonthCost',
                                    fieldLabel: 'End of Month Cost',
                                    labelWidth: 110
                                },
                                {
                                    xtype: 'checkboxfield',
                                    flex: 1,
                                    fieldLabel: 'Active',
                                    labelWidth: 110
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});