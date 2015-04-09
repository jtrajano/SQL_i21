/*
 * File: app/view/Reason.js
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

Ext.define('Inventory.view.Reason', {
    extend: 'Ext.window.Window',
    alias: 'widget.icreason',

    requires: [
        'Inventory.view.Filter1',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.toolbar.Separator',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Checkbox',
        'Ext.grid.Panel',
        'Ext.grid.column.Column',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.toolbar.Paging'
    ],

    height: 335,
    hidden: false,
    minHeight: 335,
    minWidth: 520,
    width: 520,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Reasons',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            height: 350,
            itemId: 'frmReason',
            margin: -1,
            width: 450,
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
                    xtype: 'tabpanel',
                    flex: 1,
                    itemId: 'tabReason',
                    activeTab: 0,
                    plain: true,
                    items: [
                        {
                            xtype: 'panel',
                            title: 'Details',
                            layout: {
                                type: 'vbox',
                                align: 'stretch',
                                padding: 7
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
                                            xtype: 'container',
                                            margin: '0 0 5 0',
                                            layout: 'hbox',
                                            items: [
                                                {
                                                    xtype: 'textfield',
                                                    flex: 1,
                                                    itemId: 'txtReasonCode',
                                                    fieldLabel: 'Reason Code',
                                                    labelWidth: 130
                                                },
                                                {
                                                    xtype: 'combobox',
                                                    itemId: 'cboType',
                                                    margin: '0 0 0 5',
                                                    width: 175,
                                                    fieldLabel: 'Type',
                                                    labelWidth: 40
                                                }
                                            ]
                                        },
                                        {
                                            xtype: 'textfield',
                                            itemId: 'txtDescription',
                                            fieldLabel: 'Description',
                                            labelWidth: 130
                                        },
                                        {
                                            xtype: 'combobox',
                                            itemId: 'cboLotTransactionType',
                                            fieldLabel: 'Lot Transaction Type',
                                            labelWidth: 130
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkDefault',
                                            fieldLabel: 'Default',
                                            labelWidth: 130
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkReduceAvailableTime',
                                            fieldLabel: 'Reduce Available Time',
                                            labelWidth: 130
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkExplanationRequired',
                                            fieldLabel: 'Explanation Required',
                                            labelWidth: 130
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            xtype: 'panel',
                            title: 'Work Center Mapping',
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'gridpanel',
                                    flex: 1,
                                    itemId: 'grdWorkcenter',
                                    margin: -1,
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
                                                    itemId: 'btnAddWorkCenterMapping',
                                                    iconCls: 'small-add',
                                                    text: 'Insert'
                                                },
                                                {
                                                    xtype: 'button',
                                                    tabIndex: -1,
                                                    itemId: 'btnEditWorkCenterMapping',
                                                    iconCls: 'small-edit',
                                                    text: 'Edit'
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
                                            text: 'Work Center',
                                            flex: 1
                                        }
                                    ],
                                    viewConfig: {
                                        itemId: 'grvWorkcenter'
                                    },
                                    selModel: {
                                        selType: 'checkboxmodel'
                                    }
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});