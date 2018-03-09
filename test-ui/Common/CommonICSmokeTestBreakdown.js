Ext.define('Inventory.CommonICSmokeTestBreakdown', {

  addOtherChargeItem: function (t,next
      ,item
      ,description
      ,location
      )
  {
      new iRely.FunctionalTest().start(t, next)
          .clickMenuFolder('Inventory','Folder')
          .waitUntilLoaded()
          .clickMenuScreen('Items','Screen')
          .waitUntilLoaded('')

          .filterGridRecords('Search', 'FilterGrid', item)
          .waitUntilLoaded()

          .continueIf({
              expected: true,
              actual: function(win){
                  return win.down('#grdSearch').store.getCount() > 0
              },
              success: function(next){
                  new iRely.FunctionalTest().start(t, next)
                      .displayText('Item already exists.')
                      .done()
              },
              continueOnFail: true
          })

          .continueIf({
              expected: true,
              actual: function(win){
                  return win.down('#grdSearch').store.getCount() == 0
              },
              success: function(next){
                  new iRely.FunctionalTest().start(t, next)
                      //Add Other Charge Item
                      .displayText('===== Adding Other Charge Item =====')
                      .clickButton('New')
                      .waitUntilLoaded('')
                      .enterData('Text Field','ItemNo', item)
                      .selectComboBoxRowNumber('Type',6,0)
                      .enterData('Text Field','Description', description)
//            .selectComboBoxRowNumber('Category',4,0)
                      .selectComboBoxRowValue('Category', 'Other Charges', 'CategoryId',1,1)
                      .displayText('===== Setup Item UOM=====')
                      .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Test_Pounds','strUnitMeasure')
                      .enterGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
                      .clickGridCheckBox('UnitOfMeasure', 1,'strUnitMeasure', 'Test_Pounds', 'ysnStockUnit', true)
                      .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','Test_50 lb bag','strUnitMeasure')
                      .enterGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '1')
                      .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Test_Bushels','strUnitMeasure')
                      .enterGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '1')
                      .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','Test_25 kg bag','strUnitMeasure')
                      .enterGridData('UnitOfMeasure', 4, 'colDetailUnitQty', '1')
                      .selectGridComboBoxRowValue('UnitOfMeasure',5,'strUnitMeasure','Test_KG','strUnitMeasure')
                      .enterGridData('UnitOfMeasure', 5, 'colDetailUnitQty', '1')
                      .waitUntilLoaded('')
                      .clickTab('Setup')
                      .waitUntilLoaded('')


                      .clickTab('Location')
                      .clickButton('AddLocation')
                      .waitUntilLoaded('icitemlocation')
                      .selectComboBoxRowValue('Location', location, 'Location',0)
                      .clickButton('Save')
                      .waitUntilLoaded()
                      .verifyStatusMessage('Saved')
                      .clickButton('Close')

                      .clickButton('Save')
                      .waitUntilLoaded()
                      .clickButton('Close')
                      .displayText('===== Other Charge Item Created =====')
                      .done();
              },
              continueOnFail: true
          })

          .waitUntilLoaded()
          .clickMenuFolder('Inventory','Folder')
          .done();
  },

  addInventoryItem: function (t,next
      ,item
      ,itemdesc
      ,category
      ,commodity
      ,lottrack
      ,saleuom
      ,receiveuom
      ,priceLC
      ,priceSC
      ,priceAC
      )
    {
      new iRely.FunctionalTest().start(t, next)
          .clickMenuFolder('Inventory','Folder')
          .waitUntilLoaded()
          .clickMenuScreen('Items','Screen')
          .waitUntilLoaded('')

          .filterGridRecords('Search', 'FilterGrid', item)
          .waitUntilLoaded()

          .continueIf({
              expected: true,
              actual: function(win){
                  return win.down('#grdSearch').store.getCount() > 0
              },
              success: function(next){
                  new iRely.FunctionalTest().start(t, next)
                      .displayText('Item already exists.')
                      .done()
              },
              continueOnFail: true
          })

          .continueIf({
              expected: true,
              actual: function(win){
                  return win.down('#grdSearch').store.getCount() == 0
              },
              success: function(next){
                  new iRely.FunctionalTest().start(t, next)
                      .clickButton('New')
                      .waitUntilLoaded('')
                      .verifyScreenShown('icitem')
                      .verifyStatusMessage('Ready')

                      .enterData('Text Field','ItemNo', item)
                      .enterData('Text Field','Description', itemdesc)
                      .selectComboBoxRowValue('Category', category, 'cboCategory',1)
                      .selectComboBoxRowValue('Commodity', commodity, 'strCommodityCode',1)
                      .selectComboBoxRowNumber('LotTracking', lottrack)

                      .clickTab('Setup')
                      .clickButton('AddRequiredAccounts')
                      .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
                      .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
                      .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
                      .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
                      .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
                      .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')

                      .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
                      .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
                      .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
                      .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
                      .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
                      .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')

                      .addResult('======== Setup GL Accounts Successful ========')

                      .clickTab('Location')
                      .clickButton('AddLocation')
                      .waitUntilLoaded('')
                      .selectComboBoxRowNumber('Location',1,0)
//            .selectComboBoxRowNumber('SubLocation',4,0)
//            .selectComboBoxRowNumber('StorageLocation',1,0)
                      .selectComboBoxRowValue('SubLocation', 'Raw Station', 'intSubLocationId',0)
                      .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'intStorageLocationId',0)
                      .selectComboBoxRowValue('IssueUom', saleuom, 'strUnitMeasure')
                      .selectComboBoxRowValue('ReceiveUom', receiveuom, 'strUnitMeasure')
                      .clickButton('Save')
                      .waitUntilLoaded()
                      .verifyStatusMessage('Saved')
                      .clickButton('Close')

                      .clickButton('AddLocation')
                      .waitUntilLoaded('')
//            .selectComboBoxRowNumber('Location',2,0)
//            .selectComboBoxRowNumber('SubLocation',1,0)
//            .selectComboBoxRowNumber('StorageLocation',1,0)
                      .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
                      .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
                      .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
                      .selectComboBoxRowValue('IssueUom', saleuom, 'IssueUom',0)
                      .selectComboBoxRowValue('ReceiveUom', receiveuom, 'ReceiveUom',0)
                      .clickButton('Save')
                      .waitUntilLoaded()
                      .verifyStatusMessage('Saved')
                      .clickButton('Close')

                      .clickTab('Other')
                      .clickCheckBox('TankRequired', true)
                      .clickCheckBox('AvailableForTm', true)

                      .displayText('===== Setup Item Pricing=====')
                      .clickTab('Pricing')
                      .waitUntilLoaded('')
                      .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
                      .enterGridData('Pricing', 1, 'dblLastCost', priceLC)
                      .enterGridData('Pricing', 1, 'dblStandardCost', priceSC)
                      .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                      .enterGridData('Pricing', 1, 'dblAmountPercent', priceAC)

                      .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
                      .enterGridData('Pricing', 2, 'dblLastCost', priceLC)
                      .enterGridData('Pricing', 2, 'dblStandardCost', priceSC)
                      .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
                      .enterGridData('Pricing', 2, 'dblAmountPercent', priceAC)
                      .clickButton('Save')
                      .waitUntilLoaded()
                      .clickButton('Close')
                      .done()
              },
              continueOnFail: true
          })

          .waitUntilLoaded()
          .clickMenuFolder('Inventory','Folder')
          .done();
    },

    addUOM: function (t,next, uom, symbol, unittype, decimals) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded()
            .clickMenuScreen('Inventory UOM','Screen')
            .waitUntilLoaded('')

            .filterGridRecords('Search', 'FilterGrid', uom)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('UOM already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .enterData('Text Field','UnitMeasure',uom)
                        .enterData('Text Field','Symbol',symbol)
                        .selectComboBoxRowNumber('UnitType',unittype,0)
//                        .selectComboBoxRowNumber('DecimalPlaces',decimals,0)
//                        .selectComboBoxRowValue('UnitType', unittype, 'UnitType',1)
//                        .selectComboBoxRowValue('Decimals', decimals, 'intDecimalPlaces', 1)
                        .selectComboBoxRowNumber('Decimals', decimals,0)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== UOM added =====')
                        .done()
                },
                continueOnFail: true
            })

            .waitUntilLoaded()
            .clickMenuFolder('Inventory','Folder')
            .done();
    },

    addOtherUOM: function (t,next, uom, row, otheruom, conversionto) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded()
            .clickMenuScreen('Inventory UOM','Screen')
            .waitUntilLoaded('')

            .filterGridRecords('Search', 'FilterGrid', uom)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('===== Other UOM already exists. =====')
                        .doubleClickSearchRowValue (uom,'strUnitMeasure',1)
