/**
 * Created by CCallado on 11/2/2015.
 */

StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Delete a single default lot status  */
        .login('AGADMIN','AGADMIN','AG').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Delete a single default lot status "); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('iclotstatus').wait(100)
        .checkScreenWindow({alias: 'iclotstatus', title: 'Lot Status', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, refresh: false, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#btnDelete','#btnInsertCriteria','#txtFilterGrid'], true)
        .checkControlVisible(['#colSecondaryStatus', '#colDescription', '#colPrimaryStatus'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .selectGridRow('#grdGridTemplate',0)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You cannot delete a default Lot Status!','ok', 'error').wait(100)
        .clickMessageBoxButton('ok').wait(100)
        .clickButton('#btnClose').wait(100)
        .openScreen('Lot Status').wait(200)
        .checkGridData('#grdGridTemplate', 0, 'colSecondaryStatus', 'Active').wait(500)
        .checkGridData('#grdGridTemplate', 0, 'colDescription', 'This is a system used lot status. Please do not change').wait(500)
        .checkGridData('#grdGridTemplate', 0, 'colPrimaryStatus', 'Active').wait(500)
        .clickButton('#btnClose').wait(100)



        /*Scenario 2. Delete all default lot status  */
        .addFunction(function(next){t.diag("Scenario 2. Delete all default lot status "); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .selectGridRow('#grdGridTemplate', [0,1,2])
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You cannot delete a default Lot Status!','ok', 'error').wait(100)
        .clickMessageBoxButton('ok').wait(100)
        .clickButton('#btnClose').wait(100)
        .openScreen('Lot Status').wait(200)
        .checkGridData('#grdGridTemplate', 0, 'colSecondaryStatus', 'Active').wait(300)
        .checkGridData('#grdGridTemplate', 0, 'colDescription', 'This is a system used lot status. Please do not change').wait(300)
        .checkGridData('#grdGridTemplate', 0, 'colPrimaryStatus', 'On Hold').wait(300)
        .checkGridData('#grdGridTemplate', 1, 'colSecondaryStatus', 'Active').wait(300)
        .checkGridData('#grdGridTemplate', 1, 'colDescription', 'This is a system used lot status. Please do not change').wait(300)
        .checkGridData('#grdGridTemplate', 1, 'colPrimaryStatus', 'On Hold').wait(300)
        .checkGridData('#grdGridTemplate', 2, 'colSecondaryStatus', 'Quarantine').wait(300)
        .checkGridData('#grdGridTemplate', 2, 'colDescription', 'This is a system used lot status. Please do not change').wait(300)
        .checkGridData('#grdGridTemplate', 2, 'colPrimaryStatus', 'Quarantine').wait(300)
        .clickButton('#btnClose').wait(100)


        /*Scenario 3. Delete a non default lot status*/
        .addFunction(function(next){t.diag("Scenario 3. Delete a non default lot status"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('iclotstatus').wait(100)
        .selectGridRow('#grdGridTemplate',6)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('no').wait(100)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkGridData('#grdGridTemplate', 6, 'colSecondaryStatus', '').wait(300)
        .checkGridData('#grdGridTemplate', 6, 'colDescription', '').wait(300)
        .checkGridData('#grdGridTemplate', 6, 'colPrimaryStatus', '').wait(300)
        .clickButton('#btnClose').wait(100)

        /*Scenario 4. Delete multiple non default lot status*/
        .addFunction(function(next){t.diag("Scenario 3. Delete multiple non default lot status"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('iclotstatus').wait(100)
        .selectGridRow('#grdGridTemplate',[3,4,5])
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 3 rows.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('no').wait(100)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 3 rows.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkGridData('#grdGridTemplate', 3, 'colSecondaryStatus', '').wait(300)
        .checkGridData('#grdGridTemplate', 3, 'colDescription', '').wait(300)
        .checkGridData('#grdGridTemplate', 3, 'colPrimaryStatus', '').wait(300)
        .clickButton('#btnClose').wait(100)



        .done()
})

