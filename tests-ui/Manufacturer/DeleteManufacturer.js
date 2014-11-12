/**
 * Created by RQuidato on 11/12/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1. Delete unused record */
        /* 1.  */
        .login('ssiadmin','summit','ag').wait(1500)
        .addFunction(function(next){t.diag("Scenario 1. Delete unused record"); next();}).wait(100)
        .expandMenu('Inventory').wait(100)
        .expandMenu('Maintenance').wait(200)
        .openScreen('Manufacturer').wait(500)
        //search screen name
        .checkScreenShown ('search').wait(200)
        .checkScreenWindow({alias: 'search', title: 'Search Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .selectSearchRowByIndex(0)
        .selectSearchRowByFilter('Manu03')
        .clickButton('#btnOpenSelected').wait(100)
        .addFunction(function(next){t.diag("1.a Opens selected record = Passed"); next();}).wait(100)
        .checkScreenWindow({alias: 'manufacturer', title: 'Manufacturer', collapse: true, maximize: true, minimize: false, restore: false, close: true })
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('no').wait(10)
        //close the delete msg and bring back to the record
        .clickButton('#btnDelete').wait(100)
        .checkMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(10)
        .checkIfScreenClosed('manufacturer').wait(100)

        /* Scenario 2. Delete used record*/

        .done()
})