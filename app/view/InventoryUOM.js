/*
 * File: app/view/InventoryUOM.js
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

Ext.define('Inventory.view.InventoryUOM', {
    extend: 'Ext.window.Window',
    alias: 'widget.icinventoryuom',

    requires: [
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.ComboBox',
        'Ext.grid.Panel',
        'Ext.grid.column.Number',
        'Ext.form.field.Number',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.CellEditing',
        'Ext.toolbar.Paging'
    ],

    height: 550,
    hidden: false,
    width: 500,
    layout: 'fit',
    collapsible: true,
    title: 'Inventory UOM',
    maximizable: true,

    initConfig: function(instanceConfig) {
        var me = this,
            config = {
                items: [
                    {
                        xtype: 'form',
                        autoShow: true,
                        itemId: 'frmInventoryUOM',
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
                                flex: 1,
                                dock: 'bottom'
                            }
                        ],
                        items: [
                            {
                                xtype: 'tabpanel',
                                flex: 1,
                                itemId: 'tabInventoryUOM',
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
                                                xtype: 'textfield',
                                                itemId: 'txtUnitMeasure',
                                                fieldLabel: 'Unit Measure',
                                                labelWidth: 80
                                            },
                                            {
                                                xtype: 'container',
                                                margin: '0 0 5 0',
                                                layout: {
                                                    type: 'hbox',
                                                    align: 'stretch'
                                                },
                                                items: [
                                                    {
                                                        xtype: 'textfield',
                                                        flex: 1,
                                                        itemId: 'txtSymbol',
                                                        margin: '0 5 0 0',
                                                        fieldLabel: 'Symbol',
                                                        labelWidth: 80
                                                    },
                                                    {
                                                        xtype: 'combobox',
                                                        flex: 1,
                                                        itemId: 'cboUnitType',
                                                        margin: '0 5 0 0',
                                                        fieldLabel: 'Unit Type',
                                                        labelWidth: 60,
                                                        displayField: 'strDescription',
                                                        valueField: 'strDescription'
                                                    },
                                                    {
                                                        xtype: 'combobox',
                                                        itemId: 'cboDecimals',
                                                        maxWidth: 110,
                                                        minWidth: 110,
                                                        width: 110,
                                                        fieldLabel: 'Decimals',
                                                        labelWidth: 57,
                                                        displayField: 'value',
                                                        valueField: 'value'
                                                    }
                                                ]
                                            },
                                            {
                                                xtype: 'advancefiltergrid',
                                                flex: 1,
                                                itemId: 'grdConversion',
                                                title: 'Conversion',
                                                columnLines: true,
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
                                                                xtype: 'button',
                                                                tabIndex: -1,
                                                                itemId: 'btnInsertConversion',
                                                                iconCls: 'small-insert',
                                                                text: 'Insert'
                                                            },
                                                            {
                                                                xtype: 'button',
                                                                tabIndex: -1,
                                                                itemId: 'btnDeleteConversion',
                                                                iconCls: 'small-remove',
                                                                text: 'Remove'
                                                            }
                                                        ]
                                                    }
                                                ],
                                                columns: [
                                                    {
                                                        xtype: 'gridcolumn',
                                                        hidden: true,
                                                        itemId: 'colConversionStockUOM',
                                                        dataIndex: 'strUnitMeasure',
                                                        hideable: false,
                                                        text: 'Other UOM',
                                                        flex: 1,
                                                        editor: {
                                                            xtype: 'gridcombobox',
                                                            columns: [
                                                                {
                                                                    dataIndex: 'intUnitMeasureId',
                                                                    dataType: 'numeric',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'strUnitMeasure',
                                                                    dataType: 'string',
                                                                    text: 'Unit Measure',
                                                                    flex: 1
                                                                },
                                                                {
                                                                    dataIndex: 'strUnitType',
                                                                    dataType: 'string',
                                                                    text: 'Unit Type',
                                                                    flex: 1
                                                                }
                                                            ],
                                                            itemId: 'cboStockUom',
                                                            displayField: 'strUnitMeasure',
                                                            valueField: 'strUnitMeasure'
                                                        }
                                                    },
                                                    {
                                                        xtype: 'gridcolumn',
                                                        itemId: 'colOtherUOM',
                                                        dataIndex: 'strUnitMeasure',
                                                        text: 'Other UOM',
                                                        flex: 1,
                                                        editor: {
                                                            xtype: 'gridcombobox',
                                                            columns: [
                                                                {
                                                                    dataIndex: 'intUnitMeasureId',
                                                                    dataType: 'numeric',
                                                                    text: 'Unit Of Measure ID',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'strUnitMeasure',
                                                                    dataType: 'string',
                                                                    text: 'Unit Measure',
                                                                    flex: 1
                                                                },
                                                                {
                                                                    dataIndex: 'strUnitType',
                                                                    dataType: 'string',
                                                                    text: 'Unit Type',
                                                                    flex: 1
                                                                }
                                                            ],
                                                            itemId: 'cboOtherUOM',
                                                            displayField: 'strUnitMeasure',
                                                            valueField: 'strUnitMeasure'
                                                        }
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        itemId: 'colConversionToStockUOM',
                                                        minWidth: 110,
                                                        width: 110,
                                                        dataIndex: 'string',
                                                        text: 'Conversion To',
                                                        format: '0,000.000000000000000',
                                                        editor: {
                                                            xtype: 'numberfield',
                                                            quantityField: true,
                                                            itemId: 'txtConvertToStock',
                                                            decimalPrecision: 20
                                                        }
                                                    }
                                                ],
                                                viewConfig: {
                                                    itemId: 'grvConversion'
                                                },
                                                selModel: Ext.create('Ext.selection.CheckboxModel', {
                                                    selType: 'checkboxmodel'
                                                }),
                                                plugins: [
                                                    {
                                                        ptype: 'cellediting',
                                                        pluginId: 'cepConversion',
                                                        clicksToEdit: 1
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
            };
        if (instanceConfig) {
            me.getConfigurator().merge(me, config, instanceConfig);
        }
        return me.callParent([config]);
    }

});