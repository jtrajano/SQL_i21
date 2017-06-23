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
        binding: {
            bind: {
                title: 'Commodity - {current.strCommodityCode}'
            },
            txtCommodityCode: '{current.strCommodityCode}',
            txtDescription: '{current.strDescription}',
            chkExchangeTraded: '{current.ysnExchangeTraded}',
            cboFutureMarket: {
                origValueField: 'intFutureMarketId',
                origUpdateField: 'intFutureMarketId',
                value: '{current.strFutMarketName}',
                store: '{futureMarket}',
                readOnly: '{!current.ysnExchangeTraded}'
            },
            txtDecimalsOnDpr: '{current.intDecimalDPR}',
            txtConsolidateFactor: {
                value: '{current.dblConsolidateFactor}',
                hidden: true //obsolete
            },
            chkFxExposure: {
                value: '{current.ysnFXExposure}',
                hidden: true //obsolete
            },
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
            txtEdiCode: '{current.strEDICode}',
            cboDefaultScheduleStore: {
                origValueField: 'intStorageScheduleRuleId',
                origUpdateField: 'intScheduleStoreId',
                value: '{current.strScheduleId}',
                store: '{scheduleStore}',
                defaultFilters: [{
                    column: 'intCommodity',
                    value: '{current.intCommodityId}',
                    conjunction: 'and'
                }]
            },
            cboDefaultScheduleDiscount: {
                origValueField: 'intDiscountId',
                origUpdateField: 'intScheduleDiscountId',
                value: '{current.strDiscountId}',
                store: '{scheduleDiscount}'
            },
            cboScaleAutoDistDefault: {
                origValueField: 'intStorageScheduleTypeId',
                origUpdateField: 'intScaleAutoDistId',
                value: '{current.strStorageTypeCode}',
                store: '{autoScaleDist}'
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
                //colOrigin: 'strDescription' // Have to get origin from Country maintenance
                colOrigin: {
                    dataIndex: 'strDescription',
                    editor: {
                        store: '{origins}',
                        origValueField: 'intCountryID',
                        origUpdateField: 'intCountryID'
                    }
                },
                colDefaultPackingUOM: {
                    dataIndex: 'strDefaultPackingUOM',
                    editor: {
                        store: '{packinguoms}',
                        // defaultFilters: [{
                        //     column: 'strUnitType',
                        //     value: 'Packed',
                        //     conjunction: 'and'
                        // }],
                        origValueField: 'intUnitMeasureId',
                        origUpdateField: 'intDefaultPackingUOMId',
                    }
                },
                colPurchasingGroup: {
                    dataIndex: 'strPurchasingGroup',
                    editor: {
                        store: '{purchasinggroups}',
                        origValueField: 'intPurchasingGroupId',
                        origUpdateField: 'intPurchasingGroupId'
                    }
                }
            },

            grdProductType: {
                colProductType: 'strDescription'
            },

            grdRegion: {
                colRegion: 'strDescription'
            },

            grdClassVariant: {
                colClassVariant: 'strDescription'
            },

            grdSeason: {
                colSeason: 'strDescription'
            },

            grdGrade: {
                colGrade: 'strDescription'
            },

            grdProductLine: {
                colProductLine: 'strDescription',
                colDeltaHedge: 'ysnDeltaHedge',
                colDeltaPercent: 'dblDeltaPercent'
            }
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Commodity', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            include: 'tblICCommodityUnitMeasures.tblICUnitMeasure, ' +
                'tblICCommodityAccounts.tblGLAccount, ' +
                'tblICCommodityClassVariants, ' +
                'tblICCommodityGrades, ' +
                'tblICCommodityOrigins, ' +
                'tblICCommodityOrigins.tblICUnitMeasure, ' +
                'tblICCommodityOrigins.tblSMPurchasingGroup, ' +
                'tblICCommodityProductLines, ' +
                'tblICCommodityProductTypes, ' +
                'tblICCommodityRegions, ' +
                'tblICCommoditySeasons, ' +
                'tblICCommodityGroups, ' +
                'vyuICCommodityLookUp',
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICCommodityUnitMeasures',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdUom'),
                        deleteButton : win.down('#btnDeleteUom')
                    })
                },
                {
                    key: 'tblICCommodityAccounts',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdGlAccounts'),
                        deleteButton : win.down('#btnDeleteGlAccounts')
                    })
                },
                {
                    key: 'tblICCommodityClassVariants',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdClassVariant'),
                        deleteButton : win.down('#btnDeleteClasses')
                    })
                },
                {
                    key: 'tblICCommodityGrades',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdGrade'),
                        deleteButton : win.down('#btnDeleteGrades')
                    })
                },
                {
                    key: 'tblICCommodityOrigins',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdOrigin'),
                        deleteButton : win.down('#btnDeleteOrigins')
                    })
                },
                {
                    key: 'tblICCommodityProductLines',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdProductLine'),
                        deleteButton : win.down('#btnDeleteProductLines')
                    })
                },
                {
                    key: 'tblICCommodityProductTypes',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdProductType'),
                        deleteButton : win.down('#btnDeleteProductTypes')
                    })
                },
                {
                    key: 'tblICCommodityRegions',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdRegion'),
                        deleteButton : win.down('#btnDeleteRegions')
                    })
                },
                {
                    key: 'tblICCommoditySeasons',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdSeason'),
                        deleteButton : win.down('#btnDeleteSeasons')
                    })
                }
            ]
        });

        var grdUOM = win.down('#grdUom');
        var colUnitQty = _.findWhere(grdUOM.columns, function(c) { return c.itemId === 'colUnitQty'; });
        colUnitQty.onGetDecimalPlaces = me.onGetDecimalPlaces;

        return win.context;
    },

    onGetDecimalPlaces: function(record) {
        if(record && record.get('tblICUnitMeasure'))
            return record.get('tblICUnitMeasure').intDecimalPlaces;
        return null;
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

    onUOMUnitQty: function(editor, newValue, oldValue) {
        var selection = editor.up('grid').getSelectionModel().selected;
        var decimals = 2;

        if(selection && selection.items && selection.items.length > 0) {
            if(selection.items[0].data.tblICUnitMeasure) {
                if(selection.items[0].data.tblICUnitMeasure.data)
                    decimals = selection.items[0].data.tblICUnitMeasure.data.intDecimalPlaces;
                else
                    decimals = selection.items[0].data.tblICUnitMeasure.intDecimalPlaces;
                    
                if(iRely.Functions.isEmpty(decimals))
                    decimals = 2;
                var format = "";
                for (var i = 0; i < decimals; i++)
                    format += "0";
                
                var formatted = numeral(newValue).format('0,0.[' + format + ']');
                editor.setValue(formatted);
            }
        }
    },

    onUOMSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var win = grid.up('window');
        var plugin = grid.getPlugin('cepUOM');
        var currentItem = win.viewModel.data.current;
        var current = plugin.getActiveRecord();
        var me = this;

        if (combo.column.itemId === 'colUOMCode') {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
            current.set('tblICUnitMeasure', records[0]);

            var commodityUOMs = grid.store;
            var stockUnit = commodityUOMs.findRecord('ysnStockUnit', true);
            if (stockUnit) {
                var unitMeasureId = stockUnit.get('intUnitMeasureId');
                me.getConversionValue(current.get('intUnitMeasureId'), unitMeasureId, function(value) {
                    current.set('dblUnitQty', value);
                });
            }
        }
    },    

    getConversionValue: function (unitMeasureId, stockUnitMeasureId, callback) {
        if (!Ext.isNumeric(unitMeasureId))
            return;

        if (!Ext.isNumeric(stockUnitMeasureId))
            return;

        iRely.Msg.showWait('Converting units...');
        ic.utils.ajax({
            url: '../Inventory/api/Item/GetUnitConversion',
            method: 'Post',
            params: {
                intFromUnitMeasureId: unitMeasureId,
                intToUnitMeasureId: stockUnitMeasureId
            }
        })
        .subscribe(
            function (successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                var result = jsonData && jsonData.message ? jsonData.message.data : 0.00; 
                if (Ext.isNumeric(result) && callback) {
                    callback(result);
                }
                iRely.Msg.close();
            },

            function (failureResponse) {
                 var jsonData = Ext.decode(failureResponse.responseText);
                 iRely.Msg.close();
                 iRely.Functions.showErrorDialog(jsonData.message.statusText);
            }
        );
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
        var me = this;
        var grid = obj.up('grid');
        var win = obj.up('window');
        var current = grid.view.getRecord(rowIndex);
        var uomConversion = win.viewModel.storeInfo.uomConversion;
        var uoms = grid.store.data.items;
        var newStockUOMId = current.get('intUnitMeasureId');

        if (obj.dataIndex === 'ysnStockUnit'){
            if (checked === true){
                if (uoms) {
                    uoms.forEach(function(uom){                        
                        if (uom === current){
                            current.set('dblUnitQty', 1);
                        }
                        var fromUnitMeasureId = uom.get('intUnitMeasureId');
                        if (uom !== current && fromUnitMeasureId && newStockUOMId){
                            uom.set('ysnStockUnit', false);
                            me.getConversionValue(fromUnitMeasureId, newStockUOMId, function(value) {
                                uom.set('dblUnitQty', value);
                            });                            
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
        else if (obj.dataIndex === 'ysnDefault'){
            if (checked === true) {
                uoms.forEach(function (uom) {
                    if (uom !== current) {
                        uom.set('ysnDefault', false);
                    }
                });
            }
        }
    },
    
     onFutureMarketDrilldown: function(combo) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
   
         if(current.get('intFutureMarketId') !== null)
             {
                 iRely.Functions.openScreen('RiskManagement.view.FuturesMarket', current.get('intFutureMarketId'));
             }
         else
             {
                  iRely.Functions.openScreen('RiskManagement.view.FuturesMarket', {action: 'new'});
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
            "#txtUOMUnitQty": {
                change: this.onUOMUnitQty
            },
            "#colUOMStockUnit": {
                beforecheckchange: this.onUOMStockUnitCheckChange
            },
            "#colUOMDefaultUOM": {
                beforecheckchange: this.onUOMStockUnitCheckChange
            },
             "#cboFutureMarket": {
                drilldown: this.onFutureMarketDrilldown
            },
        });
    }
});
