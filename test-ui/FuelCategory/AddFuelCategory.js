/**
 * Created by CJ Callado
 */

StartTest (function (t) {

    var engine = new iRely.TestEngine();
    engine.start(t)

        /* 1. Add a Record */
            .login('AGADMIN','AGADMIN','AG').wait(1500)
            .addFunction(function(next){t.diag("Scenario 1. Add new Fuel Category > Scenario 2.Open screen and check default controls' state and add a new record"); next();}).wait(100)
            .expandMenu('Inventory').wait(1000)
            .openScreen('Fuel Categories').wait(1000)
            .checkScreenShown ('icfuelcategory').wait(200)
            .addFunction(function(next){t.diag("2. Add Data"); next();}).wait(200)
            .enterGridData('#grdGridTemplate', 0, 'colRinFuelCategoryCode', 'Test Fuel Category1').wait(150)
            .enterGridData('#grdGridTemplate', 0, 'colDescription', 'Test Description1').wait(150)
            .enterGridData('#grdGridTemplate', 0, 'colEquivalenceValue', 'Test Equivalence Value1').wait(150)
            .addFunction(function(next){t.diag("3. Check Status Message"); next();}).wait(1000)
            .checkStatusMessage('Edited')
            .clickButton('#btnSave').wait(1000)
            .checkStatusMessage('Saved').wait(100)
            .clickButton('#btnClose').wait(100)
            .checkIfScreenClosed('fuelcategory').wait(100)


        /* 2. Add Multiple Records*/
            .addFunction(function(next){t.diag("Scenario 3 > 1. Open Fuel Category Screen"); next();}).wait(100)
            .openScreen('Fuel Categories').wait(1000)
            .addFunction(function(next){t.diag("2. Add Multiple Data"); next();}).wait(200)
            .enterGridData('#grdGridTemplate', 1, 'colRinFuelCategoryCode', 'Test Fuel Category 2').wait(150)
            .enterGridData('#grdGridTemplate', 1, 'colDescription', 'Test Description 2').wait(150)
            .enterGridData('#grdGridTemplate', 1, 'colEquivalenceValue', 'Test Equivalence Value 2').wait(150)
            .enterGridData('#grdGridTemplate', 2, 'colRinFuelCategoryCode', 'Test Fuel Category 3').wait(150)
            .enterGridData('#grdGridTemplate', 2, 'colDescription', 'Test Description 3').wait(150)
            .enterGridData('#grdGridTemplate', 2, 'colEquivalenceValue', 'Test Equivalence Value 3').wait(150)
            .addFunction(function(next){t.diag("3. Check Status Message"); next();}).wait(1000)
            .checkStatusMessage('Edited')
            .clickButton('#btnSave').wait(1000)
            .checkStatusMessage('Saved').wait(100)
            .clickButton('#btnClose').wait(100)

         /* 3. Add another record, Click Close button, do NOT save the changes Click no*/
            .addFunction(function(next){t.diag("Scenario 3.Add another record, Click Close button, do NOT save the changes> 1. Open Screen"); next();}).wait(100)
            .openScreen('Fuel Categories').wait(1000)
            .checkScreenShown ('icfuelcategory').wait(200)
            .addFunction(function(next){t.diag("2. Add another Data"); next();}).wait(200)
            .enterGridData('#grdGridTemplate', 3, 'colRinFuelCategoryCode', 'Test Fuel Category 4').wait(150)
            .enterGridData('#grdGridTemplate', 3, 'colDescription', 'Test Description 4').wait(150)
            .enterGridData('#grdGridTemplate', 3, 'colEquivalenceValue', 'Test Equivalence Value 4').wait(150)
            .addFunction(function(next){t.diag("3.Close without saving"); next();}).wait(200)
            .clickButton('#btnClose').wait(100)
            .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
            .clickMessageBoxButton('no').wait(100)
            .addFunction(function(next){t.diag("3.Check records>unsaved records should not be displayed"); next();}).wait(200)
            .openScreen('Fuel Categories').wait(1000)
            .checkGridData('#grdGridTemplate',3,'colRinFuelCategoryCode','')
            .checkGridData('#grdGridTemplate',3,'colDescription','')
            .checkGridData('#grdGridTemplate',3,'colEquivalenceValue','')
            .clickButton('#btnClose').wait(100)

        /* 4. Add another record, Click Close button, do NOT save the changes Click cancel*/

            .addFunction(function(next){t.diag("Scenario 4.Add another record, Click Close button, do NOT save the changes> 1. Open Screen"); next();}).wait(100)
            .openScreen('Fuel Categories').wait(1000)
            .checkScreenShown ('icfuelcategory').wait(200)
            .addFunction(function(next){t.diag("2. Add Data another Data"); next();}).wait(200)
            .enterGridData('#grdGridTemplate', 3, 'colRinFuelCategoryCode', 'Test Fuel Category 4').wait(150)
            .enterGridData('#grdGridTemplate', 3, 'colDescription', 'Test Description 4').wait(150)
            .enterGridData('#grdGridTemplate', 3, 'colEquivalenceValue', 'Test Equivalence Value 4').wait(150)
            .addFunction(function(next){t.diag("3.Close without saving"); next();}).wait(200)
            .clickButton('#btnClose').wait(100)
            .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
            .clickMessageBoxButton('cancel').wait(100)
            .addFunction(function(next){t.diag("3.Check records>Nothing should happen"); next();}).wait(200)
            .checkGridData('#grdGridTemplate',3,'colRinFuelCategoryCode','')
            .checkGridData('#grdGridTemplate',3,'colDescription','')
            .checkGridData('#grdGridTemplate',3,'colEquivalenceValue','').wait(200)


        /* 5. Add another record, Click Close button, save the changes Click Yes*/
            .addFunction(function(next){t.diag("Scenario 5>Click Yes>"); next();}).wait(200)
            .clickButton('#btnClose').wait(100)
            .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
            .clickMessageBoxButton('yes').wait(100)
            .addFunction(function(next){t.diag("3.Check records> Should be saved in the screen"); next();}).wait(200)
            .openScreen('Fuel Categories').wait(1000)
            .checkGridData('#grdGridTemplate',3,'colRinFuelCategoryCode','Test Description 4')
            .checkGridData('#grdGridTemplate',3,'colDescription','Test Description 4')
            .checkGridData('#grdGridTemplate',3,'colEquivalenceValue','Test Description 4')
            .clickButton('#btnClose').wait(100)




         /* 6. Add Duplicate Record*/

            .addFunction(function(next){t.diag("Scenario 6>Add Duplicate Record>1. Open Screen"); next();}).wait(100)
            .openScreen('Fuel Categories').wait(1000)
            .checkScreenShown ('icfuelcategory').wait(200)
            .addFunction(function(next){t.diag("2. Add Duplicate Data"); next();}).wait(200)
            .enterGridData('#grdGridTemplate', 4, 'colRinFuelCategoryCode', 'Test Fuel Category1').wait(150)
            .enterGridData('#grdGridTemplate', 4, 'colDescription', 'Test').wait(150)
            .enterGridData('#grdGridTemplate', 4, 'colEquivalenceValue', 'Test').wait(150)
            .addFunction(function(next){t.diag("3.Save"); next();}).wait(200)
            .clickButton('#btnSave').wait(100)
            .checkMessageBox('iRely i21','Fuel Category Already Exists!','ok', 'error')
            .clickMessageBoxButton('ok').wait(100)
            .clickButton('#btnClose').wait(100)


        /* 7. Add Description or Equivalence Value Only*/

            .addFunction(function(next){t.diag("Scenario 6>Add Duplicate Record>1. Open Screen"); next();}).wait(100)
            .openScreen('Fuel Categories').wait(1000)
            .checkScreenShown ('icfuelcategory').wait(200)
            .addFunction(function(next){t.diag("2. Add Desc or Equivalence Value Only"); next();}).wait(200)
            .enterGridData('#grdGridTemplate', 4, 'colDescription', 'Test').wait(150)
            .enterGridData('#grdGridTemplate', 4, 'colEquivalenceValue', 'Test').wait(150)
            .addFunction(function(next){t.diag("3. Check required field."); next();}).wait(200)
            .clickButton('#btnSave').wait(100)
            .enterGridData('#grdGridTemplate', 4, 'colDescription', '').wait(150)
            .enterGridData('#grdGridTemplate', 4, 'colEquivalenceValue', '').wait(150)
            .clickButton('#btnSave').wait(100)
            .clickButton('#btnClose').wait(100)
            .clickMessageBoxButton('no').wait(100)


        /*8. Add primary key only then SAVE*/
            .addFunction(function(next){t.diag("Scenario 6>Add Duplicate Record>1. Open Screen"); next();}).wait(100)
            .openScreen('Fuel Categories').wait(1000)
            .enterGridData('#grdGridTemplate', 4, 'colRinFuelCategoryCode', 'TFC - 05').wait(150)
            .checkStatusMessage('Edited')
            .clickButton('#btnSave').wait(100)
            .checkStatusMessage('Saved').wait(100)
            .clickButton('#btnClose')


        .done();
});
