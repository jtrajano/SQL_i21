/*
 * File: app/view/CopyItemLocation.js
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

Ext.define('Inventory.view.CopyItemLocation', {
    extend: 'Ext.window.Window',
    alias: 'widget.iccopyitemlocation',

    requires: [
        'Inventory.view.Filter1',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.grid.Panel',
        'Ext.grid.column.Column',
        'Ext.view.Table',
        'Ext.form.field.ComboBox',
        'Ext.selection.CheckboxModel',
        'Ext.toolbar.Paging'
    ],

    height: 594,
    minHeight: 594,
    minWidth: 715,
    width: 715,
    layout: 'fit',
    collapsible: true,
    title: 'Copy Item Location',
    maximizable: true,

    dockedItems: [
        {
            xtype: 'toolbar',
            dock: 'top',
            ui: 'i21-toolbar',
            items: [
                {
                    xtype: 'button',
                    itemId: 'btnClose',
                    ui: 'i21-button-toolbar-small',
                    text: 'Close'
                }
            ]
        },
        {
            xtype: 'istatusbar',
            dock: 'bottom'
        }
    ],
    items: [
        {
            xtype: 'form',
            height: 334,
            itemId: 'frmCopyItemLocation',
            ui: 'i21-form',
            bodyPadding: 3,
            layout: {
                type: 'vbox',
                align: 'stretch'
            },
            items: [
                {
                    xtype: 'tabpanel',
                    flex: 1,
                    itemId: 'tabDetails',
                    bodyCls: 'i21-tab',
                    activeTab: 0,
                    items: [
                        {
                            xtype: 'panel',
                            itemId: 'pgeDetails',
                            bodyPadding: 8,
                            title: 'Details',
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            tabConfig: {
                                xtype: 'tab',
                                itemId: 'cfgDetails'
                            },
                            items: [
                                {
                                    xtype: 'advancefiltergrid',
                                    flex: 1,
                                    reference: 'grdItems',
                                    itemId: 'grdItems',
                                    columns: [
                                        {
                                            xtype: 'gridcolumn',
                                            hidden: true,
                                            itemId: 'colItemId',
                                            dataIndex: 'intItemId',
                                            text: 'Item Id'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            flex: 1,
                                            itemId: 'colStrItemNo',
                                            dataIndex: 'strItemNo',
                                            text: 'Item No'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            flex: 1,
                                            itemId: 'colDescription',
                                            dataIndex: 'strDescription',
                                            text: 'Description'
                                        },
                                        {
                                            xtype: 'gridcolumn',
                                            flex: 1,
                                            itemId: 'colType',
                                            dataIndex: 'strType',
                                            text: 'Type'
                                        }
                                    ],
                                    dockedItems: [
                                        {
                                            xtype: 'toolbar',
                                            dock: 'top',
                                            items: [
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
                                                            text: 'Item',
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
                                                    reference: 'cboItem',
                                                    itemId: 'cboItem',
                                                    width: 402,
                                                    fieldLabel: 'Copy Location(s) from',
                                                    labelWidth: 150,
                                                    displayField: 'strItemNo',
                                                    valueField: 'intItemId'
                                                },
                                                {
                                                    xtype: 'button',
                                                    itemId: 'btnCopy',
                                                    iconCls: 'small-export',
                                                    text: 'Copy'
                                                },
                                                {
                                                    xtype: 'filter1'
                                                }
                                            ]
                                        }
                                    ],
                                    selModel: {
                                        selType: 'checkboxmodel'
                                    }
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});