/**
 * Created by RQuidato on 10/30/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*1.Delete unused single record*/
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Delete unused record"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .expandMenu('RIN').wait(100)
        .openScreen('Production Process').wait(200)
        .checkScreenShown ('processcode').wait(100)
        .selectGridRow('#grdGridTemplate',0)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('no').wait(10)
        .checkGridData('#grdGridTemplate', 0, 'colRinProcessCode','pp04')
        .checkGridData('#grdGridTemplate', 0, 'colDescription','production process 04')
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(10) /*FRM-1553*/
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .checkIfScreenClosed('processcode').wait(100)


        .done()
})