//                        .selectSearchRowValue(uom,'strUnitMeasure',1)
//                        .clickButton('Open')
                        .waitUntilLoaded()
                        .displayText('===== UOM record is opened. =====')
                        .clickButton('InsertConversion')
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('Conversion', row,'colOtherUOM', otheruom,'strUnitMeasure',1)
                        .enterGridData('Conversion', row, 'dblConversionToStock', conversionto)
                        .waitUntilLoaded()
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== Other UOM added =====')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('===== UOM does not exist. =====')
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .done()
                },
                continueOnFail: true
            })

            .clickMenuFolder('Inventory','Folder')
            .done();
    },
    addItemCommodity: function (t,next, commoditycode, description,
                                row1, row2, row3, row4, row5,
                                uom1, uom2, uom3, uom4, uom5,
                                isstockunit, unitqty1, unitqty2, unitqty3, unitqty4, unitqty5 ) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Inventory', 'Folder')
            .waitUntilLoaded()
            .clickMenuScreen('Commodities', 'Screen')
            .waitUntilLoaded()

            .filterGridRecords('Search', 'FilterGrid', commoditycode)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Item Commodity already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded()
                        .enterData('Text Field','CommodityCode', commoditycode)
                        .enterData('Text Field','Description',description)
                        //.clickCheckBox('ExchangeTraded',true)
                        //.enterData('Text Field','DecimalsOnDpr','6.00')
                        //.enterData('Text Field','ConsolidateFactor','6.00')

                        .selectGridComboBoxRowValue('Uom', row1,'colUOMCode', uom1,'strUnitMeasure')
                        .clickGridCheckBox('Uom', row1,'colUOMStockUnit', uom1, 'ysnStockUnit', isstockunit)
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('Uom', row2,'colUOMCode', uom2,'strUnitMeasure')
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('Uom',row3,'colUOMCode', uom3,'strUnitMeasure')
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('Uom',row4,'colUOMCode', uom4,'strUnitMeasure')
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('Uom',row5,'colUOMCode', uom5,'strUnitMeasure')
                        .waitUntilLoaded()

                        .verifyGridData('Uom', row1, 'colUOMUnitQty', unitqty1)
                        .verifyGridData('Uom', row2, 'colUOMUnitQty', unitqty2)
                        .verifyGridData('Uom', row3, 'colUOMUnitQty', unitqty3)
                        .verifyGridData('Uom', row4, 'colUOMUnitQty', unitqty4)
                        .verifyGridData('Uom', row5, 'colUOMUnitQty', unitqty5)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== Item Commodity added. =====')
                        .done()
                },
                continueOnFail: true
            })
            .waitUntilLoaded('')
            .clickMenuFolder('Inventory', 'Folder')
            .waitUntilLoaded('')
            .done();
    },

    addCategory: function (t,next, categorycode, description,inventorytype) {
        new iRely.FunctionalTest().start(t, next)

            .displayText('===== Add New Category - Inventory Type =====')
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Categories','Screen')
            .waitUntilLoaded('')

            .filterGridRecords('Search', 'FilterGrid', 'SC - Category - 01')
            .waitUntilLoaded('')

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Category already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('===== Scenario 4: Add Category =====')
                        .clickButton('New')
                        .waitUntilLoaded('')
                        .enterData('Text Field','CategoryCode', categorycode)
                        .enterData('Text Field','Description', description)
                        .selectComboBoxRowNumber('InventoryType',inventorytype,0)
                        .selectComboBoxRowNumber('CostingMethod',1,0)
                        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

                        .clickTab('GL Accounts')
                        .clickButton('AddRequired')
                        .waitUntilLoaded()
                        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
                        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Inventory')
                        .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Cost of Goods')
                        .verifyGridData('GlAccounts', 4, 'colAccountCategory', 'Sales Account')
                        .verifyGridData('GlAccounts', 5, 'colAccountCategory', 'Inventory In-Transit')
                        .verifyGridData('GlAccounts', 6, 'colAccountCategory', 'Inventory Adjustment')
                        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')

                        .clickButton('Save')
                        .waitUntilLoaded()
                        .verifyStatusMessage('Saved')
                        .clickButton('Close')
                        .done()
                },
                continueOnFail: true
            })

            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .displayText('===== Add New Category - Inventory Type Done =====')
            .done();
    },



