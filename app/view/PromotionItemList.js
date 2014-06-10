/*
 * File: app/view/PromotionItemList.js
 *
 * This file was generated by Sencha Architect version 3.0.4.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 4.2.x library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 4.2.x. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('Inventory.view.PromotionItemList', {
    extend: 'Ext.window.Window',
    alias: 'widget.promotionitemlist',

    requires: [
        'Inventory.view.StatusbarPaging',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.field.Number',
        'Ext.form.field.Checkbox',
        'Ext.grid.Panel',
        'Ext.grid.column.Number',
        'Ext.grid.View',
        'Ext.toolbar.Paging'
    ],

    height: 585,
    hidden: false,
    minHeight: 585,
    minWidth: 700,
    width: 700,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Promotion Item List',
    maximizable: true,

    initComponent: function() {
        var me = this;

        Ext.applyIf(me, {
            items: [
                {
                    xtype: 'form',
                    autoShow: true,
                    height: 350,
                    itemId: 'frmPromotionItemList',
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
                                    height: 57,
                                    itemId: 'btnNew',
                                    width: 45,
                                    iconAlign: 'top',
                                    iconCls: 'large-new',
                                    scale: 'large',
                                    tabIndex: -1,
                                    text: 'New'
                                },
                                {
                                    xtype: 'button',
                                    height: 57,
                                    itemId: 'btnSave',
                                    width: 45,
                                    iconAlign: 'top',
                                    iconCls: 'large-save',
                                    scale: 'large',
                                    tabIndex: -1,
                                    text: 'Save'
                                },
                                {
                                    xtype: 'button',
                                    height: 57,
                                    itemId: 'btnSearch',
                                    width: 45,
                                    iconAlign: 'top',
                                    iconCls: 'large-search',
                                    scale: 'large',
                                    tabIndex: -1,
                                    text: 'Search'
                                },
                                {
                                    xtype: 'button',
                                    height: 57,
                                    itemId: 'btnDelete',
                                    width: 45,
                                    iconAlign: 'top',
                                    iconCls: 'large-delete',
                                    scale: 'large',
                                    tabIndex: -1,
                                    text: 'Delete'
                                },
                                {
                                    xtype: 'button',
                                    height: 57,
                                    itemId: 'btnUndo',
                                    width: 45,
                                    iconAlign: 'top',
                                    iconCls: 'large-undo',
                                    scale: 'large',
                                    tabIndex: -1,
                                    text: 'Undo'
                                },
                                {
                                    xtype: 'tbseparator',
                                    height: 30
                                },
                                {
                                    xtype: 'button',
                                    height: 57,
                                    itemId: 'btnClose',
                                    width: 45,
                                    iconAlign: 'top',
                                    iconCls: 'large-close',
                                    scale: 'large',
                                    tabIndex: -1,
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
                            margins: '0 5 0 0',
                            width: 1014,
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'container',
                                    margins: '0 0 5 0',
                                    layout: 'hbox',
                                    items: [
                                        {
                                            xtype: 'textfield',
                                            flex: 1,
                                            itemId: 'txtStore',
                                            width: 170,
                                            fieldLabel: 'Store',
                                            labelWidth: 95
                                        },
                                        {
                                            xtype: 'container',
                                            flex: 1,
                                            margins: '0 0 0 5'
                                        }
                                    ]
                                },
                                {
                                    xtype: 'container',
                                    margins: '0 0 5 0',
                                    layout: 'hbox',
                                    items: [
                                        {
                                            xtype: 'textfield',
                                            flex: 1,
                                            itemId: 'txtItemListNo',
                                            width: 170,
                                            fieldLabel: 'Item List No',
                                            labelWidth: 95
                                        },
                                        {
                                            xtype: 'textfield',
                                            flex: 1,
                                            margins: '0 0 0 5',
                                            itemId: 'txtItemListId',
                                            width: 170,
                                            fieldLabel: 'Item List ID',
                                            labelWidth: 120
                                        }
                                    ]
                                },
                                {
                                    xtype: 'container',
                                    margins: '0 0 5 0',
                                    layout: 'hbox',
                                    items: [
                                        {
                                            xtype: 'numberfield',
                                            flex: 1,
                                            itemId: 'txtTotalUnitPrice',
                                            fieldLabel: 'Total Unit Price',
                                            labelWidth: 95,
                                            hideTrigger: true
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            flex: 1,
                                            margins: '0 0 0 5',
                                            itemId: 'chkDeleteFromRegister',
                                            fieldLabel: 'Delete from Register',
                                            labelWidth: 120
                                        }
                                    ]
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtDescription',
                                    width: 170,
                                    fieldLabel: 'Description',
                                    labelWidth: 95
                                },
                                {
                                    xtype: 'gridpanel',
                                    flex: 1,
                                    itemId: 'grdItemList',
                                    title: 'My Grid Panel',
                                    columns: [
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'UPC Code',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Modifier No.',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Item Description',
                                            flex: 2
                                        },
                                        {
                                            xtype: 'numbercolumn',
                                            align: 'right',
                                            dataIndex: 'number',
                                            text: 'Retail Price',
                                            flex: 1
                                        }
                                    ],
                                    viewConfig: {
                                        itemId: 'grvItemList'
                                    }
                                }
                            ]
                        }
                    ]
                }
            ]
        });

        me.callParent(arguments);
    }

});