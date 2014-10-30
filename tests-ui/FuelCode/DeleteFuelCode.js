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
        .openScreen('Fuel Code').wait(200)
        .checkScreenShown ('fuelcode').wait(100)
        .selectGridRow('#grdFuelCode',1)
        .clickButton('#btnDeleteFuelCode').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row. Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('no').wait(10)
//        .checkGridData('#grdFuelCode', 0, 'colFuelCode','fc01')
//        .checkGridData('#grdFuelCode', 0, 'colDescription','fuel code 01')
        .clickButton('#btnDeleteFuelCategory').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 1 row. Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(10) /*FRM-1553*/
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .checkIfScreenClosed('fuelcode').wait(100)




        /*Scenario 2. Delete multiple records */
        .addFunction(function(next){t.diag("Scenario 2. Delete multiple records"); next();}).wait(100)
        .openScreen('Fuel Code').wait(200)
        .checkScreenShown ('fuelcode').wait(100)
        .selectGridRow('#grdFuelCode',1) /* IC-98 */
        .selectGridRow('#grdFuelCode',2)
        .clickButton('#btnDeleteFuelCode').wait(100)
        .checkMessageBox('iRely i21','You are about to delete 2 rows. Are you sure you want to continue?','yesno', 'question') /* how to define number of rows deleted in the messagebox */
        .clickMessageBoxButton('yes').wait(10)
//        .checkGridData('#grdFuelCode', 0, 'colFuelCode','fc01')/*new method -  FRM-1552 or TS-447 > this is to make this checking false*/
//        .checkGridData('#grdFuelCode', 0, 'colDescription','fuel code 01')
        .clickButton('#btnClose').wait(100)
        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .checkIfScreenClosed('fuelcode').wait(100)

//        /*Scenario 3. Delete used record */
//        /* 1.  */
//        .addFunction(function(next){t.diag("Scenario 3. Delete used record"); next();}).wait(100)
//        .openScreen('Fuel Code').wait(200)
//        .checkScreenShown ('fuelcode').wait(100)
//        .selectGridRow('#grdFuelCode',1)
//        .clickButton('#btnDeleteFuelCode').wait(100)
//        .checkMessageBox('iRely i21','You are about to delete 1 row. Are you sure you want to continue?','yesno', 'question')
//        .clickMessageBoxButton('no').wait(10)
////        .checkGridData('#grdFuelCode', 0, 'colFuelCode','fc01')/* FRM-1552 or FRM-1561> this is to make this checking false*/
////        .checkGridData('#grdFuelCode', 0, 'colDescription','fuel code 01')
//        .clickButton('#btnDeleteFuelCode').wait(100)
//        .checkMessageBox('iRely i21','You are about to delete 1 row. Are you sure you want to continue?','yesno', 'question')
//        .clickMessageBoxButton('yes').wait(10)
//        .clickButton('#btnClose').wait(100)
//        .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//        .clickMessageBoxButton('yes').wait(100)
//        .checkIfScreenClosed('fuelcode').wait(100)

        .done()
})

