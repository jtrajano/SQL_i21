/**
 * Created by CCallado on 1/22/2016.
 */



StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /*Scenario 1: Open Search Storage Location Screen and toolbar buttons*/
        .login('irelyadmin', 'i21by2015', '01')
        .addFunction(function(next){t.diag("Scenario 1: Open Search Storage Location Screen and toolbar buttons"); next();}).wait(100)
        .expandMenu('Inventory').wait(200)
        .openScreen('Storage Unit Types').wait(3000)
        .checkScreenWindow({alias: 'icstorageunit',title: 'Storage Locations',collapse: true,maximize: true,minimize: false,restore: false,close: true}).wait(1000)
        .checkSearchToolbarButton({new: true, view: true, openselected: false, openall: false, refresh: true, export: false, close: true}).wait(100)
        .clickButton('#btnNew').wait(200)
        .checkScreenShown('icstorageunit')


        /*Scenario 2: Allow bin of the same name to be used in a different Sub Location.*/
        .addFunction(function(next){t.diag("Scenario 2: Allow bin of the same name to be used in a different Sub Location."); next();}).wait(100)
        .enterData('#txtName','Test SL - SH - 001').wait(100)
        .enterData('#txtDescription','Test SL - SH - 001').wait(100)
        .selectComboRowByFilter('#cboUnitType','Bin',300, 'strStorageUnitType').wait(100)
        .selectComboRowByFilter('#cboLocation','0001 - Fort Wayne',300, 'intLocationId').wait(100)
        .selectComboRowByFilter('#cboSubLocation','Stellhorn',300, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboParentUnit','RM Storage',300, 'intParentStorageLocationId').wait(100)
        .enterData('#txtAisle','Test Aisle').wait(100)
        .clickCheckBox('#chkAllowConsume',true).wait(100)
        .clickCheckBox('#chkAllowMultipleItems',true).wait(100)
        .clickCheckBox('#chkAllowMultipleLots',true).wait(100)
        .clickCheckBox('#chkMergeOnMove',true).wait(100)
        .clickCheckBox('#chkCycleCounted',true).wait(100)
        .clickCheckBox('#chkDefaultWarehouseStagingUnit',true).wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icstorageunit')

        .addFunction(function(next){t.diag("Scenario 2: Allow bin of the same name to be used in a different Sub Location."); next();}).wait(100)
        .clickButton('#btnNew').wait(200)
        .enterData('#txtName','Test SL - SH - 001').wait(100)
        .enterData('#txtDescription','Test SL - SH - 001').wait(100)
        .selectComboRowByFilter('#cboUnitType','Bin',300, 'strStorageUnitType').wait(100)
        .selectComboRowByFilter('#cboLocation','0001 - Fort Wayne',300, 'intLocationId').wait(100)
        .selectComboRowByFilter('#cboSubLocation','FG Station',300, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboParentUnit','RM Storage',300, 'intParentStorageLocationId').wait(100)
        .enterData('#txtAisle','Test Aisle').wait(100)
        .clickCheckBox('#chkAllowConsume',true).wait(100)
        .clickCheckBox('#chkAllowMultipleItems',true).wait(100)
        .clickCheckBox('#chkAllowMultipleLots',true).wait(100)
        .clickCheckBox('#chkMergeOnMove',true).wait(100)
        .clickCheckBox('#chkCycleCounted',true).wait(100)
        .clickCheckBox('#chkDefaultWarehouseStagingUnit',true).wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icstorageunit')


        /*Scenario 3: Allow bin of the same name to be used in a different Location*/
        .clickButton('#btnNew').wait(100)
        .addFunction(function(next){t.diag("Scenario 3: Allow bin of the same name to be used in a different Location."); next();}).wait(100)
        .enterData('#txtName','Test SL - SH - 002').wait(100)
        .enterData('#txtDescription','Test SL - SH - 002').wait(100)
        .selectComboRowByFilter('#cboUnitType','Bin',300, 'strStorageUnitType').wait(100)
        .selectComboRowByFilter('#cboLocation','0001 - Fort Wayne',300, 'intLocationId').wait(100)
        .selectComboRowByFilter('#cboSubLocation','Stellhorn',300, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboParentUnit','RM Storage',300, 'intParentStorageLocationId').wait(100)
        .enterData('#txtAisle','Test Aisle').wait(100)
        .clickCheckBox('#chkAllowConsume',true).wait(100)
        .clickCheckBox('#chkAllowMultipleItems',true).wait(100)
        .clickCheckBox('#chkAllowMultipleLots',true).wait(100)
        .clickCheckBox('#chkMergeOnMove',true).wait(100)
        .clickCheckBox('#chkCycleCounted',true).wait(100)
        .clickCheckBox('#chkDefaultWarehouseStagingUnit',true).wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icstorageunit')

        .addFunction(function(next){t.diag("Scenario 3: Allow bin of the same name to be used in a different Location."); next();}).wait(100)
        .clickButton('#btnNew').wait(200)
        .enterData('#txtName','Test SL - SH - 002').wait(100)
        .enterData('#txtDescription','Test SL - SH - 002').wait(100)
        .selectComboRowByFilter('#cboUnitType','Bin',300, 'strStorageUnitType').wait(100)
        .selectComboRowByFilter('#cboLocation','0002 - Indianapolis',300, 'intLocationId').wait(100)
        .selectComboRowByFilter('#cboSubLocation','Indy',300, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboParentUnit','RM Storage',300, 'intParentStorageLocationId').wait(100)
        .enterData('#txtAisle','Test Aisle').wait(100)
        .clickCheckBox('#chkAllowConsume',true).wait(100)
        .clickCheckBox('#chkAllowMultipleItems',true).wait(100)
        .clickCheckBox('#chkAllowMultipleLots',true).wait(100)
        .clickCheckBox('#chkMergeOnMove',true).wait(100)
        .clickCheckBox('#chkCycleCounted',true).wait(100)
        .clickCheckBox('#chkDefaultWarehouseStagingUnit',true).wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icstorageunit')

        /*Scenario 4: Check Mandatory Fields
        .addFunction(function(next){t.diag("Scenario 4: Check Mandatory Fields"); next();}).wait(100)
        .clickButton('#btnNew').wait(200)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Ready').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icstorageunit')*/


        /*Scenario 5: Add Duplicate Storage Location*/
        .addFunction(function(next){t.diag("Scenario 5: Add Duplicate Storage Location"); next();}).wait(100)
        .clickButton('#btnNew').wait(100)
        .enterData('#txtName','Test SL - SH - 001').wait(100)
        .enterData('#txtDescription','Test SL - SH - 001').wait(100)
        .selectComboRowByFilter('#cboUnitType','Bin',300, 'strStorageUnitType').wait(100)
        .selectComboRowByFilter('#cboLocation','0001 - Fort Wayne',300, 'intLocationId').wait(100)
        .selectComboRowByFilter('#cboSubLocation','Stellhorn',300, 'intSubLocationId').wait(100)
        .selectComboRowByFilter('#cboParentUnit','RM Storage',300, 'intParentStorageLocationId').wait(100)
        .enterData('#txtAisle','Test Aisle').wait(100)
        .clickCheckBox('#chkAllowConsume',true).wait(100)
        .clickCheckBox('#chkAllowMultipleItems',true).wait(100)
        .clickCheckBox('#chkAllowMultipleLots',true).wait(100)
        .clickCheckBox('#chkMergeOnMove',true).wait(100)
        .clickCheckBox('#chkCycleCounted',true).wait(100)
        .clickCheckBox('#chkDefaultWarehouseStagingUnit',true).wait(100)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21', 'Storage Location must be unique per Location and Sub Location.', 'ok', 'error').wait(100)
        .clickMessageBoxButton('ok').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icstorageunit')


        .done()
});

