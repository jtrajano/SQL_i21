/**
 * Created by CCallado on 1/21/2016.
 */


StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        .login('irelyadmin', 'i21by2015', '01')
        .addFunction(function(next){t.diag("Scenario 1. Open screen and check default controls' state"); next();}).wait(100)
        .expandMenu('Inventory').wait(200)
        .openScreen('Commodities').wait(3000)
        .checkScreenWindow({alias: 'icitems',title: 'Category',collapse: true,maximize: true,minimize: false,restore: false,close: true}).wait(1000)
        .checkSearchToolbarButton({new: true, view: true, openselected: false, openall: false, refresh: true, export: false, close: true}).wait(100)
        .clickButton('#btnNew').wait(200)
        .checkScreenShown('iccommodity')


        /*Add Commodity with no UOM Setup and Attributes*/
        .addFunction(function(next){t.diag("Scenario 2. Add Commodity with no UOM Setup and Attributes"); next();}).wait(100)
        .enterData('#txtCommodityCode','Test Commodity 1').wait(100)
        .enterData('#txtDescription','Test Commodity 1').wait(100)
        .clickCheckBox('#chkExchangeTraded',true).wait(100)
        .enterData('#txtDecimalsOnDpr','6.00').wait(100)
        .enterData('#txtConsolidateFactor','6.00').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity')



        /*Add Commodity with UOM*/
        .addFunction(function(next){t.diag("Scenario 3. Add Commodity with UOM"); next();}).wait(100)
        .clickButton('#btnNew')
        .enterData('#txtCommodityCode','Test Commodity 2').wait(100)
        .enterData('#txtDescription','Test Commodity 2').wait(100)
        .clickCheckBox('#chkExchangeTraded',true).wait(100)
        .enterData('#txtDecimalsOnDpr','6.00').wait(100)
        .enterData('#txtConsolidateFactor','6.00').wait(100)
        .selectGridComboRowByFilter('#grdUom', 0,'strUnitMeasure','LB', 300,'strUnitMeasure').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .selectGridComboRowByFilter('#grdUom', 1,'strUnitMeasure','50 lb bag', 300,'strUnitMeasure').wait(100)
        .clickGridCheckBox('#grdUom', 'strUnitMeasure', 'LB', 'ysnStockUnit', true).wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity')


        /*Add Duplicate Commodity*/
        .addFunction(function(next){t.diag("Scenario 4. Add Duplicate commodity"); next();}).wait(100)
        .clickButton('#btnNew')
        .enterData('#txtCommodityCode','Test Commodity 2').wait(100)
        .enterData('#txtDescription','Test Commodity 2').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21', 'Commodity Code must be unique.', 'ok', 'error').wait(100)
        .clickMessageBoxButton('ok')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity')


        .done()
});

