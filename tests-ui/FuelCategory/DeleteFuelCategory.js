/**
 * Created by CJ Callado
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*1.Delete unused single record*/
            .login('AGADMIN','AGADMIN','AG').wait(1500)
            .addFunction(function(next){t.diag("Step 1: Select Fuel Category that is not used."); next();}).wait(100)
            .expandMenu('Inventory').wait(1000)
            .openScreen('Fuel Categories').wait(1000)
            .checkScreenShown ('icfuelcategory').wait(200)
            .selectGridRow('#grdGridTemplate', 1).wait(150)
            .addFunction(function(next){t.diag("2. Click Remove button."); next();}).wait(1000)
            .clickButton('#btnDelete').wait(1000)
            .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question').wait(150)
            .clickMessageBoxButton('yes')
            .checkStatusMessage('Edited')
            .clickButton('#btnSave')
            .checkStatusMessage('Saved')
            .clickButton('#btnClose')


        /*2.Delete used single record*/
            .addFunction(function(next){t.diag("1. Removing used record."); next();}).wait(1000)
            .openScreen('Fuel Categories').wait(1000)
            .checkScreenShown ('icfuelcategory').wait(200)
            .selectGridRow('#grdGridTemplate', 0).wait(150)
            .clickButton('#btnDelete').wait(1000)
            .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question').wait(150)
            .clickMessageBoxButton('yes')
            .checkStatusMessage('Edited')
            .clickButton('#btnSave')
            .checkMessageBox('iRely i21','The record you are trying to delete is being used.','ok', 'error').wait(150)
            .clickMessageBoxButton('ok')
            .addFunction(function(next){t.diag("2. Check records upon reopen."); next();}).wait(1000)
            .checkGridData('#grdGridTemplate',0,'colRinFuelCategoryCode','Test Fuel Category1')
            .checkGridData('#grdGridTemplate',0,'colDescription','Test Description1')
            .checkGridData('#grdGridTemplate',0,'colEquivalenceValue','Test Equivalence Value1')
            .clickButton('#btnClose')

        /*3.Delete unused multiple  record*/
        .addFunction(function(next){t.diag("Step 1: Select multiple Fuel Category that is not used."); next();}).wait(100)
        .openScreen('Fuel Categories').wait(1000)
        .checkScreenShown ('icfuelcategory').wait(200)
        .selectGridRow('#grdGridTemplate', [1,2,3]).wait(150)
        .addFunction(function(next){t.diag("2. Click Remove button."); next();}).wait(1000)
        .clickButton('#btnDelete').wait(1000)
        .checkMessageBox('iRely i21','You are about to delete 3 rows.<br/>Are you sure you want to continue?','yesno', 'question').wait(150)
        .clickMessageBoxButton('yes')
        .checkStatusMessage('Edited')
        .clickButton('#btnSave')
        .checkStatusMessage('Saved')
        .clickButton('#btnClose')

        .done();
})

