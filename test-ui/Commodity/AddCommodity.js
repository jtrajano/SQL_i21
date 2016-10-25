StartTest(function (t) {

    var engine = new iRely.TestEngine();
    var commonSM = Ext.create('SystemManager.CommonSM');
    var commonIC = Ext.create('i21.test.Inventory.CommonIC');

    engine.start(t)

        // LOG IN
        .displayText('Log In').wait(500)
        .addFunction(function (next) {
            commonSM.commonLogin(t, next); }).wait(100)
        .waitTillMainMenuLoaded('Login Successful').wait(500)


        .expandMenu('Inventory').wait(500)
        .markSuccess('Inventory successfully expanded').wait(300)
        .openScreen('Commodities').wait(500)
        .waitTillLoaded('Open Commodity  Search Screen Successful').wait(200)



        //#1 Add Commodity with no UOM Setup and Attributes
        .displayText('====== Scenario 1. Add Commodity with no UOM Setup and Attributes ======').wait(300)
        .clickButton('#btnNew').wait(300)
        .waitTillVisible('iccommodity','Open Commodity Screen Successful').wait(300)
        .enterData('#txtCommodityCode','Test Commodity 1').wait(100)
        .enterData('#txtDescription','Test Commodity 1').wait(100)
        .clickCheckBox('#chkExchangeTraded',true).wait(100)
        .enterData('#txtDecimalsOnDpr','6.00').wait(100)
        .enterData('#txtConsolidateFactor','6.00').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkStatusMessage('Saved').wait(100)
        .markSuccess('Add Commodity with no UOM Setup and Attributes Successful')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity').wait(300)



        //#2 Add Commodity with UOM
        .displayText('====== Scenario 2. Add Commodity with no UOM Setup and Attributes ======').wait(300)
        .clickButton('#btnNew').wait(300)
        .waitTillVisible('iccommodity','Open Commodity Screen Successful').wait(300)
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
        .markSuccess('Add Commodity with no UOM Setup and Attributes Successful')
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('iccommodity').wait(300)


        //#3 Add Duplicate Commodity
        .displayText('====== Scenario 2. Add Duplicate commodity ======').wait(300)
        .clickButton('#btnNew')
        .waitTillVisible('iccommodity','Open Commodity Screen Successful').wait(300)
        .enterData('#txtCommodityCode','Test Commodity 2').wait(100)
        .enterData('#txtDescription','Test Commodity 2').wait(100)
        .clickButton('#btnSave').wait(100)
        .checkMessageBox('iRely i21', 'Commodity Code must be unique.', 'ok', 'error').wait(100)
        .clickMessageBoxButton('ok').wait(200)
        .clickButton('#btnClose').wait(200)
        .checkIfScreenClosed('iccommodity').wait(300)
        .markSuccess('Was not able to add duplicate commodity!')


        .done();
});

