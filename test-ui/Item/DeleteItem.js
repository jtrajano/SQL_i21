/**
 * Created by CCallado on 1/19/2016.
 */

StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Add Item - Software Type Lot Tracked Yes Serial Number)*/
        .login('irelyadmin', 'i21by2015', '01')
        .addFunction(function(next){t.diag("Scenario 1. Open screen and check default controls' state"); next();}).wait(100)
        .expandMenu('Inventory').wait(200)
        .openScreen('Items').wait(5000)
        .checkScreenWindow({alias: 'icitems',title: 'Inventory UOMs',collapse: true,maximize: true,minimize: false,restore: false,close: true}).wait(500)
        .checkSearchToolbarButton({new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: true}).wait(100)
        .selectGridRow('#grdSearch',[28])
        .clickButton('#btnOpenSelected')
        .checkScreenShown('icitem').wait(200)
        .clickButton('#btnDelete')
        .checkMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes').wait(100)
        .checkIfScreenClosed('icitem').wait(100)




        .done()
});