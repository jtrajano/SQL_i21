Ext.define('Inventory.view.override.CategoryViewController', {
    override: 'Inventory.view.CategoryViewController',

    config: {
        searchConfig: {
            title: 'Search Category',
            type: 'Inventory.Category',
            api: {
                read: '../Inventory/api/Category/SearchCategories'
            },
            columns: [
                {dataIndex: 'intCategoryId', text: "Category Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCategoryCode', text: 'Category Code', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'}
            ]
        },
        binding: {
            txtCategoryCode: '{current.strCategoryCode}',
            txtDescription: '{current.strDescription}',
            cboLineOfBusiness: '{current.strLineBusiness}',
            cboCatalogGroup: '{current.intCatalogGroupId}',
            cboCostingMethod: '{current.strCostingMethod}',
            cboInventoryTracking: '{current.strInventoryTracking}',
            txtStandardQty: '{current.dblStandardQty}',
            cboStandardUom: '{current.intUOMId}',
            txtGlDivisionNumber: '{current.strGLDivisionNumber}',
            chkSalesAnalysisByTon: '{current.ysnSalesAnalysisByTon}',
            cboMaterialFee: '{current.strMaterialFee}',
            cboMaterialItem: '{current.intMaterialItemId}',
            chkAutoCalculateFreight: '{current.ysnAutoCalculateFreight}',
            cboFreightItem: '{current.intFreightItemId}',
            chkNonRetailUseDepartment: '{current.ysnNonRetailUseDepartment}',
            chkReportInNetOrGross: '{current.ysnReportNetGross}',
            chkDepartmentForPumps: '{current.ysnDepartmentPumps}',
            cboConvertToPaidout: '{current.intConvertPaidOutId}',
            chkDeleteFromRegister: '{current.ysnDeleteRegister}',
            chkDepartmentKeyTaxed: '{current.ysnDepartmentKeyTaxed}',
            cboDefaultProductCode: '{current.intProductCodeId}',
            cboDefaultFamily: '{current.intFamilyId}',
            cboDefaultClass: '{current.intClassId}',
            chkDefaultFoodStampable: '{current.ysnFoodStampable}',
            chkDefaultReturnable: '{current.ysnReturnable}',
            chkDefaultSaleable: '{current.ysnSaleable}',
            chkDefaultPrepriced: '{current.ysnPrepriced}',
            chkDefaultIdRequiredLiquor: '{current.ysnIdRequiredLiquor}',
            chkDefaultIdRequiredCigarette: '{current.ysnIdRequiredCigarette}',
            txtDefaultMinimumAge: '{current.intMinimumAge}',
            txtERPItemClass: '{current.strERPItemClass}',
            txtLifeTime: '{current.dblfeTime}',
            txtBOMItemShrinkage: '{current.dblBOMItemShrinkage}',
            txtBOMItemUpperTolerance: '{current.dblBOMItemUpperTolerance}',
            txtBOMItemLowerTolerance: '{current.dblBOMItemLowerTolerance}',
            chkScaled: '{current.ysnScaled}',
            chkOutputItemMandatory: '{current.ysnOutputItemMandatory}',
            txtConsumptionMethod: '{current.strConsumptionMethod}',
            txtBOMItemType: '{current.strBOMItemType}',
            txtShortName: '{current.strShortName}',
            txtReceiptImage: '{current.imgReceiptImage}',
            txtWIPImage: '{current.imgWIPImage}',
            txtFGImage: '{current.imgFGImage}',
            txtShipImage: '{current.imgShipImage}',
            txtLaborCost: '{current.dblLaborCost}',
            txtOverHead: '{current.dblOverHead}',
            txtPercentage: '{current.dblPercentage}',
            txtCostDistributionMethod: '{current.strCostDistributionMethod}',
            chkSellable: '{current.ysnSellable}',
            chkYieldAdjustment: '{current.ysnYieldAdjustment}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Category', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICCategoryAccounts',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdGlAccounts'),
                        deleteButton : win.down('#btnDeleteGlAccounts')
                    })
                },
                {
                    key: 'tblICCategoryStores',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdStore'),
                        deleteButton : win.down('#btnDeleteStore')
                    })
                },
                {
                    key: 'tblICCategoryVendors',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdVendorCategoryXref'),
                        deleteButton : win.down('#btnDeleteVendorCategoryXref')
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
                        column: 'intCategoryId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
//            });
        }
    }

    
});