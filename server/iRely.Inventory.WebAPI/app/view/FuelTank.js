/*
 * File: app/view/FuelTank.js
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

Ext.define('Inventory.view.FuelTank', {
    extend: 'Ext.window.Window',
    alias: 'widget.fueltank',

    requires: [
        'Inventory.view.Filter',
        'Inventory.view.Statusbar',
        'Ext.form.Panel',
        'Ext.toolbar.Toolbar',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.grid.Panel',
        'Ext.grid.column.Number',
        'Ext.grid.column.Date',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel'
    ],

    height: 621,
    hidden: false,
    minHeight: 500,
    minWidth: 530,
    width: 875,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Fuel Tank',
    maximizable: true,

    initConfig: function(instanceConfig) {
        var me = this,
            config = {
                items: [
                    {
                        xtype: 'form',
                        autoShow: true,
                        height: 350,
                        itemId: 'frmFuelTank',
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
                                xtype: 'statusbar',
                                flex: 1,
                                dock: 'bottom'
                            }
                        ],
                        items: [
                            {
                                xtype: 'gridpanel',
                                flex: 1,
                                itemId: 'grdFuelTank',
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
                                                itemId: 'btnDeleteFuelTank',
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
                                        width: 82,
                                        dataIndex: 'string',
                                        text: 'Store Name'
                                    },
                                    {
                                        xtype: 'gridcolumn',
                                        width: 81,
                                        dataIndex: 'string',
                                        text: 'Fuel Tank No.'
                                    },
                                    {
                                        xtype: 'gridcolumn',
                                        dataIndex: 'string',
                                        text: 'Description',
                                        flex: 1
                                    },
                                    {
                                        xtype: 'numbercolumn',
                                        width: 85,
                                        text: 'Tank Capacity'
                                    },
                                    {
                                        xtype: 'numbercolumn',
                                        width: 92,
                                        text: 'Current Volume'
                                    },
                                    {
                                        xtype: 'datecolumn',
                                        width: 78,
                                        text: 'Last Update'
                                    },
                                    {
                                        xtype: 'numbercolumn',
                                        width: 96,
                                        text: 'Last Update Shift'
                                    },
                                    {
                                        xtype: 'gridcolumn',
                                        width: 108,
                                        dataIndex: 'string',
                                        text: 'Tax Department No.'
                                    }
                                ],
                                viewConfig: {
                                    itemId: 'grvFuelTank'
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