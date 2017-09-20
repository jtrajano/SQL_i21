StartTest (function (t) {
    //var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

//Build JDE Accounts
    .addFunction(function(next){
        var ysnBuild20011=false;
        var ysnBuild15011=false;
        var ysnBuild50011=false;
        var ysnBuild40011=false;
        var ysnBuild16011=false;
        var ysnBuild50021=false;
        var ysnBuild12011=false;
        var ysnBuild20003=false;
        var ysnBuild49011=false;
        var ysnBuild59011=false;
        var ysnBuildPrimaryAccount =false;
        ysnBuildPrimaryAccount =false;
        new iRely.FunctionalTest().start(t, next)
        .addScenario('Precondition Setup','GL Setup',1000)
        .clickMenuFolder('General Ledger')
        .clickMenuScreen('GL Account Detail')
        
        .clickButton('Segments')
        .waitUntilLoaded('glsegmentaccounts')
        .selectGridRowNumber('SegmentName', 1)
        
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '20011[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 20011 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild20011 =true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 20011 does not exists.')
                    .addStep('Add Primary Account 20011')
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '20011'}
                                                        ,{column: 'strDescription', data: 'AP Clearing'}
                                                       ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '20011[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Pending Payables' ,'strAccountGroup',1) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'AP Clearing' ,'strAccountCategory',1)                                                       
                    .done()    
                },
                continueOnFail: true   
        })  
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '15011[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 15011 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild15011 =true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 15011 does not exists.')
                    .addStep('Add Primary Account 15011')
                    .clearTextFilter('FilterGrid')                                    
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '15011'}
                                                        ,{column: 'strDescription', data: 'Inventories'}
                                                        ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '15011[ENTER]')
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Inventories' ,'strAccountGroup',1) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Inventory' ,'strAccountCategory',3)
                    .done()    
                },
                continueOnFail: true   
        })
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '50011[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 50011 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild50011=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 50011 does not exists.')
                    .addStep('Add Primary Account 50011')
                    .clearTextFilter('FilterGrid')
                    // .clickButton('AddSegment')
                    // .enterGridData('SegmentAccounts',1,'colCode','50011')
                    // .enterGridData('SegmentAccounts',1,'colGLSegmentAccountsDescription','COGS')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '50011'}
                                    ,{column: 'strDescription', data: 'COGS'}
                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '50011[ENTER]')
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Cost of Goods Sold' ,'strAccountGroup',1) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Cost of Goods' ,'strAccountCategory',1)
                    .done()    
                },
                continueOnFail: true   
        })
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '40011[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 40011 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild40011=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 40011 does not exists.')
                    .addStep('Add Primary Account 40011')
                    .clearTextFilter('FilterGrid')
                    // .clickButton('AddSegment')
                    // .enterGridData('SegmentAccounts',1,'colCode','40011')
                    // .enterGridData('SegmentAccounts',1,'colGLSegmentAccountsDescription','Sales')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '40011'}
                                    ,{column: 'strDescription', data: 'Sales'}
                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '40011[ENTER]')
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Sales' ,'strAccountGroup',2) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Sales Account' ,'strAccountCategory',4)
                    .done()    
                },
                continueOnFail: true   
        })
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '16011[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 16011 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild16011=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 16011 does not exists.')
                    .addStep('Add Primary Account 16011')
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '16011'}
                                                       ,{column: 'strDescription', data: 'Inventory in Transit'}
                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '16011[ENTER]')
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Inventories' ,'strAccountGroup',1) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Inventory In-Transit' ,'strAccountCategory',1)
                    .done()    
                },
                continueOnFail: true   
        })
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '50021[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 50021 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild50021=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 50021 does not exists.')
                    .addStep('Add Primary Account 50021')
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '50021'}
                                                       ,{column: 'strDescription', data: 'Inventory Adjustment'}
                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '50021[ENTER]')
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Cost of Goods Sold' ,'strAccountGroup',1) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Inventory Adjustment' ,'strAccountCategory',1)
                    .done()    
                },
                continueOnFail: true   
        })
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '12011[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 12011 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild12011=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 12011 does not exists.')
                    .addStep('Add Primary Account 12011')
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '12011'}
                                                       ,{column: 'strDescription', data: 'Accounts Receivable'}
                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '12011[ENTER]')
                    // .clickButton('AddSegment')
                    // .enterGridData('SegmentAccounts',1,'colCode','12011')
                    // .enterGridData('SegmentAccounts',1,'colGLSegmentAccountsDescription','Accounts Receivable')
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Receivables' ,'strAccountGroup',1) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'AR Account' ,'strAccountCategory',1)
                    .done()    
                },
                continueOnFail: true   
        })
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '20003[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 20003 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild20003=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 20003 does not exists.')
                    .addStep('Add Primary Account 20003')
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '20003'}
                                                       ,{column: 'strDescription', data: 'Accounts Payable'}
                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '20003[ENTER]')
                    //.clickButton('AddSegment')
                    // .enterGridData('SegmentAccounts',1,'colCode','20003')
                    // .enterGridData('SegmentAccounts',1,'colGLSegmentAccountsDescription','Accounts Payable')
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Payables' ,'strAccountGroup',1) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'AP Account' ,'strAccountCategory',1)
                    .done()    
                },
                continueOnFail: true   
        })
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '49011[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 49011 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild49011=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 49011 does not exists.')
                    .addStep('Add Primary Account 49011')
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '49011'}
                                                       ,{column: 'strDescription', data: 'Other Charge Income'}
                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '49011[ENTER]')
                    // .clickButton('AddSegment')
                    // .enterGridData('SegmentAccounts',1,'colCode','49011')
                    // .enterGridData('SegmentAccounts',1,'colGLSegmentAccountsDescription','Other Charge Income')
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Other Income' ,'strAccountGroup',1) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Other Charge Income' ,'strAccountCategory',1)
                    .done()    
                },
                continueOnFail: true   
        })
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '59011[ENTER]')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 59011 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysnBuild59011=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 59011 does not exists.')
                    .addStep('Add Primary Account 59011')
                    .clearTextFilter('FilterGrid')
                    //.clickButton('AddSegment')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '59011'}
                                                       ,{column: 'strDescription', data: 'Other Charge Expense'}
                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '59011[ENTER]')
                    // .clickButton('AddSegment')
                    // .enterGridData('SegmentAccounts',1,'colCode','59011')
                    // .enterGridData('SegmentAccounts',1,'colGLSegmentAccountsDescription','Other Charge Expense')
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Other Expense' ,'strAccountGroup',1) 
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Other Charge Expense' ,'strAccountCategory',1)
                    .done()    
                },
                continueOnFail: true   
        })
       
        // Proccess To Build Primary Accounts
        .continueIf({
                    expected: 'true',
                    actual: function (sring) {
                        return ysnBuildPrimaryAccount.toString();
                    },
                    success: function (next) {
                        new iRely.FunctionalTest().start(t, next)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Build')
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild20011;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '20011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '20011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()    

                                    .done();
                                },
                                continueOnFail: true   
                        })
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild15011;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '15011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '15011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()   
                                    
                                    .done();

                                },
                                continueOnFail: true   
                        })
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild50011 ;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '50011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '50011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()   
                                    
                                    .done();
                                },
                                continueOnFail: true   
                        })
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild40011 ;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '40011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '40011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()   
                                    
                                    .done();
                                },
                                continueOnFail: true   
                        })
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild16011 ;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '16011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '16011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()   
                                    
                                    .done();
                                },
                                continueOnFail: true   
                        })
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild50021 ;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '50021')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '50021')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()   
                                    
                                    .done();
                                },
                                continueOnFail: true   
                        })
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild12011 ;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '12011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '12011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()   
                                    
                                    .done();
                                },
                                continueOnFail: true   
                        })
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild20003 ;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '20003')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '20003')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()   
                                    
                                    .done();
                                },
                                continueOnFail: true   
                        })
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild49011 ;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '49011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '49011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .clearTextFilter()
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()   
                                
                                    .done();
                                },
                                continueOnFail: true   
                        })
                        .continueIf({
                                expected: true,
                                actual: function (bool) {
                                    return ysnBuild59011 ;
                                },
                                success: function (next) {
                                    new iRely.FunctionalTest().start(t, next)
                                    
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '59011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '001') 
                                    .selectGridRowNumber('BuildAccountsSegment', 1)
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .waitUntilLoaded()
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 11.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                   .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()
                                    
                                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '59011')
                                    .selectGridRowNumber('BuildAccountsPrimarySegment', 1)
                                    .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '00') 
                                    .selectGridRowNumber('BuildAccountsSegment', 2)
                                    .selectGridRowNumber('BuildAccountsSegment', 14)
                                    .addFunction(function (next) {
                                        t.chain(
                                            { click : "#frmBuildAccounts #tabBuildAccounts panel[title=Details] #grdBuildAccountsSegment => table.x-grid-item:nth-child(1) .x-grid-cell:nth-child(2)", offset : [20.6666259765625, 40.666656494140625] }
                                        )
                                        next();
                                    })
                                    .clickButton('Build')
                                    .waitUntilLoaded()
                                    .clickButton('Commit')
                                    .waitUntilLoaded()
                                    .clickMessageBoxButton('ok')
                                    .waitUntilLoaded()
                                   
                                    .waitUntilLoaded()   
                                    
                                    .done();
                                },
                                continueOnFail: true   
                        })
                        .waitUntilLoaded()
                        .clickButton('Close')
                        
                        .done();
                    },
                    continueOnFail: true   
        })
       .waitUntilLoaded()
       .clickButton('Close')
       .clickMenuFolder('General Ledger')
       .done()  
    }) 
