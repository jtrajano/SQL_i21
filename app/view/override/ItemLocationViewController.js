Ext.define('Inventory.view.override.ItemLocationViewController', {
    override: 'Inventory.view.ItemLocationViewController',

    config: {
        binding: {
            cboLocation: '{current.intLocationId}',
            cboDefaultVendor: '{current.intVendorId}',
            cboCostingMethod: '{current.intCostingMethod}',
            cboCategory: '{current.intCategoryId}',
            txtDescription: '{current.strPOSDescription}',
            txtRow: '{current.strRow}',
            txtBon: '{current.strBin}',
            cboDefaultUom: '{current.intDefaultUOMId}',
            cboIssueUom: '{current.intIssueUOMId}',
            cboReceiveUom: '{current.intReceiveUOMId}',
            cboFamily: '{current.intFamilyId}',
            cboClass: '{current.intClassId}',
            cboProductCode: '{current.intProductCodeId}',
            cboFuelTankNo: '{current.intFuelTankId}',
            txtPassportFuelId1: '{current.strPassportFuelId1}',
            txtPassportFuelId2: '{current.strPassportFuelId2}',
            txtPassportFuelId3: '{current.strPassportFuelId3}',
            chkTaxFlag1: '{current.ysnTaxFlag1}',
            chkTaxFlag2: '{current.ysnTaxFlag2}',
            chkTaxFlag3: '{current.ysnTaxFlag3}',
            chkTaxFlag4: '{current.ysnTaxFlag4}',
            chkPromotionalItem: '{current.ysnPromotionalItem}',
            cboMixMatchCode: '{current.intMixMatchId}',
            chkDepositRequired: '{current.ysnDepositRequired}',
            txtBottleDepositNo: '{current.intBottleDepositNo}',
            chkSaleable: '{current.ysnSaleable}',
            chkQuantityRequired: '{current.ysnQuantityRequired}',
            chkScaleItem: '{current.ysnScaleItem}',
            chkFoodStampable: '{current.ysnFoodStampable}',
            chkReturnable: '{current.ysnReturnable}',
            chkPrePriced: '{current.ysnPrePriced}',
            chkOpenPricePlu: '{current.ysnOpenPricePLU}',
            chkLinkedItem: '{current.ysnLinkedItem}',
            txtVendorCategory: '{current.strVendorCategory}',
            chkCountbySerialNumber: '{current.ysnCountBySINo}',
            txtSerialNumberBegin: '{current.strSerialNoBegin}',
            txtSerialNumberEnd: '{current.strSerialNoEnd}',
            chkIdRequiredLiqour: '{current.ysnIdRequiredLiquor}',
            chkIdRequiredCigarettes: '{current.ysnIdRequiredCigarette}',
            txtMinimumAge: '{current.intMinimumAge}',
            chkApplyBlueLaw1: '{current.ysnApplyBlueLaw1}',
            chkApplyBlueLaw2: '{current.ysnApplyBlueLaw2}',
            cboItemTypeCode: '{current.intItemTypeCode}',
            txtItemTypeSubcode: '{current.intItemTypeSubCode}',
            chkAutoCalculateFreight: '{current.ysnAutoCalculateFreight}',
            cboFreightMethod: '{current.intFreightMethodId}',
            txtFreightRate: '{current.dblFreightRate}',
            cboFreightVendor: '{current.intFreightVendorId}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = options.store;

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding
        });

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var current = config.store['tblICItemLocations']();
            var context = me.setupContext( { window : win, store: current } );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                var filter = [{
                        column: 'intItemId',
                        value: config.id
                    }];


                context.data.load({
                    filters: filter
                });
            }
        }
    }
    
});