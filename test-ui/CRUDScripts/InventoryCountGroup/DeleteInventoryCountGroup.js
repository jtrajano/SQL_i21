/**
 Created by CJ Callado
 */

StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Delete unused single record */
        .login('AGADMIN','AGADMIN','AG').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Delete unused single record"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('iccountgroup').wait(100)
        .selectGridRow('#grdGridTemplate',5)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('no').wait(10)
        .checkScreenShown('iccountgroup').wait(100)
        .checkGridData('#grdGridTemplate', 5, 'colCountGroup','ICG - 06')
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(10)
        .checkStatusMessage('Edited').wait(100)
        .checkGridData('#grdGridTemplate', 5, 'colCountGroup', '').wait(500)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccountgroup').wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('iccountgroup').wait(100)
        .checkGridData('#grdGridTemplate', 5, 'colCountGroup', '').wait(500)
        .clickButton('#btnClose').wait(100)


        /*Scenario 2. Delete used record */
        .addFunction(function(next){t.diag("Scenario 2. Delete used record"); next();}).wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('iccountgroup').wait(100)
        .selectGridRow('#grdGridTemplate',0)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('no').wait(10)
        .checkScreenShown('iccountgroup').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colCountGroup','ICG - 01')
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(10)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave')
        .checkMessageBox('iRely i21','The record you are trying to delete is being used.','ok', 'error')
        .clickMessageBoxButton('ok')
        .checkGridData('#grdGridTemplate', 0, 'colCountGroup','ICG - 01')
        .clickButton('#btnClose')


        /*Scenario 3. Delete multiple records */
        .addFunction(function(next){t.diag("Scenario 2. Delete used record"); next();}).wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('iccountgroup').wait(100)
        .selectGridRow('#grdGridTemplate',[1,2,3,4])
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 4 rows.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('no').wait(10)
        .checkScreenShown('iccountgroup').wait(100)
        .checkGridData('#grdGridTemplate', 1, 'colCountGroup','ICG - 02')
        .checkGridData('#grdGridTemplate', 2, 'colCountGroup','ICG - 03')
        .checkGridData('#grdGridTemplate', 3, 'colCountGroup','ICG - 04')
        .checkGridData('#grdGridTemplate', 4, 'colCountGroup','ICG - 05')
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 4 rows.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(10)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(10)
        .checkIfScreenClosed('iccountgroup').wait(100)
        .openScreen('Inventory Count Group').wait(200)
        .checkScreenShown ('iccountgroup').wait(100)
        .checkGridData('#grdGridTemplate', 1, 'colCountGroup','')

        .done()
})