//Create JDE UOM's
    .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .addScenario('Precondition Setup','UOM Setup',1000)
        .clickMenuFolder('Inventory')
        .clickMenuScreen('Inventory UOM')
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','LB1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM LB1 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM LB1 does not exists.')
                    .addStep('Add UOM LB1')
                    .clickButton('New')
                    .waitUntilLoaded()
                    .enterData('Text Field','UnitMeasure','LB1' )
                    .enterData('Text Field','Symbol','LB1' )
                    .selectComboBoxRowNumber('UnitType',6)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .done()    
                },
                continueOnFail: true   
        })  
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','10-lb bag1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 10-lb bag1 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 10-lb bag1 does not exists.')
                    .addStep('Add UOM 10-lb bag1')
                    .clickButton('New')
                    .waitUntilLoaded()
                    .enterData('Text Field','UnitMeasure','10-lb bag1' )
                    .enterData('Text Field','Symbol','10-lb bag1' )
                    .selectComboBoxRowNumber('UnitType',7)
                    .clickButton('InsertConversion')
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM', 'LB1' ,'strUnitMeasure',1)
                    .enterGridData('Conversion',1,'colConversionToStockUOM',10) 
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','20-lb bag1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 20-lb bag1 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 20-lb bag1 does not exists.')
                    .addStep('Add UOM 20-lb bag1')
                    .clickButton('New')
                    .waitUntilLoaded()
                    .enterData('Text Field','UnitMeasure','20-lb bag1' )
                    .enterData('Text Field','Symbol','20-lb bag1' )
                    .selectComboBoxRowNumber('UnitType',7)
                    .clickButton('InsertConversion')
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM', 'LB1' ,'strUnitMeasure',1)
                    .enterGridData('Conversion',1,'colConversionToStockUOM',20) 
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','KG1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM KG1 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM KG1 does not exists.')
                    .addStep('Add UOM KG1')
                    .clickButton('New')
                    .waitUntilLoaded()
                    .enterData('Text Field','UnitMeasure','KG1' )
                    .enterData('Text Field','Symbol','KG1' )
                    .selectComboBoxRowNumber('UnitType',6)
                    .clickButton('InsertConversion')
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM', 'LB1' ,'strUnitMeasure',1)
                    .enterGridData('Conversion',1,'colConversionToStockUOM',2.20462) 
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded()
        .doubleClickSearchRowValue('LB1', 'strUnitMeasure', 1)
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','KG1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdConversion').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM KG1 exists.')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM KG1 does not exists.')
                    .addStep('Add UOM KG1')
                    .clearTextFilter('FilterGrid')
                    .clickButton('InsertConversion')
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM', 'KG1' ,'strUnitMeasure',1)
                    .enterGridData('Conversion',1,'colConversionToStockUOM',2.20+'[ENTER]')
                    .clearTextFilter('FilterGrid') 
                    
                    .done()    
                },
                continueOnFail: true   
        })
        
        .enterData('Text Field','FilterGrid','10-lb bag1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdConversion').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 10-lb bag1 exists.')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 10-lb bag1 does not exists.')
                    .addStep('Add UOM 10-lb bag1')
                    .clearTextFilter('FilterGrid')
                    .clickButton('InsertConversion')
                    .selectGridComboBoxRowValue('Conversion',2,'colOtherUOM', '10-lb bag1' ,'strUnitMeasure',1)
                    .enterGridData('Conversion',2,'colConversionToStockUOM',10+'[ENTER]')
                    .clearTextFilter('FilterGrid') 
                    .done()    
                },
                continueOnFail: true   
        })
        

        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','20-lb bag1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdConversion').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 20-lb1 bag1 exists.')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM 20-lb1 bag1 does not exists.')
                    .addStep('Add UOM 20-lb bag1')
                    .clearTextFilter('FilterGrid')
                    .clickButton('InsertConversion')
                    .selectGridComboBoxRowValue('Conversion',3,'colOtherUOM', '20-lb bag1' ,'strUnitMeasure',1)
                    .enterGridData('Conversion',3,'colConversionToStockUOM',20+'[ENTER]')
                    .clearTextFilter('FilterGrid') 
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .clickMenuFolder('Inventory')
        .done()
    })
