/*
 * File: app/view/FeedStockUom.js
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

Ext.define('Inventory.view.FeedStockUom', {
    extend: 'Ext.window.Window',
    alias: 'widget.feedstockuom',

    requires: [
        'Inventory.view.FeedStockUomViewModel',
        'Inventory.view.Statusbar1',
        'Ext.form.Panel',
        'Ext.toolbar.Toolbar',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.grid.Panel',
        'Ext.grid.column.Column',
        'Ext.form.field.Text',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.CellEditing'
    ],

    viewModel: {
        type: 'feedstockuom'
    },
    height: 535,
    hidden: false,
    minHeight: 535,
    minWidth: 530,
    width: 530,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Feed Stock UOM',
    maximizable: true,

    initConfig: function(instanceConfig) {
        var me = this,
            config = {
                items: [
                    {
                        xtype: 'form',
                        autoShow: true,
                        height: 350,
                        itemId: 'frmFeedStockUom',
                        margin: -1,
                        width: 450,
                        bodyPadding: 5,
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
                                xtype: 'istatusbar',
                                flex: 1,
                                dock: 'bottom'
                            }
                        ],
                        items: [
                            {
                                xtype: 'gridpanel',
                                flex: 1,
                                itemId: 'grdFeedStockUom',
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
                                                itemId: 'btnDeleteFeedStockUom',
                                                iconCls: 'small-delete',
                                                text: 'Delete'
                                            },
                                            {
                                                xtype: 'tbseparator'
                                            }
                                        ]
                                    }
                                ],
                                columns: [
                                    {
                                        xtype: 'gridcolumn',
                                        itemId: 'colUOM',
                                        width: 82,
                                        dataIndex: 'string',
                                        text: 'UOM',
                                        flex: 1,
                                        editor: {
                                            xtype: 'textfield'
                                        }
                                    },
                                    {
                                        xtype: 'gridcolumn',
                                        itemId: 'colUOMCode',
                                        dataIndex: 'string',
                                        text: 'UOM Code',
                                        flex: 2,
                                        editor: {
                                            xtype: 'textfield'
                                        }
                                    }
                                ],
                                viewConfig: {
                                    itemId: 'grvFeedStockUom'
                                },
                                selModel: Ext.create('Ext.selection.CheckboxModel', {
                                    selType: 'checkboxmodel'
                                }),
                                plugins: [
                                    {
                                        ptype: 'cellediting',
                                        pluginId: 'FeedStockUOMplugin',
                                        clicksToEdit: 1
                                    }
                                ]
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