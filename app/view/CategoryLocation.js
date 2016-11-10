/*
 * File: app/view/CategoryLocation.js
 *
 * This file was generated by Sencha Architect version 3.5.1.
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

Ext.define('Inventory.view.CategoryLocation', {
    extend: 'Ext.window.Window',
    alias: 'widget.iccategorylocation',

    requires: [
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.tab.Panel',
        'Ext.tab.Tab',
        'Ext.form.field.ComboBox',
        'Ext.form.field.Checkbox',
        'Ext.form.field.Number',
        'Ext.form.field.Date',
        'Ext.toolbar.Paging'
    ],

    height: 597,
    hidden: false,
    width: 880,
    layout: 'fit',
    collapsible: true,
    title: 'Category Location',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            itemId: 'frmCategoryLocation',
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
                    itemId: 'tabCategoryLocation',
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
                                    layout: {
                                        type: 'hbox',
                                        align: 'stretch'
                                    },
                                    items: [
                                        {
                                            xtype: 'container',
                                            flex: 1.1,
                                            margin: '0 5 0 0 ',
                                            width: 346,
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
                                                    itemId: 'cboLocation',
                                                    fieldLabel: 'Location',
                                                    labelWidth: 165,
                                                    displayField: 'strLocationName',
                                                    valueField: 'intCompanyLocationId'
                                                },
                                                {
                                                    xtype: 'textfield',
                                                    itemId: 'txtCashRegisterDepartment',
                                                    fieldLabel: 'Cash Register Department',
                                                    labelWidth: 165
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkUpdatePricesOnPbImports',
                                                    fieldLabel: 'Update Prices on PB Imports',
                                                    labelWidth: 165
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultUseTaxFlag1',
                                                    fieldLabel: 'Default Use Tax Flag 1',
                                                    labelWidth: 165
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultUseTaxFlag2',
                                                    fieldLabel: 'Default Use Tax Flag 2',
                                                    labelWidth: 165
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultUseTaxFlag3',
                                                    fieldLabel: 'Default Use Tax Flag 3',
                                                    labelWidth: 165
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultUseTaxFlag4',
                                                    fieldLabel: 'Default Use Tax Flag 4',
                                                    labelWidth: 165
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultBlueLaw1',
                                                    fieldLabel: 'Default Blue Law 1',
                                                    labelWidth: 165
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultBlueLaw2',
                                                    fieldLabel: 'Default Blue Law 2',
                                                    labelWidth: 165
                                                },
                                                {
                                                    xtype: 'numberfield',
                                                    itemId: 'txtDefaultNucleusGroupId',
                                                    fieldLabel: 'Default Nucleus Group ID',
                                                    labelWidth: 165,
                                                    hideTrigger: true
                                                },
                                                {
                                                    xtype: 'numberfield',
                                                    itemId: 'txtTargetGrossProfitPercent',
                                                    fieldLabel: 'Target Gross Profit %',
                                                    labelWidth: 165,
                                                    fieldStyle: 'text-align:right',
                                                    hideTrigger: true
                                                },
                                                {
                                                    xtype: 'numberfield',
                                                    itemId: 'txtTargetInventoryAtCost',
                                                    fieldLabel: 'Target Inventory at Cost',
                                                    labelWidth: 165,
                                                    fieldStyle: 'text-align:right',
                                                    hideTrigger: true
                                                },
                                                {
                                                    xtype: 'numberfield',
                                                    itemId: 'txtCostOfInventoryAtBom',
                                                    fieldLabel: 'Cost of Inventory at BOM',
                                                    labelWidth: 165,
                                                    fieldStyle: 'text-align:right',
                                                    hideTrigger: true
                                                },
                                                {
                                                    xtype: 'numberfield',
                                                    itemId: 'txtLowGrossMarginPercentAlert',
                                                    fieldLabel: 'Low Gross Margin % Alert',
                                                    labelWidth: 165,
                                                    fieldStyle: 'text-align:right',
                                                    hideTrigger: true
                                                },
                                                {
                                                    xtype: 'numberfield',
                                                    itemId: 'txtHighGrossMarginPercentAlert',
                                                    fieldLabel: 'High Gross Margin % Alert',
                                                    labelWidth: 165,
                                                    fieldStyle: 'text-align:right',
                                                    hideTrigger: true
                                                },
                                                {
                                                    xtype: 'datefield',
                                                    itemId: 'dtmLastInventoryLevelEntry',
                                                    fieldLabel: 'Last Inventory Level Entry',
                                                    labelWidth: 165
                                                }
                                            ]
                                        },
                                        {
                                            xtype: 'container',
                                            flex: 1,
                                            margin: '0 1 0 5',
                                            layout: {
                                                type: 'vbox',
                                                align: 'stretch'
                                            },
                                            items: [
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkNonRetailUseDepartment',
                                                    fieldLabel: 'Non Retail Use Department',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkReportInNetOrGross',
                                                    fieldLabel: 'Report in Net or Gross',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDepartmentForPumps',
                                                    fieldLabel: 'Department for Pumps',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'gridcombobox',
                                                    columns: [
                                                        {
                                                            dataIndex: 'intPaidOutId',
                                                            dataType: 'numeric',
                                                            text: 'Paid Out Id',
                                                            hidden: true
                                                        },
                                                        {
                                                            dataIndex: 'strPaidOutId',
                                                            dataType: 'string',
                                                            text: 'Paid Out',
                                                            flex: 1
                                                        },
                                                        {
                                                            dataIndex: 'strDescription',
                                                            dataType: 'string',
                                                            text: 'Description',
                                                            flex: 1
                                                        }
                                                    ],
                                                    flex: 1,
                                                    itemId: 'cboConvertToPaidout',
                                                    fieldLabel: 'Convert to Paidout',
                                                    labelWidth: 175,
                                                    displayField: 'strPaidOutId',
                                                    valueField: 'intPaidOutId'
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDeleteFromRegister',
                                                    fieldLabel: 'Delete from Register',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDepartmentKeyTaxed',
                                                    fieldLabel: 'Department Key Taxed',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'gridcombobox',
                                                    columns: [
                                                        {
                                                            dataIndex: 'intRegProdId',
                                                            dataType: 'numeric',
                                                            text: 'Product Id',
                                                            hidden: true
                                                        },
                                                        {
                                                            dataIndex: 'strRegProdCode',
                                                            dataType: 'string',
                                                            text: 'Product',
                                                            flex: 1
                                                        },
                                                        {
                                                            dataIndex: 'strRegProdDesc',
                                                            dataType: 'string',
                                                            text: 'Description',
                                                            flex: 1
                                                        },
                                                        {
                                                            dataIndex: 'intCompanyLocationId',
                                                            dataType: 'numeric',
                                                            hidden: true
                                                        }
                                                    ],
                                                    itemId: 'cboDefaultProductCode',
                                                    fieldLabel: 'Default Product Code',
                                                    labelWidth: 175,
                                                    displayField: 'strRegProdCode',
                                                    valueField: 'intRegProdId'
                                                },
                                                {
                                                    xtype: 'gridcombobox',
                                                    columns: [
                                                        {
                                                            dataIndex: 'intSubcategoryId',
                                                            dataType: 'numeric',
                                                            hidden: true
                                                        },
                                                        {
                                                            dataIndex: 'strSubcategoryId',
                                                            dataType: 'string',
                                                            text: 'Family',
                                                            flex: 1
                                                        },
                                                        {
                                                            dataIndex: 'strSubcategoryDesc',
                                                            dataType: 'string',
                                                            text: 'Description',
                                                            flex: 1
                                                        }
                                                    ],
                                                    itemId: 'cboDefaultFamily',
                                                    fieldLabel: 'Default Family',
                                                    labelWidth: 175,
                                                    displayField: 'strSubcategoryId',
                                                    valueField: 'inSubcategoryId'
                                                },
                                                {
                                                    xtype: 'gridcombobox',
                                                    columns: [
                                                        {
                                                            dataIndex: 'intSubcategoryId',
                                                            dataType: 'numeric',
                                                            hidden: true
                                                        },
                                                        {
                                                            dataIndex: 'strSubcategoryId',
                                                            dataType: 'string',
                                                            text: 'Family',
                                                            flex: 1
                                                        },
                                                        {
                                                            dataIndex: 'strSubcategoryDesc',
                                                            dataType: 'string',
                                                            text: 'Description',
                                                            flex: 1
                                                        }
                                                    ],
                                                    itemId: 'cboDefaultClass',
                                                    fieldLabel: 'Default Class',
                                                    labelWidth: 175,
                                                    displayField: 'strSubcategoryId',
                                                    valueField: 'inSubcategoryId'
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultFoodStampable',
                                                    fieldLabel: 'Default Food Stampable',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultReturnable',
                                                    fieldLabel: 'Default Returnable',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultSaleable',
                                                    fieldLabel: 'Default Saleable',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultPrepriced',
                                                    fieldLabel: 'Default Pre-priced',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultIdRequiredLiquor',
                                                    fieldLabel: 'Default ID Required (liquor)',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'checkboxfield',
                                                    itemId: 'chkDefaultIdRequiredCigarette',
                                                    fieldLabel: 'Default ID Required (cigarette)',
                                                    labelWidth: 175
                                                },
                                                {
                                                    xtype: 'numberfield',
                                                    itemId: 'txtDefaultMinimumAge',
                                                    maxWidth: 225,
                                                    fieldLabel: 'Default Minimum Age',
                                                    labelWidth: 175,
                                                    fieldStyle: 'text-align:right',
                                                    hideTrigger: true
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
        }
    ]

});