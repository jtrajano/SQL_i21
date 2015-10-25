/*
 * File: app/view/BuildAssemblyBlend.js
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

Ext.define('Inventory.view.BuildAssemblyBlend', {
    extend: 'Ext.window.Window',
    alias: 'widget.icbuildassemblyblend',

    requires: [
        'Inventory.view.Filter1',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.Date',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Number',
        'Ext.grid.Panel',
        'Ext.grid.column.Number',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.CellEditing',
        'Ext.toolbar.Paging'
    ],

    height: 625,
    hidden: false,
    width: 765,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Build Assembly/Blend',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmBuildAssemblyBlend',
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
                            itemId: 'btnDelete',
                            ui: 'i21-button-toolbar-small',
                            text: 'Delete'
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
                            itemId: 'btnUndo',
                            ui: 'i21-button-toolbar-small',
                            text: 'Undo'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            itemId: 'btnPrint',
                            ui: 'i21-button-toolbar-small',
                            text: 'Print'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            itemId: 'btnPost',
                            ui: 'i21-button-toolbar-small',
                            text: 'Post'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            hidden: true,
                            itemId: 'btnDuplicate',
                            ui: 'i21-button-toolbar-small',
                            text: 'Duplicate'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            itemId: 'btnRecap',
                            ui: 'i21-button-toolbar-small',
                            text: 'Recap'
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
                    itemId: 'tabBuildAssemblyBlend',
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
                                    layout: 'hbox',
                                    items: [
                                        {
                                            xtype: 'container',
                                            flex: 1,
                                            layout: {
                                                type: 'vbox',
                                                align: 'stretch'
                                            },
                                            items: [
                                                {
                                                    xtype: 'datefield',
                                                    itemId: 'dtmBuildDate',
                                                    fieldLabel: 'Build Date',
                                                    labelWidth: 85
                                                },
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
                                                    itemId: 'cboLocation',
                                                    fieldLabel: 'Location',
                                                    labelWidth: 85,
                                                    displayField: 'strLocationName',
                                                    valueField: 'intCompanyLocationId'
                                                },
                                                {
                                                    xtype: 'gridcombobox',
                                                    columns: [
                                                        {
                                                            dataIndex: 'intCompanyLocationSubLocationId',
                                                            dataType: 'numeric',
                                                            text: 'Sub Location Id',
                                                            hidden: true
                                                        },
                                                        {
                                                            dataIndex: 'intCompanyLocationId',
                                                            dataType: 'numeric',
                                                            text: 'Location Id',
                                                            hidden: true
                                                        },
                                                        {
                                                            dataIndex: 'strSubLocationName',
                                                            dataType: 'string',
                                                            text: 'Sub Location Name',
                                                            flex: 1
                                                        },
                                                        {
                                                            dataIndex: 'strSubLocationDescription',
                                                            dataType: 'string',
                                                            text: 'Description',
                                                            flex: 1
                                                        }
                                                    ],
                                                    itemId: 'cboSubLocation',
                                                    fieldLabel: 'Sub Location',
                                                    labelWidth: 85,
                                                    displayField: 'strSubLocationName',
                                                    valueField: 'intCompanyLocationSubLocationId'
                                                }
                                            ]
                                        },
                                        {
                                            xtype: 'container',
                                            flex: 1,
                                            margin: '0 0 0 5',
                                            layout: {
                                                type: 'vbox',
                                                align: 'stretch'
                                            },
                                            items: [
                                                {
                                                    xtype: 'gridcombobox',
                                                    columns: [
                                                        {
                                                            dataIndex: 'intItemId',
                                                            dataType: 'numeric',
                                                            text: 'Item Id',
                                                            hidden: true
                                                        },
                                                        {
                                                            dataIndex: 'strItemNo',
                                                            dataType: 'string',
                                                            text: 'Item Number',
                                                            flex: 1
                                                        },
                                                        {
                                                            dataIndex: 'strType',
                                                            dataType: 'string',
                                                            text: 'Item Type',
                                                            flex: 1
                                                        },
                                                        {
                                                            dataIndex: 'strDescription',
                                                            dataType: 'string',
                                                            text: 'Description',
                                                            flex: 1
                                                        },
                                                        {
                                                            dataIndex: 'strLotTracking',
                                                            dataType: 'string',
                                                            text: 'Lot Tracking',
                                                            hidden: true
                                                        },
                                                        {
                                                            dataIndex: 'tblICItemAssemblies',
                                                            hidden: true
                                                        }
                                                    ],
                                                    itemId: 'cboItemNumber',
                                                    fieldLabel: 'Item No',
                                                    labelWidth: 85,
                                                    displayField: 'strItemNo',
                                                    valueField: 'intItemId'
                                                },
                                                {
                                                    xtype: 'numeric',
                                                    itemId: 'txtBuildQuantity',
                                                    fieldLabel: 'Build Quantity',
                                                    labelWidth: 85,
                                                    hideTrigger: true,
                                                    minValue: 0
                                                },
                                                {
                                                    xtype: 'gridcombobox',
                                                    columns: [
                                                        {
                                                            dataIndex: 'intItemUOMId',
                                                            dataType: 'numeric',
                                                            text: 'Unit Of Measure Id',
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
                                                            xtype: 'checkcolumn',
                                                            dataIndex: 'ysnStockUnit',
                                                            dataType: 'boolean',
                                                            text: 'Stock Unit',
                                                            flex: 1
                                                        }
                                                    ],
                                                    itemId: 'cboUOM',
                                                    fieldLabel: 'UOM',
                                                    labelWidth: 85,
                                                    displayField: 'strUnitMeasure',
                                                    valueField: 'intItemUOMId'
                                                }
                                            ]
                                        },
                                        {
                                            xtype: 'container',
                                            flex: 0.7,
                                            margin: '0 0 0 5',
                                            layout: {
                                                type: 'vbox',
                                                align: 'stretch'
                                            },
                                            items: [
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtBuildNumber',
                                                    fieldLabel: 'Build No',
                                                    labelWidth: 50,
                                                    readOnly: true,
                                                    blankText: 'Created on Save',
                                                    emptyText: 'Created on Save'
                                                },
                                                {
                                                    xtype: 'numeric',
                                                    itemId: 'txtCost',
                                                    fieldLabel: 'Cost',
                                                    labelWidth: 50,
                                                    readOnly: true,
                                                    hideTrigger: true
                                                }
                                            ]
                                        }
                                    ]
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtDescription',
                                    fieldLabel: 'Description',
                                    labelWidth: 85
                                },
                                {
                                    xtype: 'gridpanel',
                                    flex: 1,
                                    reference: 'grdBuildAssemblyBlend',
                                    itemId: 'grdBuildAssemblyBlend',
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
                                                    itemId: 'btnViewItem',
                                                    iconCls: 'small-open',
                                                    text: 'View Item'
                                                },
                                                {
                                                    xtype: 'button',
                                                    tabIndex: -1,
                                                    itemId: 'btnRemove',
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
                                            itemId: 'colItemNo',
                                            dataIndex: 'string',
                                            text: 'Item No.',
                                            flex: 1
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            itemId: 'colDescription',
                                            dataIndex: 'string',
                                            text: 'Description',
                                            flex: 2
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            itemId: 'colSubLocation',
                                            dataIndex: 'string',
                                            text: 'Sub Location',
                                            editor: {
                                                xtype: 'gridcombobox',
                                                columns: [
                                                    {
                                                        dataIndex: 'intSubLocationId',
                                                        dataType: 'numeric',
                                                        text: 'Sub Location Id',
                                                        hidden: true
                                                    },
                                                    {
                                                        dataIndex: 'strSubLocationName',
                                                        dataType: 'string',
                                                        text: 'Sub Location',
                                                        flex: 2
                                                    }
                                                ],
                                                itemId: 'cboItemSubLocation',
                                                displayField: 'strSubLocationName',
                                                valueField: 'strSubLocationName'
                                            }
                                        },
                                        {
                                            xtype: 'numbercolumn',
                                            itemId: 'colStock',
                                            width: 70,
                                            align: 'right',
                                            text: 'On Hand'
                                        },
                                        {
                                            xtype: 'numbercolumn',
                                            itemId: 'colQuantity',
                                            width: 70,
                                            align: 'right',
                                            text: 'Quantity'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            itemId: 'colUOM',
                                            width: 63,
                                            defaultWidth: 90,
                                            dataIndex: 'string',
                                            text: 'UOM'
                                        },
                                        {
                                            xtype: 'numbercolumn',
                                            itemId: 'colCost',
                                            width: 85,
                                            align: 'right',
                                            text: 'Cost'
                                        }
                                    ],
                                    viewConfig: {
                                        itemId: 'grvBuildAssemblyBlend'
                                    },
                                    selModel: {
                                        selType: 'checkboxmodel'
                                    },
                                    plugins: [
                                        {
                                            ptype: 'cellediting',
                                            pluginId: 'cepItem',
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