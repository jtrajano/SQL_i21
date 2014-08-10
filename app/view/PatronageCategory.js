/*
 * File: app/view/PatronageCategory.js
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

Ext.define('Inventory.view.PatronageCategory', {
    extend: 'Ext.window.Window',
    alias: 'widget.patronagecategory',

    requires: [
        'Inventory.view.PatronageCategoryViewModel',
        'Inventory.view.Filter',
        'Inventory.view.StatusbarPaging',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.grid.Panel',
        'Ext.grid.column.Column',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.toolbar.Paging'
    ],

    viewModel: {
        type: 'patronagecategory'
    },
    height: 500,
    hidden: false,
    minHeight: 500,
    minWidth: 530,
    width: 530,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Patronage Category',
    maximizable: true,

    initConfig: function(instanceConfig) {
        var me = this,
            config = {
                items: [
                    {
                        xtype: 'form',
                        autoShow: true,
                        height: 350,
                        itemId: 'frmPatronageCategory',
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
                                xtype: 'gridpanel',
                                flex: 1,
                                itemId: 'grdPatronageCategory',
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
                                                itemId: 'btnDelete',
                                                iconCls: 'small-delete',
                                                text: 'Delete'
                                            },
                                            {
                                                xtype: 'tbseparator'
                                            },
                                            {
                                                xtype: 'filter'
                                            }
                                        ]
                                    }
                                ],
                                columns: [
                                    {
                                        xtype: 'gridcolumn',
                                        dataIndex: 'string',
                                        text: 'Category Code',
                                        flex: 1
                                    },
                                    {
                                        xtype: 'gridcolumn',
                                        dataIndex: 'string',
                                        text: 'Description',
                                        flex: 2
                                    },
                                    {
                                        xtype: 'gridcolumn',
                                        width: 82,
                                        dataIndex: 'string',
                                        text: 'Purchase/Sale'
                                    },
                                    {
                                        xtype: 'gridcolumn',
                                        width: 75,
                                        dataIndex: 'string',
                                        text: 'Unit/Amount'
                                    }
                                ],
                                viewConfig: {
                                    itemId: 'grvPatronageCategory'
                                },
                                selModel: Ext.create('Ext.selection.CheckboxModel', {
                                    selType: 'checkboxmodel'
                                })
                            }
                        ]
                    }
                ]
            };
        if (instanceConfig) {
            me.getConfigurator().merge(me, config, instanceConfig);
        }
        return me.callParent([config]);
    }

});