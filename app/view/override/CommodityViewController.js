Ext.define('Inventory.view.override.CommodityViewController', {
    override: 'Inventory.view.CommodityViewController',

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
            txtCommodityCode: '{current.strCommodityCode}',
            txtDescription: '{current.strDescription}',
            chkExchangeTraded: '{current.ysnExchangeTraded}',
            txtDecimalsOnDpr: '{current.intDecimalDPR}',
            txtConsolidateFactor: '{current.dblConsolidateFactor}',
            chkFxExposure: '{current.ysnFXExposure}',
            txtPriceChecksMin: '{current.dblPriceCheckMin}',
            txtPriceChecksMax: '{current.dblPriceCheckMax}',
            txtCheckoffTaxDesc: '{current.strCheckoffTaxDesc}',
            cboCheckoffTaxAllStates: '{current.strCheckoffAllState}',
            txtInsuranceTaxDesc: '{current.strInsuranceTaxDesc}',
            cboInsuranceTaxAllStates: '{current.strInsuranceAllState}',
            dtmCropEndDateCurrent: '{current.dtmCropEndDateCurrent}',
            dtmCropEndDateNew: '{current.dtmCropEndDateNew}',
            txtEdiCode: '{current.strEDICode}',
            txtDefaultScheduleStore: '{current.strScheduleStore}',
            txtDefaultScheduleDiscount: '{current.strScheduleDiscount}',
            txtTextPurchase: '{current.strTextPurchase}',
            txtTextSales: '{current.strTextSales}',
            txtTextFees: '{current.strTextFees}',
            txtAgItemNumber: '{current.strAGItemNumber}',
            cboScaleAutoDistDefault: '{current.strScaleAutoDist}',
            chkRequireLoadNoAtKiosk: '{current.ysnRequireLoadNumber}',
            chkAllowVariety: '{current.ysnAllowVariety}',
            chkAllowLoadContracts: '{current.ysnAllowLoadContracts}',
            txtMaximumUnder: '{current.dblMaxUnder}',
            txtMaximumOver: '{current.dblMaxOver}',
            cboPatronageCategory: '{current.intPatronageCategoryId}',
            cboPatronageCategoryDirect: '{current.intPatronageCategoryDirectId}'
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
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICCommodityUnitMeasures',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdUom'),
                        deleteButton : win.down('#btnDeleteUom')
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
    }
    
});