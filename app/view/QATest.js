/*
 * File: app/view/QATest.js
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

Ext.define('Inventory.view.QATest', {
    extend: 'Ext.window.Window',
    alias: 'widget.qatest',

    requires: [
        'Inventory.view.QATestViewModel',
        'Inventory.view.Filter1',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Number',
        'Ext.form.field.Checkbox',
        'Ext.grid.Panel',
        'Ext.grid.column.Column',
        'Ext.grid.View',
        'Ext.selection.CheckboxModel',
        'Ext.toolbar.Paging'
    ],

    viewModel: {
        type: 'qatest'
    },
    height: 460,
    hidden: false,
    minHeight: 460,
    minWidth: 765,
    width: 765,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'QA Test',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            height: 350,
            itemId: 'frmQATest',
            margin: -1,
            width: 450,
            bodyBorder: false,
            bodyPadding: 10,
            header: false,
            trackResetOnLoad: true,
            layout: {
                type: 'hbox',
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
                    itemId: 'pagingtoolbar',
                    flex: 1,
                    dock: 'bottom'
                }
            ],
            items: [
                {
                    xtype: 'panel',
                    flex: 1.1,
                    itemId: 'pnlTestDetail',
                    margin: '0 5 0 0',
                    bodyPadding: 10,
                    title: 'Test Details',
                    layout: {
                        type: 'vbox',
                        align: 'stretch'
                    },
                    items: [
                        {
                            xtype: 'textfield',
                            itemId: 'txtTestName',
                            fieldLabel: 'Test Name',
                            labelWidth: 145
                        },
                        {
                            xtype: 'textfield',
                            itemId: 'txtDescription',
                            fieldLabel: 'Description',
                            labelWidth: 145
                        },
                        {
                            xtype: 'combobox',
                            itemId: 'cboAnalysisType',
                            fieldLabel: 'Analysis Type',
                            labelWidth: 145
                        },
                        {
                            xtype: 'textfield',
                            itemId: 'txtTestMethod',
                            fieldLabel: 'Test Method',
                            labelWidth: 145
                        },
                        {
                            xtype: 'textfield',
                            itemId: 'txtIndustryStandards',
                            fieldLabel: 'Industry Standards',
                            labelWidth: 145
                        },
                        {
                            xtype: 'textfield',
                            itemId: 'txtSensorialLabel',
                            fieldLabel: 'Sensorial Label',
                            labelWidth: 145
                        },
                        {
                            xtype: 'numberfield',
                            itemId: 'txtReplications',
                            fieldLabel: 'Replications',
                            labelWidth: 145,
                            hideTrigger: true
                        },
                        {
                            xtype: 'checkboxfield',
                            itemId: 'chkAutoCapture',
                            fieldLabel: 'Auto Capture',
                            labelWidth: 145
                        },
                        {
                            xtype: 'checkboxfield',
                            itemId: 'chkActive',
                            fieldLabel: 'Active',
                            labelWidth: 145
                        },
                        {
                            xtype: 'checkboxfield',
                            itemId: 'chkIgnoreSubsampleCount',
                            fieldLabel: 'Ignore Subsample Count',
                            labelWidth: 145
                        }
                    ]
                },
                {
                    xtype: 'gridpanel',
                    flex: 1,
                    itemId: 'grdProperties',
                    title: 'Properties',
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
                                    itemId: 'btnAddProperties',
                                    iconCls: 'small-add',
                                    text: 'Quick Add'
                                },
                                {
                                    xtype: 'button',
                                    tabIndex: -1,
                                    itemId: 'btnDeleteProperties1',
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
                            dataIndex: 'string',
                            text: 'Property Name',
                            flex: 1
                        }
                    ],
                    viewConfig: {
                        itemId: 'grvProperties'
                    },
                    selModel: {
                        selType: 'checkboxmodel'
                    }
                }
            ]
        }
    ]

});