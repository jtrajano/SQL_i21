/*
 * File: app/view/RebuildInventory.js
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

Ext.define('Inventory.view.RebuildInventory', {
    extend: 'Ext.window.Window',
    alias: 'widget.icrebuildinventory',

    requires: [
        'Inventory.view.Statusbar1',
        'Ext.form.Panel',
        'Ext.toolbar.Toolbar',
        'Ext.button.Button',
        'Ext.form.field.ComboBox'
    ],

    height: 220,
    hidden: false,
    margin: '',
    minHeight: 220,
    width: 438,
    layout: 'fit',
    title: 'Rebuild Inventory',
    titleCollapse: false,
    modal: true,

    items: [
        {
            xtype: 'form',
            layout: 'border',
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
                },
                {
                    xtype: 'ipagingstatusbar',
                    width: 150,
                    region: 'east',
                    dock: 'bottom'
                }
            ],
            items: [
                {
                    xtype: 'form',
                    region: 'center',
                    border: false,
                    itemId: 'frmRebuildInventory',
                    bodyPadding: 10,
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
                                    xtype: 'gridcombobox',
                                    columns: [
                                        {
                                            dataIndex: 'intGLFiscalYearPeriodId',
                                            dataType: 'int',
                                            hidden: true
                                        },
                                        {
                                            dataIndex: 'strPeriod',
                                            dataType: 'string',
                                            text: 'Period',
                                            flex: 1
                                        },
                                        {
                                            dataIndex: 'strStartMonth',
                                            dataType: 'string',
                                            text: 'Fiscal Month',
                                            flex: 1
                                        },
                                        {
                                            dataIndex: 'strFiscalYear',
                                            dataType: 'string',
                                            text: 'Fiscal Year',
                                            flex: 1
                                        }
                                    ],
                                    flex: 2,
                                    publishes: 'value',
                                    reference: 'fiscalmonth',
                                    itemId: 'cboFiscalMonth',
                                    fieldLabel: 'Fiscal Month',
                                    displayField: 'strPeriod',
                                    forceSelection: true,
                                    valueField: 'strStartMonth'
                                }
                            ]
                        },
                        {
                            xtype: 'combobox',
                            anchor: '100%',
                            publishes: 'value',
                            reference: 'postorder',
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
                            publishes: 'value',
                            reference: 'item',
                            itemId: 'cboItem',
                            fieldLabel: 'Item (optional)',
                            displayField: 'strItemNo',
                            valueField: 'strItemNo'
                        }
                    ]
                }
            ]
        }
    ]

});