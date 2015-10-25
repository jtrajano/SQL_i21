/*
 * File: app/view/ContractDocument.js
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

Ext.define('Inventory.view.ContractDocument', {
    extend: 'Ext.window.Window',
    alias: 'widget.iccontractdocument',

    requires: [
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Checkbox',
        'Ext.toolbar.Paging'
    ],

    height: 268,
    hidden: false,
    width: 451,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Contract Document',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmContractDocument',
            margin: -1,
            ui: 'i21-form',
            layout: 'fit',
            bodyPadding: 3,
            trackResetOnLoad: true,
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
                    dock: 'bottom'
                }
            ],
            items: [
                {
                    xtype: 'tabpanel',
                    itemId: 'tabContractDocument',
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
                                            itemId: 'txtDocumentName',
                                            fieldLabel: 'Document Name',
                                            labelWidth: 105
                                        },
                                        {
                                            xtype: 'textfield',
                                            itemId: 'txtDescription',
                                            fieldLabel: 'Description',
                                            labelWidth: 105
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intDocumentType',
                                                    dataType: 'numeric',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Document Type',
                                                    flex: 1
                                                }
                                            ],
                                            itemId: 'cboDocumentType',
                                            width: 170,
                                            fieldLabel: 'Document Type',
                                            labelWidth: 105,
                                            displayField: 'strDescription',
                                            valueField: 'intDocumentType'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intCommodityId',
                                                    dataType: 'numeric',
                                                    text: 'Commodity Id',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strCommodityCode',
                                                    dataType: 'string',
                                                    text: 'Commodity Code',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Description',
                                                    flex: 1
                                                }
                                            ],
                                            itemId: 'cboCommodity',
                                            width: 170,
                                            fieldLabel: 'Commodity',
                                            labelWidth: 105,
                                            displayField: 'strCommodityCode',
                                            valueField: 'intCommodityId'
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkStandard',
                                            fieldLabel: 'Standard',
                                            labelWidth: 105
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