//    addCompanyLoc: function (t,next, user, timezone, location, numberformat) {
//        new iRely.FunctionalTest().start(t, next)
//            .displayText('===== 1. Add Indianapolis for Company Location for irelyadmin User =====')
//            .clickMenuFolder('System Manager','Folder')
//            .clickMenuScreen('Users','Screen')
//            .waitUntilLoaded('')
//            .doubleClickSearchRowValue(user, 'strUsername', 1)
//            .waitUntilLoaded('')
//            .waitUntilLoaded('')
//            .selectComboBoxRowValue('Timezone', timezone, 'Timezone',0)
//            .clickTab('User')
//            .waitUntilLoaded('')
//            .clickTab('User Roles')
//
//            .waitUntilLoaded('')
//            .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', location)
//            .waitUntilLoaded('')
//
//            .continueIf({
//                expected: true,
//                actual: function(win){
//                    return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() > 0
//                },
//                success: function(next){
//                    new iRely.FunctionalTest().start(t, next)
//                        .displayText('Location already exists.')
//                        .clickButton('Close')
//                        .waitUntilLoaded('')
//                        .clickMessageBoxButton('no')
//                        .waitUntilLoaded('')
//                        .done()
//                },
//                continueOnFail: true
//            })
//
//            .continueIf({
//                expected: true,
//                actual: function(win){
//                    return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() == 0
//                },
//                success: function(next){
//                    new iRely.FunctionalTest().start(t, next)
//                        .displayText('Location is not yet existing.')
//                        .clickButton('Close')
//                        .waitUntilLoaded('')
//                        .clickMessageBoxButton('no')
//                        .waitUntilLoaded('')
//                        .doubleClickSearchRowValue(user, 'strUsername', 1)
//                        .waitUntilLoaded('')
//                        .clickTab('User')
//                        .waitUntilLoaded('')
//                        .clickTab('User Roles')
//                        .waitUntilLoaded('')
//                        .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 'Dummy','strLocationName', location,'strLocationName', 1)
//                        .selectGridComboBoxBottomRowValue('UserRoleCompanyLocationRolePermission', 'strUserRole', 'ADMIN', 'strUserRole', 1)
//                        .clickTab('Detail')
//                        .waitUntilLoaded('')
//                        .selectComboBoxRowValue('UserNumberFormat', numberformat, 'UserNumberFormat',1)
//                        .clickButton('Save')
//                        .waitUntilLoaded('')
//                        .clickButton('Close')
//                        .waitUntilLoaded('')
//                        .done()
//                },
//                continueOnFail: true
//            })
//
//            .clickMenuFolder('System Manager','Folder')
//            .waitUntilLoaded('')
//            .done();
//    }

    addLocationToUser: function (t,next, user, location, defaultlocation, numberformat) {
        new iRely.FunctionalTest().start(t, next)

            .displayText('===== Add Location to User =====')
            .clickMenuFolder('System Manager','Folder')
            .clickMenuScreen('Users','Screen')
            .waitUntilLoaded()
            .doubleClickSearchRowValue(user, 'strUsername', 1)
            .waitUntilLoaded('ementity')
            .clickTab('User')
            .waitUntilLoaded()
            .clickTab('User Roles')

            .waitUntilLoaded()
            .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', location)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() > 0;
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Location already exists.')
                        .addFunction(function(next){
                            t.chain(
                                { click : "#frmEntity #tabEntity #pnlUser #conEntityUserTab #tabUser #pnlUserRole #grdUserRoleCompanyLocationRolePermission #tlbGridOptions #txtFilterGrid => .x-form-trigger" }
                            );
                            next();
                        })
                        .clickTab('Detail')
                        .waitUntilLoaded()
                        .selectComboBoxRowValue('UserDefaultLocation', defaultlocation, 'strLocationName',1)
                        .waitUntilLoaded()
                        .clickButton('Save')
                        .waitUntilLoaded()

//                        .clickButton('Close')
//                        .waitUntilLoaded()
//                        .clickMessageBoxButton('no')
                        .waitUntilLoaded()
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() == 0;
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Location is not yet existing.')
                        .addFunction(function(next){
                            t.chain(
                                { click : "#frmEntity #tabEntity #pnlUser #conEntityUserTab #tabUser #pnlUserRole #grdUserRoleCompanyLocationRolePermission #tlbGridOptions #txtFilterGrid => .x-form-trigger" }
                            );
                            next();
                        })
                        .clickButton('UserRoleCompanyLocationAdd')
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 'Dummy','strLocationName', '0002 - Indianapolis','strLocationName', 1)
                        .selectGridComboBoxBottomRowValue('UserRoleCompanyLocationRolePermission', 'strUserRole', 'ADMIN', 'strUserRole', 5)
                        .clickTab('Detail')
                        .waitUntilLoaded()
                        .selectComboBoxRowValue('UserDefaultLocation', defaultlocation, 'strLocationName',1)
                        .waitUntilLoaded()
                        .selectComboBoxRowValue('UserNumberFormat', numberformat, 'UserNumberFormat',1)
                        .clickButton('Save')
                        .waitUntilLoaded()
//                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== Location added to user. =====')
                        .done()
                },
                continueOnFail: true
            })

            .clickButton('Close')
            .waitUntilLoaded()
            .clickMenuFolder('System Manager','Folder')
            .done();
    }

});