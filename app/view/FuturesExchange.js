/*
 * File: app/view/FuturesExchange.js
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

Ext.define('Inventory.view.FuturesExchange', {
    extend: 'Ext.window.Window',
    alias: 'widget.futuresexchange',

    requires: [
        'Inventory.view.FuturesExchangeViewModel',
        'Inventory.view.StatusbarPaging',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.Label',
        'Ext.form.field.TextArea',
        'Ext.form.field.ComboBox',
        'Ext.toolbar.Paging'
    ],

    viewModel: {
        type: 'futuresexchange'
    },
    height: 390,
    hidden: false,
    maxHeight: 390,
    minHeight: 385,
    minWidth: 475,
    width: 475,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Futures Exchange',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            height: 350,
            itemId: 'frmFuturesExchange',
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
                    flex: 1.25,
                    margin: '0 5 0 0',
                    width: 1014,
                    layout: {
                        type: 'vbox',
                        align: 'stretch'
                    },
                    items: [
                        {
                            xtype: 'textfield',
                            itemId: 'txtExchangeCode',
                            width: 170,
                            fieldLabel: 'Exchange Code',
                            labelWidth: 95
                        },
                        {
                            xtype: 'textfield',
                            itemId: 'txtExchangeName',
                            width: 170,
                            fieldLabel: 'Exchange Name',
                            labelWidth: 95
                        },
                        {
                            xtype: 'container',
                            height: 58,
                            margin: '0 0 5 0 ',
                            layout: 'hbox',
                            items: [
                                {
                                    xtype: 'label',
                                    padding: '3 0 0 0',
                                    width: 78,
                                    text: 'Address:'
                                },
                                {
                                    xtype: 'container',
                                    width: 22,
                                    layout: 'hbox',
                                    items: [
                                        {
                                            xtype: 'button',
                                            tabIndex: -1,
                                            itemId: 'btnAddressMap',
                                            style: {
                                                background: 'transparent',
                                                borderColor: 'transparent'
                                            },
                                            iconCls: 'small-map'
                                        }
                                    ]
                                },
                                {
                                    xtype: 'textareafield',
                                    flex: 1,
                                    height: 58,
                                    itemId: 'txtAddress',
                                    hideLabel: true,
                                    labelWidth: 0,
                                    name: 'strAddress',
                                    enforceMaxLength: true,
                                    maxLength: 65
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: 'hbox',
                            items: [
                                {
                                    xtype: 'gridcombobox',
                                    columns: [
                                        {
                                            dataIndex: 'intZipCodeId',
                                            text: 'Zip Code Id',
                                            hidden: true
                                        },
                                        {
                                            dataIndex: 'strZipCode',
                                            text: 'Zip/Postal Code',
                                            flex: 1
                                        },
                                        {
                                            dataIndex: 'strCity',
                                            text: 'City',
                                            flex: 1
                                        },
                                        {
                                            dataIndex: 'strState',
                                            text: 'State/Province',
                                            flex: 1
                                        },
                                        {
                                            dataIndex: 'strCountry',
                                            text: 'Country',
                                            flex: 1
                                        }
                                    ],
                                    flex: 1.2,
                                    itemId: 'cboZipCode',
                                    fieldLabel: 'Zip/Postal Code',
                                    labelWidth: 95,
                                    name: 'strZipCode',
                                    displayField: 'strZipCode',
                                    valueField: 'strZipCode'
                                },
                                {
                                    xtype: 'textfield',
                                    flex: 1,
                                    tabIndex: -1,
                                    itemId: 'txtCity',
                                    margin: '0 0 0 5',
                                    fieldLabel: 'City',
                                    labelWidth: 50,
                                    name: 'strCity',
                                    enforceMaxLength: true,
                                    maxLength: 85
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: 'hbox',
                            items: [
                                {
                                    xtype: 'textfield',
                                    flex: 1.2,
                                    tabIndex: -1,
                                    itemId: 'txtState',
                                    fieldLabel: 'State/Province',
                                    labelWidth: 95,
                                    name: 'strState',
                                    enforceMaxLength: true,
                                    maxLength: 60
                                },
                                {
                                    xtype: 'gridcombobox',
                                    columns: [
                                        {
                                            dataIndex: 'intCountryId',
                                            text: 'Country Id',
                                            hidden: true
                                        },
                                        {
                                            dataIndex: 'strCountry',
                                            text: 'Country',
                                            flex: 1
                                        }
                                    ],
                                    flex: 1,
                                    tabIndex: -1,
                                    itemId: 'cboCountry',
                                    margin: '0 0 0 5',
                                    fieldLabel: 'Country',
                                    labelWidth: 50,
                                    name: 'strCountry',
                                    enforceMaxLength: true,
                                    maxLength: 75,
                                    displayField: 'strCountry',
                                    valueField: 'strCountry'
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: 'hbox',
                            items: [
                                {
                                    xtype: 'textfield',
                                    flex: 1.2,
                                    itemId: 'txtPhone',
                                    fieldLabel: 'Phone',
                                    labelWidth: 95,
                                    name: 'strPhone',
                                    enforceMaxLength: true,
                                    maxLength: 30,
                                    vtype: 'phone'
                                },
                                {
                                    xtype: 'textfield',
                                    flex: 1,
                                    itemId: 'txtFax',
                                    margin: '0 0 0 5',
                                    fieldLabel: 'Fax',
                                    labelWidth: 50,
                                    name: 'strFax',
                                    enforceMaxLength: true,
                                    maxLength: 30,
                                    vtype: 'phone'
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            height: 22,
                            margin: '0 0 5 0 ',
                            layout: 'hbox',
                            items: [
                                {
                                    xtype: 'label',
                                    padding: '3 0 0 0',
                                    width: 78,
                                    text: 'Website:'
                                },
                                {
                                    xtype: 'container',
                                    width: 22,
                                    layout: 'hbox',
                                    items: [
                                        {
                                            xtype: 'button',
                                            tabIndex: -1,
                                            itemId: 'btnWebsite',
                                            style: {
                                                background: 'transparent',
                                                borderColor: 'transparent'
                                            },
                                            iconAlign: 'right',
                                            iconCls: 'small-web'
                                        }
                                    ]
                                },
                                {
                                    xtype: 'textfield',
                                    flex: 1,
                                    itemId: 'txtWebsite',
                                    hideLabel: true,
                                    labelWidth: 0,
                                    name: 'strWebsite',
                                    enforceMaxLength: true,
                                    maxLength: 125
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            height: 22,
                            margin: '0 0 5 0 ',
                            layout: 'hbox',
                            items: [
                                {
                                    xtype: 'label',
                                    padding: '3 0 0 0',
                                    width: 78,
                                    text: 'Email:'
                                },
                                {
                                    xtype: 'container',
                                    width: 22,
                                    layout: 'hbox',
                                    items: [
                                        {
                                            xtype: 'button',
                                            tabIndex: -1,
                                            itemId: 'btnEmail',
                                            style: {
                                                background: 'transparent',
                                                borderColor: 'transparent'
                                            },
                                            iconCls: 'small-email'
                                        }
                                    ]
                                },
                                {
                                    xtype: 'textfield',
                                    flex: 1,
                                    itemId: 'txtEmail',
                                    hideLabel: true,
                                    labelWidth: 0,
                                    name: 'strEmail',
                                    enforceMaxLength: true,
                                    maxLength: 225
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});