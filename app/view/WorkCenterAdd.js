/*
 * File: app/view/WorkCenterAdd.js
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

Ext.define('Inventory.view.WorkCenterAdd', {
    extend: 'Ext.window.Window',
    alias: 'widget.icworkcenteradd',

    requires: [
        'Inventory.view.Filter1',
        'Inventory.view.Statusbar1',
        'Ext.form.Panel',
        'Ext.toolbar.Toolbar',
        'Ext.button.Button',
        'Ext.grid.Panel',
        'Ext.grid.column.Column',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel'
    ],

    height: 424,
    hidden: false,
    minHeight: 300,
    minWidth: 400,
    width: 400,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Add Work Centers',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            height: 350,
            itemId: 'frmReasonCodeAdd',
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
                            itemId: 'btnOk',
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-ok',
                            scale: 'large',
                            text: 'OK'
                        },
                        {
                            xtype: 'button',
                            tabIndex: -1,
                            height: 57,
                            itemId: 'btnCancel',
                            width: 45,
                            iconAlign: 'top',
                            iconCls: 'large-cancel',
                            scale: 'large',
                            text: 'Cancel'
                        }
                    ]
                }
            ],
            items: [
                {
                    xtype: 'gridpanel',
                    flex: 1,
                    itemId: 'grdWorkcenter',
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
                                    xtype: 'filter1'
                                }
                            ]
                        }
                    ],
                    columns: [
                        {
                            xtype: 'gridcolumn',
                            dataIndex: 'string',
                            text: 'Work Center',
                            flex: 1
                        }
                    ],
                    viewConfig: {
                        itemId: 'grvWorkcenter'
                    },
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