/*
 * File: app/view/CommodityViewController.js
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

Ext.define('Inventory.view.CommodityViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iccommodity',

    config: {
        searchConfig: {
            title:  'Search Commodity',
            type: 'Inventory.Commodity',
            api: {
                read: '../Inventory/api/Commodity/SearchCommodities'
            },
            columns: [
                {dataIndex: 'intCommodityId',text: "Commodity Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCommodityCode', text: 'Commodity Code', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Commodity - {current.strCommodityCode}'
            },
            txtCommodityCode: '{current.strCommodityCode}',
            txtDescription: '{current.strDescription}',
            chkExchangeTraded: '{current.ysnExchangeTraded}',
            txtDecimalsOnDpr: '{current.intDecimalDPR}',
            txtConsolidateFactor: '{current.dblConsolidateFactor}',
            chkFxExposure: '{current.ysnFXExposure}',
            txtPriceChecksMin: '{current.dblPriceCheckMin}',
            txtPriceChecksMax: '{current.dblPriceCheckMax}',
            txtCheckoffTaxDesc: '{current.strCheckoffTaxDesc}',
            cboCheckoffTaxAllStates: {
                value: '{current.strCheckoffAllState}',
                store: '{states}'
            },
            txtInsuranceTaxDesc: '{current.strInsuranceTaxDesc}',
            cboInsuranceTaxAllStates: {
                value: '{current.strInsuranceAllState}',
                store: '{states}'
            },
            dtmCropEndDateCurrent: '{current.dtmCropEndDateCurrent}',
            dtmCropEndDateNew: '{current.dtmCropEndDateNew}',
            txtEdiCode: '{current.strEDICode}',
            txtDefaultScheduleStore: '{current.strScheduleStore}',
            txtDefaultScheduleDiscount: '{current.strScheduleDiscount}',
            txtTextPurchase: '{current.strTextPurchase}',
            txtTextSales: '{current.strTextSales}',
            txtTextFees: '{current.strTextFees}',
            txtAgItemNumber: '{current.strAGItemNumber}',
            cboScaleAutoDistDefault: {
                value: '{current.strScaleAutoDist}',
                store: '{autoScaleDist}'
            },
            chkRequireLoadNoAtKiosk: '{current.ysnRequireLoadNumber}',
            chkAllowVariety: '{current.ysnAllowVariety}',
            chkAllowLoadContracts: '{current.ysnAllowLoadContracts}',
            txtMaximumUnder: '{current.dblMaxUnder}',
            txtMaximumOver: '{current.dblMaxOver}',
            cboPatronageCategory: {
                value: '{current.intPatronageCategoryId}',
                store: '{patronageCategory}'
            },
            cboPatronageCategoryDirect: {
                value: '{current.intPatronageCategoryDirectId}',
                store: '{directPatronageCategory}'
            },

            grdUom: {
                colUOMCode: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{unitMeasure}'
                    }
                },
                colUOMUnitQty: 'dblUnitQty',
                colUOMStockUnit: 'ysnStockUnit',
                colUOMDefaultUOM: 'ysnDefault'
            },

            grdGlAccounts: {
                colAccountLocation: {
                    dataIndex: 'strLocationName',
                    editor: {
                        store: '{location}'
                    }
                },
                colAccountCategory: {
                    dataIndex: 'strAccountCategory',
                    editor: {
                        store: '{accountCategory}',
                        defaultFilters: [{
                            column: 'strAccountCategoryGroupCode',
                            value: 'INV',
                            conjunction: 'and'
                        }]
                    }
                },
                colAccountGroup: 'strAccountGroup',
                colAccountId: {
                    dataIndex: 'strAccountId',
                    editor: {
                        store: '{glAccount}',
                        defaultFilters: [{
                            column: 'intAccountCategoryId',
                            value: '{grdGlAccounts.selection.intAccountCategoryId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colAccountDescription: 'strAccountDescription'
            },

            grdOrigin: {
                colOrigin: 'strDescription'
            },

            grdProductType: {
                colProductType: 'strDescription'
            },

            grdRegion: {
                colRegion: 'strDescription'
            },

            grdClassVarient: {
                colClassVarient: 'strDescription'
            },

            grdSeason: {
                colSeason: 'strDescription'
            },

            grdGrade: {
                colGrade: 'strDescription'
            },

            grdProductLine: {
                colProductLine: 'strDescription'
            }
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Commodity', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICCommodityUnitMeasures',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdUom'),
                        deleteButton : win.down('#btnDeleteUom')
                    })
                },
                {
                    key: 'tblICCommodityAccounts',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdGlAccounts'),
                        deleteButton : win.down('#btnDeleteGlAccounts')
                    })
                },
                {
                    key: 'tblICCommodityClassVariants',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdClassVarient'),
                        deleteButton : win.down('#btnDeleteClasses')
                    })
                },
                {
                    key: 'tblICCommodityGrades',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdGrade'),
                        deleteButton : win.down('#btnDeleteGrades')
                    })
                },
                {
                    key: 'tblICCommodityOrigins',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdOrigin'),
                        deleteButton : win.down('#btnDeleteOrigins')
                    })
                },
                {
                    key: 'tblICCommodityProductLines',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdProductLine'),
                        deleteButton : win.down('#btnDeleteProductLines')
                    })
                },
                {
                    key: 'tblICCommodityProductTypes',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdProductType'),
                        deleteButton : win.down('#btnDeleteProductTypes')
                    })
                },
                {
                    key: 'tblICCommodityRegions',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdRegion'),
                        deleteButton : win.down('#btnDeleteRegions')
                    })
                },
                {
                    key: 'tblICCommoditySeasons',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdSeason'),
                        deleteButton : win.down('#btnDeleteSeasons')
                    })
                }
            ]
        });

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intCommodityId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    onUOMSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepUOM');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colUOMCode')
        {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
            current.set('tblICUnitMeasure', records[0]);

            var uoms = grid.store.data.items;
            var exists = Ext.Array.findBy(uoms, function (row) {
                if (row.get('ysnStockUnit') === true) {
                    return true;
                }
            });
            if (exists) {
                var currUOM = exists.get('tblICUnitMeasure');
                if (currUOM) {
                    var conversions = currUOM.vyuICGetUOMConversions;
                    if (!conversions) {
                        conversions = currUOM.data.vyuICGetUOMConversions;
                    }
                    var selectedUOM = Ext.Array.findBy(conversions, function (row) {
                        if (row.intUnitMeasureId === records[0].get('intUnitMeasureId')) {
                            return true;
                        }
                    });
                    if (selectedUOM) {
                        current.set('dblUnitQty', selectedUOM.dblConversionToStock);
                    }
                }
            }
        }
    },

    onAccountSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepAccounts');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colAccountLocation')
        {
            current.set('intLocationId', records[0].get('intCompanyLocationId'));
        }
        else if (combo.column.itemId === 'colAccountCategory')
        {
            current.set('intAccountCategoryId', records[0].get('intAccountCategoryId'));
        }
        else if (combo.column.itemId === 'colAccountId')
        {
            current.set('intAccountId', records[0].get('intAccountId'));
            current.set('strAccountGroup', records[0].get('strAccountGroup'));
            current.set('strAccountDescription', records[0].get('strDescription'));
        }
    },

    onUOMStockUnitCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnStockUnit'){
            var grid = obj.up('grid');

            var current = grid.view.getRecord(rowIndex);

            if (checked === true){
                var uoms = grid.store.data.items;
                var currUOM = current.get('tblICUnitMeasure');
                if (currUOM) {
                    var conversions = currUOM.vyuICGetUOMConversions;
                    if (!conversions) {
                        conversions = currUOM.data.vyuICGetUOMConversions;
                    }
                    uoms.forEach(function(uom){
                        if (uom === current){
                            current.set('dblUnitQty', 1);
                        }
                        if (uom !== current){
                            uom.set('ysnStockUnit', false);
                        }
                        if (conversions){
                            var exists = Ext.Array.findBy(conversions, function(row) {
                                if (row.intUnitMeasureId === uom.get('intUnitMeasureId')) {
                                    return true;
                                }
                            });
                            if (exists) {
                                uom.set('dblUnitQty', exists.dblConversionToStock);
                            }
                        }
                    });
                }
            }
            else {
                if (current){
                    current.set('dblUnitQty', 1);
                }
            }
        }
    },

    init: function(application) {
        this.control({
            "#cboUOM": {
                select: this.onUOMSelect
            },
            "#cboAccountLocation": {
                select: this.onAccountSelect
            },
            "#cboAccountCategory": {
                select: this.onAccountSelect
            },
            "#cboAccountId": {
                select: this.onAccountSelect
            },
            "#colUOMStockUnit": {
                beforecheckchange: this.onUOMStockUnitCheckChange
            }
        });
    }
});
