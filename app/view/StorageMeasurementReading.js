/*
 * File: app/view/StorageMeasurementReading.js
 *
 * This file was generated by Sencha Architect version 4.2.2.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 6.5.x Classic library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 6.5.x Classic. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('Inventory.view.StorageMeasurementReading', {
    extend: 'Ext.window.Window',
    alias: 'widget.storagemeasurementreading',

    requires: [
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Date',
        'Ext.grid.Panel',
        'Ext.grid.column.Number',
        'Ext.form.field.Number',
        'Ext.view.Table',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.CellEditing',
        'Ext.toolbar.Paging'
    ],

    height: 400,
    hidden: false,
    minHeight: 400,
    minWidth: 850,
    width: 850,
    layout: 'fit',
    collapsible: true,
    title: 'Storage Measurement Reading',
    maximizable: true,

    initConfig: function(instanceConfig) {
        var me = this,
            config = {
                items: [
                    {
                        xtype: 'form',
                        autoShow: true,
                        itemId: 'frmStorageMeasurementReading',
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
                                        itemId: 'btnNew',
                                        tabIndex: -1,
                                        ui: 'i21-button-toolbar-small',
                                        text: 'New'
                                    },
                                    {
                                        xtype: 'button',
                                        itemId: 'btnSave',
                                        tabIndex: -1,
                                        ui: 'i21-button-toolbar-small',
                                        text: 'Save'
                                    },
                                    {
                                        xtype: 'button',
                                        itemId: 'btnSearch',
                                        tabIndex: -1,
                                        ui: 'i21-button-toolbar-small',
                                        text: 'Search'
                                    },
                                    {
                                        xtype: 'button',
                                        itemId: 'btnDelete',
                                        tabIndex: -1,
                                        ui: 'i21-button-toolbar-small',
                                        text: 'Delete'
                                    },
                                    {
                                        xtype: 'button',
                                        itemId: 'btnUndo',
                                        tabIndex: -1,
                                        ui: 'i21-button-toolbar-small',
                                        text: 'Undo'
                                    },
                                    {
                                        xtype: 'button',
                                        itemId: 'btnClose',
                                        tabIndex: -1,
                                        ui: 'i21-button-toolbar-small',
                                        text: 'Close'
                                    }
                                ]
                            },
                            {
                                xtype: 'ipagingstatusbar',
                                dock: 'bottom',
                                flex: 1
                            }
                        ],
                        items: [
                            {
                                xtype: 'tabpanel',
                                flex: 1,
                                itemId: 'tabStorageMeasurementReading',
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
                                                margin: '0 0 5 0',
                                                layout: {
                                                    type: 'hbox',
                                                    align: 'stretch'
                                                },
                                                items: [
                                                    {
                                                        xtype: 'gridcombobox',
                                                        columns: [
                                                            {
                                                                dataIndex: 'intCompanyLocationId',
                                                                dataType: 'numeric',
                                                                hidden: true
                                                            },
                                                            {
                                                                dataIndex: 'strLocationName',
                                                                dataType: 'string',
                                                                text: 'Location Name',
                                                                flex: 1
                                                            },
                                                            {
                                                                dataIndex: 'strLocationType',
                                                                dataType: 'string',
                                                                text: 'Location Type',
                                                                flex: 1
                                                            }
                                                        ],
                                                        flex: 1,
                                                        itemId: 'cboLocation',
                                                        margin: '0 5 0 0',
                                                        fieldLabel: 'Location',
                                                        labelWidth: 55,
                                                        displayField: 'strLocationName',
                                                        valueField: 'strLocationName'
                                                    },
                                                    {
                                                        xtype: 'datefield',
                                                        flex: 0.7,
                                                        itemId: 'dtmDate',
                                                        margin: '0 5 0 0',
                                                        fieldLabel: 'Date',
                                                        labelWidth: 55
                                                    },
                                                    {
                                                        xtype: 'textfield',
                                                        flex: 0.7,
                                                        itemId: 'txtReadingNumber',
                                                        fieldLabel: 'Reading No',
                                                        labelWidth: 80,
                                                        readOnly: true,
                                                        blankText: 'Created on Save',
                                                        emptyText: 'Created on Save'
                                                    }
                                                ]
                                            },
                                            {
                                                xtype: 'advancefiltergrid',
                                                flex: 1,
                                                reference: 'grdStorageMeasurementReading',
                                                itemId: 'grdStorageMeasurementReading',
                                                title: 'Conversion',
                                                columnLines: true,
                                                dockedItems: [
                                                    {
                                                        xtype: 'toolbar',
                                                        componentCls: 'i21-toolbar-grid',
                                                        dock: 'top',
                                                        itemId: 'tlbGridOptions',
                                                        layout: {
                                                            type: 'hbox',
                                                            padding: '0 0 0 1'
                                                        },
                                                        items: [
                                                            {
                                                                xtype: 'button',
                                                                itemId: 'btnInsert',
                                                                tabIndex: -1,
                                                                iconCls: 'small-insert',
                                                                text: 'Insert'
                                                            },
                                                            {
                                                                xtype: 'button',
                                                                itemId: 'btnRemove',
                                                                tabIndex: -1,
                                                                iconCls: 'small-remove',
                                                                text: 'Remove'
                                                            },
                                                            {
                                                                xtype: 'button',
                                                                itemId: 'btnQuality',
                                                                tabIndex: -1,
                                                                iconCls: 'small-open',
                                                                text: 'Quality'
                                                            }
                                                        ]
                                                    }
                                                ],
                                                columns: [
                                                    {
                                                        xtype: 'gridcolumn',
                                                        itemId: 'colStorageLocation',
                                                        width: 120,
                                                        text: 'Storage Unit',
                                                        editor: {
                                                            xtype: 'gridcombobox',
                                                            columns: [
                                                                {
                                                                    dataIndex: 'intStorageUnitId',
                                                                    dataType: 'numeric',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'strStorageUnit',
                                                                    dataType: 'string',
                                                                    width: 200,
                                                                    text: 'Storage Unit',
                                                                    flex: 1
                                                                },
                                                                {
                                                                    dataIndex: 'intStorageLocationId',
                                                                    dataType: 'numeric',
                                                                    text: 'Storage Location Id',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'strStorageLocation',
                                                                    dataType: 'string',
                                                                    text: 'Storage Location',
                                                                    width: 200,
                                                                    flex: 1
                                                                },
                                                                {
                                                                    dataIndex: 'dblEffectiveDepth',
                                                                    dataType: 'float',
                                                                    text: 'Effective Depth',
                                                                    flex: 1
                                                                },
                                                                {
                                                                    dataIndex: 'intCommodityId',
                                                                    dataType: 'numeric',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'strCommodityCode',
                                                                    dataType: 'string',
                                                                    text: 'Commodity',
                                                                    flex: 1
                                                                },
                                                                {
                                                                    dataIndex: 'intItemId',
                                                                    dataType: 'numeric',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'strItemNo',
                                                                    dataType: 'string',
                                                                    width: 180,
                                                                    flex: 1,
                                                                    text: 'Item No'
                                                                },
                                                                {
                                                                    dataIndex: 'dblOnHand',
                                                                    dataType: 'float',
                                                                    text: 'On Hand',
                                                                    flex: 1
                                                                },
                                                                {
                                                                    dataIndex: 'strUnitMeasure',
                                                                    dataType: 'string',
                                                                    text: 'UOM',
                                                                    flex: 1
                                                                },
                                                                {
                                                                    dataIndex: 'intLotId',
                                                                    dataType: 'numeric',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'strLotNumber',
                                                                    dataType: 'string',
                                                                    flex: 1,
                                                                    text: 'Lot No'
                                                                },
                                                                {
                                                                    dataIndex: 'dblUnitPerFoot',
                                                                    dataType: 'float',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'dblResidualUnit',
                                                                    dataType: 'float',
                                                                    hidden: true
                                                                }
                                                            ],
                                                            pickerWidth: 750,
                                                            itemId: 'cboStorageLocation',
                                                            displayField: 'strStorageUnit',
                                                            valueField: 'strStorageUnit'
                                                        }
                                                    },
                                                    {
                                                        xtype: 'gridcolumn',
                                                        itemId: 'colSubLocation',
                                                        width: 120,
                                                        text: 'Storage Location'
                                                    },
                                                    {
                                                        xtype: 'gridcolumn',
                                                        itemId: 'colCommodity',
                                                        width: 100,
                                                        text: 'Commodity'
                                                    },
                                                    {
                                                        xtype: 'gridcolumn',
                                                        itemId: 'colItem',
                                                        width: 120,
                                                        text: 'Item'
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        format: '0,000.##',
                                                        itemId: 'colEffectiveDepth',
                                                        width: 100,
                                                        text: 'Effective Depth'
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        format: '0,000.##',
                                                        itemId: 'colUnitsPerFoot',
                                                        width: 100,
                                                        text: 'Units per Foot'
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        itemId: 'colAirSpaceReading',
                                                        width: 120,
                                                        align: 'right',
                                                        text: 'Reading in Foot',
                                                        editor: {
                                                            xtype: 'numberfield',
                                                            quantityField: true
                                                        }
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        itemId: 'colCashPrice',
                                                        width: 100,
                                                        align: 'right',
                                                        text: 'Cash Price',
                                                        editor: {
                                                            xtype: 'numberfield',
                                                            currencyField: true
                                                        }
                                                    },
                                                    {
                                                        xtype: 'gridcolumn',
                                                        itemId: 'colUnitMeasure',
                                                        dataIndex: 'strUnitMeasure',
                                                        text: 'Stock UOM'
                                                    },
                                                    {
                                                        xtype: 'gridcolumn',
                                                        itemId: 'colDiscountSchedule',
                                                        width: 120,
                                                        text: 'Discount Schedule',
                                                        editor: {
                                                            xtype: 'gridcombobox',
                                                            columns: [
                                                                {
                                                                    dataIndex: 'intDiscountScheduleId',
                                                                    dataType: 'numeric',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'intCommodityId',
                                                                    dataType: 'numeric',
                                                                    hidden: true
                                                                },
                                                                {
                                                                    dataIndex: 'strDiscountDescription',
                                                                    dataType: 'string',
                                                                    text: 'Discount Description',
                                                                    flex: 1
                                                                },
                                                                {
                                                                    dataIndex: 'strCurrency',
                                                                    dataType: 'string',
                                                                    text: 'Currency',
                                                                    flex: 1
                                                                }
                                                            ],
                                                            itemId: 'cboDiscountSchedule',
                                                            displayField: 'strDiscountDescription',
                                                            valueField: 'strDiscountDescription'
                                                        }
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        format: '0,000.##',
                                                        itemId: 'colCurrentStock',
                                                        width: 100,
                                                        dataIndex: 'dblOnHand',
                                                        text: 'Current Stock'
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        format: '0,000.##',
                                                        itemId: 'colNewStock',
                                                        width: 100,
                                                        dataIndex: 'dblNewOnHand',
                                                        text: 'New Stock'
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        format: '0,000.##',
                                                        itemId: 'colValue',
                                                        width: 100,
                                                        dataIndex: 'dblValue',
                                                        text: 'Value'
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        format: '0,000.##',
                                                        itemId: 'colVariance',
                                                        width: 100,
                                                        dataIndex: 'dblVariance',
                                                        text: 'Variance'
                                                    },
                                                    {
                                                        xtype: 'numbercolumn',
                                                        format: '0,000.##',
                                                        itemId: 'colGainLoss',
                                                        width: 100,
                                                        dataIndex: 'dblGainLoss',
                                                        text: 'Gain/Loss'
                                                    }
                                                ],
                                                viewConfig: {
                                                    itemId: 'grvStorageMeasurementReading'
                                                },
                                                selModel: Ext.create('Ext.selection.CheckboxModel', {
                                                    selType: 'checkboxmodel'
                                                }),
                                                plugins: [
                                                    {
                                                        ptype: 'cellediting',
                                                        pluginId: 'cepStorageMeasurementReading',
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
            me.self.getConfigurator().merge(me, config, instanceConfig);
        }
        return me.callParent([config]);
    }

});