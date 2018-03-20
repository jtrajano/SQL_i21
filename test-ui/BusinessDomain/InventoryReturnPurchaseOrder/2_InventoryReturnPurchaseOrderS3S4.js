StartTest (function (t) {
    var myDate = new Date();
    var randomNo=Math.floor((Math.random() * 1000000) + 1);
    var productID = 'NLTI-'  + randomNo + ' ' + myDate.toLocaleDateString('en-US') ;
    
    randomNo=Math.floor((Math.random() * 1000000) + 1);
    var productID2 = 'LTI-'  + randomNo + ' ' + myDate.toLocaleDateString('en-US') ; 
    
    new iRely.FunctionalTest().start(t)
  
    //.addFunction(function(next){
    //    new iRely.FunctionalTest().start(t, next)
    //     .addScenario('Precondition Setup','UOM Setup',1000)
    //     .clickMenuFolder('Inventory')
    //     .clickMenuScreen('Inventory UOM')
    //     .waitUntilLoaded()
    //     .enterData('Text Field','FilterGrid','LB2' )
    //     .enterData('Text Field','FilterGrid','[ENTER]' )
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .continueIf({
    //             expected: true,
    //             actual: function (win) {
    //                 return win.down('#grdSearch').getStore().getCount() !== 0;
    //             },
    //             success: function (next) {
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM LB2 exists.')
    //                 .clearTextFilter('FilterGrid')
    //                 .done();
    //             },
    //             failure: function(next){
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM LB2 does not exists.')
    //                 .addStep('Add UOM LB2')
    //                 .clickButton('New')
    //                 .waitUntilLoaded()
    //                 .enterData('Text Field','UnitMeasure','LB2' )
    //                 .enterData('Text Field','Symbol','LB2' )
    //                 .selectComboBoxRowNumber('UnitType',6)
    //                 .clickButton('Save')
    //                 .waitUntilLoaded()
    //                 .clickButton('Close')
    //                 .done()    
    //             },
    //             continueOnFail: true   
    //     })  
    //     .waitUntilLoaded()
    //     .enterData('Text Field','FilterGrid','50lb bag2' )
    //     .enterData('Text Field','FilterGrid','[ENTER]' )
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .continueIf({
    //             expected: true,
    //             actual: function (win) {
    //                 return win.down('#grdSearch').getStore().getCount() !== 0;
    //             },
    //             success: function (next) {
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM 50lb bag2 exists.')
    //                 .clearTextFilter('FilterGrid')
    //                 .done();
    //             },
    //             failure: function(next){
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM 50lb bag2 does not exists.')
    //                 .addStep('Add UOM 50lb bag2')
    //                 .clickButton('New')
    //                 .waitUntilLoaded()
    //                 .enterData('Text Field','UnitMeasure','50lb bag2' )
    //                 .enterData('Text Field','Symbol','50lb bag2' )
    //                 .selectComboBoxRowNumber('UnitType',7)
    //                 .clickButton('InsertConversion')
    //                 .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM', 'LB2' ,'strUnitMeasure',1)
    //                 .enterGridData('Conversion',1,'colConversionToStockUOM',50) 
    //                 .clickButton('Save')
    //                 .waitUntilLoaded()
    //                 .clickButton('Close')
    //                 .done()    
    //             },
    //             continueOnFail: true   
    //     })
    //     .waitUntilLoaded()
    //     .enterData('Text Field','FilterGrid','10lb bag2' )
    //     .enterData('Text Field','FilterGrid','[ENTER]' )
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .continueIf({
    //             expected: true,
    //             actual: function (win) {
    //                 return win.down('#grdSearch').getStore().getCount() !== 0;
    //             },
    //             success: function (next) {
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM 20-lb bag1 exists.')
    //                 .clearTextFilter('FilterGrid')
    //                 .done();
    //             },
    //             failure: function(next){
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM 10lb bag2 does not exists.')
    //                 .addStep('Add UOM 10lb bag2')
    //                 .clickButton('New')
    //                 .waitUntilLoaded()
    //                 .enterData('Text Field','UnitMeasure','10lb bag2' )
    //                 .enterData('Text Field','Symbol','10lb bag2' )
    //                 .selectComboBoxRowNumber('UnitType',7)
    //                 .clickButton('InsertConversion')
    //                 .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM', 'LB2' ,'strUnitMeasure',1)
    //                 .enterGridData('Conversion',1,'colConversionToStockUOM',10) 
    //                 .clickButton('Save')
    //                 .waitUntilLoaded()
    //                 .clickButton('Close')
    //                 .done()    
    //             },
    //             continueOnFail: true   
    //     })
    //     .waitUntilLoaded()
    //     .enterData('Text Field','FilterGrid','KG2' )
    //     .enterData('Text Field','FilterGrid','[ENTER]' )
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .continueIf({
    //             expected: true,
    //             actual: function (win) {
    //                 return win.down('#grdSearch').getStore().getCount() !== 0;
    //             },
    //             success: function (next) {
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM KG2 exists.')
    //                 .clearTextFilter('FilterGrid')
    //                 .done();
    //             },
    //             failure: function(next){
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM KG2 does not exists.')
    //                 .addStep('Add UOM KG2')
    //                 .clickButton('New')
    //                 .waitUntilLoaded()
    //                 .enterData('Text Field','UnitMeasure','KG2' )
    //                 .enterData('Text Field','Symbol','KG2' )
    //                 .selectComboBoxRowNumber('UnitType',6)
    //                 .clickButton('InsertConversion')
    //                 .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM', 'LB2' ,'strUnitMeasure',1)
    //                 .enterGridData('Conversion',1,'colConversionToStockUOM',.0453592) 
    //                 .clickButton('Save')
    //                 .waitUntilLoaded()
    //                 .clickButton('Close')
    //                 .done()    
    //             },
    //             continueOnFail: true   
    //     })
    //     .waitUntilLoaded()
    //     .doubleClickSearchRowValue('LB2', 'strUnitMeasure', 1)
    //     .waitUntilLoaded()
    //     .enterData('Text Field','FilterGrid','KG2' )
    //     .enterData('Text Field','FilterGrid','[ENTER]' )
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .continueIf({
    //             expected: true,
    //             actual: function (win) {
    //                 return win.down('#grdConversion').getStore().getCount() !== 0;
    //             },
    //             success: function (next) {
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM KG2 exists.')
    //                 .done();
    //             },
    //             failure: function(next){
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM KG1 does not exists.')
    //                 .addStep('Add UOM KG2')
    //                 .clearTextFilter('FilterGrid')
    //                 .clickButton('InsertConversion')
    //                 .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM', 'KG2' ,'strUnitMeasure',1)
    //                 .enterGridData('Conversion',1,'colConversionToStockUOM',.0453592+'[ENTER]')
    //                 .clearTextFilter('FilterGrid') 
                    
    //                 .done()    
    //             },
    //             continueOnFail: true   
    //     })
        
    //     .enterData('Text Field','FilterGrid','10lb bag2' )
    //     .enterData('Text Field','FilterGrid','[ENTER]' )
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .continueIf({
    //             expected: true,
    //             actual: function (win) {
    //                 return win.down('#grdConversion').getStore().getCount() !== 0;
    //             },
    //             success: function (next) {
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM 10lb bag2 exists.')
    //                 .done();
    //             },
    //             failure: function(next){
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM 10lb bag2 does not exists.')
    //                 .addStep('Add UOM 10lb bag2')
    //                 .clearTextFilter('FilterGrid')
    //                 .clickButton('InsertConversion')
    //                 .selectGridComboBoxRowValue('Conversion',2,'colOtherUOM', '10lb bag2' ,'strUnitMeasure',1)
    //                 .enterGridData('Conversion',2,'colConversionToStockUOM',10+'[ENTER]')
    //                 .clearTextFilter('FilterGrid') 
    //                 .done()    
    //             },
    //             continueOnFail: true   
    //     })
        

    //     .waitUntilLoaded()
    //     .enterData('Text Field','FilterGrid','50lb bag2' )
    //     .enterData('Text Field','FilterGrid','[ENTER]' )
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .waitUntilLoaded()
    //     .continueIf({
    //             expected: true,
    //             actual: function (win) {
    //                 return win.down('#grdConversion').getStore().getCount() !== 0;
    //             },
    //             success: function (next) {
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM 50lb bag2 exists.')
    //                 .done();
    //             },
    //             failure: function(next){
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .addResult('UOM 50lb bag2 does not exists.')
    //                 .addStep('Add UOM 50lb bag2')
    //                 .clearTextFilter('FilterGrid')
    //                 .clickButton('InsertConversion')
    //                 .selectGridComboBoxRowValue('Conversion',3,'colOtherUOM', '50lb bag2' ,'strUnitMeasure',1)
    //                 .enterGridData('Conversion',3,'colConversionToStockUOM',50+'[ENTER]')
    //                 .clearTextFilter('FilterGrid') 
    //                 .done()    
    //             },
    //             continueOnFail: true   
    //     })
    //     .waitUntilLoaded()
    //     .clickButton('Save')
    //     .waitUntilLoaded()
    //     .clickButton('Close')

    //     .done()
    // })
    // .clickMenuScreen('Commodities')
    // .waitUntilLoaded()
    // .waitUntilLoaded()
    // .enterData('Text Field','FilterGrid','Corn1' )
    // .enterData('Text Field','FilterGrid','[ENTER]' )
    // .waitUntilLoaded()
    // .waitUntilLoaded()
    // .waitUntilLoaded()
    // .continueIf({
    //         expected: true,
    //         actual: function (win) {
    //             return win.down('#grdSearch').getStore().getCount() !== 0;
    //         },
    //         success: function (next) {
    //             new iRely.FunctionalTest().start(t, next)
    //             .addResult('Corn1 exists.')
    //             .clearTextFilter('FilterGrid')
    //             .done();
    //         },
    //         failure: function(next){
    //             new iRely.FunctionalTest().start(t, next)
    //             .addResult('Corn1 does not exists.')
    //             .addStep('Add Commodity Corn1')
    //             .clickButton('New')
    //             .waitUntilLoaded()
    //             .enterData('Text Field','CommodityCode','Corn1' )
    //             .enterData('Text Field','Description','Corn1 Description' )
    //             .enterGridNewRow('Uom', [{column: 'strUnitMeasure', data: 'LB2'}])
    //             .selectGridRowNumber('Uom', 1)
    //             .selectGridComboBoxRowValue('Uom',1,'colUOMCode', 'LB2' ,'strUnitMeasure',1)
    //             .clickGridCheckBox('Uom',1 , 'colUOMStockUnit', 'LB2', 'ysnStockUnit', true)
    //             .waitUntilLoaded()
    //             .selectGridComboBoxRowValue('Uom',2,'colUOMCode', 'KG2' ,'strUnitMeasure',1)
    //             .waitUntilLoaded()
    //             .selectGridComboBoxRowValue('Uom',3,'colUOMCode', '10lb bag2' ,'strUnitMeasure',1)
    //             .waitUntilLoaded()
    //             .selectGridComboBoxRowValue('Uom',4,'colUOMCode', '50lb bag2' ,'strUnitMeasure',1)
    //             .waitUntilLoaded()
    //             // .clickTab('Attribute')
    //             // .waitUntilLoaded()
    //             // .selectGridRowNumber('Origin', 1)
    //             // .waitUntilLoaded()
    //             // .selectGridComboBoxRowValue('Origin',1,'colOrigin', 'Philippines' ,'strDescription',1)
    //             // .waitUntilLoaded()
    //             // .selectGridComboBoxRowValue('Origin',1,'colDefaultPackingUOM', '10lb bag2' ,'strDefaultPackingUOM',1)
    //             // .waitUntilLoaded()
    //             // .selectGridComboBoxRowValue('Origin',1,'colPurchasingGroup', 'South East Asian Group' ,'strPurchasingGroup',1)
    //             // .waitUntilLoaded()
    //             // .selectGridComboBoxRowValue('Origin',2,'colOrigin', 'United States' ,'strDescription',1)
    //             // .waitUntilLoaded()
    //             // .selectGridComboBoxRowValue('Origin',2,'colDefaultPackingUOM', '50lb bag2' ,'strDefaultPackingUOM',1)
    //             // .waitUntilLoaded()
    //             // .selectGridComboBoxRowValue('Origin',2,'colPurchasingGroup', 'North American Group' ,'strPurchasingGroup',1)
    //             // .waitUntilLoaded()
    //             // .selectGridComboBoxRowValue('Origin',3,'colOrigin', 'India' ,'strDescription',1)
    //             // .waitUntilLoaded()
    //             // .selectGridComboBoxRowValue('Origin',3,'colDefaultPackingUOM', '10lb bag2' ,'strDefaultPackingUOM',1)
    //             // .waitUntilLoaded()
    //             // .selectGridComboBoxRowValue('Origin',3,'colPurchasingGroup', 'South East Asian Group' ,'strPurchasingGroup',1)
    //             // .waitUntilLoaded()
    //             .clickButton('Save')
    //             .waitUntilLoaded()
    //             .clickButton('Close')
    //             .done()    
    //         },
    //         continueOnFail: true   
    // })
    // .addScenario('Pre-setup','Create Non Lotted Item',1000)
     .clickMenuScreen('Items')
     .waitUntilLoaded()
      .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
    // .clickTab('Item')
    // .clearTextFilter('FilterGrid')
    .waitUntilLoaded()
    .waitUntilLoaded()
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
    // .waitUntilLoaded()
    // .selectComboBoxRowNumber('Condition',2)             
    // .enterData('Text Field','From','NLTI-01' )
    // .enterData('Text Field','From','[ENTER]' )
    // .waitUntilLoaded()
    // .waitUntilLoaded()
    // .waitUntilLoaded()
    // .continueIf({
    //         expected: true,
    //         actual: function (win) {
    //             return win.down('#grdSearch').getStore().getCount() !== 0;
    //         },
    //         success: function (next) {
    //             new iRely.FunctionalTest().start(t, next)
    //             .addScenario('Duplicate NLTI-01 to ' + productID ,'',1000)              
    //             .addResult('Inventory NLTI-01 exists.')
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
                .clickButton('Save')
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()
                .clickButton('Close')
                // .addFunction(function (next) {
                //     t.chain(
                //         { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch #pnlFilter #con0 #filterDeleteButton => .small-delete" }
                //     )
                //     next();
                // })
    //             .done()
    //         },
    //         failure: function(next){
    //             new iRely.FunctionalTest().start(t, next)
    //             .addResult('Inventory NLTI-01 does not exists.')
    //             .addStep('Add Inventory NLTI-01 ')
    //             .waitUntilLoaded()
    //             .clickButton('New')
    //             .waitUntilLoaded()
    //             .clickButton('Delete')
    //             .waitUntilLoaded()
    //             .addFunction(function(next){
    //                 var msg = document.querySelector('.sweet-alert'),
    //                     message = msg.querySelector('p').innerHTML;
    //                 if (msg){
    //                     if(msg.querySelector('p').innerHTML === message){
    //                     new iRely.FunctionalTest().start(t, next)
    //                     .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
    //                     .displayText(msg.querySelector('p').innerHTML)
    //                     .waitUntilLoaded()
    //                     .waitUntilLoaded()
    //                     .clickMessageBoxButton('yes')
    //                     .done()
    //                     }else{
    //                         new iRely.FunctionalTest().start(t, next)
    //                         .displayText('Skip message')
    //                         .done()
    //                     }
                    
    //                 }
    //             })
    //             .waitUntilLoaded()
    //             .clickButton('New')
    //             .waitUntilLoaded()
    //             .enterData('Text Field','ItemNo','NLTI-01' )
    //             .selectComboBoxRowNumber('Type',2)
    //             .waitUntilLoaded()
    //             // .addFunction(function (next) {
    //             //     t.chain(
    //             //         { click : "#frmItem #tabItem #pgeDetails #grdUnitOfMeasure gridcolumn:ariadne-nth-child(1) => .x-column-header-text" }
    //             //     )
    //             //     next();
    //             // })
    //             // .waitUntilLoaded()
    //             // .waitUntilLoaded()
    //             // .clickButton('DeleteUom')
    //             // .waitUntilLoaded()
              
    //             // .waitUntilLoaded()
    //             // .addFunction(function(next){
    //             //     var msg = document.querySelector('.sweet-alert'),
    //             //         message = msg.querySelector('p').innerHTML;
    //             //     if (msg){
    //             //         if(msg.querySelector('p').innerHTML === message){
    //             //         new iRely.FunctionalTest().start(t, next)
    //             //         .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
    //             //         .displayText(msg.querySelector('p').innerHTML)
    //             //         .waitUntilLoaded()
    //             //         .waitUntilLoaded()
    //             //         .clickMessageBoxButton('yes')
    //             //         .done()
    //             //         }else{
    //             //             new iRely.FunctionalTest().start(t, next)
    //             //             .displayText('Skip message')
    //             //             .done()
    //             //         }
                    
    //             //     }
    //             // })
    //             .waitUntilLoaded()
    //             //.clickButton('Save')
    //             .selectComboBoxRowValue('Commodity', 'Corn1', 'CommodityId',1)
    //             .selectComboBoxRowValue('Category', 'Grains', 'CategoryId',1)
    //             .enterData('Text Field','Description','Inventory NLTI-01 Desc' )
    //             .selectComboBoxRowNumber('LotTracking',5)
    //             .waitUntilLoaded()
    //             //.clickButton('Save')
    //             .waitUntilLoaded() 
    //             .clickTab('Setup')
    //             .clickButton('AddRequiredAccounts')
    //             .waitUntilLoaded()
    //             .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
    //             .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
    //             .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
    //             .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
    //             .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
    //             .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')

    //             .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
    //             .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
    //             .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
    //             .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
    //             .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
    //             .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
    //             .waitUntilLoaded()
    //             .clickTab('Location')
    //             .waitUntilLoaded()
    //             .clickButton('AddLocation')
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'LocationId',1)
    //             .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocationId',1)
    //             .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocationId',1)
    //             .selectComboBoxRowNumber('NegativeInventory',2) 
    //             .clickButton('Save')
    //             .waitUntilLoaded()
    //             .clickButton('Close')
    //             .waitUntilLoaded()    
                
    //             .clickTab('Contract Item')    
    //             .addFunction(function (next) {
    //                 t.chain(
    //                     { click : "#frmItem #tabItem #pgeSetup #tabSetup #pgeContract #grdCertification #colCertification => .x-column-header-text" }
    //                 )
    //                 next();
    //             })
    //             .waitUntilLoaded()
    //             .addFunction(function (next) {
    //                 t.chain(
    //                     { click : "menu{isVisible()} #mnuHeaderDrillDown => .x-menu-item-text"}
    //                 )
    //                 next();
    //             })
                
    //             .waitUntilLoaded()
    //             .waitUntilLoaded('iccertificationprogram')
    //             .isControlVisible('textfield',['Certification Code','txtCertificationCode'],'true')
    //             .addFunction(function(next){
    //                 var record=Math.floor((Math.random() * 1000000) + 1);
    //                 var d = new Date();
    //                 var certCode = 'CODE-' + ' ' + record + ' ' + d.toLocaleDateString('en-US') ;
    //                 new iRely.FunctionalTest().start(t, next)
    //                 .enterData('Text Field','CertificationProgram','CertProg'+ record + ' ' + d.toLocaleDateString('en-US'))
    //                 .enterData('Text Field','IssuingOrganization','IssueOrg1'+ record + ' ' + d.toLocaleDateString('en-US'))
    //                 .enterData('Text Field','CertificationCode',certCode)
    //                 .waitUntilLoaded()
    //                 .clickButton('Save')
    //                 .waitUntilLoaded()
    //                 .waitUntilLoaded()
    //                 .waitUntilLoaded()
    //                 .clickButton('Close')
    //                 .waitUntilLoaded()
    //                 .clickButton('InsertCertification')
    //                 .waitUntilLoaded()
    //                 //.selectComboBoxRowValue('Certification', 'CertProg'+ record + ' ' + d.toLocaleDateString('en-US'), 'strCertificationName',1)
    //                 .selectGridComboBoxRowValue('Certification', 1, 'colCertification',  'CertProg'+ record + ' ' + d.toLocaleDateString('en-US'), 'strCertificationName')
    //                 .done()
    //             })
    //             .waitUntilLoaded()
    //             .clickTab('Pricing')
    //             .enterGridData('Pricing',1,'colPricingLastCost',10) 
    //             .enterGridData('Pricing',1,'colPricingStandardCost',10)
    //             .selectGridComboBoxRowNumber('Pricing',1,'strPricingMethod',3)
    //             .enterGridData('Pricing',1,'colPricingAmount',40) 
    //             .enterGridData('Pricing',1,'colPricingRetailPrice',14) 
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .clickButton('Save')
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .clickTab('Details')
    //             .waitUntilLoaded()
    //             .clickButton('Duplicate')
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .enterData('Text Field','ItemNo',productID)
    //             .enterData('Text Field','Description','Inventory ' + productID +' Desc' )
    //             .clickButton('Save')
    //             .waitUntilLoaded()
    //             .clickButton('Close')
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .waitUntilLoaded()
    //             .addFunction(function (next) {
    //                 t.chain(
    //                     { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch #pnlFilter #con0 #filterDeleteButton => .small-delete" }
    //                 )
    //                 next();
    //             })
    //             .done()    
    //         },
    //         continueOnFail: true   
    // })
    // // .addScenario('Pre-setup','Create Lotted Item',1000)
    // // .clickMenuScreen('Items')
    // // .waitUntilLoaded()
    // // .clickTab('Item')
// //    .clearTextFilter('FilterGrid')
    // // .waitUntilLoaded()
    // // .waitUntilLoaded()
    // // .clearData('Text Field','From')
    // // .enterData('Text Field','From','LTI-01' )
    // // .enterData('Text Field','From','[ENTER]' )
    // // .waitUntilLoaded()
    // // .waitUntilLoaded()
    // // .waitUntilLoaded()
    // // .continueIf({
    // //         expected: true,
    // //         actual: function (win) {
    // //             return win.down('#grdSearch').getStore().getCount() !== 0;
    // //         },
    // //         success: function (next) {
    // //             new iRely.FunctionalTest().start(t, next)
    // //             .addScenario('Duplicate LTI-01 to ' + productID2 ,'',1000)              
    // //             .addResult('Inventory LTI-01 exists.')
                // // .doubleClickSearchRowValue ('LTI-01','strItemNo',1)
                // // .waitUntilLoaded()
                // // .waitUntilLoaded()
                // // .waitUntilLoaded()
                // // .waitUntilLoaded()
                // // .waitUntilLoaded()
                // // .clickButton('Duplicate')
                // // .waitUntilLoaded()
                // // .waitUntilLoaded()
                // // .waitUntilLoaded()
                // // .waitUntilLoaded()
                // // .waitUntilLoaded()
                // // .enterData('Text Field','ItemNo',productID2)
                // // .enterData('Text Field','Description','Inventory ' + productID2 +' Desc' )
                // // .clickButton('Save')
                // // .waitUntilLoaded()
                // // .clickButton('Close')
                // // .waitUntilLoaded()
    // //             .addFunction(function (next) {
    // //                 t.chain(
    // //                     { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch #pnlFilter #con0 #filterDeleteButton => .small-delete" }
    // //                 )
    // //                 next();
    // //             })
    // //             .done()
    // //         },
    // //         failure: function(next){
    // //             new iRely.FunctionalTest().start(t, next)
    // //             .addResult('Inventory LTI-01 does not exists.')
    // //             .addStep('Add Inventory LTI-01 ')
    // //             .clickButton('New')
    // //             .waitUntilLoaded()
    // //             .enterData('Text Field','ItemNo','LTI-01' )
    // //             .selectComboBoxRowNumber('Type',2)
    // //             .waitUntilLoaded()
               
    // //             .waitUntilLoaded()
    // //             .selectComboBoxRowValue('Category', 'Grains', 'CategoryId',1)
    // //             .selectComboBoxRowValue('Commodity', 'Corn1', 'CommodityId',1)
    // //             .enterData('Text Field','Description','Inventory LTI-01 Desc' )
    // //             .selectComboBoxRowNumber('LotTracking',1) 
    // //             .waitUntilLoaded()
    // //             //.clickButton('Save')
    // //             .waitUntilLoaded()
    // //             .clickTab('Setup')
    // //             .clickButton('AddRequiredAccounts')
    // //             .waitUntilLoaded()
    // //             .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
    // //             .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
    // //             .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
    // //             .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
    // //             .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
    // //             .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')
    // //             .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '20011-0001-001', 'strAccountId')
    // //             .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '15011-0001-001', 'strAccountId')
    // //             .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50011-0001-001', 'strAccountId')
    // //             .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40011-0001-001', 'strAccountId')
    // //             .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16011-0001-001', 'strAccountId')
    // //             .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '50021-0001-001', 'strAccountId')
    // //             .waitUntilLoaded()
    // //             .clickTab('Location')
    // //             .waitUntilLoaded()
    // //             .clickButton('AddLocation')
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded()
    // //             .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'LocationId',1)
    // //             .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocationId',1)
    // //             .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocationId',1)
    // //             .selectComboBoxRowNumber('NegativeInventory',2) 
    // //             .clickButton('Save')
    // //             .waitUntilLoaded()
    // //             .clickButton('Close')
    // //             .waitUntilLoaded()    
                
    // //             .clickTab('Contract Item')    
    // //             .addFunction(function (next) {
    // //                 t.chain(
    // //                     { click : "#frmItem #tabItem #pgeSetup #tabSetup #pgeContract #grdCertification #colCertification => .x-column-header-text" }
    // //                 )
    // //                 next();
    // //             })
    // //             .waitUntilLoaded()
    // //             .addFunction(function (next) {
    // //                 t.chain(
    // //                     { click : "menu{isVisible()} #mnuHeaderDrillDown => .x-menu-item-text"}
    // //                 )
    // //                 next();
    // //             })
                
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded('iccertificationprogram')
    // //             .isControlVisible('textfield',['Certification Code','txtCertificationCode'],'true')
    // //             .addFunction(function(next){
    // //                 var record=Math.floor((Math.random() * 1000000) + 1);
    // //                 var d = new Date();
    // //                 var certCode = 'CODE-' + ' ' + record + ' ' + d.toLocaleDateString('en-US') ;
    // //                 new iRely.FunctionalTest().start(t, next)
    // //                 .enterData('Text Field','CertificationProgram','CertProg'+ record + ' ' + d.toLocaleDateString('en-US'))
    // //                 .enterData('Text Field','IssuingOrganization','IssueOrg1'+ record + ' ' + d.toLocaleDateString('en-US'))
    // //                 .enterData('Text Field','CertificationCode',certCode)
    // //                 .waitUntilLoaded()
    // //                 .clickButton('Save')
    // //                 .waitUntilLoaded()
    // //                 .waitUntilLoaded()
    // //                 .waitUntilLoaded()
    // //                 .clickButton('Close')
    // //                 .waitUntilLoaded()
    // //                 .clickButton('InsertCertification')
    // //                 .waitUntilLoaded()
    // //                 //.selectComboBoxRowValue('Certification', 'CertProg'+ record + ' ' + d.toLocaleDateString('en-US'), 'strCertificationName',1)
    // //                 .selectGridComboBoxRowValue('Certification', 1, 'colCertification',  'CertProg'+ record + ' ' + d.toLocaleDateString('en-US'), 'strCertificationName')
    // //                 .done()
    // //             })
    // //             .waitUntilLoaded()
    // //             .clickTab('Pricing')
    // //             .enterGridData('Pricing',1,'colPricingLastCost',10) 
    // //             .enterGridData('Pricing',1,'colPricingStandardCost',10)
    // //             .selectGridComboBoxRowNumber('Pricing',1,'strPricingMethod',3)
    // //             .enterGridData('Pricing',1,'colPricingAmount',40) 
    // //             .enterGridData('Pricing',1,'colPricingRetailPrice',14) 
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded()
    // //             .clickButton('Save')
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded()
    // //             .clickTab('Details')
    // //             .waitUntilLoaded()
    // //             .clickButton('Duplicate')
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded()
    // //             .waitUntilLoaded()
    // //             .enterData('Text Field','ItemNo',productID2)
    // //             .enterData('Text Field','Description','Inventory ' + productID2 +' Desc' )
    // //             .clickButton('Save')
    // //             .waitUntilLoaded()
    // //             .clickButton('Close')
    // //             .waitUntilLoaded()
    // //             .addFunction(function (next) {
    // //                 t.chain(
    // //                     { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch #pnlFilter #con0 #filterDeleteButton => .small-delete" }
    // //                 )
    // //                 next();
    // //             })
    // //             .done()

    // //         },
    // //         continueOnFail: true   
    // // })


//////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////      Scenario 3      ///////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    .addScenario('3','Inventory Return',1000)
    .clickMenuFolder('Purchasing (A/P)')
    .clickMenuScreen('Purchase Orders')
    .waitUntilLoaded()
    .clickButton('New')
    .waitUntilLoaded()
    //.waitUntilLoaded('appurchaseorder')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)    
    .selectComboBoxRowValue('ShipTo', '0001-Fort Wayne', 'ShipTo',1)
    .selectComboBoxRowValue('ShipFrom', 'Office', 'ShipFrom',1)
    .selectComboBoxRowValue('ShipVia1', 'Trucks', 'ShipVia1',1)
    
    .selectGridComboBoxRowValue('Items',1,'strItemNo', productID ,'strItemNo') 
    .enterGridData('Items',1,'dblQtyOrdered',100)
    .enterGridData('Items',1,'dblCost',10)
    .clickButton('Save')
    .waitUntilLoaded()
    .waitUntilLoaded()
    .waitUntilLoaded()
    .addFunction(function (next) {
        var PONumber = Ext.WindowManager.getActive().down('#txtPurchaseOrderNo').rawValue;
        new iRely.FunctionalTest().start(t, next)
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .addScenario('3','Inventory Receipts',1000)
        .clickMenuFolder('Inventory')
        .clickMenuScreen('Inventory Receipts')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowNumber('ReceiptType',2)
        .selectComboBoxRowValue('FreightTerms', 'Deliver', 'FreightTerm',1)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'EntityVendorId',1) 
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .doubleClickSearchRowValue (PONumber,'strOrderNumber',1)
        .waitUntilLoaded()
        .selectGridRowNumber('InventoryReceipt', 1)
        .verifyGridData ('InventoryReceipt', 1 ,'strItemNo' , productID)
        .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB2', 'equal')
        .verifyGridData ('InventoryReceipt', 1 ,'dblUnitCost' , 10)
        
        .enterGridData('InventoryReceipt',1,'colUnitCost',10)
        .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colSubLocation', 'Raw Station', 'strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage', 'strStorageLocationName')
        // .selectGridRowNumber('LotTracking', 1)
        // .enterGridData('LotTracking',1,'colLotId','LOT-01' + '[TAB]') 
        // .enterGridData('LotTracking',1,'colLotQuantity',100 +'[ENTER]')
        //.enterGridData('LotTracking',1,'colLotGrossWeight',95 )  
        .clickButton('Save')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickTab('Post Preview')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 1000)
        .displayText('AP Clearing Account')
        .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 1000)
        .waitUntilLoaded()
        .clickButton('Post')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .isControlDisable('Button',['Return'],false)
        .addFunction(function (next) {
            var ReceiptNumber = Ext.WindowManager.getActive().down('#txtReceiptNumber').rawValue;
            new iRely.FunctionalTest().start(t, next)
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
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .filterGridRecords('Search','From','',1)        
            .doubleClickSearchRowValue (productID,'strItemNo',1)
            .waitUntilLoaded()
            .clickTab('Stock')
            .waitUntilLoaded()
            .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 100)
            .verifyGridData ('Stock', 1 ,'dblAvailable' , 100)
            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            .waitUntilLoaded()
            .addScenario('3','Inventory Return',1000)
            .clickMenuScreen('Inventory Receipts')
            .waitUntilLoaded()
            .doubleClickSearchRowValue (ReceiptNumber,'strReceiptNumber',1)
            .waitUntilLoaded()
            .clickButton('Return')
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
            .waitUntilLoaded()

            





            .selectGridRowNumber('InventoryReceipt', 1)
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
            .verifyGridData ('InventoryReceipt', 1 ,'dblOrderQty' , 100,'equal')
            .waitUntilLoaded()
            .verifyGridData ('InventoryReceipt', 1 ,'dblReceived' ,0,'equal')
            .waitUntilLoaded()
            .verifyUOMGridData('InventoryReceipt', 1, 'dblOpenReceive', 100, 'LB2', 'equal')
            .waitUntilLoaded()
            .verifyGridData ('InventoryReceipt', 1 ,'dblUnitCost' , 10,'equal')
            .selectGridRowNumber('InventoryReceipt', 1)
            .waitUntilLoaded()

            .waitUntilLoaded()
            // .addFunction(function (next){
            //     var today =  new Date().toLocaleDateString();
            //     var engine = new iRely.FunctionalTest();
            //     engine.start(t,next)
            //         .displayText('Checks if the Post Date is set to current system date.')
            //         .verifyData('Date Field', 'ReceiptDate', today, 'equal')
            //         .done()
            // })
            .isControlReadOnly('Combo Box',['ReceiptType','SourceType','Vendor','Location', 'Currency','Receiver','ShipFrom','ShipVia','FreightTerms'],true)
            .isControlReadOnly('Text Field',['ReceiptNumber','BillOfLadingNumber','VendorRefNumber','WarehouseRefNo', 'FobPoint','Vessel','ShiftNumber'],true)
            .waitUntilLoaded()
            .clickButton('Save')
         
            .waitUntilLoaded()
            .clickButton('Save')
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            
            .waitUntilLoaded()

            .clickTab('Post Preview')
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .displayText('Inventory Account')
            .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 1000,'equal')
            .displayText('AP Clearing Account')
            .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 1000,'equal')
            .clickButton('Post')
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .clickMenuScreen('Items')
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded() .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()   
            .addFunction(function (next) {
                        t.chain(
                            { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                        )
                        next();
                    })
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()        
            //.clearTextFilter('From')
            .filterGridRecords('Search','From','',1)
            .doubleClickSearchRowValue (productID,'strItemNo',1)
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .clickTab('Stock')
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 0)
            .verifyGridData ('Stock', 1 ,'dblAvailable' , 0)
            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            /////////////////////////////////////////////////////////////////////////////////
            //////////          Scenario 4      /////////////////////////////////////////////
            /////////////////////////////////////////////////////////////////////////////////
            .addScenario('4','Create PO',1000)
            .clickMenuFolder('Purchasing (A/P)')
            .clickMenuScreen('Purchase Orders')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded()
            //.waitUntilLoaded('appurchaseorder')
            .waitUntilLoaded()
            .waitUntilLoaded()
            .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)    
            .selectComboBoxRowValue('ShipTo', '0001-Fort Wayne', 'ShipTo',1)
            .selectComboBoxRowValue('ShipFrom', 'Office', 'ShipFrom',1)
            .selectComboBoxRowValue('ShipVia1', 'Trucks', 'ShipVia1',1)
            
            .selectGridComboBoxRowValue('Items',1,'strItemNo', productID ,'strItemNo') 
            .enterGridData('Items',1,'dblQtyOrdered',100)
            .enterGridData('Items',1,'dblCost',10)
            .clickButton('Save')
            .waitUntilLoaded()
            .waitUntilLoaded()
            .waitUntilLoaded()
            .addFunction(function (next) {
                PONumber = Ext.WindowManager.getActive().down('#txtPurchaseOrderNo').rawValue;
                new iRely.FunctionalTest().start(t, next)
                .clickButton('Close')
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .addScenario('4','Inventory Receipts',1000)
                .clickMenuFolder('Inventory')
                .clickMenuScreen('Inventory Receipts')
                .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded()
                .selectComboBoxRowNumber('ReceiptType',2)
                .selectComboBoxRowValue('FreightTerms', 'Deliver', 'FreightTerm',1)
                .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'EntityVendorId',1) 
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .doubleClickSearchRowValue (PONumber,'strOrderNumber',1)
                .waitUntilLoaded()
                .selectGridRowNumber('InventoryReceipt', 1)
                .verifyGridData ('InventoryReceipt', 1 ,'strItemNo' , productID)
                .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 100, 'LB2', 'equal')
                .verifyGridData ('InventoryReceipt', 1 ,'dblUnitCost' , 10)
                
                .enterGridData('InventoryReceipt',1,'colUnitCost',10)
                .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colSubLocation', 'Raw Station', 'strSubLocationName')
                .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage', 'strStorageLocationName')
                //.selectGridRowNumber('LotTracking', 1)
                // .enterGridData('LotTracking',1,'colLotId','LOT-01' + '[TAB]') 
                // .enterGridData('LotTracking',1,'colLotQuantity',100 +'[ENTER]')
                // .verifyGridData ('LotTracking', 1 ,'dblGrossWeight' , 100)
                // .verifyGridData ('LotTracking', 1 ,'dblNetWeight' , 100)
                //.enterGridData('LotTracking',1,'colLotGrossWeight',95 )  
                .clickButton('Save')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .clickTab('Post Preview')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .displayText('Inventory Account')
                .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 1000)
                .displayText('AP Clearing Account')
                .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 1000)
                .waitUntilLoaded()
                .clickButton('Post')
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .isControlDisable('Button',['Return'],false)
                .addFunction(function (next) {
                    var ReceiptNumber = Ext.WindowManager.getActive().down('#txtReceiptNumber').rawValue;
                    new iRely.FunctionalTest().start(t, next)
                    .clickButton('Close')
                    .waitUntilLoaded()
                    // .clickMenuScreen('Items')
                    // .waitUntilLoaded()
                    // .waitUntilLoaded()
                    // .waitUntilLoaded()
                    // .clearTextFilter('FilterGrid')
                    // .doubleClickSearchRowValue (productID,'strItemNo',1)
                    // .waitUntilLoaded()
                    // .waitUntilLoaded()
                    // .waitUntilLoaded()
                    // .clickTab('Stock')
                    // .waitUntilLoaded()
                    // .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 100)
                    // .verifyGridData ('Stock', 1 ,'dblAvailable' , 100)
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .addScenario('4','Inventory Return',1000)
                    .clickMenuFolder('Inventory')
                    .clickMenuScreen('Inventory Receipts')
                    .waitUntilLoaded()
                     .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    //.clearTextFilter('From')
                    .doubleClickSearchRowValue (ReceiptNumber,'strReceiptNumber',1)
                    .waitUntilLoaded()
                    .clickButton('Return')
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
                    .waitUntilLoaded()
                    .selectGridRowNumber('InventoryReceipt', 1)
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
                    .verifyGridData ('InventoryReceipt', 1 ,'dblOrderQty' , 100,'equal')
                    .waitUntilLoaded()
                    .verifyGridData ('InventoryReceipt', 1 ,'dblReceived' ,0,'equal')
                    .waitUntilLoaded()
                    .verifyUOMGridData('InventoryReceipt', 1, 'dblOpenReceive', 100, 'LB2', 'equal')
                    .waitUntilLoaded()
                    .verifyGridData ('InventoryReceipt', 1 ,'dblUnitCost' , 10,'equal')
                    .selectGridRowNumber('InventoryReceipt', 1)
                   
                    .waitUntilLoaded()
                    // .addFunction(function (next){
                    //     var today =  new Date().toLocaleDateString();
                    //     var engine = new iRely.FunctionalTest();
                    //     engine.start(t,next)
                    //         .displayText('Checks if the Post Date is set to current system date.')
                    //         .verifyData('Date Field', 'ReceiptDate', today, 'equal')
                    //         .done()
                    // })
                    .isControlReadOnly('Combo Box',['ReceiptType','SourceType','Vendor','Location', 'Currency','Receiver','ShipFrom','ShipVia','FreightTerms'],true)
                    .isControlReadOnly('Text Field',['ReceiptNumber','BillOfLadingNumber','VendorRefNumber','WarehouseRefNo', 'FobPoint','Vessel','ShiftNumber'],true)
                    .waitUntilLoaded()
                   
                    // .enterGridData('LotTracking',1,'colLotQuantity',50 +'[ENTER]')
                    // .waitUntilLoaded()
                    // .verifyGridData ('LotTracking', 1 ,'dblGrossWeight' , 50,'equal')//100
                    // .waitUntilLoaded()
                    // .verifyGridData ('LotTracking', 1 ,'dblTareWeight' , 0,'equal')  
                    // .waitUntilLoaded()
                    // .verifyGridData ('LotTracking', 1 ,'dblNetWeight' ,50,'equal')//100
                    .waitUntilLoaded()
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()

                    .selectGridRowNumber('InventoryReceipt', 1)
                    .addFunction(function (next) {
                        t.chain(
                            { click : "#frmInventoryReceipt #tabInventoryReceipt #pgeDetails #pnlItem #grdInventoryReceipt #grvInventoryReceipt => .x-grid-item:nth-of-type(1) .x-grid-cell-colUOMQtyToReceive .x-grid-cell-inner" }
                        )
                        next();
                    })
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',50 , 'LB2')
                    .enterGridData('InventoryReceipt',1,'dblGross',50)
                    .clickTab('Details')
                    .waitUntilLoaded()
                    .clickTab('Post Preview')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .displayText('Inventory Account')
                    .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 500,'equal')
                    .displayText('AP Clearing Account')
                    .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 500,'equal')
                    .clickButton('Post')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickMenuScreen('Items')
                    .waitUntilLoaded()
                    .addFunction(function (next) {
                        t.chain(
                            { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                        )
                        next();
                    })
                    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()        
                     .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                   // .clearTextFilter('FilterGrid')
                   .filterGridRecords('Search','From','',1)
                    .doubleClickSearchRowValue (productID,'strItemNo',1)
                    .waitUntilLoaded()
                    .clickTab('Stock')
                    .waitUntilLoaded()
                    .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 50)
                    .verifyGridData ('Stock', 1 ,'dblAvailable' , 50)
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .addScenario('4','Inventory Return 2',1000)
                    .clickMenuFolder('Inventory')
                    .clickMenuScreen('Inventory Receipts')
                    .waitUntilLoaded()
                    .doubleClickSearchRowValue (ReceiptNumber,'strReceiptNumber',1)
                    .waitUntilLoaded()
                    .clickButton('Return')
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
                    .waitUntilLoaded()
                    .selectGridRowNumber('InventoryReceipt', 1)
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
                    .verifyGridData ('InventoryReceipt', 1 ,'dblOrderQty' , 100,'equal')
                    .waitUntilLoaded()
                    .verifyGridData ('InventoryReceipt', 1 ,'dblReceived' ,0,'equal')
                    .waitUntilLoaded()
                    .verifyUOMGridData('InventoryReceipt', 1, 'dblOpenReceive', 100, 'LB2', 'equal')
                    .waitUntilLoaded()
                    .verifyGridData ('InventoryReceipt', 1 ,'dblUnitCost' , 10,'equal')
                    .selectGridRowNumber('InventoryReceipt', 1)
                    .waitUntilLoaded()
          
                    .waitUntilLoaded()
                    // .addFunction(function (next){
                    //     var today =  new Date().toLocaleDateString();
                    //     var engine = new iRely.FunctionalTest();
                    //     engine.start(t,next)
                    //         .displayText('Checks if the Post Date is set to current system date.')
                    //         .verifyData('Date Field', 'ReceiptDate', today, 'equal')
                    //         .done()
                    // })
                    .isControlReadOnly('Combo Box',['ReceiptType','SourceType','Vendor','Location', 'Currency','Receiver','ShipFrom','ShipVia','FreightTerms'],true)
                    .isControlReadOnly('Text Field',['ReceiptNumber','BillOfLadingNumber','VendorRefNumber','WarehouseRefNo', 'FobPoint','Vessel','ShiftNumber'],true)
                    .waitUntilLoaded()
                   // .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',50, 'LB2')
                    //.enterGridData('LotTracking',1,'colLotQuantity',50 +'[ENTER]')
                    .waitUntilLoaded()
                    // .verifyGridData ('LotTracking', 1 ,'dblGrossWeight' , 50,'equal')//100
                    // .waitUntilLoaded()
                    // .verifyGridData ('LotTracking', 1 ,'dblTareWeight' , 0,'equal')  
                    // .waitUntilLoaded()
                    // .verifyGridData ('LotTracking', 1 ,'dblNetWeight' ,50,'equal')//100
                    .waitUntilLoaded()
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    // .clickButton('Post')
                    // .waitUntilLoaded()
                    // .waitUntilLoaded()
                    // .waitUntilLoaded()
                    // .waitUntilLoaded()
                    // .clickButton('Unpost')
                    // .waitUntilLoaded()
                    // .waitUntilLoaded()
                    // .waitUntilLoaded()
                    .waitUntilLoaded()
                    .selectGridRowNumber('InventoryReceipt', 1)
                    .addFunction(function (next) {
                        t.chain(
                            { click : "#frmInventoryReceipt #tabInventoryReceipt #pgeDetails #pnlItem #grdInventoryReceipt #grvInventoryReceipt => .x-grid-item:nth-of-type(1) .x-grid-cell-colUOMQtyToReceive .x-grid-cell-inner" }
                        )
                        next();
                    })
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',50 , 'LB2')
                    // .enterGridData('InventoryReceipt',1,'dblGross',50)
                    .clickTab('Details')
                    .waitUntilLoaded()
                    .clickTab('Post Preview')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .displayText('Inventory Account')
                    .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 500,'equal')
                    .displayText('AP Clearing Account')
                    .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 500,'equal')
                    .clickButton('Post')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickMenuScreen('Items')
                    .waitUntilLoaded()
                    .addFunction(function (next) {
                        t.chain(
                            { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                        )
                        next();
                    })
                    .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()        
                     .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    //.clearTextFilter('From')
                    //.clearGridData('Search','1', 'dtmEffectiveDate')
                    .filterGridRecords('Search','From','',1)
                    .doubleClickSearchRowValue (productID,'strItemNo',1)
                    .waitUntilLoaded()
                    .clickTab('Stock')
                    .waitUntilLoaded()
                    .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 0)
                    .verifyGridData ('Stock', 1 ,'dblAvailable' , 0)
                    .clickButton('Close')
                    .waitUntilLoaded()
                     .clickButton('Close')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    // .clickMenuFolder('Purchasing (Accounts Payable)')
                    // .clickMenuFolder('Inventory')
                    .done()
                })
                .done()
            })
            .done()
        })
   .done()
})   
 .done()
})       
          