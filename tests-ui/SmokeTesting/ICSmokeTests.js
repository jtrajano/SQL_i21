/**
 * Created by CCallado on 9/26/2016.
 */
StartTest(function (t) {

    var engine = new iRely.TestEngine(),
        commonSM = Ext.create('SystemManager.CommonSM');

    engine.start(t)

        /*Add Item - Inventory Type Lot Tracked Yes Serial Number)*/
        .addFunction(function (next) { commonSM.commonLogin(t, next); })
        .addFunction(function (next) { t.diag("Scenario 1. Open screen and check default controls' state"); next(); }).wait(1000)
        .expandMenu('Inventory').wait(5000)
        .openScreen('Items').wait(5000)
        .checkScreenWindow({ alias: 'icitems', title: 'Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true }).wait(1000)
        .checkSearchToolbarButton({ new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: false }).wait(100)
        .clickButton('#btnNew').wait(200)
        .checkScreenShown('icitem').wait(200)
        .checkToolbarButton({ new: true, save: true, search: true, refresh: false, delete: true, undo: true, duplicate: true, close: true })
        .checkControlVisible(['#btnInsertUom', '#btnDeleteUom', '#btnLoadUOM', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true)
        .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true)
        .checkStatusMessage('Ready')
        .clickButton('#btnClose').wait(100)
        .clickMessageBoxButton('no').wait(100)
        .checkIfScreenClosed('icitem').wait(100)



        .done()
});



