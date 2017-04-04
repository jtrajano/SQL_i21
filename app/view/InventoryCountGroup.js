/*
 * File: app/view/InventoryCountGroup.js
 *
 * This file was generated by Sencha Architect version 3.5.1.
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

Ext.define('Inventory.view.InventoryCountGroup', {
    extend: 'Ext.window.Window',
    alias: 'widget.inventorycountgroup',

    requires: [
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.Number',
        'Ext.form.field.Checkbox',
        'Ext.toolbar.Paging'
    ],

    height: 359,
    hidden: false,
    minHeight: 359,
    minWidth: 473,
    width: 473,
    layout: 'fit',
    collapsible: true,
    title: 'Inventory Count Group',

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmInventoryCountGroup',
            margin: -1,
            ui: 'i21-form',
            bodyPadding: 3,
            trackResetOnLoad: true,
            layout: {
                type: 'vbox',
                align: 'stretch'
            },
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
                    flex: 1,
                    dock: 'bottom'
                }
            ],
            items: [
                {
                    xtype: 'tabpanel',
                    flex: 1,
                    itemId: 'tabInventoryCountGroup',
                    bodyCls: 'i21-tab',
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
                                    layout: {
                                        type: 'vbox',
                                        align: 'stretch'
                                    },
                                    items: [
                                        {
                                            xtype: 'textfield',
                                            itemId: 'txtCountGroup',
                                            fieldLabel: 'Count Group',
                                            labelWidth: 125
                                        },
                                        {
                                            xtype: 'numericfield',
                                            quantityField: true,
                                            itemId: 'txtCountsPerYear',
                                            fieldLabel: 'Counts Per Year',
                                            labelWidth: 125,
                                            hideTrigger: true,
                                            allowDecimals: false
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkIncludeOnHand',
                                            fieldLabel: 'Include On Hand',
                                            labelWidth: 125
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkScannedCountEntry',
                                            fieldLabel: 'Scanned Count Entry',
                                            labelWidth: 125
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkCountByLots',
                                            fieldLabel: 'Count by Lots',
                                            labelWidth: 125
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkCountByPallets',
                                            fieldLabel: 'Count by Pallets',
                                            labelWidth: 125
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkRecountMismatch',
                                            fieldLabel: 'Recount Mismatch',
                                            labelWidth: 125
                                        },
                                        {
                                            xtype: 'checkboxfield',
                                            itemId: 'chkExternal',
                                            fieldLabel: 'External',
                                            labelWidth: 125
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