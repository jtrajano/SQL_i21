Ext.define('Inventory.view.override.ItemLocationViewController', {
    override: 'Inventory.view.ItemLocationViewController',

    config: {
        binding: {
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{Location}'
            },
            cboDefaultVendor: {
                value: '{current.intVendorId}',
                store: '{Vendor}'
            },
            cboCostingMethod: {
                value: '{current.intCostingMethod}',
                store: '{CostingMethods}'
            },
            cboCategory: {
                value: '{current.intCategoryId}',
                store: '{Category}'
            },
            txtDescription: '{current.strDescription}',
            txtRow: '{current.strRow}',
            txtBon: '{current.strBin}',
            cboDefaultUom: {
                value: '{current.intDefaultUOMId}',
                store: '{UnitMeasure}'
            },
            cboIssueUom: {
                value: '{current.intIssueUOMId}',
                store: '{UnitMeasure}'
            },
            cboReceiveUom: {
                value: '{current.intReceiveUOMId}',
                store: '{UnitMeasure}'
            },
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
            cboFreightVendor: {
                value: '{current.intFreightVendorId}',
                store: '{Vendor}'
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.ItemLocation', { pageSize: 1 });


        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding,
            createRecord: {
                fn: me.createRecord,
                scope: me
            }
        });

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( { window : win } );
            me.intItemId = config.id;
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
    },

    createRecord: function(config, action) {
        var me = this;
        var record = Ext.create('Inventory.model.ItemLocation');
        record.set('intItemId', me.intItemId);
        action(record);
    }
    
});