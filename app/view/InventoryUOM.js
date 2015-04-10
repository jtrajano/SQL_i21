/*
 * File: app/view/InventoryUOM.js
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

Ext.define('Inventory.view.InventoryUOM', {
    extend: 'Ext.window.Window',
    alias: 'widget.icinventoryuom',

    requires: [
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
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
    minHeight: 550,
    minWidth: 500,
    width: 500,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Inventory UOM',
    maximizable: true,

    initConfig: function(instanceConfig) {
        var me = this,
            config = {
                items: [
                    {
                        xtype: 'form',
                        autoShow: true,
                        height: 350,
                        itemId: 'frmInventoryUOM',
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
                                flex: 1,
                                dock: 'bottom'
                            }
                        ],
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
                                        fieldLabel: 'Symbol',
                                        labelWidth: 80
                                    },
                                    {
                                        xtype: 'combobox',
                                        flex: 1,
                                        itemId: 'cboUnitType',
                                        margin: '0 0 0 5',
                                        fieldLabel: 'Unit Type',
                                        labelWidth: 80,
                                        displayField: 'strDescription',
                                        valueField: 'strDescription'
                                    }
                                ]
                            },
                            {
                                xtype: 'advancefiltergrid',
                                flex: 1,
                                itemId: 'grdConversion',
                                title: 'Conversion',
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
                                                itemId: 'btnInsertConversion',
                                                iconCls: 'small-add',
                                                text: 'Insert'
                                            },
                                            {
                                                xtype: 'button',
                                                tabIndex: -1,
                                                itemId: 'btnDeleteConversion',
                                                iconCls: 'small-delete',
                                                text: 'Remove'
                                            }
                                        ]
                                    }
                                ],
                                columns: [
                                    {
                                        xtype: 'gridcolumn',
                                        itemId: 'colConversionStockUOM',
                                        dataIndex: 'string',
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
                                            itemId: 'cboStockUom',
                                            displayField: 'strUnitMeasure',
                                            valueField: 'strUnitMeasure',
                                            bind: {
                                                store: '{UnitMeasure}'
                                            }
                                        }
                                    },
                                    {
                                        xtype: 'numbercolumn',
                                        itemId: 'colConversionToStockUOM',
                                        minWidth: 110,
                                        width: 110,
                                        dataIndex: 'string',
                                        text: 'Conversion To',
                                        editor: {
                                            xtype: 'numberfield',
                                            itemId: 'txtConvertToStock'
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
            };
        if (instanceConfig) {
            me.getConfigurator().merge(me, config, instanceConfig);
        }
        return me.callParent([config]);
    }

});