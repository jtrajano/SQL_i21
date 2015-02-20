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
    alias: 'widget.icitempricing',

    requires: [
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Number',
        'Ext.toolbar.Paging'
    ],

    height: 330,
    hidden: false,
    minHeight: 330,
    minWidth: 594,
    width: 594,
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
                                    dataIndex: 'intCompanyLocationId',
                                    dataType: 'numeric',
                                    text: 'Location Id',
                                    hidden: true
                                },
                                {
                                    dataIndex: 'strLocationName',
                                    dataType: 'string',
                                    text: 'Location Name',
                                    flex: 1
                                },
                                {
                                    dataIndex: 'strLocationType',
                                    dataType: 'string',
                                    text: 'Location Type',
                                    flex: 1
                                }
                            ],
                            tabIndex: 0,
                            itemId: 'cboLocation',
                            fieldLabel: 'Location',
                            labelWidth: 110,
                            displayField: 'strLocationName',
                            valueField: 'intItemLocationId',
                            bind: {
                                store: '{Location}'
                            }
                        },
                        {
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: {
                                type: 'hbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 3,
                                    itemId: 'txtLastCost',
                                    fieldLabel: 'Last Cost',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    fieldStyle: 'text-align:right',
                                    hideTrigger: true,
                                    allowExponential: false
                                },
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 4,
                                    itemId: 'txtStandardCost',
                                    margin: '0 0 0 5',
                                    fieldLabel: 'Standard Cost',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    fieldStyle: 'text-align:right',
                                    hideTrigger: true,
                                    allowExponential: false
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: {
                                type: 'hbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 5,
                                    itemId: 'txtAverageCost',
                                    margin: '',
                                    fieldLabel: 'Average Cost',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    fieldStyle: 'text-align:right',
                                    hideTrigger: true,
                                    allowExponential: false
                                },
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 6,
                                    itemId: 'txtEndofMonthCost',
                                    margin: '0 0 0 5',
                                    fieldLabel: 'End of Month Cost',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    fieldStyle: 'text-align:right',
                                    hideTrigger: true,
                                    allowExponential: false
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: {
                                type: 'hbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'combobox',
                                    flex: 1,
                                    tabIndex: 7,
                                    itemId: 'cboPricingMethod',
                                    fieldLabel: 'Pricing Method',
                                    labelWidth: 110,
                                    displayField: 'strDescription',
                                    valueField: 'strDescription',
                                    bind: {
                                        store: '{PricingMethods}'
                                    }
                                },
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 8,
                                    itemId: 'txtAmountPercent',
                                    margin: '0 0 0 5',
                                    width: 115,
                                    fieldLabel: 'Amount',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    hideTrigger: true
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: {
                                type: 'hbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 9,
                                    itemId: 'txtSalePrice',
                                    fieldLabel: 'Sale Price',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    fieldStyle: 'text-align:right',
                                    hideTrigger: true,
                                    allowExponential: false
                                },
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 10,
                                    itemId: 'txtRetailPrice',
                                    margin: '0 0 0 5',
                                    fieldLabel: 'Retail Price',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    fieldStyle: 'text-align:right',
                                    hideTrigger: true,
                                    allowExponential: false
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: {
                                type: 'hbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 11,
                                    itemId: 'txtWholesalePrice',
                                    fieldLabel: 'Wholesale Price',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    fieldStyle: 'text-align:right',
                                    hideTrigger: true,
                                    allowExponential: false
                                },
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 12,
                                    itemId: 'txtLargeVolumePrice',
                                    margin: '0 0 0 5',
                                    fieldLabel: 'Large Volume Price',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    fieldStyle: 'text-align:right',
                                    hideTrigger: true,
                                    allowExponential: false
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: {
                                type: 'hbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'moneynumber',
                                    flex: 1,
                                    tabIndex: 13,
                                    itemId: 'txtMsrp',
                                    fieldLabel: 'MSRP',
                                    labelWidth: 110,
                                    checkChangeBuffer: 3000,
                                    fieldStyle: 'text-align:right',
                                    hideTrigger: true,
                                    allowExponential: false
                                },
                                {
                                    xtype: 'container',
                                    flex: 1,
                                    margin: '0 0 0 5'
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});