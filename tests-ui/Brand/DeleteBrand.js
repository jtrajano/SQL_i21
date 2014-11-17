/**
 * Created by RQuidato on 11/12/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Delete unused single record */
        /* 1.  */
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Delete unused record"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Brand').wait(200)
        .checkScreenShown ('brand').wait(100)
        .selectGridRow('#grdGridTemplate',0)
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('no').wait(10)
        .checkGridData('#grdGridTemplate', 0, 'colBrandCode','b04')
        .checkGridData('#grdGridTemplate', 0, 'colBrandName','brand 04')

        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(10) /*FRM-1553*/
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .checkIfScreenClosed('brand').wait(100)


        .done()
})