//Create JDE Category    
    .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .addScenario('Precondition Setup','Category Setup',1000)
        .clickMenuFolder('Inventory')
        .clickMenuScreen('Categories')
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','OC Category1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Category OC Category1 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Category OC Category1 does not exists.')
                    .addStep('Add Category OC Category1')
                    .clickButton('New')
                    .waitUntilLoaded()
                    .enterData('Text Field','CategoryCode','OC Category1' )
                    .enterData('Text Field','Description','OC Category1 Description' )
                    .selectComboBoxRowNumber('InventoryType',6)
                    .clickTab('GL Accounts')
                    .waitUntilLoaded()
                    .clickButton('AddRequired')
                    .waitUntilLoaded()
                    .selectGridRowNumber('GlAccounts', 1)
                    .selectGridComboBoxRowValue('GlAccounts',1,'colAccountId', '20011-0001-001' ,'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts',2,'colAccountId', '49011-0001-001' ,'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts',3,'colAccountId', '59011-0001-001' ,'strAccountId',1)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .done()    
                },
                continueOnFail: true   
        })
        
                
        .clickMenuScreen('Categories')
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','Inventory Category1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Category Inventory Category1 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Category Inventory Category1 does not exists.')
                    .addStep('Add Category Inventory Category1')
                    .clickButton('New')
                    .waitUntilLoaded()
                    .enterData('Text Field','CategoryCode','Inventory Category1' )
                    .enterData('Text Field','Description','Inventory Category1 Description' )
                    .selectComboBoxRowNumber('InventoryType',2)
                    .selectComboBoxRowNumber('CostingMethod',1)
                    .selectComboBoxRowNumber('InventoryValuation',1)
                    .clickTab('GL Accounts')
                    .waitUntilLoaded()
                    .clickButton('AddRequired')
                    .waitUntilLoaded()
                    .selectGridRowNumber('GlAccounts', 1)
                    .selectGridComboBoxRowValue('GlAccounts',1,'colAccountId', '20011-0001-001' ,'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts',2,'colAccountId', '15011-0001-001' ,'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts',3,'colAccountId', '50011-0001-001' ,'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts',4,'colAccountId', '40011-0001-001' ,'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts',5,'colAccountId', '16011-0001-001' ,'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts',6,'colAccountId', '50021-0001-001' ,'strAccountId',1)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .done()    
                },
                continueOnFail: true   
        })
        .clickMenuFolder('Inventory')
        .done()          
    })
