StartTest (function (t) {
    var myDate = new Date();
    var randomNo=Math.floor((Math.random() * 1000000) + 1);
    var productID = 'NLTI-'  + randomNo + ' ' + myDate.toLocaleDateString('en-US') ;
    
    randomNo=Math.floor((Math.random() * 1000000) + 1);
    var productID2 = 'LTI-'  + randomNo + ' ' + myDate.toLocaleDateString('en-US') ; 
    
    new iRely.FunctionalTest().start(t)
  
    .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .displayText('1')
        .addScenario('Precondition Setup','UOM Setup',1000)
        .clickMenuFolder('Inventory')
        .clickMenuScreen('Inventory UOM')
        .waitUntilLoaded()
        .filterGridRecords('UOM', 'FilterGrid', 'LB2')
        // .enterData('Text Field','FilterGrid','LB2' )
        // .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdUOM').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM LB2 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid').waitUntilLoaded().waitUntilLoaded()
                        .clickButton('InsertUOM')
                        .addFunction(function(next){
                            var win = Ext.WindowManager.getActive();
                            var recCount = win.down('#grdUOM').store.getCount();
                            new iRely.FunctionalTest().start(t, next)
                            .enterGridData('UOM', recCount, 'strUnitMeasure', 'LB2')
                            .enterGridData('UOM', recCount, 'strSymbol', 'LB2')
                            .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                       
                            .clickButton('Save')
                            .waitUntilLoaded()
                            .verifyStatusMessage('Saved')
                            .waitUntilLoaded()
                            .done()
                        })
                        .done();
               
                      
                },
                continueOnFail: true   
        }) 
        .clickButton('Close') 
        .waitUntilLoaded()
        .displayText('2')
        .clickMenuScreen('Inventory UOM')
        .filterGridRecords('UOM', 'FilterGrid', '50lb bag2')
        // .enterData('Text Field','FilterGrid','50lb bag2' )
        // .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdUOM').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 50lb bag2 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid').waitUntilLoaded().waitUntilLoaded()
                    .clickButton('InsertUOM')
                    .addFunction(function(next){
                        var win = Ext.WindowManager.getActive();
                        var recCount = win.down('#grdUOM').store.getCount();
                        new iRely.FunctionalTest().start(t, next)
                        .enterGridData('UOM', recCount, 'strUnitMeasure', '50lb bag2')
                        .enterGridData('UOM', recCount, 'strSymbol', '50lb bag2')
                        .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                        .clickButton('InsertConversion')
                        .selectGridComboBoxRowValue('Conversion',1,'colConversionTo','LB2','strUnitMeasure',1)
                        .waitUntilLoaded()
                        .enterGridData('Conversion', 1, 'dblConversionToStock', '50')
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .verifyStatusMessage('Saved')
                        .waitUntilLoaded()
                        
                        .done()
                    })
                    .done();
                   
                },
                continueOnFail: true   
        })
        .clickButton('Close') 
        .waitUntilLoaded()
        .displayText('3')
        .clickMenuScreen('Inventory UOM')
         .waitUntilLoaded()
        .filterGridRecords('UOM', 'FilterGrid', '10lb bag2')
        // .enterData('Text Field','FilterGrid','50lb bag2' )
        // .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdUOM').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 10lb bag2 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid').waitUntilLoaded().waitUntilLoaded()
                    .clickButton('InsertUOM')
                    .addFunction(function(next){
                        var win = Ext.WindowManager.getActive();
                        var recCount = win.down('#grdUOM').store.getCount();
                        new iRely.FunctionalTest().start(t, next)
                        .enterGridData('UOM', recCount, 'strUnitMeasure', '10lb bag2')
                        .enterGridData('UOM', recCount, 'strSymbol', '10lb bag2')
                        .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                        .clickButton('InsertConversion')
                        .selectGridComboBoxRowValue('Conversion',1,'colConversionTo','LB2','strUnitMeasure',1)
                        .waitUntilLoaded()
                        .enterGridData('Conversion', 1, 'dblConversionToStock', '10')
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .verifyStatusMessage('Saved')
                        .waitUntilLoaded()
                        
                        .done()
                    })
                    .done();
                   
                },
                continueOnFail: true   
        })
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('4')
        .clickMenuScreen('Inventory UOM')
         .waitUntilLoaded()
        .filterGridRecords('UOM', 'FilterGrid', 'KG2')
        // .enterData('Text Field','FilterGrid','50lb bag2' )
        // .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdUOM').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM KG2 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid').waitUntilLoaded().waitUntilLoaded()
                    .clickButton('InsertUOM')
                    .addFunction(function(next){
                        var win = Ext.WindowManager.getActive();
                        var recCount = win.down('#grdUOM').store.getCount();
                        new iRely.FunctionalTest().start(t, next)
                        .enterGridData('UOM', recCount, 'strUnitMeasure', 'KG2')
                        .enterGridData('UOM', recCount, 'strSymbol', 'KG2')
                        .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                        .clickButton('InsertConversion')
                        .selectGridComboBoxRowValue('Conversion',1,'colConversionTo','LB2','strUnitMeasure',1)
                        .waitUntilLoaded()
                        .enterGridData('Conversion', 1, 'dblConversionToStock', .0453592)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .verifyStatusMessage('Saved')
                        .waitUntilLoaded()
                        
                        .done()
                    })
                    .done();
                   
                },
                continueOnFail: true   
        })
        .clickButton('Close')
        .displayText('5')
         .clickMenuScreen('Inventory UOM')
      
        .waitUntilLoaded()
        //.doubleClickSearchRowValue('LB2', 'strUnitMeasure', 1)
         //.filterGridRecords('UOM', 'FilterGrid', 'KG2')
        .waitUntilLoaded()
        .filterGridRecords('UOM', 'FilterGrid', 'LB2')
        // .enterData('Text Field','FilterGrid','KG2' )
        // .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        // .continueIf({
        //         expected: true,
        //         actual: function (win) {
        //             return win.down('#grdConversion').getStore().getCount() !== 0;
        //         },
        //         success: function (next) {
        //             new iRely.FunctionalTest().start(t, next)
        //             .addResult('UOM KG2 exists.')
        //             .done();
        //         },
        //         failure: function(next){
        //             new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM KG1 does not exists.')
                    .addStep('Add UOM LB2')
                    //.clearTextFilter('FilterGrid')
                    .selectGridRowValue('UOM','LB2')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                     .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    // .addFunction(function (next) {
                    // t.chain(
                    //     { click : "#frmInventoryUOM #tabInventoryUOM #grdUOM #grvUOM => .x-grid-cell-colUOM .x-grid-cell-inner" }
                    // )
                    // next();
                    // })
                    //.clickButton('InsertConversion')
                    .selectGridComboBoxRowValue('Conversion',1,'colConversionTo', 'KG2' ,'strStockUOM',1)
                    .enterGridData('Conversion',1,'colConversion',.0453592+'[ENTER]')
                    .clearTextFilter('FilterGrid') 
                    .clickButton('Save')
                    //.done()    
        //         },
        //         continueOnFail: true   
        // })
          .waitUntilLoaded()
        .clickButton('Close')
        .displayText('6')
            .clickMenuScreen('Inventory UOM')
      .waitUntilLoaded()
        //.clickButton('Close')
        // .enterData('Text Field','FilterGrid','10lb bag2' )
        // .enterData('Text Field','FilterGrid','[ENTER]' )
         .filterGridRecords('UOM', 'FilterGrid', 'LB2')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        // .continueIf({
        //         expected: true,
        //         actual: function (win) {
        //             return win.down('#grdConversion').getStore().getCount() !== 0;
        //         },
        //         success: function (next) {
        //             new iRely.FunctionalTest().start(t, next)
        //             .addResult('UOM KG2 bag2 exists.')
        //             .done();
        //         },
        //         failure: function(next){
        //             new iRely.FunctionalTest().start(t, next)
        //             .addResult('UOM KG2 does not exists.')
        //             .addStep('Add UOM 10lb bag2')
                    //.clearTextFilter('FilterGrid')
                    .selectGridRowValue('UOM','LB2')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                     .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    // .addFunction(function (next) {
                    // t.chain(
                    //     { click : "#frmInventoryUOM #tabInventoryUOM #grdUOM #grvUOM => .x-grid-cell-colUOM .x-grid-cell-inner" }
                    // )
                    // next();
                    // })
                    //.clickButton('InsertConversion')
                    .selectGridComboBoxRowValue('Conversion',2,'colConversionTo', '10lb bag2' ,'strStockUOM',1)
                    .enterGridData('Conversion',2,'colConversion',10+'[ENTER]')
                    .clearTextFilter('FilterGrid') 
                    .clickButton('Save')
                    //.done()    
        //         },
        //         continueOnFail: true   
        // })
        
        .waitUntilLoaded()
        .clickButton('Close')
        .displayText('7')
            .clickMenuScreen('Inventory UOM')
      
        .waitUntilLoaded()
        //.enterData('Text Field','FilterGrid','50lb bag2' )
        .enterData('Text Field','FilterGrid','LB2' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        // .continueIf({
        //         expected: true,
        //         actual: function (win) {
        //             return win.down('#grdConversion').getStore().getCount() !== 0;
        //         },
        //         success: function (next) {
        //             new iRely.FunctionalTest().start(t, next)
        //             .addResult('UOM 50lb bag2 exists.')
        //             .done();
        //         },
        //         failure: function(next){
        //             new iRely.FunctionalTest().start(t, next)
        //             .addResult('UOM 50lb bag2 does not exists.')
        //             .addStep('Add UOM 50lb bag2')
                    //.clearTextFilter('FilterGrid')
                    .selectGridRowValue('UOM','LB2')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                     .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    // .addFunction(function (next) {
                    // t.chain(
                    //     { click : "#frmInventoryUOM #tabInventoryUOM #grdUOM #grvUOM => .x-grid-cell-colUOM .x-grid-cell-inner" }
                    // )
                    // next();
                    // })
                    //.clickButton('InsertConversion')
                    .selectGridComboBoxRowValue('Conversion',3,'colConversionTo', '50lb bag2' ,'strStockUOM',1)
                    .enterGridData('Conversion',3,'colConversion',50+'[ENTER]')
                    .clearTextFilter('FilterGrid') 
                    .clickButton('Save')
                    //.done()    
    //            },
    //             continueOnFail: true   
    //     })
        .waitUntilLoaded()
        // .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')

        .done()
    })
    .clickMenuScreen('Commodities')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .enterData('Text Field','From','Corn1' )
    .enterData('Text Field','From','[ENTER]' )
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .continueIf({
            expected: true,
            actual: function (win) {
                return win.down('#grdSearch').getStore().getCount() !== 0;
            },
            success: function (next) {
                new iRely.FunctionalTest().start(t, next)
                .addResult('Corn1 exists.')
               // .clearTextFilter('From')
                .done();
            },
            failure: function(next){
                new iRely.FunctionalTest().start(t, next)
                .addResult('Corn1 does not exists.')
                .addStep('Add Commodity Corn1')
                .clickButton('New')
                .waitUntilLoaded()
                .enterData('Text Field','CommodityCode','Corn1' )
                .enterData('Text Field','Description','Corn1 Description' )
                .enterGridNewRow('Uom', [{column: 'strUnitMeasure', data: 'LB2'}])
                .selectGridRowNumber('Uom', 1)
                .selectGridComboBoxRowValue('Uom',1,'colUOMCode', 'LB2' ,'strUnitMeasure',1)
                .clickGridCheckBox('Uom',1 , 'colUOMStockUnit', 'LB2', 'ysnStockUnit', true)
                .waitUntilLoaded()
                .selectGridComboBoxRowValue('Uom',2,'colUOMCode', 'KG2' ,'strUnitMeasure',1)
                .waitUntilLoaded()
                .selectGridComboBoxRowValue('Uom',3,'colUOMCode', '10lb bag2' ,'strUnitMeasure',1)
                .waitUntilLoaded()
                .selectGridComboBoxRowValue('Uom',4,'colUOMCode', '50lb bag2' ,'strUnitMeasure',1)
                .waitUntilLoaded()
                // .clickTab('Attribute')
                // .waitUntilLoaded()
                // .selectGridRowNumber('Origin', 1)
                // .waitUntilLoaded()
                // .selectGridComboBoxRowValue('Origin',1,'colOrigin', 'Philippines' ,'strDescription',1)
                // .waitUntilLoaded()
                // .selectGridComboBoxRowValue('Origin',1,'colDefaultPackingUOM', '10lb bag2' ,'strDefaultPackingUOM',1)
                // .waitUntilLoaded()
                // .selectGridComboBoxRowValue('Origin',1,'colPurchasingGroup', 'South East Asian Group' ,'strPurchasingGroup',1)
                // .waitUntilLoaded()
                // .selectGridComboBoxRowValue('Origin',2,'colOrigin', 'United States' ,'strDescription',1)
                // .waitUntilLoaded()
                // .selectGridComboBoxRowValue('Origin',2,'colDefaultPackingUOM', '50lb bag2' ,'strDefaultPackingUOM',1)
                // .waitUntilLoaded()
                // .selectGridComboBoxRowValue('Origin',2,'colPurchasingGroup', 'North American Group' ,'strPurchasingGroup',1)
                // .waitUntilLoaded()
                // .selectGridComboBoxRowValue('Origin',3,'colOrigin', 'India' ,'strDescription',1)
                // .waitUntilLoaded()
                // .selectGridComboBoxRowValue('Origin',3,'colDefaultPackingUOM', '10lb bag2' ,'strDefaultPackingUOM',1)
                // .waitUntilLoaded()
                // .selectGridComboBoxRowValue('Origin',3,'colPurchasingGroup', 'South East Asian Group' ,'strPurchasingGroup',1)
                // .waitUntilLoaded()
                .clickButton('Save')
                .waitUntilLoaded()
                .clickButton('Close')
                .done()    
            },
            continueOnFail: true   
    })
    .waitUntilLoaded()
     .waitUntilLoaded()
      .waitUntilLoaded()
    .clickButton('Close')
    .addScenario('Pre-setup','Create Non Lotted Item',1000)
     .waitUntilLoaded()
     .waitUntilLoaded()
     
    .clickMenuScreen('Items')
    .waitUntilLoaded()
     .waitUntilLoaded()
    //   .waitUntilLoaded()
    //   .waitUntilLoaded()
    //.clickTab('Item')
    //.clearTextFilter('From')
    .waitUntilLoaded()
    .waitUntilLoaded()
    
    .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
    // .addFunction(function (next) {
    //                 t.chain(
    //                     { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch gridcolumn[text=Item No] => .x-column-header-text-wrapper" }
    //                 )
    //                 next();
    //             })
    // .waitUntilLoaded()
    // .waitUntilLoaded()
    // .waitUntilLoaded()
    // .addFunction(function (next) {
    //                 t.chain(
    //                    { click : "menu{isVisible()} #mnuFilter => .x-menu-item-text"}
    //                 )
    //                 next();
    //             })
    .waitUntilLoaded()
    .selectComboBoxRowNumber('Condition',2)             
    .enterData('Text Field','From','NLTI-01' )
    .enterData('Text Field','From','[ENTER]' )
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .continueIf({
            expected: true,
            actual: function (win) {
                return win.down('#grdSearch').getStore().getCount() !== 0;
            },
            success: function (next) {
                new iRely.FunctionalTest().start(t, next)
                .addScenario('Duplicate NLTI-01 to ' + productID ,'',1000)              
                .addResult('Inventory NLTI-01 exists.')
                .doubleClickSearchRowValue ('NLTI-01','strItemNo',1)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickButton('Duplicate')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                
                .waitUntilLoaded()
                .waitUntilLoaded()
                .enterData('Text Field','ItemNo',productID)
                .enterData('Text Field','Description','Inventory ' + productID +' Desc' )
                .clickTab('Pricing')
                .waitUntilLoaded()
                .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
                .enterGridData('Pricing', 1, 'dblLastCost', '10')
                .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                .enterGridData('Pricing', 1, 'dblAmountPercent', '40')
                .waitUntilLoaded()
                .clickButton('Save')
                .waitUntilLoaded()
                .clickButton('Close')
                .done()
            },
            failure: function(next){
                new iRely.FunctionalTest().start(t, next)
                .addResult('Inventory NLTI-01 does not exists.')
                .addStep('Add Inventory NLTI-01 ')
                .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded()
                .clickButton('Delete')
                .waitUntilLoaded()
                .addFunction(function(next){
                    var msg = document.querySelector('.sweet-alert'),
                        message = msg.querySelector('p').innerHTML;
                    if (msg){
                        if(msg.querySelector('p').innerHTML === message){
                        new iRely.FunctionalTest().start(t, next)
                        .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                        .displayText(msg.querySelector('p').innerHTML)
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .clickMessageBoxButton('yes')
                        .done()
                        }else{
                            new iRely.FunctionalTest().start(t, next)
                            .displayText('Skip message')
                            .done()
                        }
                    
                    }
                })
                .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded()
                .enterData('Text Field','ItemNo','NLTI-01' )
                .selectComboBoxRowNumber('Type',1)
                .waitUntilLoaded()
              
                .waitUntilLoaded()
                //.clickButton('Save')
                .selectComboBoxRowValue('Commodity', 'Corn1', 'CommodityId',1)
                .selectComboBoxRowValue('Category', 'Grains', 'CategoryId',1)
                .enterData('Text Field','Description','Inventory NLTI-01 Desc' )
                .selectComboBoxRowNumber('LotTracking',5)
                .waitUntilLoaded()
                //.clickButton('Save')
                .waitUntilLoaded() 
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
                .waitUntilLoaded()
                .clickTab('Location')
                .waitUntilLoaded()
                .clickButton('AddLocation')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .selectComboBoxRowValue('Location', '0001-Fort Wayne', 'LocationId',1)
                .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocationId',1)
                .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocationId',1)
                .selectComboBoxRowNumber('NegativeInventory',2) 
                .clickButton('Save')
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()    
                
                .clickTab('Contract Item')    
                .addFunction(function (next) {
                    t.chain(
                        { click : "#frmItem #tabItem #pgeSetup #tabSetup #pgeContract #grdCertification #colCertification => .x-column-header-text" }
                    )
                    next();
                })
                .waitUntilLoaded()
                .addFunction(function (next) {
                    t.chain(
                        { click : "menu{isVisible()} #mnuHeaderDrillDown => .x-menu-item-text"}
                    )
                    next();
                })
                
                .waitUntilLoaded()
                .waitUntilLoaded('iccertificationprogram')
                .isControlVisible('textfield',['Certification Code','txtCertificationCode'],'true')
                .addFunction(function(next){
                    var record=Math.floor((Math.random() * 1000000) + 1);
                    var d = new Date();
                    var certCode = 'CODE-' + ' ' + record + ' ' + d.toLocaleDateString('en-US') ;
                    new iRely.FunctionalTest().start(t, next)
                    .enterData('Text Field','CertificationProgram','CertProg'+ record + ' ' + d.toLocaleDateString('en-US'))
                    .enterData('Text Field','IssuingOrganization','IssueOrg1'+ record + ' ' + d.toLocaleDateString('en-US'))
                    .enterData('Text Field','CertificationCode',certCode)
                    .waitUntilLoaded()
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickButton('InsertCertification')
                    .waitUntilLoaded()
                    //.selectComboBoxRowValue('Certification', 'CertProg'+ record + ' ' + d.toLocaleDateString('en-US'), 'strCertificationName',1)
                    .selectGridComboBoxRowValue('Certification', 1, 'colCertification',  'CertProg'+ record + ' ' + d.toLocaleDateString('en-US'), 'strCertificationName')
                    .done()
                })
                .waitUntilLoaded()
                .clickTab('Pricing')
                .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
                .enterGridData('Pricing', 1, 'dblLastCost', '10')
                .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                .enterGridData('Pricing', 1, 'dblAmountPercent', '40')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickButton('Save')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickTab('Details')
                .waitUntilLoaded()
                .clickButton('Duplicate')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .enterData('Text Field','ItemNo',productID)
                .enterData('Text Field','Description','Inventory ' + productID +' Desc' )
                .clickButton('Save')
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .done()    
            },
            continueOnFail: true   
    })
     .clickButton('Close')
    .addScenario('Pre-setup','Create Lotted Item',1000)
    .clickMenuScreen('Items')
    .waitUntilLoaded()
    //.clickTab('Item')
    //.clearTextFilter('FilterGrid')
    .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clearData('Text Field','From')
    .enterData('Text Field','From','LTI-01' )
    .enterData('Text Field','From','[ENTER]' )
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .continueIf({
            expected: true,
            actual: function (win) {
                return win.down('#grdSearch').getStore().getCount() !== 0;
            },
            success: function (next) {
                new iRely.FunctionalTest().start(t, next)
                .addScenario('Duplicate LTI-01 to ' + productID2 ,'',1000)              
                .addResult('Inventory LTI-01 exists.')
                .doubleClickSearchRowValue ('LTI-01','strItemNo',1)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickButton('Duplicate')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .enterData('Text Field','ItemNo',productID2)
                .enterData('Text Field','Description','Inventory ' + productID2 +' Desc' )
                .clickTab('Pricing')
                .waitUntilLoaded()
                .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
                .enterGridData('Pricing', 1, 'dblLastCost', '10')
                .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                .enterGridData('Pricing', 1, 'dblAmountPercent', '40')
                .waitUntilLoaded()
                .clickButton('Save')
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()
                // .addFunction(function (next) {
                //     t.chain(
                //         { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch #pnlFilter #con0 #filterDeleteButton => .small-delete" }
                //     )
                //     next();
                // })
                .done()
            },
            failure: function(next){
                new iRely.FunctionalTest().start(t, next)
                .addResult('Inventory LTI-01 does not exists.')
                .addStep('Add Inventory LTI-01 ')
                .clickButton('New')
                .waitUntilLoaded()
                .enterData('Text Field','ItemNo','LTI-01' )
                .selectComboBoxRowNumber('Type',1)
                .waitUntilLoaded()
               
                .waitUntilLoaded()
                .selectComboBoxRowValue('Category', 'Grains', 'CategoryId',1)
                .selectComboBoxRowValue('Commodity', 'Corn1', 'CommodityId',1)
                .enterData('Text Field','Description','Inventory LTI-01 Desc' )
                .selectComboBoxRowNumber('LotTracking',1) 
                .waitUntilLoaded()
                //.clickButton('Save')
                .waitUntilLoaded()
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
                .waitUntilLoaded()
                .clickTab('Location')
                .waitUntilLoaded()
                .clickButton('AddLocation')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .selectComboBoxRowValue('Location', '0001-Fort Wayne', 'LocationId',1)
                .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocationId',1)
                .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocationId',1)
                .selectComboBoxRowNumber('NegativeInventory',2) 
                .clickButton('Save')
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()    
                
                .clickTab('Contract Item')    
                .addFunction(function (next) {
                    t.chain(
                        { click : "#frmItem #tabItem #pgeSetup #tabSetup #pgeContract #grdCertification #colCertification => .x-column-header-text" }
                    )
                    next();
                })
                .waitUntilLoaded()
                .addFunction(function (next) {
                    t.chain(
                        { click : "menu{isVisible()} #mnuHeaderDrillDown => .x-menu-item-text"}
                    )
                    next();
                })
                
                .waitUntilLoaded()
                .waitUntilLoaded('iccertificationprogram')
                .isControlVisible('textfield',['Certification Code','txtCertificationCode'],'true')
                .addFunction(function(next){
                    var record=Math.floor((Math.random() * 1000000) + 1);
                    var d = new Date();
                    var certCode = 'CODE-' + ' ' + record + ' ' + d.toLocaleDateString('en-US') ;
                    new iRely.FunctionalTest().start(t, next)
                    .enterData('Text Field','CertificationProgram','CertProg'+ record + ' ' + d.toLocaleDateString('en-US'))
                    .enterData('Text Field','IssuingOrganization','IssueOrg1'+ record + ' ' + d.toLocaleDateString('en-US'))
                    .enterData('Text Field','CertificationCode',certCode)
                    .waitUntilLoaded()
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickButton('InsertCertification')
                    .waitUntilLoaded()
                    //.selectComboBoxRowValue('Certification', 'CertProg'+ record + ' ' + d.toLocaleDateString('en-US'), 'strCertificationName',1)
                    .selectGridComboBoxRowValue('Certification', 1, 'colCertification',  'CertProg'+ record + ' ' + d.toLocaleDateString('en-US'), 'strCertificationName')
                    .done()
                })
                .waitUntilLoaded()
                .clickTab('Pricing')
                .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
                .enterGridData('Pricing', 1, 'dblLastCost', '10')
                .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                .enterGridData('Pricing', 1, 'dblAmountPercent', '40')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickButton('Save')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickTab('Details')
                .waitUntilLoaded()
                .clickButton('Duplicate')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .enterData('Text Field','ItemNo',productID2)
                .enterData('Text Field','Description','Inventory ' + productID2 +' Desc' )
                .waitUntilLoaded()
                .clickTab('Pricing')
                .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
                .enterGridData('Pricing', 1, 'dblLastCost', '10')
                .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                .enterGridData('Pricing', 1, 'dblAmountPercent', '40')
                .clickButton('Save')
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()
                // .addFunction(function (next) {
                //     t.chain(
                //         { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch #pnlFilter #con0 #filterDeleteButton => .small-delete" }
                //     )
                //     next();
                // })
                .done()

            },
            continueOnFail: true   
    })
     .waitUntilLoaded() .waitUntilLoaded()
     .clickButton('Close')
    .addScenario('1','Create Direct Inventory Receipt',1000)
    .waitUntilLoaded()
    .clickMenuScreen('Inventory Receipts')
    .clickButton('New')
    .waitUntilLoaded('icinventoryreceipt')
    .selectComboBoxRowNumber('ReceiptType',4) 
    .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1) 
    .clickButton('InsertInventoryReceipt')
    .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colItemNo', productID2, 'strItemNo')
    .waitUntilLoaded()
    .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',100, 'LB2')
    .selectGridComboBoxRowValue('InventoryReceipt',1,'colSubLocation', 'Raw Station','strSubLocationName',1) 
    .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage', 'strStorageLocationName')
    .selectGridRowNumber('LotTracking', 1)
    .enterGridData('LotTracking',1,'colLotId','LOT-01' + '[TAB]')
    .enterGridData('LotTracking',1,'colLotQuantity',100 +'[ENTER]')
    .clickTab('Post Preview').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .displayText('Inventory Account')
    .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 1000)
    .displayText('AP Clearing Account')
    .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 1000)
    .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .clickTab('Unpost Preview').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .clickButton('Unpost').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .clickTab('Details')
    .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    //.isControlReadOnly('Button',['Return'],false)
    .isControlVisible('Button',['Return'],true)
    .waitUntilLoaded()
    .clickButton('Voucher')
    .waitUntilLoaded().waitUntilLoaded() .waitUntilLoaded().waitUntilLoaded()
    .addFunction(function(next){
            var msg = document.querySelector('.sweet-alert'),
                message = msg.querySelector('p').innerHTML;
            if (msg){
                if(msg.querySelector('p').innerHTML === message){
                new iRely.FunctionalTest().start(t, next)
                .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                .displayText(msg.querySelector('p').innerHTML)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickMessageBoxButton('yes')
                .done()
                }else{
                    new iRely.FunctionalTest().start(t, next)
                    .displayText('Skip message')
                    .done()
                }
            
            }
     })
    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .enterData('Text Field','InvoiceNo',randomNo )
    .selectComboBoxRowValue('PayToAddress', 'ABC Trucking', 'PayTo',1) 
    .clickButton('Post')
    .waitUntilLoaded()
    .clickButton('Close') 
    .waitUntilLoaded()
    .clickButton('Close') 
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickMenuScreen('Items')
    .waitUntilLoaded()
    //.clickTab('Item')
    
    .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
    .waitUntilLoaded()        
    .clearTextFilter('FilterGrid')
    .waitUntilLoaded()
    .waitUntilLoaded()
    // .enterData('Text Field','From',productID2 )
    // .enterData('Text Field','From','[ENTER]' )

    .doubleClickSearchRowValue (productID2,'strItemNo',1)
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickTab('Stock')
    .waitUntilLoaded()
    .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 100)
    .verifyGridData ('Stock', 1 ,'dblAvailable' , 100)
    .waitUntilLoaded()
    .clickButton('Close')

    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .clickMenuScreen('Inventory Receipts')
    .waitUntilLoaded()
    .doubleClickSearchRowNumber (1)
    .waitUntilLoaded()
     .waitUntilLoaded()
    .clickButton('Return')
    .addFunction(function(next){
            var msg = document.querySelector('.sweet-alert'),
                message = msg.querySelector('p').innerHTML;
            if (msg){
                if(msg.querySelector('p').innerHTML === message){
                new iRely.FunctionalTest().start(t, next)
                .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                .displayText(msg.querySelector('p').innerHTML)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickMessageBoxButton('yes')
                .done()
                }else{
                    new iRely.FunctionalTest().start(t, next)
                    .displayText('Skip message')
                    .done()
                }
            
            }
     })
    .waitUntilLoaded()
    .addFunction(function(next){
            var msg = document.querySelector('.sweet-alert'),
                message = msg.querySelector('p').innerHTML;
            if (msg){
                if(msg.querySelector('p').innerHTML === message){
                new iRely.FunctionalTest().start(t, next)
                .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                .displayText(msg.querySelector('p').innerHTML)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickMessageBoxButton('yes')
                .done()
                }else{
                    new iRely.FunctionalTest().start(t, next)
                    .displayText('Skip message')
                    .done()
                }
            
            }
     })
     .waitUntilLoaded()
    .selectGridRowNumber('InventoryReceipt', 1)
    .waitUntilLoaded()
    .verifyData('Combo Box', 'ReceiptType', 'Inventory Return', 'equal')
    .waitUntilLoaded()
    .verifyData('Combo Box', 'SourceType', 'None', 'equal')
    .waitUntilLoaded()
    .verifyData('Combo Box', 'Vendor', 'ABC Trucking', 'equal')
    .waitUntilLoaded()
    .verifyData('Combo Box', 'Location', '0001-Fort Wayne', 'equal')
    .waitUntilLoaded()
    .verifyData('Text Field','ReceiptNumber', 'RTN-','like')
    .waitUntilLoaded()
    .verifyGridData ('InventoryReceipt', 1 ,'dblOrderQty' , 0,'equal')
    .waitUntilLoaded()
    .verifyGridData ('InventoryReceipt', 1 ,'dblReceived' ,0,'equal')
    .waitUntilLoaded()
    .verifyUOMGridData('InventoryReceipt', 1, 'dblOpenReceive', 100, 'LB2', 'equal')
    .waitUntilLoaded()
    .verifyGridData ('InventoryReceipt', 1 ,'dblUnitCost' , 10,'equal')
    .selectGridRowNumber('InventoryReceipt', 1)
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblQuantity' , 100,'equal')//100         
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblGrossWeight' , 100,'equal')//100
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblTareWeight' , 0,'equal')  
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblNetWeight' ,100,'equal')//100
    .waitUntilLoaded()
    // .addFunction(function (next){
    //     var today =  new Date().toLocaleDateString();
    //     var engine = new iRely.FunctionalTest();
    //     engine.start(t,next)
    //         .displayText('Checks if the Post Date is set to current system date.')
    //         .displayText(today.toLocaleDateString)
    //         .verifyData('Date Field', 'ReceiptDate', today, 'equal')
    //         .done()
    // })
    .isControlReadOnly('Combo Box',['ReceiptType','SourceType','Vendor','Location', 'Currency','Receiver','ShipFrom','ShipVia','FreightTerms'],true)
    .isControlReadOnly('Text Field',['ReceiptNumber','BillOfLadingNumber','VendorRefNumber','WarehouseRefNo', 'FobPoint','Vessel','ShiftNumber'],true)
    .waitUntilLoaded()
    .clickButton('Save')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickTab('Post Preview')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickButton('Post')
    .waitUntilLoaded()
    .clickButton('Close')
     .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .clickMenuScreen('Items')
    .waitUntilLoaded()
    .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
    .waitUntilLoaded()
    // .clickTab('Item')
    // .clearTextFilter('FilterGrid')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .continueIf({
            expected: true,
            actual: function (win) {
                return win.down('#grdSearch').getStore().getCount() !== 0;
            },
            success: function (next) {
                new iRely.FunctionalTest().start(t, next)
                .doubleClickSearchRowValue (productID2,'strItemNo',1)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickTab('Stock')
                .waitUntilLoaded()
                .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 0)
                .verifyGridData ('Stock', 1 ,'dblAvailable' , 0)
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()
                .done()
            }
    })
    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickMenuScreen('Inventory Receipts')
    .waitUntilLoaded()
    .clickButton('Refresh')
    .waitUntilLoaded()
    .doubleClickSearchRowNumber (2)
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickButton('Return')
    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .addFunction(function(next){
                    var msg = document.querySelector('.sweet-alert'),
                        message = msg.querySelector('p').innerHTML;
                    if (msg){
                        if(msg.querySelector('p').innerHTML === message){
                        new iRely.FunctionalTest().start(t, next)
                        .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'ok', 'error')
                        .displayText(msg.querySelector('p').innerHTML)
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .clickMessageBoxButton('ok')
                        .done()
                        }else{
                            new iRely.FunctionalTest().start(t, next)
                            .displayText('Skip message')
                            .done()
                        }
                    
                    }
                })
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickButton('Close') 
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .addScenario('2','Create Direct Inventory Receipt',1000)
    .clickButton('Close') 
    .waitUntilLoaded()
    .clickMenuScreen('Inventory Receipts')
    .clickButton('New')
    .waitUntilLoaded('icinventoryreceipt')
    .selectComboBoxRowNumber('ReceiptType',4) 
    .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1) 
    .clickButton('InsertInventoryReceipt')
    .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colItemNo', productID2, 'strItemNo')
    .waitUntilLoaded().waitUntilLoaded()
    .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',100, 'LB2')
    .enterGridData('InventoryReceipt',1,'colUnitCost',10)
    .selectGridComboBoxRowValue('InventoryReceipt',1,'colSubLocation', 'Raw Station','strSubLocationName',1) 
    .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage', 'strStorageLocationName')
    .selectGridRowNumber('LotTracking', 1)
    .enterGridData('LotTracking',1,'colLotId','LOT-01' + '[TAB]')
    .enterGridData('LotTracking',1,'colLotQuantity',100 +'[ENTER]')
    .clickTab('Post Preview').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .displayText('Inventory Account')
    .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 1000)
    .displayText('AP Clearing Account')
    .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 1000)
    .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .clickTab('Unpost Preview').waitUntilLoaded().waitUntilLoaded()
    .clickButton('Unpost').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .clickTab('Details')
    .clickButton('Post')
    .waitUntilLoaded().waitUntilLoaded()
    .addScenario('2','Create Inventory Return',1000)
    .clickButton('Return')
    .waitUntilLoaded().waitUntilLoaded()
    .addFunction(function(next){
            var msg = document.querySelector('.sweet-alert'),
                message = msg.querySelector('p').innerHTML;
            if (msg){
                if(msg.querySelector('p').innerHTML === message){
                new iRely.FunctionalTest().start(t, next)
                .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                .displayText(msg.querySelector('p').innerHTML)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickMessageBoxButton('yes')
                .done()
                }else{
                    new iRely.FunctionalTest().start(t, next)
                    .displayText('Skip message')
                    .done()
                }
            
            }
     })
    .waitUntilLoaded()
    .addFunction(function(next){
            var msg = document.querySelector('.sweet-alert'),
                message = msg.querySelector('p').innerHTML;
            if (msg){
                if(msg.querySelector('p').innerHTML === message){
                new iRely.FunctionalTest().start(t, next)
                .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                .displayText(msg.querySelector('p').innerHTML)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickMessageBoxButton('yes')
                .done()
                }else{
                    new iRely.FunctionalTest().start(t, next)
                    .displayText('Skip message')
                    .done()
                }
            
            }
     })
     .waitUntilLoaded()
    .selectGridRowNumber('InventoryReceipt', 1)
    .waitUntilLoaded()
    .verifyData('Combo Box', 'ReceiptType', 'Inventory Return', 'equal')
    .waitUntilLoaded()
    .verifyData('Combo Box', 'SourceType', 'None', 'equal')
    .waitUntilLoaded()
    .verifyData('Combo Box', 'Vendor', 'ABC Trucking', 'equal')
    .waitUntilLoaded()
    .verifyData('Combo Box', 'Location', '0001-Fort Wayne', 'equal')
    .waitUntilLoaded()
    .verifyData('Text Field','ReceiptNumber', 'RTN-','like')
    .waitUntilLoaded()
    .verifyGridData ('InventoryReceipt', 1 ,'dblOrderQty' , 0,'equal')
    .waitUntilLoaded()
    .verifyGridData ('InventoryReceipt', 1 ,'dblReceived' ,0,'equal')
    .waitUntilLoaded()
    .verifyUOMGridData('InventoryReceipt', 1, 'dblOpenReceive', 100, 'LB2', 'equal')
    .waitUntilLoaded()
    .selectGridRowNumber('InventoryReceipt',1)
    .waitUntilLoaded()
    .addFunction(function (next) {
        t.chain(
            { click : "#frmInventoryReceipt #tabInventoryReceipt #pgeDetails #pnlItem #grdInventoryReceipt #grvInventoryReceipt => .x-grid-item:nth-of-type(1) .x-grid-cell-colUOMQtyToReceive .x-grid-cell-inner" }
        )
        next();
    })
    .waitUntilLoaded().waitUntilLoaded()
    .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',50, 'LB2')
    .waitUntilLoaded()
    .enterGridData('InventoryReceipt',1,'colGross',50)
    .verifyGridData ('InventoryReceipt', 1 ,'dblUnitCost' , 10,'equal')
    .selectGridRowNumber('InventoryReceipt', 1)
    .waitUntilLoaded()
    //.verifyGridData ('LotTracking', 1 ,'dblQuantity' , 100,'equal')//100         
    .waitUntilLoaded()
    .enterGridData('LotTracking',1,'dblQuantity',50)
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblGrossWeight' , 50,'equal')//100
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblTareWeight' , 0,'equal')  
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblNetWeight' ,50,'equal')//100
    .waitUntilLoaded()
    // .addFunction(function (next){
    //     var today =  new Date().toLocaleDateString();
    //     today=Ext.Date.format(today,'m/d/Y');
    //     var engine = new iRely.FunctionalTest();
    //     engine.start(t,next)
    //         .displayText('Checks if the Post Date is set to current system date.')
    //         .displayText(today)
    //         .verifyData('Date Field', 'ReceiptDate', today, 'equal')
    //         .done()
    // })
    .isControlReadOnly('Combo Box',['ReceiptType','SourceType','Vendor','Location', 'Currency','Receiver','ShipFrom','ShipVia','FreightTerms'],true)
    .isControlReadOnly('Text Field',['ReceiptNumber','BillOfLadingNumber','VendorRefNumber','WarehouseRefNo', 'FobPoint','Vessel','ShiftNumber'],true)
    .waitUntilLoaded()
    .clickButton('Save')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickTab('Post Preview')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .displayText('Inventory Account')
    .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 500)
    .displayText('AP Clearing Account')
    .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 500)
    .clickButton('Post')
    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
     .addScenario('2','Check Stock on hand',1000)
    .clickMenuScreen('Items')
    .waitUntilLoaded()
    //.clickTab('Item')
    .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
    .waitUntilLoaded()
    .clearTextFilter('FilterGrid')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .continueIf({
            expected: true,
            actual: function (win) {
                return win.down('#grdSearch').getStore().getCount() !== 0;
            },
            success: function (next) {
                new iRely.FunctionalTest().start(t, next)
                .doubleClickSearchRowValue (productID2,'strItemNo',1)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickTab('Stock')
                .waitUntilLoaded()
                .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 50)
                .verifyGridData ('Stock', 1 ,'dblAvailable' , 50)
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()
                .done()
            }
    })
    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .clickMenuScreen('Inventory Receipts')
    .waitUntilLoaded()
    .clickButton('Refresh')
    .waitUntilLoaded()
    .doubleClickSearchRowNumber (2)

    .waitUntilLoaded().waitUntilLoaded()
    .addScenario('2','Create Inventory Return 2',1000)
    .clickButton('Return')
    .waitUntilLoaded().waitUntilLoaded()
    .addFunction(function(next){
            var msg = document.querySelector('.sweet-alert'),
                message = msg.querySelector('p').innerHTML;
            if (msg){
                if(msg.querySelector('p').innerHTML === message){
                new iRely.FunctionalTest().start(t, next)
                .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                .displayText(msg.querySelector('p').innerHTML)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickMessageBoxButton('yes')
                .done()
                }else{
                    new iRely.FunctionalTest().start(t, next)
                    .displayText('Skip message')
                    .done()
                }
            
            }
     })
    .waitUntilLoaded()
    .addFunction(function(next){
            var msg = document.querySelector('.sweet-alert'),
                message = msg.querySelector('p').innerHTML;
            if (msg){
                if(msg.querySelector('p').innerHTML === message){
                new iRely.FunctionalTest().start(t, next)
                .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                .displayText(msg.querySelector('p').innerHTML)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickMessageBoxButton('yes')
                .done()
                }else{
                    new iRely.FunctionalTest().start(t, next)
                    .displayText('Skip message')
                    .done()
                }
            
            }
     })
     .waitUntilLoaded()
    .selectGridRowNumber('InventoryReceipt', 1)
    .waitUntilLoaded()
    .verifyData('Combo Box', 'ReceiptType', 'Inventory Return', 'equal')
    .waitUntilLoaded()
    .verifyData('Combo Box', 'SourceType', 'None', 'equal')
    .waitUntilLoaded()
    .verifyData('Combo Box', 'Vendor', 'ABC Trucking', 'equal')
    .waitUntilLoaded()
    .verifyData('Combo Box', 'Location', '0001-Fort Wayne', 'equal')
    .waitUntilLoaded()
    .verifyData('Text Field','ReceiptNumber', 'RTN-','like')
    .waitUntilLoaded()
    .verifyGridData ('InventoryReceipt', 1 ,'dblOrderQty' , 0,'equal')
    .waitUntilLoaded()
    .verifyGridData ('InventoryReceipt', 1 ,'dblReceived' ,0,'equal')
    .waitUntilLoaded()
    .verifyUOMGridData('InventoryReceipt', 1, 'dblOpenReceive', 50, 'LB2', 'equal')
    .waitUntilLoaded()
    .selectGridRowNumber('InventoryReceipt',1)
    .waitUntilLoaded()
    .addFunction(function (next) {
        t.chain(
            { click : "#frmInventoryReceipt #tabInventoryReceipt #pgeDetails #pnlItem #grdInventoryReceipt #grvInventoryReceipt => .x-grid-item:nth-of-type(1) .x-grid-cell-colUOMQtyToReceive .x-grid-cell-inner" }
        )
        next();
    })
    .waitUntilLoaded().waitUntilLoaded()
    .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',50, 'LB2')
    .waitUntilLoaded()
    .enterGridData('InventoryReceipt',1,'colGross',50)
    .verifyGridData ('InventoryReceipt', 1 ,'dblUnitCost' , 10,'equal')
    .selectGridRowNumber('InventoryReceipt', 1)
    .waitUntilLoaded()
    //.verifyGridData ('LotTracking', 1 ,'dblQuantity' , 100,'equal')//100         
    .waitUntilLoaded()
    .enterGridData('LotTracking',1,'dblQuantity',50)
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblGrossWeight' , 50,'equal')//100
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblTareWeight' , 0,'equal')  
    .waitUntilLoaded()
    .verifyGridData ('LotTracking', 1 ,'dblNetWeight' ,50,'equal')//100
    .waitUntilLoaded()
    // .addFunction(function (next){
    //     var today =  new Date().toLocaleDateString();
    //     today=Ext.Date.format(today,'m/d/Y');
    //     var engine = new iRely.FunctionalTest();
    //     engine.start(t,next)
    //         .displayText('Checks if the Post Date is set to current system date.')
    //         .displayText(today)
    //         .verifyData('Date Field', 'ReceiptDate', today, 'equal')
    //         .done()
    // })
    .isControlReadOnly('Combo Box',['ReceiptType','SourceType','Vendor','Location', 'Currency','Receiver','ShipFrom','ShipVia','FreightTerms'],true)
    .isControlReadOnly('Text Field',['ReceiptNumber','BillOfLadingNumber','VendorRefNumber','WarehouseRefNo', 'FobPoint','Vessel','ShiftNumber'],true)
    .waitUntilLoaded()
    .clickButton('Save')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickTab('Post Preview')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .displayText('Inventory Account')
    .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 500)
    .displayText('AP Clearing Account')
    .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 500)
    .clickButton('Post')
    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .addScenario('2','Check Stock 2',1000)
    .clickMenuScreen('Items')
    .waitUntilLoaded()
    //.clickTab('Item')
    .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
    .waitUntilLoaded()
    .clearTextFilter('FilterGrid')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .continueIf({
            expected: true,
            actual: function (win) {
                return win.down('#grdSearch').getStore().getCount() !== 0;
            },
            success: function (next) {
                new iRely.FunctionalTest().start(t, next)
                .doubleClickSearchRowValue (productID2,'strItemNo',1)
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickTab('Stock')
                .waitUntilLoaded()
                .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 0)
                .verifyGridData ('Stock', 1 ,'dblAvailable' , 0)
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()
                .done()
            }
    })
    .waitUntilLoaded()
    .clickButton('Close')
    .addScenario('2','Try to over Return',1000)
    //.clickMenuFolder('Inventory')
    .waitUntilLoaded()
    //.clickMenuFolder('Inventory')
    .clickMenuScreen('Inventory Receipts')
    .waitUntilLoaded()
    .clickButton('Refresh')
    .waitUntilLoaded()
    .doubleClickSearchRowNumber (3)
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickButton('Return')
    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .addFunction(function(next){
                    var msg = document.querySelector('.sweet-alert'),
                        message = msg.querySelector('p').innerHTML;
                    if (msg){
                        if(msg.querySelector('p').innerHTML === message){
                        new iRely.FunctionalTest().start(t, next)
                        .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'ok', 'error')
                        .displayText(msg.querySelector('p').innerHTML)
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .clickMessageBoxButton('ok')
                        .done()
                        }else{
                            new iRely.FunctionalTest().start(t, next)
                            .displayText('Skip message')
                            .done()
                        }
                    
                    }
                })
    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .clickMenuScreen('Inventory Receipts')
    .waitUntilLoaded()
    .clickButton('Refresh')
    .waitUntilLoaded()
    .doubleClickSearchRowNumber (2)
       .addScenario('2','Convert to Debit Memo',1000)
    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()   
    .clickButton('DebitMemo')
    .addFunction(function(next){
                    var msg = document.querySelector('.sweet-alert'),
                        message = msg.querySelector('p').innerHTML;
                    if (msg){
                        if(msg.querySelector('p').innerHTML === message){
                        new iRely.FunctionalTest().start(t, next)
                        .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                        .displayText(msg.querySelector('p').innerHTML)
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .clickMessageBoxButton('yes')
                        .done()
                        }else{
                            new iRely.FunctionalTest().start(t, next)
                            .displayText('Skip message')
                            .done()
                        }
                    
                    }
                })
    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .clickButton('Save') 
    .waitUntilLoaded()
    .clickButton('Post')                            
    .waitUntilLoaded()
    .clickButton('Close') 
    .waitUntilLoaded()
    .clickButton('Close') 
    .waitUntilLoaded()
    .addScenario('2','Unpost Inventory Return with existing Debit Memo',1000)
    .clickMenuScreen('Inventory Receipts')
    .waitUntilLoaded()
    .clickButton('Refresh')
    .waitUntilLoaded()
    .doubleClickSearchRowNumber (2)
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .clickButton('Unpost')
    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .addFunction(function(next){
                    var msg = document.querySelector('.sweet-alert'),
                        message = msg.querySelector('p').innerHTML;
                    if (msg){
                        if(msg.querySelector('p').innerHTML === message){
                        new iRely.FunctionalTest().start(t, next)
                        .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'ok', 'error')
                        .displayText(msg.querySelector('p').innerHTML)
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .clickMessageBoxButton('ok')
                        .done()
                        }else{
                            new iRely.FunctionalTest().start(t, next)
                            .displayText('Skip message')
                            .done()
                        }
                    
                    }
                })
    .waitUntilLoaded()
    .addScenario('2','Create Debit Memo for Returns with Debit Memo already',1000)
     .waitUntilLoaded()
    .clickButton('DebitMemo')
    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
    .addFunction(function(next){
                    var msg = document.querySelector('.sweet-alert'),
                        message = msg.querySelector('p').innerHTML;
                    if (msg){
                        if(msg.querySelector('p').innerHTML === message){
                        new iRely.FunctionalTest().start(t, next)
                        .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'ok', 'error')
                        .displayText(msg.querySelector('p').innerHTML)
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .clickMessageBoxButton('ok')
                        .done()
                        }else{
                            new iRely.FunctionalTest().start(t, next)
                            .displayText('Skip message')
                            .done()
                        }
                    
                    }
                })
    .waitUntilLoaded()
    .clickButton('Close')
    .waitUntilLoaded()
    .clickButton('Close')
    .done()
   
    
})
