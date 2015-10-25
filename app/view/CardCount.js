/*
 * File: app/view/CardCount.js
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

Ext.define('Inventory.view.CardCount', {
    extend: 'Ext.window.Window',
    alias: 'widget.cardcount',

    requires: [
        'Inventory.view.Filter1',
        'Inventory.view.Statusbar1',
        'Ext.form.Panel',
        'Ext.toolbar.Toolbar',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.ComboBox',
        'Ext.grid.Panel',
        'Ext.grid.column.Column',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel'
    ],

    height: 629,
    hidden: false,
    width: 1050,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Card Count',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmCardCount',
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
                            itemId: 'btnFetch',
                            ui: 'i21-button-toolbar-small',
                            text: 'Fetch'
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
                    xtype: 'statusbar1',
                    dock: 'bottom'
                }
            ],
            items: [
                {
                    xtype: 'tabpanel',
                    itemId: 'tabCardCount',
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
                                    margin: '0 0 8 0',
                                    layout: 'hbox',
                                    items: [
                                        {
                                            xtype: 'textfield',
                                            flex: 1,
                                            itemId: 'txtCountNumber',
                                            margin: '0 5 0 0',
                                            fieldLabel: 'Count No',
                                            labelWidth: 60
                                        },
                                        {
                                            xtype: 'combobox',
                                            flex: 1,
                                            itemId: 'cboFrom',
                                            margin: '0 5 0 0',
                                            fieldLabel: 'From',
                                            labelWidth: 35
                                        },
                                        {
                                            xtype: 'combobox',
                                            flex: 1,
                                            itemId: 'cboTo',
                                            margin: '0 5 0 0',
                                            fieldLabel: 'To',
                                            labelWidth: 30
                                        }
                                    ]
                                },
                                {
                                    xtype: 'gridpanel',
                                    flex: 1,
                                    itemId: 'grdCardCount',
                                    dockedItems: [
                                        {
                                            xtype: 'toolbar',
                                            dock: 'top',
                                            componentCls: 'i21-toolbar-grid',
                                            itemId: 'tlbGridOptions',
                                            layout: {
                                                type: 'hbox',
                                                padding: '0 0 0 1'
                                            },
                                            items: [
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
                                            text: 'Item',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Description',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Lot ID'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Count Card No.'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            width: 83,
                                            dataIndex: 'string',
                                            text: 'No. of Pallets'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            width: 80,
                                            dataIndex: 'string',
                                            text: 'Qty per Pallet'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            width: 88,
                                            dataIndex: 'string',
                                            text: 'Physical Count'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            width: 66,
                                            dataIndex: 'string',
                                            text: 'UOM'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            dataIndex: 'string',
                                            text: 'Entered By'
                                        }
                                    ],
                                    viewConfig: {
                                        itemId: 'grvCardCount'
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