//Create JDE Purchasing Groups
    .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .addScenario('Precondition Setup','Purchasing Groups Setup',1000)
        .clickMenuFolder('Common Info')
        .clickMenuScreen('Purchasing Groups')
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','South East Asian Group' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdGridTemplate').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('South East Asian Group exists.')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('South East Asian Group does not exists.')
                    .addStep('South East Asian Group')
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('GridTemplate', [{column: 'strName', data: 'South East Asian Group'}
                                                    ,{column: 'strDescription', data:'South East Asian Group Description'}])
                    .clickButton('Save')
                    .clearTextFilter('FilterGrid')
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','North American Group' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdGridTemplate').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('North American Group exists.')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('North American Group does not exists.')
                    .addStep('North American Group')
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('GridTemplate', [{column: 'strName', data: 'North American Group'}
                                                    ,{column: 'strDescription', data:'North American Group Description'}])
                    .clickButton('Save')
                    .clearTextFilter('FilterGrid')
                    .done()    
                },
                continueOnFail: true   
        })
        .clickButton('Close')
        .clickMenuFolder('Common Info')
        .done()
    })    
//Create JDE Commodities
    .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .addScenario('Precondition Setup','Commodity Setup',1000)
        .clickMenuFolder('Inventory')
        .clickMenuScreen('Commodities')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','Commodity1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Commodity Commodity1 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Commodity Commodity1 does not exists.')
                    .addStep('Add Commodity Commodity1')
                    .clickButton('New')
                    .waitUntilLoaded()
                    .enterData('Text Field','CommodityCode','Commodity1' )
                    .enterData('Text Field','Description','Commodity1 Description' )
                    .enterGridNewRow('Uom', [{column: 'strUnitMeasure', data: 'LB1'}])
                    .selectGridRowNumber('Uom', 1)
                    .selectGridComboBoxRowValue('Uom',1,'colUOMCode', 'LB1' ,'strUnitMeasure',1)
                    .clickGridCheckBox('Uom',1 , 'colUOMStockUnit', 'LB1', 'ysnStockUnit', true)
                    .selectGridComboBoxRowValue('Uom',2,'colUOMCode', 'KG1' ,'strUnitMeasure',1)
                    .enterGridData('Uom',2,'colUOMUnitQty',2.20)
                    .selectGridComboBoxRowValue('Uom',3,'colUOMCode', '10-lb bag1' ,'strUnitMeasure',1)
                    .enterGridData('Uom',3,'colUOMUnitQty',10)
                    .selectGridComboBoxRowValue('Uom',4,'colUOMCode', '20-lb bag1' ,'strUnitMeasure',1)
                    .enterGridData('Uom',4,'colUOMUnitQty',20)
                    .clickTab('Attribute')
                    .selectGridRowNumber('Origin', 1)
                    .selectGridComboBoxRowValue('Origin',1,'colOrigin', 'Philippines' ,'strDescription',1)
                    .selectGridComboBoxRowValue('Origin',1,'colDefaultPackingUOM', '10-lb bag1' ,'strDefaultPackingUOM',1)
                    .selectGridComboBoxRowValue('Origin',1,'colPurchasingGroup', 'South East Asian Group' ,'strPurchasingGroup',1)
                    .selectGridComboBoxRowValue('Origin',2,'colOrigin', 'United States' ,'strDescription',1)
                    .selectGridComboBoxRowValue('Origin',2,'colDefaultPackingUOM', '20-lb bag1' ,'strDefaultPackingUOM',1)
                    .selectGridComboBoxRowValue('Origin',2,'colPurchasingGroup', 'North American Group' ,'strPurchasingGroup',1)
                    .selectGridComboBoxRowValue('Origin',3,'colOrigin', 'India' ,'strDescription',1)
                    .selectGridComboBoxRowValue('Origin',3,'colDefaultPackingUOM', '10-lb bag1' ,'strDefaultPackingUOM',1)
                    .selectGridComboBoxRowValue('Origin',3,'colPurchasingGroup', 'South East Asian Group' ,'strPurchasingGroup',1)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .done()    
                },
                continueOnFail: true   
        })
        .clickMenuFolder('Inventory')
        .done()
    })
