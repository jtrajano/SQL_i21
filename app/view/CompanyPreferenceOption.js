/*
 * File: app/view/CompanyPreferenceOption.js
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

Ext.define('Inventory.view.CompanyPreferenceOption', {
    extend: 'Ext.container.Container',
    alias: 'widget.iccompanypreferenceoption',

    requires: [
        'Ext.form.field.ComboBox',
        'Ext.tab.Panel',
        'Ext.tab.Tab'
    ],

    padding: 5,

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
                    xtype: 'gridcombobox',
                    columns: [
                        {
                            dataIndex: 'strInheritSetup',
                            dataType: 'string',
                            text: 'Inherit Setup',
                            flex: 1
                        },
                        {
                            dataIndex: 'intInheritSetup',
                            dataType: 'numeric',
                            hidden: true
                        }
                    ],
                    hidden: true,
                    itemId: 'cboInheritSetup',
                    fieldLabel: 'Inherit Setup',
                    displayField: 'strInheritSetup',
                    valueField: 'intInheritSetup'
                },
                {
                    xtype: 'tabpanel',
                    flex: 1,
                    itemId: 'tabInventory',
                    bodyCls: 'i21-tab',
                    activeTab: 0,
                    plain: true,
                    items: [
                        {
                            xtype: 'panel',
                            itemId: 'pgeInventory',
                            bodyPadding: 10,
                            title: 'Inventory',
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'panel',
                                    flex: 1,
                                    itemId: 'pnlDefaults',
                                    bodyPadding: 5,
                                    title: 'Defaults',
                                    layout: {
                                        type: 'vbox',
                                        align: 'stretch'
                                    },
                                    items: [
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'strReceiptType',
                                                    dataType: 'string',
                                                    text: 'Shipment Order Type',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'intReceiptType',
                                                    dataType: 'numeric',
                                                    hidden: true
                                                }
                                            ],
                                            itemId: 'cboReceiptOrderType',
                                            fieldLabel: 'Receipt Order Type',
                                            labelWidth: 130,
                                            displayField: 'strReceiptType',
                                            valueField: 'strReceiptType'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Receipt Source Type',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'intReceiptSourceType',
                                                    dataType: 'numeric',
                                                    hidden: true
                                                }
                                            ],
                                            itemId: 'cboReceiptSourceType',
                                            fieldLabel: 'Receipt Source Type',
                                            labelWidth: 130,
                                            displayField: 'strDescription',
                                            valueField: 'intReceiptSourceType'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Shipment Order Type',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'intShipmentOrderType',
                                                    dataType: 'numeric',
                                                    hidden: true
                                                }
                                            ],
                                            itemId: 'cboShipmentOrderType',
                                            fieldLabel: 'Shipment Order Type',
                                            labelWidth: 130,
                                            displayField: 'strDescription',
                                            valueField: 'intShipmentOrderType'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Shipment Source Type',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'intShipmentSourceType',
                                                    dataType: 'numeric',
                                                    hidden: true
                                                }
                                            ],
                                            itemId: 'cboShipmentSourceType',
                                            fieldLabel: 'Shipment Source Type',
                                            labelWidth: 130,
                                            displayField: 'strDescription',
                                            valueField: 'intShipmentSourceType'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'strLotCondition',
                                                    dataType: 'string',
                                                    text: 'Shipment Source Type',
                                                    flex: 1
                                                },
                                                {
                                                    dataIndex: 'intLotCondition',
                                                    dataType: 'numeric',
                                                    hidden: true
                                                }
                                            ],
                                            itemId: 'cboLotCondition',
                                            fieldLabel: 'Lot Condition',
                                            labelWidth: 130,
                                            displayField: 'strLotCondition',
                                            valueField: 'strLotCondition'
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            xtype: 'panel',
                            itemId: 'pgeIntegration',
                            bodyPadding: 10,
                            title: 'Integration',
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'panel',
                                    flex: 1,
                                    itemId: 'pnlDefaults',
                                    bodyPadding: 5,
                                    title: 'SAP Integration',
                                    layout: {
                                        type: 'vbox',
                                        align: 'stretch'
                                    },
                                    items: [
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'strIRUnpostMode',
                                                    dataType: 'string',
                                                    text: 'Unpost Mode',
                                                    flex: 2
                                                },
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Description',
                                                    flex: 5
                                                }
                                            ],
                                            itemId: 'cboIRUnpostMode',
                                            fieldLabel: 'Inventory Receipt Unpost Mode',
                                            labelWidth: 200,
                                            displayField: 'strIRUnpostMode',
                                            valueField: 'strIRUnpostMode'
                                        },
                                        {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'strReturnPostMode',
                                                    dataType: 'string',
                                                    text: 'Post Mode',
                                                    flex: 2
                                                },
                                                {
                                                    dataIndex: 'strDescription',
                                                    dataType: 'string',
                                                    text: 'Description',
                                                    flex: 5
                                                }
                                            ],
                                            itemId: 'cboReturnPostMode',
                                            fieldLabel: 'Inventory Return Post Mode',
                                            labelWidth: 200,
                                            displayField: 'strReturnPostMode',
                                            valueField: 'strReturnPostMode'
                                        }
                                    ]
                                }
                            ]
                        },
                        {
                            xtype: 'panel',
                            itemId: 'pgeAuditLog',
                            layout: 'fit',
                            title: 'Audit Log',
                            items: [
                                {
                                    xtype: 'auditlogtree'
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});