/*
 * File: app/view/Catalog.js
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

Ext.define('Inventory.view.Catalog', {
    extend: 'Ext.window.Window',
    alias: 'widget.iccatalog',

    requires: [
        'Inventory.view.Filter1',
        'Inventory.view.Statusbar1',
        'Ext.form.Panel',
        'Ext.toolbar.Toolbar',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.tree.Panel',
        'Ext.tree.View',
        'Ext.tree.Column',
        'Ext.selection.CheckboxModel'
    ],

    height: 586,
    hidden: false,
    minHeight: 525,
    minWidth: 425,
    width: 608,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Catalog',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            height: 350,
            itemId: 'frmCatalog',
            margin: -1,
            width: 450,
            bodyBorder: false,
            bodyPadding: 5,
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
                }
            ],
            items: [
                {
                    xtype: 'treepanel',
                    flex: 1,
                    height: 250,
                    itemId: 'grdCatalog',
                    width: 400,
                    allowDeselect: true,
                    rootVisible: false,
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
                                    itemId: 'btnAddCatalog',
                                    iconCls: 'small-add',
                                    text: 'Add'
                                },
                                {
                                    xtype: 'button',
                                    tabIndex: -1,
                                    itemId: 'btnEditCatalog',
                                    iconCls: 'small-edit',
                                    text: 'Edit'
                                },
                                {
                                    xtype: 'button',
                                    tabIndex: -1,
                                    itemId: 'btnDeleteCatalog',
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
                    viewConfig: {
                        itemId: 'grvCatalog'
                    },
                    columns: [
                        {
                            xtype: 'treecolumn',
                            dataIndex: 'strCatalogName',
                            text: 'Catalogs',
                            flex: 1
                        }
                    ],
                    selModel: {
                        selType: 'checkboxmodel'
                    }
                }
            ]
        }
    ],
    dockedItems: [
        {
            xtype: 'istatusbar',
            dock: 'bottom'
        }
    ]

});