// //Check if Location is linked to irelyadmin
//     .addFunction(function(next){
//         new iRely.FunctionalTest().start(t, next)
//         .addScenario('Precondition Setup','Check Location setup',1000)
//         .clickMenuFolder('System Manager')
//         .clickMenuScreen('Users')
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .doubleClickSearchRowValue('irelyadmin', 'strUserName', 1)
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .clickTab('User')
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .clickTab('User Roles')
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .filterGridRecords('UserRoleCompanyLocationRolePermission','FilterGrid','0002 - Indianapolis[ENTER]',1)
//         // .enterData('Text Field','FilterGrid','0002 - Indianapolis' )
//         // .enterData('Text Field','FilterGrid','[ENTER]' )
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .continueIf({
//                 expected: true,
//                 actual: function (win) {
//                     return win.down('#grdUserRoleCompanyLocationRolePermission').getStore().getCount() !== 0;
//                 },
//                 success: function (next) {
//                     new iRely.FunctionalTest().start(t, next)
//                     .addResult('Location 0002 - Indianapolis exists in user irelyadmin.')
//                     .clearTextFilter('FilterGrid')
//                     .done();
//                 },
//                 failure: function(next){
//                     new iRely.FunctionalTest().start(t, next)
                    
                    
//                     .addResult('Location 0002 - Indianapolis does not exists in user irelyadmin.')
//                     .addStep('Add Location 0002 - Indianapolis')
//                     //.clickButton('UserRoleCompanyLocationAdd')
//                     .waitUntilLoaded()
//                     .waitUntilLoaded()
//                     .waitUntilLoaded()
//                     //.filterGridRecords('UserRoleCompanyLocationRolePermission','FilterGrid','[ENTER]',1)
//                     .clearTextFilter('FilterGrid')
//                     .enterGridNewRow('UserRoleCompanyLocationRolePermission', [{column: 'strLocationName', data: '0002 - Indianapolis'}])  
//                     .waitUntilLoaded()
//                     .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission',1,'colUserRoleCompanyLocationName', '0002 - Indianapolis' ,'strLocationName',1)
//                     .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission',1,'colUserRoleUserRole', 'ADMIN' ,'strUserRole',1)    
//                     .clickButton('Save')
//                     .waitUntilLoaded()
//                     .clickButton('Close')
//                     .done()    
//                 },
//                 continueOnFail: true   
//         })
//         .clickMenuFolder('System Manager')
//         .done()
//     })
     

// //Create JDE Locations
//     .addFunction(function(next){
//         new iRely.FunctionalTest().start(t, next)
//         .addScenario('Precondition Setup','Location Setup',1000)
//         .clickMenuFolder('Common Info')
//         .clickMenuScreen('Company Locations')
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .enterData('Text Field','FilterGrid','0002 - Indianapolis' )
//         .enterData('Text Field','FilterGrid','[ENTER]' )
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .continueIf({
//                 expected: true,
//                 actual: function (win) {
//                     return win.down('#grdSearch').getStore().getCount() !== 0;
//                 },
//                 success: function (next) {
//                     new iRely.FunctionalTest().start(t, next)
//                     .addResult('Location 0002 - Indianapolis exists.')
//                     .clearTextFilter('FilterGrid')
//                     .done();
//                 },
//                 failure: function(next){
//                     new iRely.FunctionalTest().start(t, next)
//                     .addResult('Location 0002 - Indianapolis does not exists.')
//                     .addStep('Add Location 0002 - Indianapolis')
//                     .clickButton('New')
//                     .waitUntilLoaded()
//                     .enterData('Text Field','LocationName','0002 - Indianapolis' )
//                     .selectComboBoxRowNumber('Type',2)
//                     .enterData('Text Field','LocationNumber','002' )
//                     .clickTab('GL Accounts')
//                     .selectComboBoxRowValue('Location', '0002', 'ProfitCenter',1)
//                     .clickTab('Sub Location')
//                     .enterGridNewRow('SubLocation', [{column: 'strSubLocationName', data: 'Indy'}])   
//                     .selectGridComboBoxRowValue('SubLocation',1,'colClassification', 'Inventory' ,'strClassification',1)  
//                     .clickButton('Save')
//                     .waitUntilLoaded()
//                     .clickButton('Close')
//                     .done()    
//                 },
//                 continueOnFail: true   
//         })
//         .clickMenuFolder('Common Info')
//         .done()
//     })
// //Create JDE Storage Location
//     .addFunction(function(next){
//         new iRely.FunctionalTest().start(t, next)
//         .addScenario('Precondition Setup','Storage Location Setup',1000)
//         .clickMenuFolder('Inventory')
//         .clickMenuScreen('Storage Locations')
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .enterData('Text Field','FilterGrid','Indy Storage' )
//         .enterData('Text Field','FilterGrid','[ENTER]' )
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .waitUntilLoaded()
//         .continueIf({
//                 expected: true,
//                 actual: function (win) {
//                     return win.down('#grdSearch').getStore().getCount() !== 0;
//                 },
//                 success: function (next) {
//                     new iRely.FunctionalTest().start(t, next)
//                     .addResult('Storage Indy Storage exists.')
//                     .clearTextFilter('FilterGrid')
//                     .done();
//                 },
//                 failure: function(next){
//                     new iRely.FunctionalTest().start(t, next)
//                     .addResult('Storage Indy Storage does not exists.')
//                     .addStep('Add Storage Indy Storage')
//                     .clickButton('New')
//                     .waitUntilLoaded()
//                     .enterData('Text Field','Name','Indy Storage' )
//                     .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'LocationId',1)
//                     .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocationId',1)
//                     .selectComboBoxRowNumber('Type',2)
//                     .enterData('Text Field','LocationNumber','002' )
//                     .clickTab('Sub Location')
//                     .enterGridNewRow('SubLocation', [{column: 'strSubLocationName', data: 'Indy'}])
                    
//                     .clickButton('Save')
//                     .waitUntilLoaded()
//                     .clickButton('Close')
//                     .done()    
//                 },
//                 continueOnFail: true   
//         })
//         .clickMenuFolder('Inventory')
//         .done()
//     }) 

//Create JDE Other Charge item
    .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .addScenario('Precondition Setup','Other Charge Item Setup',1000)
        .clickMenuFolder('Inventory')
        .clickMenuScreen('Items')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','OC 1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Item OC 1 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Item OC 1 does not exists.')
                    .addStep('Add Item OC 1')
                    .clickButton('New')
                    .waitUntilLoaded()
                    .enterData('Text Field','ItemNo','OC 1' )
                    .selectComboBoxRowNumber('Type',6)
                    .selectComboBoxRowValue('Category', 'OC Category1', 'CategoryId',1)
                    .enterData('Text Field','Description','OC 1 Desc' )
                    
                    .enterGridNewRow('UnitOfMeasure', [{column: 'strUnitMeasure', data: 'LB1'}])
                     .waitUntilLoaded()
                    .selectGridRowNumber('UnitOfMeasure', 1)
                     .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UnitOfMeasure',1,'colDetailUnitMeasure', 'LB1' ,'strUnitMeasure',1)
                     .waitUntilLoaded()
                    .clickGridCheckBox('UnitOfMeasure',1 , 'colStockUnit', 'LB1', 'ysnStockUnit', true)
                     .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UnitOfMeasure',2,'colDetailUnitMeasure', 'KG1' ,'strUnitMeasure',1)
                     .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UnitOfMeasure',3,'colDetailUnitMeasure', '10-lb bag1' ,'strUnitMeasure',1)
                     .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UnitOfMeasure',4,'colDetailUnitMeasure', '20-lb bag1' ,'strUnitMeasure',1)
                     .waitUntilLoaded()
                    
                    .clickTab('Setup')
                    .clickTab('Location')
                    .clickButton('AddLocation')
                    .waitUntilLoaded()
                    .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'LocationId',1)
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocationId',1)
                    .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocationId',1)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()    
                    .clickTab('Cost')
                    .selectComboBoxRowValue('CostType', 'Freight', 'CostType',1)
                    .selectComboBoxRowValue('CostMethod', 'Per Unit', 'CostMethod',1)
                    .enterData('Text Field','Amount',.20 )
                    .selectComboBoxRowValue('CostUOM', 'LB1', 'CostUOMId',1)
                    .verifyCheckboxValue('BasisContract', false )
                    .clickCheckBox('BasisContract',true)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .done()    
                },
                continueOnFail: true   
        })
        .clickMenuFolder('Inventory')
        .done()   
   })
