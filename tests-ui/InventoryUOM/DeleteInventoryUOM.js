/**
 * Created by CCallado
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();

    engine.start(t)

        /* 1. Delete an inventory UOM that is not used.*/
        .login('AGADMIN','AGADMIN','AG').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1.> Delete a category that is not used."); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .openScreen('Inventory UOM').wait(200)
        .checkScreenShown ('icinventoryuom').wait(100)
        .selectGridRow('#grdSearch', 15).wait(1000)
        .clickButton('#btnOpenSelected').wait(500)
        .checkScreenShown('icinventoryuom').wait(100)
        .checkControlVisible(['#btnInsertConversion','#btnDeleteConversion', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true)
        .checkControlVisible(['#colConversionStockUOM', '#colConversionToStockUOM'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true)
        .checkStatusMessage('Ready').wait(100)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question').wait(300)
        .clickMessageBoxButton('yes').wait(100)
        .checkIfScreenClosed('icinventoryuom')


        /* 2. Delete an Inventory UOM that is used.*/
        .addFunction(function(next){t.diag("Scenario 2.> Delete an Inventory UOM that is used."); next();}).wait(100)
        .selectGridRow('#grdSearch', 0).wait(1000)
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown('icinventoryuom')
        .checkControlVisible(['#btnInsertConversion','#btnDeleteConversion', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true)
        .checkControlVisible(['#colConversionStockUOM', '#colConversionToStockUOM'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true)
        .checkStatusMessage('Ready')
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question').wait(300)
        .clickMessageBoxButton('yes').wait(100)
        .checkMessageBox('iRely i21','The record you are trying to delete is being used.','ok', 'error').wait(300)
        .clickMessageBoxButton('ok').wait(100)
        .checkScreenShown('icinventoryuom')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)


        /* 3. Delete a single Inventory UOM conversion record.*/
        .addFunction(function(next){t.diag("Scenario 3.> Delete a single Inventory UOM conversion record."); next();}).wait(100)
        .selectGridRow('#grdSearch', 14).wait(1000)
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown('icinventoryuom')
        .checkStatusMessage('Ready').wait(100)
        .selectGridRow('#grdConversion', 0).wait(1000)
        .clickButton('#btnDeleteConversion').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question').wait(100)
        .clickMessageBoxButton('yes').wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .checkGridData('#grdConversion', 0, 'strUnitMeasure', '').wait(300)
        .checkGridData('#grdConversion', 0, 'dblConversionToStock', '0.00').wait(300)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom')

        /* 4. Delete multiple Inventory UOM conversion record.*/
        .addFunction(function(next){t.diag("Scenario 4. Delete multiple Inventory UOM conversion record."); next();}).wait(100)
        .selectGridRow('#grdSearch', 13).wait(1000)
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown('icinventoryuom').wait(100)
        .checkStatusMessage('Ready').wait(100)
        .selectGridRow('#grdConversion', [0,1]).wait(1000)
        .clickButton('#btnDeleteConversion').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 2 rows.<br/>Are you sure you want to continue?','yesno', 'question').wait(100)
        .clickMessageBoxButton('yes').wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .checkGridData('#grdConversion', 0, 'strUnitMeasure', '').wait(300)
        .checkGridData('#grdConversion', 0, 'dblConversionToStock', '0.00').wait(300)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom')


        /* 5. View Multiple records and delete them.*/
        .addFunction(function(next){t.diag("5. View Multiple records and delete them."); next();}).wait(100)
        .selectGridRow('#grdSearch', [12,13,14]).wait(1000)
        .clickButton('#btnOpenSelected').wait(100)
        .checkScreenShown('icinventoryuom')
        .checkStatusMessage('Ready').wait(100)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question').wait(300)
        .checkScreenShown('icinventoryuom')
        .clickMessageBoxButton('yes').wait(100)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question').wait(300)
        .clickMessageBoxButton('yes').wait(100)
        .checkScreenShown('icinventoryuom')
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question').wait(300)
        .clickMessageBoxButton('yes').wait(100)
        .checkScreenShown('icinventoryuom')
        .checkIfScreenClosed('icinventoryuom')

        .done()

})