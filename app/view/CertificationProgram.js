/*
 * File: app/view/CertificationProgram.js
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

Ext.define('Inventory.view.CertificationProgram', {
    extend: 'Ext.window.Window',
    alias: 'widget.iccertificationprogram',

    requires: [
        'Inventory.view.Filter1',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.toolbar.Separator',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.Checkbox',
        'Ext.form.field.ComboBox',
        'Ext.grid.Panel',
        'Ext.grid.column.Number',
        'Ext.form.field.Number',
        'Ext.grid.column.Date',
        'Ext.form.field.Date',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.CellEditing',
        'Ext.toolbar.Paging'
    ],

    height: 551,
    hidden: false,
    width: 660,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Certification Programs',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmCertificationProgram',
            margin: -1,
            bodyBorder: false,
            bodyPadding: 3,
            header: false,
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
                    itemId: 'pagingtoolbar',
                    flex: 1,
                    dock: 'bottom'
                }
            ],
            items: [
                {
                    xtype: 'tabpanel',
                    flex: 1,
                    itemId: 'tabCertificationProgram',
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
                                    margin: '0 0 10 0',
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
                                                    xtype: 'textfield',
                                                    flex: 1.2,
                                                    itemId: 'txtCertificationProgram',
                                                    fieldLabel: 'Certification Program',
                                                    labelWidth: 120
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    flex: 2,
                                                    itemId: 'txtIssuingOrganization',
                                                    fieldLabel: 'Issuing Organization',
                                                    labelWidth: 120
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtCertificationID',
                                                    fieldLabel: 'Certification ID',
                                                    labelWidth: 120
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
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkGlobalCertification',
                                                    fieldLabel: 'Global Certification',
                                                    labelWidth: 110
                                                },
                                                {
                                                    xtype: 'gridcombobox',
                                                    columns: [
                                                        {
                                                            dataIndex: 'intCountryID',
                                                            dataType: 'numeric',
                                                            text: 'Country Id',
                                                            hidden: true
                                                        },
                                                        {
                                                            dataIndex: 'strCountry',
                                                            dataType: 'string',
                                                            text: 'Country',
                                                            flex: 1
                                                        }
                                                    ],
                                                    flex: 1,
                                                    itemId: 'cboSpecificCountry',
                                                    fieldLabel: 'Specific Country',
                                                    labelWidth: 110,
                                                    displayField: 'strCountry',
                                                    valueField: 'intCountryID'
                                                }
                                            ]
                                        }
                                    ]
                                },
                                {
                                    xtype: 'gridpanel',
                                    flex: 1,
                                    itemId: 'grdCertificationProgram',
                                    dockedItems: [
                                        {
                                            xtype: 'toolbar',
                                            dock: 'top',
                                            componentCls: 'x-toolbar-default-grid',
                                            itemId: 'tlbGridOptions',
                                            layout: {
                                                type: 'hbox',
                                                padding: '0 0 0 1'
                                            },
                                            items: [
                                                {
                                                    xtype: 'button',
                                                    tabIndex: -1,
                                                    itemId: 'btnDeleteCertificationProgram',
                                                    iconCls: 'small-delete',
                                                    text: 'Remove'
                                                },
                                                {
                                                    xtype: 'tbseparator'
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
                                            itemId: 'colCommodity',
                                            dataIndex: 'string',
                                            text: 'Commodity',
                                            flex: 1,
                                            editor: {
                                                xtype: 'gridcombobox',
                                                columns: [
                                                    {
                                                        dataIndex: 'intCommodityId',
                                                        dataType: 'numeric',
                                                        text: 'Commodity Id',
                                                        hidden: true
                                                    },
                                                    {
                                                        dataIndex: 'strCommodityCode',
                                                        dataType: 'string',
                                                        text: 'Commodity',
                                                        flex: 1
                                                    },
                                                    {
                                                        dataIndex: 'strDescription',
                                                        dataType: 'string',
                                                        text: 'Description',
                                                        flex: 1
                                                    }
                                                ],
                                                itemId: 'cboCommodity',
                                                displayField: 'strCommodityCode',
                                                valueField: 'strCommodityCode'
                                            }
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            itemId: 'colCurrency',
                                            defaultWidth: 90,
                                            dataIndex: 'string',
                                            text: 'Currency',
                                            editor: {
                                                xtype: 'gridcombobox',
                                                columns: [
                                                    {
                                                        dataIndex: 'intCurrencyID',
                                                        dataType: 'numeric',
                                                        text: 'Currency Id',
                                                        hidden: true
                                                    },
                                                    {
                                                        dataIndex: 'strCurrency',
                                                        dataType: 'string',
                                                        text: 'Currency',
                                                        flex: 1
                                                    },
                                                    {
                                                        dataIndex: 'strDescription',
                                                        dataType: 'string',
                                                        text: 'Description',
                                                        flex: 1
                                                    }
                                                ],
                                                itemId: 'cboCurrency',
                                                displayField: 'strCurrency',
                                                valueField: 'strCurrency'
                                            }
                                        },
                                        {
                                            xtype: 'numbercolumn',
                                            itemId: 'colPremium',
                                            minWidth: 150,
                                            width: 150,
                                            text: 'Certification Premium',
                                            editor: {
                                                xtype: 'numberfield'
                                            }
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            itemId: 'colPerUOM',
                                            width: 80,
                                            text: 'Per UOM',
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
                                                itemId: 'cboPerUnitMeasure',
                                                displayField: 'strUnitMeasure',
                                                valueField: 'strUnitMeasure'
                                            }
                                        },
                                        {
                                            xtype: 'datecolumn',
                                            itemId: 'colEffectiveFrom',
                                            text: 'Effective From',
                                            editor: {
                                                xtype: 'datefield'
                                            }
                                        }
                                    ],
                                    viewConfig: {
                                        itemId: 'grvCertificationProgram'
                                    },
                                    selModel: {
                                        selType: 'checkboxmodel'
                                    },
                                    plugins: [
                                        {
                                            ptype: 'cellediting',
                                            pluginId: 'cepCommodity',
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