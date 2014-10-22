/*
 * File: app/view/Brand.js
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

Ext.define('Inventory.view.Brand', {
    extend: 'Ext.window.Window',
    alias: 'widget.brand',

    requires: [
        'Inventory.view.BrandViewModel',
        'Inventory.view.Filter1',
        'Inventory.view.Statusbar1',
        'Ext.form.Panel',
        'Ext.toolbar.Toolbar',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.grid.Panel',
        'Ext.grid.column.Column',
        'Ext.form.field.ComboBox',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.grid.plugin.CellEditing'
    ],

    viewModel: {
        type: 'brand'
    },
    height: 500,
    hidden: false,
    minHeight: 500,
    minWidth: 530,
    width: 530,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Brand',
    maximizable: true,

    initConfig: function(instanceConfig) {
        var me = this,
            config = {
                items: [
                    {
                        xtype: 'form',
                        autoShow: true,
                        height: 350,
                        itemId: 'frmBrand',
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
                                xtype: 'istatusbar',
                                flex: 1,
                                dock: 'bottom'
                            }
                        ],
                        items: [
                            {
                                xtype: 'gridpanel',
                                flex: 1,
                                itemId: 'grdBrand',
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
                                                itemId: 'btnDeleteBrand',
                                                iconCls: 'small-delete',
                                                text: 'Delete'
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
                                        itemId: 'colBrandCode',
                                        dataIndex: 'string',
                                        text: 'Brand Code',
                                        flex: 1,
                                        editor: {
                                            xtype: 'textfield'
                                        }
                                    },
                                    {
                                        xtype: 'gridcolumn',
                                        itemId: 'colBrandName',
                                        dataIndex: 'string',
                                        text: 'Brand Name',
                                        flex: 1,
                                        editor: {
                                            xtype: 'textfield'
                                        }
                                    },
                                    {
                                        xtype: 'gridcolumn',
                                        itemId: 'colManufacturer',
                                        dataIndex: 'string',
                                        text: 'Manufacturer',
                                        flex: 1,
                                        editor: {
                                            xtype: 'gridcombobox',
                                            columns: [
                                                {
                                                    dataIndex: 'intManufacturerId',
                                                    dataType: 'numeric',
                                                    text: 'Manufacturer ID',
                                                    hidden: true
                                                },
                                                {
                                                    dataIndex: 'strManufacturer',
                                                    dataType: 'string',
                                                    text: 'Manufacturer',
                                                    flex: 1
                                                }
                                            ],
                                            itemId: 'cboManufacturer',
                                            displayField: 'strManufacturer',
                                            valueField: 'intManufacturerId'
                                        }
                                    }
                                ],
                                viewConfig: {
                                    itemId: 'grvBrand'
                                },
                                selModel: Ext.create('Ext.selection.CheckboxModel', {
                                    selType: 'checkboxmodel'
                                }),
                                plugins: [
                                    {
                                        ptype: 'cellediting',
                                        pluginId: 'cepBrand',
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