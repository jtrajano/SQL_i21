/*
 * File: app/view/InventoryTag.js
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

Ext.define('Inventory.view.InventoryTag', {
    extend: 'Ext.window.Window',
    alias: 'widget.icinventorytag',

    requires: [
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.field.Checkbox',
        'Ext.form.field.TextArea',
        'Ext.toolbar.Paging'
    ],

    height: 525,
    hidden: false,
    minHeight: 525,
    minWidth: 600,
    width: 600,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Inventory Tag',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            height: 350,
            itemId: 'frmInventoryTag',
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
                            xtype: 'container',
                            margin: '0 0 5 0',
                            layout: 'hbox',
                            items: [
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtTagNumber',
                                    width: 300,
                                    fieldLabel: 'Tag Number',
                                    labelWidth: 90
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkHAZMATMessage',
                                    margin: '0 0 0 5',
                                    fieldLabel: 'HAZMAT Message',
                                    labelWidth: 110
                                }
                            ]
                        },
                        {
                            xtype: 'textfield',
                            itemId: 'txtDescription',
                            fieldLabel: 'Description',
                            labelWidth: 90
                        },
                        {
                            xtype: 'textareafield',
                            flex: 1,
                            itemId: 'txtMessage',
                            fieldLabel: 'Message',
                            labelWidth: 90,
                            grow: true
                        }
                    ]
                }
            ]
        }
    ]

});