//Create JDE Inventory Item
    .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .addScenario('Precondition Setup','Inventory Item Setup',1000)
        .clickMenuFolder('Inventory')
        .clickMenuScreen('Items')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','Item 1' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Inventory Item 1 exists.')
                    .clearTextFilter('FilterGrid')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Inventory Item 1 does not exists.')
                    .addStep('Add Inventory Item 1 ')
                    .clickButton('New')
                    .waitUntilLoaded()
                    .enterData('Text Field','ItemNo','Item 1' )
                    .selectComboBoxRowNumber('Type',2)
                    .selectComboBoxRowValue('Category', 'Inventory Category1', 'CategoryId',1)
                    .enterData('Text Field','Description','Inventory Category1 Desc' )
                    
                    .enterGridNewRow('UnitOfMeasure', [{column: 'strUnitMeasure', data: 'LB1'}])
                    .waitUntilLoaded()
                    .selectGridRowNumber('UnitOfMeasure', 1)
                    .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UnitOfMeasure',1,'colDetailUnitMeasure', 'LB1' ,'strUnitMeasure',1)
                    .waitUntilLoaded()
                    .clickGridCheckBox('UnitOfMeasure',1 , 'colStockUnit', 'LB1', 'ysnStockUnit', true)
                    .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UnitOfMeasure',2,'colDetailUnitMeasure', 'KG1' ,'strUnitMeasure',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UnitOfMeasure',3,'colDetailUnitMeasure', '10-lb bag1' ,'strUnitMeasure',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UnitOfMeasure',4,'colDetailUnitMeasure', '20-lb bag1' ,'strUnitMeasure',1)
                    .waitUntilLoaded()
                    
                    .clickTab('Setup')
                    .waitUntilLoaded()
                    .clickTab('Location')
                    .waitUntilLoaded()
                    .clickButton('AddLocation')
                    .waitUntilLoaded()
                    .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'LocationId',1)
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocationId',1)
                    .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocationId',1)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()    
                   
                    .clickTab('Contract Item')    
                    .addFunction(function (next) {
                        t.chain(
                            { click : "#frmItem #tabItem #pgeSetup #tabSetup #pgeContract #grdCertification #colCertification => .x-column-header-text" }
                        )
                        next();
                    })
                    .waitUntilLoaded()
                    .addFunction(function (next) {
                        t.chain(
                            { click : "menu{isVisible()} #mnuHeaderDrillDown => .x-menu-item-text"}
                        )
                        next();
                    })
                    .waitUntilLoaded()
                    .waitUntilLoaded('iccertificationprogram')
                    .isControlVisible('textfield',['Certification Code','txtCertificationCode'],'true')
                    .addFunction(function(next){
                        var record=Math.floor((Math.random() * 1000000) + 1);
                        var d = new Date();
                        var certCode = 'CODE-' + ' ' + record + ' ' + d.toLocaleDateString('en-US') ;
                        new iRely.FunctionalTest().start(t, next)
                        .enterData('Text Field','CertificationProgram','CertProg'+ record + ' ' + d.toLocaleDateString('en-US'))
                        .enterData('Text Field','IssuingOrganization','IssueOrg1'+ record + ' ' + d.toLocaleDateString('en-US'))
                        .enterData('Text Field','CertificationCode',certCode)
                        .done()
                    })
                    .waitUntilLoaded()
                    .clickButton('Save')
                    .clickButton('Close')
                   
                    .clickTab('Pricing')
                    .enterGridData('Pricing',1,'colPricingLastCost',10) 
                    .enterGridData('Pricing',1,'colPricingStandardCost',10)
                    .selectGridComboBoxRowNumber('Pricing',1,'strPricingMethod',3)
                    .enterGridData('Pricing',1,'colPricingAmount',40) 
                    .enterGridData('Pricing',1,'colPricingRetailPrice',14) 
                    .waitUntilLoaded()
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded()
        .clickMenuFolder('Inventory')
        .done()   
    })               
.done()
})