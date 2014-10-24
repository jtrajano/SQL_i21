/*
 * File: app/view/ItemLocation.js
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

Ext.define('Inventory.view.ItemLocation', {
    extend: 'Ext.window.Window',
    alias: 'widget.itemlocation',

    requires: [
        'Inventory.view.ItemLocationViewModel',
        'Inventory.view.StatusbarPaging1',
        'Ext.form.Panel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.field.ComboBox',
        'Ext.form.field.TextArea',
        'Ext.form.field.Checkbox',
        'Ext.toolbar.Paging'
    ],

    viewModel: {
        type: 'itemlocation'
    },
    height: 660,
    hidden: false,
    minHeight: 660,
    minWidth: 995,
    width: 995,
    layout: 'fit',
    collapsible: true,
    iconCls: 'small-icon-i21',
    title: 'Item Location',
    maximizable: true,

    items: [
        {
            xtype: 'form',
            autoShow: true,
            height: 350,
            itemId: 'frmItemLocation',
            margin: -1,
            width: 450,
            bodyBorder: false,
            bodyPadding: 10,
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
                    xtype: 'container',
                    margin: '0 0 5 0',
                    layout: {
                        type: 'hbox',
                        align: 'stretch'
                    },
                    items: [
                        {
                            xtype: 'combobox',
                            flex: 1.4,
                            itemId: 'cboLocation',
                            fieldLabel: 'Location',
                            labelWidth: 105
                        },
                        {
                            xtype: 'combobox',
                            flex: 1,
                            itemId: 'cboDefaultVendor',
                            margin: '0 5',
                            fieldLabel: 'Vendor',
                            labelWidth: 50
                        },
                        {
                            xtype: 'combobox',
                            flex: 1,
                            itemId: 'cboCostingMethod',
                            fieldLabel: 'Costing Method',
                            labelWidth: 95
                        },
                        {
                            xtype: 'combobox',
                            flex: 1,
                            itemId: 'cboCategory',
                            margin: '0 0 0 5',
                            fieldLabel: 'Category',
                            labelWidth: 55
                        }
                    ]
                },
                {
                    xtype: 'textareafield',
                    itemId: 'txtDescription',
                    fieldLabel: 'Description',
                    labelWidth: 105,
                    grow: true
                },
                {
                    xtype: 'container',
                    flex: 1,
                    height: 432,
                    layout: {
                        type: 'hbox',
                        align: 'stretch'
                    },
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
                                    itemId: 'txtRow',
                                    fieldLabel: 'Row',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtBin',
                                    fieldLabel: 'Bin',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboDefaultUom',
                                    fieldLabel: 'Default UOM',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboIssueUom',
                                    fieldLabel: 'Issue UOM',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboReceiveUom',
                                    fieldLabel: 'Receive UOM',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboFamily',
                                    fieldLabel: 'Family',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboClass',
                                    fieldLabel: 'Class',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboProductCode',
                                    fieldLabel: 'Product Code',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboFuelTankNo',
                                    fieldLabel: 'Fuel Tank No',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtPassportFuelId1',
                                    fieldLabel: 'Passport Fuel ID 1',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtPassportFuelId2',
                                    fieldLabel: 'Passport Fuel ID 2',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtPassportFuelId3',
                                    fieldLabel: 'Passport Fuel ID 3',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkTaxFlag1',
                                    fieldLabel: 'Tax Flag 1',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkTaxFlag2',
                                    fieldLabel: 'Tax Flag 2',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkTaxFlag3',
                                    fieldLabel: 'Tax Flag 3',
                                    labelWidth: 105
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkTaxFlag4',
                                    fieldLabel: 'Tax Flag 4',
                                    labelWidth: 105
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            flex: 1,
                            margin: '0 7',
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkPromotionalItem',
                                    fieldLabel: 'Promotional Item',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboMixMatchCode',
                                    fieldLabel: 'Mix/Match Code',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkDepositRequired',
                                    fieldLabel: 'Deposit Required',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtBottleDepositNo',
                                    fieldLabel: 'Bottle Deposit No',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkSaleable',
                                    fieldLabel: 'Saleable',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkQuantityRequired',
                                    fieldLabel: 'Quantity Required',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkScaleItem',
                                    fieldLabel: 'Scale Item',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkFoodStampable',
                                    fieldLabel: 'Food Stampable',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkReturnable',
                                    fieldLabel: 'Returnable',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkPrePriced',
                                    fieldLabel: 'Pre Priced',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkOpenPricePlu',
                                    fieldLabel: 'Open Price PLU',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkLinkedItem',
                                    fieldLabel: 'Linked Item',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtVendorCategory',
                                    fieldLabel: 'Vendor Category',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkCountbySerialNumber',
                                    fieldLabel: 'Count by Serial Number',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtSerialNumberBegin',
                                    fieldLabel: 'Serial Number Begin',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtSerialNumberEnd',
                                    fieldLabel: 'Serial Number End',
                                    labelWidth: 140
                                }
                            ]
                        },
                        {
                            xtype: 'container',
                            flex: 1,
                            layout: {
                                type: 'vbox',
                                align: 'stretch'
                            },
                            items: [
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkIdRequiredLiqour',
                                    fieldLabel: 'ID Required (liqour)',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkIdRequiredCigarettes',
                                    fieldLabel: 'ID Required (Cigarettes)',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtMinimumAge',
                                    fieldLabel: 'Minimum Age',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkApplyBlueLaw1',
                                    fieldLabel: 'Apply Blue Law 1',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkApplyBlueLaw2',
                                    fieldLabel: 'Apply Blue Law 2',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboItemTypeCode',
                                    fieldLabel: 'Item Type Code',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtItemTypeSubcode',
                                    fieldLabel: 'Item Type Subcode',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'checkboxfield',
                                    itemId: 'chkAutoCalculateFreight',
                                    fieldLabel: 'Auto Calculate Freight',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboFreightMethod',
                                    fieldLabel: 'Freight Method',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'textfield',
                                    itemId: 'txtFreightRate',
                                    fieldLabel: 'Freight Rate',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboFreightVendor',
                                    fieldLabel: 'Freight Vendor',
                                    labelWidth: 140
                                },
                                {
                                    xtype: 'combobox',
                                    itemId: 'cboNegativeInventory',
                                    fieldLabel: 'Negative Inventory',
                                    labelWidth: 140
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]

});