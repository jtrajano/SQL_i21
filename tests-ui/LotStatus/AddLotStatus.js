/**
 * Created by CJ Callado
 */

StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Lot Status Defaults - Open screen and check default controls' state  */
        .login('AGADMIN','AGADMIN','AG').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Lot Status defaults > 1. Open screen and check default controls' state"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('iclotstatus').wait(100)
        .checkScreenWindow({alias: 'iclotstatus', title: 'Lot Status', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .checkToolbarButton({new: false, save: true, refresh: false, search: false, delete: false, undo: true, close: true})
        .checkControlVisible(['#btnDelete','#btnInsertCriteria','#txtFilterGrid'], true)
        .checkControlVisible(['#colSecondaryStatus', '#colDescription', '#colPrimaryStatus'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
        .checkGridData('#grdGridTemplate', 0, 'colSecondaryStatus', 'Active').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colDescription', 'This is system used lot status. Please do not change.').wait(100)
        .checkGridData('#grdGridTemplate', 0, 'colPrimaryStatus', 'Active').wait(100)
        .checkGridData('#grdGridTemplate', 1, 'colSecondaryStatus', 'On Hold').wait(100)
        .checkGridData('#grdGridTemplate', 1, 'colDescription', 'This is system used lot status. Please do not change.').wait(100)
        .checkGridData('#grdGridTemplate', 1, 'colPrimaryStatus', 'On Hold').wait(100)
        .checkGridData('#grdGridTemplate', 2, 'colSecondaryStatus', 'Quarantine').wait(100)
        .checkGridData('#grdGridTemplate', 2, 'colDescription', 'This is system used lot status. Please do not change.').wait(100)
        .checkGridData('#grdGridTemplate', 2, 'colPrimaryStatus', 'Quarantine').wait(100)
        .checkStatusBar()
        .checkStatusMessage('Ready')
        .clickButton('#btnClose')

        /*Scenario 2. Modify Lot Status Defaults*/

        .addFunction(function(next){t.diag("Scenario 2. Modify Default Lot Status"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('iclotstatus').wait(100)
        .checkControlReadOnly('#colSecondaryStatus', false)
        .clickButton('#btnClose')


        /*Scenario 3. Add new lot status*/
        .addFunction(function(next){t.diag("Scenario 3. Add new lot status"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('iclotstatus').wait(100)
        .enterGridData('#grdGridTemplate', 3, 'colSecondaryStatus', 'LS - 01').wait(500)
        .enterGridData('#grdGridTemplate', 3, 'colDescription', 'Additional lot status.').wait(500)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .openScreen('Lot Status').wait(200)
        .checkGridData('#grdGridTemplate', 3, 'colSecondaryStatus', 'LS - 01').wait(100)
        .checkGridData('#grdGridTemplate', 3, 'colDescription', 'Additional lot status.').wait(100)
        .clickButton('#btnClose').wait(100)



        /*Scenario 4. Add multiple lot status*/
        .addFunction(function(next){t.diag("Scenario 4. Add multiple lot status"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('iclotstatus').wait(100)
        .enterGridData('#grdGridTemplate', 4, 'colSecondaryStatus', 'LS - 02').wait(500)
        .enterGridData('#grdGridTemplate', 4, 'colDescription', 'Additional lot status.').wait(500)
        .enterGridData('#grdGridTemplate', 5, 'colSecondaryStatus', 'LS - 03').wait(500)
        .enterGridData('#grdGridTemplate', 5, 'colDescription', 'Additional lot status.').wait(500)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose')
        .openScreen('Lot Status').wait(200)
        .checkGridData('#grdGridTemplate', 4, 'colSecondaryStatus', 'LS - 02').wait(100)
        .checkGridData('#grdGridTemplate', 4, 'colDescription', 'Additional lot status.').wait(100)
        .checkGridData('#grdGridTemplate', 5, 'colSecondaryStatus', 'LS - 03').wait(100)
        .checkGridData('#grdGridTemplate', 5, 'colDescription', 'Additional lot status.').wait(100)
        .clickButton('#btnClose').wait(100)

        /*Scenario 5. Enter Primary Key only (Secondary Status)*/
        .addFunction(function(next){t.diag("Scenario 5. Enter Primary Key only (Secondary Status)"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('iclotstatus').wait(100)
        .enterGridData('#grdGridTemplate', 6, 'colSecondaryStatus', 'LS - 04').wait(500)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose')
        .openScreen('Lot Status').wait(200)
        .checkGridData('#grdGridTemplate', 6, 'colSecondaryStatus', 'LS - 04').wait(100)
        .clickButton('#btnClose').wait(100)

        /*Scenario 6. Enter Desc or Primary status only leave primary key blank*/
        .addFunction(function(next){t.diag("Scenario 6. Enter Desc or Primary status only leave primary key blank"); next();}).wait(100)
        .openScreen('Lot Status').wait(200)
        .checkScreenShown ('iclotstatus').wait(100)
        .enterGridData('#grdGridTemplate', 7, 'colDescription', 'Test Description').wait(500)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
        .clickMessageBoxButton('no')
        .openScreen('Lot Status').wait(200)
        .checkGridData('#grdGridTemplate', 7, 'colSecondaryStatus', '').wait(100)
        .clickButton('#btnClose').wait(100)


        .done()
})

