/*
 * File: app/view/ManufacturingCell.js
 *
 * This file was generated by Sencha Architect version 4.2.2.
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

Ext.define('Inventory.view.ManufacturingCell', {
    extend: 'Ext.window.Window',
    alias: 'widget.icmanufacturingcell',

    requires: [
        'Inventory.view.Filter1',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Checkbox',
        'Ext.form.field.Number',
        'Ext.grid.Panel',
        'Ext.grid.column.Number',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.CellEditing',
        'Ext.toolbar.Paging'
    ],

    height: 396,
    hidden: false,
    width: 757,
    layout: 'fit',
    collapsible: true,
    title: 'Manufacturing Cell',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmManufacturingCell',
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
                    itemId: 'tabManufacturingCell',
                    bodyCls: 'i21-tab',
                    activeTab: 0,
                    plain: true,
                    items: [
                        {
                            xtype: 'panel',
                            title: 'Details',
                            layout: {
                                type: 'vbox',
                                align: 'stretch',
                                padding: 10
                            },
                            items: [
                                {
                                    xtype: 'container',
                                    flex: 1.25,
                                    margin: '0 5 0 0',
                                    width: 1014,
                                    layout: {
                                        type: 'vbox',
                                        align: 'stretch'
                                    },
                                    items: [
                                        {
                                            xtype: 'textfield',
                                            itemId: 'txtName',
                                            fieldLabel: 'Name',
                                            labelWidth: 160
                                        },
                                        {
                                            xtype: 'textfield',
                                            itemId: 'txtDescription',
                                            fieldLabel: 'Description',
                                            labelWidth: 160
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
                                                    xtype: 'container',
                                                    flex: 1.4,
                                                    margin: '0 0 5 0',
                                                    layout: {
                                                        type: 'vbox',
                                                        align: 'stretch'
                                                    },
                                                    items: [
                                                        {
                                                            xtype: 'gridcombobox',
                                                            columns: [
                                                                {
                                                                    dataIndex: 'intCompanyLocationId',
                                                                    dataType: 'numeric',
                                                                    text: 'Location Id',
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
                                                            flex: 1.4,
                                                            disabled: true,
                                                            itemId: 'cboLocationName',
                                                            fieldLabel: 'Location Name',
                                                            labelWidth: 160,
                                                            displayField: 'strLocationName',
                                                            valueField: 'intCompanyLocationId'
                                                        },
                                                        {
                                                            xtype: 'checkboxfield',
                                                            flex: 1,
                                                            itemId: 'chkActive',
                                                            fieldLabel: 'Active',
                                                            labelWidth: 160,
                                                            boxLabel: ''
                                                        },
                                                        {
                                                            xtype: 'numberfield',
                                                            flex: 1.4,
                                                            itemId: 'txtStandardCapacity',
                                                            fieldLabel: 'Standard Capacity',
                                                            labelWidth: 160,
                                                            hideTrigger: true
                                                        },
                                                        {
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
                                                                },
                                                                {
                                                                    dataIndex: 'ysnDefault',
                                                                    dataType: 'boolean',
                                                                    text: 'Default',
                                                                    flex: 1
                                                                }
                                                            ],
                                                            flex: 1,
                                                            itemId: 'cboStandardCapacityUom',
                                                            fieldLabel: 'Standard Capacity UOM',
                                                            labelWidth: 160,
                                                            displayField: 'strUnitMeasure',
                                                            valueField: 'intUnitMeasureId'
                                                        },
                                                        {
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
                                                                },
                                                                {
                                                                    dataIndex: 'ysnDefault',
                                                                    dataType: 'boolean',
                                                                    text: 'Default',
                                                                    flex: 1
                                                                }
                                                            ],
                                                            flex: 1.4,
                                                            itemId: 'cboStandardCapacityRate',
                                                            fieldLabel: 'Standard Capacity Rate',
                                                            labelWidth: 160,
                                                            displayField: 'strUnitMeasure',
                                                            valueField: 'intUnitMeasureId'
                                                        },
                                                        {
                                                            xtype: 'numberfield',
                                                            flex: 1,
                                                            itemId: 'txtStandardLineEfficiency',
                                                            fieldLabel: 'Standard Line Efficiency (%)',
                                                            labelWidth: 160,
                                                            hideTrigger: true
                                                        },
                                                        {
                                                            xtype: 'checkboxfield',
                                                            itemId: 'chkIncludeInScheduling',
                                                            fieldLabel: 'Include in Scheduling',
                                                            labelWidth: 160
                                                        }
                                                    ]
                                                },
                                                {
                                                    xtype: 'container',
                                                    flex: 1,
                                                    margin: '0 0 5 0',
                                                    layout: {
                                                        type: 'hbox',
                                                        align: 'stretch'
                                                    }
                                                }
                                            ]
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            xtype: 'panel',
                            title: 'Packing Type',
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'gridpanel',
                                    flex: 1,
                                    itemId: 'grdPackingType',
                                    margin: -1,
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
                                                    itemId: 'btnDeletePackingType',
                                                    iconCls: 'small-remove',
                                                    text: 'Remove'
                                                },
                                                {
                                                    xtype: 'filter1'
                                                }
                                            ]
                                        }
                                    ],
                                    columns: [
                                        {
                                            xtype: 'gridcolumn',
                                            itemId: 'colPackTypeName',
                                            dataIndex: 'string',
                                            text: 'Pack Type Name',
                                            flex: 1,
                                            editor: {
                                                xtype: 'gridcombobox',
                                                columns: [
                                                    {
                                                        dataIndex: 'intPackTypeId',
                                                        dataType: 'numeric',
                                                        text: 'Pack Type Id',
                                                        hidden: true
                                                    },
                                                    {
                                                        dataIndex: 'strPackName',
                                                        dataType: 'string',
                                                        text: 'Pack Type Name',
                                                        flex: 1
                                                    },
                                                    {
                                                        dataIndex: 'strDescription',
                                                        dataType: 'string',
                                                        text: 'Description',
                                                        flex: 1
                                                    }
                                                ],
                                                itemId: 'cboPackType',
                                                displayField: 'strPackName',
                                                valueField: 'strPackName',
                                                bind: {
                                                    store: '{packType}'
                                                }
                                            }
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            itemId: 'colPackTypeDescription',
                                            dataIndex: 'string',
                                            text: 'Pack Type Description',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'numbercolumn',
                                            itemId: 'colLineCapacity',
                                            width: 83,
                                            dataIndex: 'string',
                                            text: 'Line Capacity',
                                            editor: {
                                                xtype: 'numberfield'
                                            }
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            itemId: 'colLineCapacityUOM',
                                            width: 105,
                                            dataIndex: 'string',
                                            text: 'Line Capacity UOM',
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
                                                    },
                                                    {
                                                        dataIndex: 'ysnDefault',
                                                        dataType: 'boolean',
                                                        text: 'Default',
                                                        flex: 1
                                                    }
                                                ],
                                                itemId: 'cboCapacityUOM',
                                                displayField: 'strUnitMeasure',
                                                valueField: 'strUnitMeasure'
                                            }
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            itemId: 'colLineCapacityRate',
                                            width: 105,
                                            dataIndex: 'string',
                                            text: 'Line Capacity Rate',
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
                                                    },
                                                    {
                                                        dataIndex: 'ysnDefault',
                                                        dataType: 'boolean',
                                                        text: 'Default',
                                                        flex: 1
                                                    }
                                                ],
                                                itemId: 'cboCapacityRateUOM',
                                                displayField: 'strUnitMeasure',
                                                valueField: 'strUnitMeasure'
                                            }
                                        },
                                        {
                                            xtype: 'numbercolumn',
                                            itemId: 'colLineEfficiency',
                                            width: 85,
                                            dataIndex: 'string',
                                            text: 'Line Efficiency',
                                            editor: {
                                                xtype: 'numberfield'
                                            }
                                        }
                                    ],
                                    viewConfig: {
                                        itemId: 'grvPackingType'
                                    },
                                    selModel: {
                                        selType: 'checkboxmodel'
                                    },
                                    plugins: [
                                        {
                                            ptype: 'cellediting',
                                            pluginId: 'cepPackType',
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

});