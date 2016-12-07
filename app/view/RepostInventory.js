/*
 * File: app/view/RepostInventory.js
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

Ext.define('Inventory.view.RepostInventory', {
    extend: 'Ext.window.Window',
    alias: 'widget.icrepostinventory',

    requires: [
        'Ext.toolbar.Toolbar',
        'Ext.button.Button',
        'Ext.form.Panel',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Display',
        'Ext.grid.Panel',
        'Ext.grid.column.Date',
        'Ext.grid.View'
    ],

    height: 403,
    hidden: false,
    margin: '',
    width: 520,
    layout: 'fit',
    title: 'Repost Inventory',
    modal: true,

    dockedItems: [
        {
            xtype: 'toolbar',
            dock: 'top',
            height: 32,
            ui: 'i21-toolbar',
            items: [
                {
                    xtype: 'button',
                    itemId: 'btnRepost',
                    ui: 'i21-button-toolbar-small',
                    text: 'Post'
                },
                {
                    xtype: 'button',
                    itemId: 'btnClose',
                    ui: 'i21-button-toolbar-small',
                    text: 'Close'
                }
            ]
        }
    ],
    items: [
        {
            xtype: 'container',
            padding: '',
            layout: 'fit',
            items: [
                {
                    xtype: 'container',
                    layout: 'border',
                    items: [
                        {
                            xtype: 'form',
                            region: 'north',
                            border: false,
                            height: 106,
                            itemId: 'frmRebuildInventory',
                            ui: 'i21-form',
                            bodyPadding: 3,
                            items: [
                                {
                                    xtype: 'container',
                                    layout: {
                                        type: 'hbox',
                                        align: 'stretch',
                                        padding: '0 0 5 0'
                                    },
                                    items: [
                                        {
                                            xtype: 'combobox',
                                            flex: 2,
                                            itemId: 'cboFiscalMonth',
                                            fieldLabel: 'Fiscal Month',
                                            displayField: 'strMonth',
                                            forceSelection: true,
                                            valueField: 'strMonth'
                                        },
                                        {
                                            xtype: 'datefield',
                                            flex: 1,
                                            margins: '',
                                            itemId: 'cboFiscalDate',
                                            padding: '0 0 0 5',
                                            fieldLabel: 'Fiscal Month',
                                            hideLabel: true
                                        }
                                    ]
                                },
                                {
                                    xtype: 'combobox',
                                    anchor: '100%',
                                    itemId: 'cboPostOrder',
                                    fieldLabel: 'Post Order',
                                    displayField: 'strPostOrder',
                                    forceSelection: true,
                                    valueField: 'strPostOrder'
                                },
                                {
                                    xtype: 'gridcombobox',
                                    columns: [
                                        {
                                            dataIndex: 'intItemId',
                                            dataType: 'int',
                                            hidden: true
                                        },
                                        {
                                            dataIndex: 'strItemNo',
                                            dataType: 'string',
                                            text: 'Item No.',
                                            flex: 1
                                        },
                                        {
                                            dataIndex: 'strType',
                                            dataType: 'string',
                                            text: 'Type',
                                            flex: 1
                                        },
                                        {
                                            dataIndex: 'strDescription',
                                            dataType: 'string',
                                            text: 'Description',
                                            flex: 1
                                        }
                                    ],
                                    anchor: '100%',
                                    itemId: 'cboItem',
                                    fieldLabel: 'Item (optional)',
                                    displayField: 'strItemNo',
                                    valueField: 'strItemNo'
                                },
                                {
                                    xtype: 'displayfield',
                                    anchor: '100%',
                                    itemId: 'lblDescription',
                                    padding: '0 0 0 105',
                                    hideEmptyLabel: false,
                                    hideLabel: true,
                                    value: 'Please fill out the required fields above.',
                                    fieldStyle: 'font-size: 8pt; color: gray; font-style: italic;'
                                }
                            ]
                        },
                        {
                            xtype: 'gridpanel',
                            region: 'center',
                            border: true,
                            itemId: 'grdLog',
                            title: 'Messages',
                            hideHeaders: true,
                            rowLines: false,
                            columns: [
                                {
                                    xtype: 'gridcolumn',
                                    width: 380,
                                    dataIndex: 'string',
                                    text: 'Message'
                                },
                                {
                                    xtype: 'datecolumn',
                                    dataIndex: 'date',
                                    text: 'Date'
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});