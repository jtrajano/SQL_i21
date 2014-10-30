/**
 * Created by RQuidato on 10/30/14.
 */
/**
 * Created by RQuidato on 10/29/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Delete unused record */
        /* 1.  */
        .login('ssiadmin','summit','eo').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Delete unused record"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .expandMenu('RIN').wait(100)
        .openScreen('Process Code').wait(200)
        .checkScreenShown ('processcode').wait(100)
        .selectGridRow('#grdProcessCode',1)
        .clickButton('#btnDeleteProcessCode').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row. Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('no').wait(10)
//        .checkGridData('#grdProcessCode', 0, 'colProcessCode','pc01')
//        .checkGridData('#grdProcessCode', 0, 'colDescription','process code 01')
        .clickButton('#btnDeleteProcessCategory').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row. Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(10) /*FRM-1553*/
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .checkIfScreenClosed('processcode').wait(100)




        /*Scenario 2. Delete multiple records */
        .addFunction(function(next){t.diag("Scenario 2. Delete multiple records"); next();}).wait(100)
        .openScreen('Process Code').wait(200)
        .checkScreenShown ('processcode').wait(100)
        .selectGridRow('#grdProcessCode',1) /* IC-98 */
        .selectGridRow('#grdProcessCode',2)
        .clickButton('#btnDeleteProcessCode').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 2 rows. Are you sure you want to continue?','yesno', 'question') /* how to define number of rows deleted in the messagebox */
        .clickMessageBoxButton('yes').wait(10)
//        .checkGridData('#grdProcessCode', 0, 'colProcessCode','pc01')/*new method -  FRM-1552 or TS-447 > this is to make this checking false*/
//        .checkGridData('#grdProcessCode', 0, 'colDescription','process code 01')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .checkIfScreenClosed('processcode').wait(100)

//        /*Scenario 3. Delete used record */
//        /* 1.  */
//        .addFunction(function(next){t.diag("Scenario 3. Delete used record"); next();}).wait(100)
//        .openScreen('Process Code').wait(200)
//        .checkScreenShown ('processcode').wait(100)
//        .selectGridRow('#grdProcessCode',1)
//        .clickButton('#btnDeleteProcessCode').wait(100)
//        .checkMessageBox('iRely i21','You are about to delete 1 row. Are you sure you want to continue?','yesno', 'question')
//        .clickMessageBoxButton('no').wait(10)
////        .checkGridData('#grdProcessCode', 0, 'colProcessCode','pc01')/* FRM-1552 or FRM-1561> this is to make this checking false*/
////        .checkGridData('#grdProcessCode', 0, 'colDescription','process code 01')
//        .clickButton('#btnDeleteProcessCode').wait(100)
//        .checkMessageBox('iRely i21','You are about to delete 1 row. Are you sure you want to continue?','yesno', 'question')
//        .clickMessageBoxButton('yes').wait(10)
//        .clickButton('#btnClose').wait(100)
//        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//        .clickMessageBoxButton('yes').wait(100)
//        .checkIfScreenClosed('processcode').wait(100)

        .done()
})

