StartTest (function (t) {
    var commonGL = Ext.create('GeneralLedger.commonGL');
    var commonIC = Ext.create('Inventory.CommonIC');

    new iRely.FunctionalTest().start(t)

        /*====================================== Add Another Company Location for Irelyadmin User and setup default decimals ======================================*/
        //region
        .displayText('===== 1. Add Indianapolis for Company Location for irelyadmin User =====')
        .clickMenuFolder('System Manager','Folder')
        .clickMenuScreen('Users','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        .waitUntilLoaded('ementity')
        .clickTab('User')
        .waitUntilLoaded()
        .clickTab('User Roles')

        .waitUntilLoaded()
        .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)

                    .displayText('Location is not yet existing.')
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
                    .waitUntilLoaded('ementity')
                    .clickTab('User')
                    .waitUntilLoaded()
                    .clickTab('User Roles')
                    .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 'Dummy','strLocationName', '0002 - Indianapolis','strLocationName', 1)
                    .selectGridComboBoxBottomRowValue('UserRoleCompanyLocationRolePermission', 'strUserRole', 'ADMIN', 'strUserRole', 5)
                    .clickTab('Detail')
                    .waitUntilLoaded()
                    .selectComboBoxRowValue('UserNumberFormat', '1,234,567.89', 'UserNumberFormat',1)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
                    .waitUntilLoaded('ementity')
                    .clickTab('User')
                    .waitUntilLoaded()
                    .clickTab('User Roles')
                    .waitUntilLoaded()
                    .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickMenuFolder('System Manager','Folder')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })

        /*====================================== Add GL Accounts ======================================*/
        .displayText('===== 2. Add GL Accounts =====')
        .clickMenuFolder('General Ledger')
        .waitUntilLoaded()
        .clickMenuScreen('GL Account Detail')
        .waitUntilLoaded()
        .addResult('GL Account Detail opened')

        .clickButton('Segments')
        .waitUntilLoaded()
        .verifyScreenShown('glsegmentaccounts')
        .addResult('Segment Accounts screen opened')
        .waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '20022')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 20022 - AP Clearing Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '20022'},{column: 'strDescription',data: 'AP Clearing'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Pending Payables','Account Group',1)
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','AP Clearing', 'Account Category',1)
                    .addResult('----Add 20022- AP Clearing Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })

        .filterGridRecords('SegmentAccounts', 'FilterGrid', '15012')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 15012 - Inventories Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '15012'},{column: 'strDescription',data: 'Inventories'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Inventories','Account Group',1)
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Inventory', 'Account Category',3)
                    .addResult('----Add 15012 - Inventories Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })


        .filterGridRecords('SegmentAccounts', 'FilterGrid', '50012')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 50012 - COGS Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '50012'},{column: 'strDescription',data: 'COGS'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Cost of Goods Sold','Account Group',1)
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Cost of Goods', 'Account Category',1)
                    .addResult('----Add 50012 - COGS Primary Account Done---')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })


        .filterGridRecords('SegmentAccounts', 'FilterGrid', '40012')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 40012 - Sales Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '40012'},{column: 'strDescription',data: 'Sales'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Sales','Account Group',2)
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Sales Account', 'Account Category',1)
                    .addResult('----Add 40012 - Sales Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })



        .filterGridRecords('SegmentAccounts', 'FilterGrid', '16012')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 16012 - Inventory in Transit Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '16012'},{column: 'strDescription',data: 'Inventory in Transit'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Inventories','Account Group',1)
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Inventory In-Transit', 'Account Category',1)
                    .addResult('----Add 16012 - Inventory in Transit Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })



        .filterGridRecords('SegmentAccounts', 'FilterGrid', '50022')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 50022 - Inventory Adjustment')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '50022'},{column: 'strDescription',data: 'Inventory Adjustment'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Cost of Goods Sold','Account Group',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Inventory Adjustment', 'Account Category',1)
                    .waitUntilLoaded()
                    .addResult('----Add 50022 - Inventory Adjustment Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })



        .filterGridRecords('SegmentAccounts', 'FilterGrid', '50032')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 50032 - Inventory Variance')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '50032'},{column: 'strDescription',data: 'Inventory Variance'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Cost of Goods Sold','Account Group',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Auto-Variance', 'Account Category',1)
                    .waitUntilLoaded()
                    .addResult('----Add 50032 - Inventory Variance Primary AccountDone----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })



        .filterGridRecords('SegmentAccounts', 'FilterGrid', '12012')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 12012 - AR Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '12012'},{column: 'strDescription',data: 'AR Account'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Receivables','Account Group',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','AR Account', 'Account Category',1)
                    .waitUntilLoaded()
                    .addResult('----Add 12012 - AR Account Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })



        .filterGridRecords('SegmentAccounts', 'FilterGrid', '20012')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 20012 - AP Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '20012'},{column: 'strDescription',data: 'AP Account'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Payables','Account Group',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','AP Account', 'Account Category',1)
                    .waitUntilLoaded()
                    .addResult('----Add 20012 - AP Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })



        .filterGridRecords('SegmentAccounts', 'FilterGrid', '49012')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()

                    .clickButton('AddSegment')
                    .displayText('Add 49012 - Other Charge Income Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '49012'},{column: 'strDescription',data: 'Other Charge Income'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Other Income','Account Group',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Other Charge Income', 'Account Category',1)
                    .waitUntilLoaded()
                    .addResult('----Add 49012 - Other Charge Income Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })


        .filterGridRecords('SegmentAccounts', 'FilterGrid', '59012')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()

                    .clickButton('AddSegment')
                    .displayText('Add 59012 - Other Charge Expense Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '59012'},{column: 'strDescription',data: 'Other Charge Expense'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Other Expense','Account Group',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Other Charge Expense', 'Account Category',1)
                    .waitUntilLoaded()
                    .addResult('----Add 59012 - Other Charge Expense Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })



        .filterGridRecords('SegmentAccounts', 'FilterGrid', '25012')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 25012 - Sales Tax Liability Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '25012'},{column: 'strDescription',data: 'Sales Tax Liability'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Sales Tax Payables','Account Group',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Sales Tax Account', 'Account Category',1)
                    .waitUntilLoaded()
                    .addResult('----Add 25012 - Sales Tax Liability Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })

        .filterGridRecords('SegmentAccounts', 'FilterGrid', '72512')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment not yet existing.')
                return win.down('#grdSegmentAccounts').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('AddSegment')
                    .displayText('Add 72512 - Tax Expense Primary Account')
                    .waitUntilLoaded()
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode',data: '72512'},{column: 'strDescription',data: 'Tax Expense'}])
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountGroup','Other Expenses','Account Group',1)
                    .waitUntilLoaded()
                    .selectGridComboBoxBottomRowValue('SegmentAccounts','strAccountCategory','Purchase Tax Account', 'Account Category',1)
                    .waitUntilLoaded()
                    .addResult('----Add 72512 - Tax Expense Primary Account Done----')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Segment already exists.')
                return win.down('#grdSegmentAccounts').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Save')
        .clickButton('Close')




        .addFunction(function(next){commonGL.buildAccount(t, next, '20022', '0001', '001', 'AP Clearing', 'Pending Payables','AP Clearing', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '15012', '0001', '001', 'Inventory', 'Inventories','Inventory', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '50012', '0001', '001', 'COGS', 'Cost of Goods Sold','Cost of Goods', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '40012', '0001', '001', 'Sales', 'Sales','Sales Account', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '16012', '0001', '001', 'Inventory in Transit', 'Inventories','Inventory In-Transit', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '50022', '0001', '001', 'Inventory Adjustment', 'Cost of Goods Sold','Inventory Adjustment', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '50032', '0001', '001', 'Inventory Variance', 'Cost of Goods Sold','Auto-Variance', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '12012', '0001', '001', 'AR Account', 'Receivables','AR Account', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '20012', '0001', '001', 'AP Account', 'Payables','AP Account', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '49012', '0001', '001', 'Other Charge Income', 'Other Income','Other Charge Income', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '59012', '0001', '001', 'Other Charge Expense', 'Other Expense','Other Charge Expense', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '25012', '0001', '001', 'Sales Tax Liability', 'Sales Tax Payables','Sales Tax Account', 'Fort Wayne','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '72512', '0001', '001', 'Tax Expense', 'Other Expenses','Purchase Tax Account', 'Fort Wayne','Grains','USD',1,1)})

        .addFunction(function(next){commonGL.buildAccount(t, next, '20022', '0002', '001', 'AP Clearing', 'Pending Payables','AP Clearing', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '15012', '0002', '001', 'Inventory', 'Inventories','Inventory', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '50012', '0002', '001', 'COGS', 'Cost of Goods Sold','Cost of Goods', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '40012', '0002', '001', 'Sales', 'Sales','Sales Account', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '16012', '0002', '001', 'Inventory in Transit', 'Inventories','Inventory In-Transit', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '50022', '0002', '001', 'Inventory Adjustment', 'Cost of Goods Sold','Inventory Adjustment', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '50032', '0002', '001', 'Inventory Variance', 'Cost of Goods Sold','Auto-Variance', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '12012', '0002', '001', 'AR Account', 'Receivables','AR Account', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '20012', '0002', '001', 'AP Account', 'Payables','AP Account', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '49012', '0002', '001', 'Other Charge Income', 'Other Income','Other Charge Income', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '59012', '0002', '001', 'Other Charge Expense', 'Other Expense','Other Charge Expense', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '25012', '0002', '001', 'Sales Tax Liability', 'Sales Tax Payables','Sales Tax Account', 'Indianapolis','Grains','USD',1,1)})
        .addFunction(function(next){commonGL.buildAccount(t, next, '72512', '0002', '001', 'Tax Expense', 'Other Expenses','Purchase Tax Account', 'Indianapolis','Grains','USD',1,1)})

        .displayText('===== 2. Add GL Accounts DONE =====')
        .clickMenuFolder('General Ledger')
        .waitUntilLoaded()

        .displayText('===== 3. Assign default AR account in the Company Configuration  =====')
        .clickMenuFolder('System Manager','Folder')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Company Configuration','Screen')
        .waitUntilLoaded('smcompanypreference',3000)
        .waitUntilLoaded('smcompanypreference',3000)
        .waitUntilLoaded('smcompanypreference',3000)
        .waitUntilLoaded('')
        .selectGridRowNumber('Settings',6)
        .waitUntilLoaded('',3000)
        .selectComboBoxRowValue('ARAccount', '12012-0001-001','ARAccount',1)
        .waitUntilLoaded('',3000)
        .verifyData('Combo Box','ARAccount','12012-0001-001')
        .clickButton('Ok')
        .waitUntilLoaded('',3000)
        .displayText('===== 3. Assign default AR account in the Company Configuration DONE  =====')
        .clickMenuFolder('System Manager','Folder')
        .waitUntilLoaded()


        .displayText('======== 4. Setup account id for AP and AR in the Company Location ========')
        .clickMenuFolder('Common Info','Folder')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Company Locations','Screen')
        .doubleClickSearchRowValue('0001 - Fort Wayne', 1)
        .waitUntilLoaded('smcompanylocation',3000)
        .clickTab('GL Accounts')
        .waitUntilLoaded('',3000)
        .selectComboBoxRowValue('ARAccount', '12012-0001-001', 'ARAccount',0)
        .waitUntilLoaded('',3000)
        .verifyData('Combo Box','ARAccount','12012-0001-001')
        .selectComboBoxRowValue('APAccount', '20012-0001-001', 'APAccount',0)
        .waitUntilLoaded('',3000)
        .verifyData('Combo Box','APAccount','20012-0001-001')
        .clickButton('Save')
        .clickButton('Close')

        .doubleClickSearchRowValue('0002 - Indianapolis', 1)
        .waitUntilLoaded('smcompanylocation',3000)
        .clickTab('GL Accounts')
        .waitUntilLoaded('',3000)
        .selectComboBoxRowValue('ARAccount', '12012-0002-001', 'ARAccount',0)
        .waitUntilLoaded('',3000)
        .verifyData('Combo Box','ARAccount','12012-0002-001')
        .selectComboBoxRowValue('APAccount', '20012-0002-001', 'APAccount',0)
        .waitUntilLoaded('',3000)
        .verifyData('Combo Box','APAccount','20012-0002-001')
        .clickButton('Save')
        .waitUntilLoaded('',3000)
        .clickButton('Close')
        .waitUntilLoaded('',3000)
        .displayText('======== 4. Setup account id for AP and AR in the Company Location DONE ========')
        .waitUntilLoaded()


        .displayText('===== 5. Add Tax Class - Tax Class A =====')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Tax Class','Screen')
        .waitUntilLoaded('smtaxclass',1000)


        .filterGridRecords('GridTemplate', 'FilterGrid', 'Tax Class A')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdGridTemplate').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)

                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('Insert')
                    .enterGridData('GridTemplate', 1, 'colTaxClass', 'Tax Class A')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .displayText('===== 5. Add Tax Class DONE =====')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
            })
                .continueIf({
                    expected: true,
                    actual: function (win,next) {
                        new iRely.FunctionalTest().start(t, next)
                        return win.down('#grdGridTemplate').store.getCount() != 0;
                    },
                    success: function(next){
                        new iRely.FunctionalTest().start(t, next)
                            .waitUntilLoaded()
                            .clickButton('Close')
                            .waitUntilLoaded()
                            .displayText('===== 5. Add Tax Class DONE =====')
                            .done();
                    },
                    continueOnFail: true
                })


       //6. Add Tax Codes
        .displayText('===== 6. Add Tax Codes  =====')
        .displayText('===== a. Add Tax Code - Tax 1 =====')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Tax Codes','Screen')
        .waitUntilLoaded('')

        .filterGridRecords('Search', 'FilterGrid', 'Tax 1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)

                    .clickButton('New')
                    .waitUntilLoaded('smtaxcode',1000)
                    .enterData('Text Field','TaxCode','Tax 1')
                    .selectComboBoxRowValue('TaxClass','Tax Class A', 'TaxClass', 1)
                    .enterData('Text Field','Description','Tax 1 desc')
                    .enterData('Text Field','Address','63 Overlook Drive')
                    .enterData('Text Field','ZipCode','47374')
                    .enterData('Text Field','City','Richmond')
                    .enterData('Text Field','State','IN')
                    .selectComboBoxRowValue('Country', 'United States', 'Country',1)
                    .selectComboBoxRowValue('SalesTaxAccount', '25012-0001-001','SalesTaxAccount',1)
                    .selectComboBoxRowValue('PurchaseTaxAccount', '72512-0001-001','PurchaseTaxAccount',1)
                    .addFunction (function (next){
                    var date = new Date().toLocaleDateString();
                    new iRely.FunctionalTest().start(t, next)
                        .selectGridComboBoxRowValue('TaxCodeRate',1,'colEffectiveDate',date,'dtmEffectiveDate', 0, 10)
                        .done();
                })
                    .selectGridComboBoxRowValue('TaxCodeRate',1,'colCalculationMethod','Percentage','strCalculationMethod',1)
                    .enterGridData('TaxCodeRate', 1, 'colRate', '10.00')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .displayText('===== Add Tax Code - Tax 1 Done =====')
                    .done();
            },
            continueOnFail: true
        })


        .displayText('===== b. Add Tax Code - Tax 2 =====')
        .filterGridRecords('Search', 'FilterGrid', 'Tax 2')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)


                    .clickButton('New')
                    .waitUntilLoaded('smtaxcode',1000)
                    .enterData('Text Field','TaxCode','Tax 2')
                    .selectComboBoxRowValue('TaxClass','Tax Class A', 'TaxClass', 1)
                    .enterData('Text Field','Description','Tax 2 desc')
                    .enterData('Text Field','Address','63 Overlook Drive')
                    .enterData('Text Field','ZipCode','47374')
                    .enterData('Text Field','City','Richmond')
                    .enterData('Text Field','State','IN')
                    .selectComboBoxRowValue('Country', 'United States', 'Country',1)
                    .selectComboBoxRowValue('SalesTaxAccount', '25012-0001-001','SalesTaxAccount',1)
                    .selectComboBoxRowValue('PurchaseTaxAccount', '72512-0001-001','PurchaseTaxAccount',1)
                    .addFunction (function (next){
                    var date = new Date().toLocaleDateString();
                    new iRely.FunctionalTest().start(t, next)
                        .selectGridComboBoxRowValue('TaxCodeRate',1,'colEffectiveDate',date,'dtmEffectiveDate', 0, 10)
                        .done();
                })
                    .selectGridComboBoxRowValue('TaxCodeRate',1,'colCalculationMethod','Unit','strCalculationMethod',1)
                    .enterGridData('TaxCodeRate', 1, 'colRate', '0.40')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .displayText('===== Add Tax Code - Tax 2 Done =====')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })


        .displayText('===== c. Add Tax Code - Tax on Tax =====')
        .filterGridRecords('Search', 'FilterGrid', 'Tax on Tax')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)


                    .clickButton('New')
                    .waitUntilLoaded('smtaxcode',1000)
                    .enterData('Text Field','TaxCode','Tax on Tax')
                    .selectComboBoxRowValue('TaxClass','Tax Class A', 'TaxClass', 1)
                    .enterData('Text Field','Description','Tax on Tax desc')
                    .enterData('Text Field','Address','63 Overlook Drive')
                    .enterData('Text Field','ZipCode','47374')
                    .enterData('Text Field','City','Richmond')
                    .enterData('Text Field','State','IN')
                    .selectComboBoxRowValue('Country', 'United States', 'Country',1)
                    .selectComboBoxRowValue('SalesTaxAccount', '25012-0001-001','SalesTaxAccount',1)
                    .selectComboBoxRowValue('PurchaseTaxAccount', '72512-0001-001','PurchaseTaxAccount',1)
                    .addFunction (function (next){
                    var date = new Date().toLocaleDateString();
                    new iRely.FunctionalTest().start(t, next)
                        .selectGridComboBoxRowValue('TaxCodeRate',1,'colEffectiveDate',date,'dtmEffectiveDate', 0, 10)
                        .done();
                })
                    .selectGridComboBoxRowValue('TaxCodeRate',1,'colCalculationMethod','Percentage','strCalculationMethod',1)
                    .enterGridData('TaxCodeRate', 1, 'colRate', '2.5')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .displayText('===== Add Tax Code - Tax on Tax Done =====')
                    .waitUntilLoaded()
                    .displayText('===== 6. Add Tax Codes DONE =====')
                    .done();
            },
            continueOnFail: true
        })

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .waitUntilLoaded()
                    .displayText('===== 6. Add Tax Codes DONE =====')
                    .done();
            },
            continueOnFail: true
        })



        .displayText('===== 7. Add Tax Group - Test Group 1 =====')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Tax Groups','Screen')
        .waitUntilLoaded('smtaxgroup',1000)
        .filterGridRecords('Search', 'FilterGrid', 'Test Group 1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('New')
                    .enterData('Text Field','TaxGroup','Test Group 1')
                    .enterData('Text Field','Description','Test Group 1')
                    .selectGridComboBoxRowValue('TaxGroup',1,'colTaxCode','Tax 2','strTaxCode',1)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .displayText('===== 7. Add Tax Group - Test Group 1 Done =====')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })

            .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .waitUntilLoaded()
                    .displayText('===== 7. Add Tax Group - Test Group 1 Done =====')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })


        .displayText('===== 8. Assign Tax to Company Location - 0001 - Fort Wayne   =====')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Company Locations','Screen')
        .doubleClickSearchRowValue('0001 - Fort Wayne', 1)
        .waitUntilLoaded('smcompanylocation',3000)
        .clickTab('Setup')
        .selectComboBoxRowValue('TaxGroup', 'Test Group 1', 'TaxGroup',1)
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== 8. Assign Tax to Company Location - 0001 - Fort Wayne DONE   =====')
        .clickMenuFolder('Common Info','Folder')
        .waitUntilLoaded()


        .displayText('===== 9: Add New Storage Location - Indy Storage =====')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()

        .clickMenuScreen('Storage Locations','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Indy Storage')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('===== Scenario 1: Add New Storage Location. =====')
                    .clickMenuScreen('Storage Locations','Screen')
                    .clickButton('New')
                    .waitUntilLoaded('icstorageunit')
                    .enterData('Text Field','Name','Indy Storage')
                    .enterData('Text Field','Description','Indy Storage')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .selectComboBoxRowNumber('Location',2,0)
                    .selectComboBoxRowNumber('SubLocation',1,0)
                    .selectComboBoxRowNumber('ParentUnit',1,0)
                    .enterData('Text Field','Aisle','Test Aisle - 01')
                    .clickCheckBox('AllowConsume', true)
                    .clickCheckBox('AllowMultipleItems', true)
                    .clickCheckBox('AllowMultipleLots', true)
                    .clickCheckBox('CycleCounted', true)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })

        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })



        //Add UOM
        .displayText('===== 10. Add Inventory UOM =====')
        .clickMenuScreen('Inventory UOM','Screen')

        .filterGridRecords('Search', 'FilterGrid', 'lb1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('New')
                    .waitUntilLoaded()
                    .waitUntilLoaded('icinventoryuom',3000)

                    //a. Add LB UOM
                    .displayText('a. Add lb1 UOM.')
                    .enterData('Text Field','UnitMeasure','lb1')
                    .enterData('Text Field','Symbol','lb')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .selectComboBoxRowNumber('Decimals',3,0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })


        .filterGridRecords('Search', 'FilterGrid', '10-lb bag1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //b. Add 10-lb bag UOM
                    .displayText('b. Add 10-lb bag1 UOM.')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','UnitMeasure','10-lb bag1')
                    .enterData('Text Field','Symbol','10-lb bag')
                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectComboBoxRowNumber('Decimals',3,0)
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM','lb1','strUnitMeasure',1)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '10')
                    .clickButton('Save')
                    .waitUntilLoaded('')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .displayText('======== 10-lb bag1 UOM added ========')
                    .done();
            },
            continueOnFail: true
        })


        .filterGridRecords('Search', 'FilterGrid', 'kg1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //c. Add kg UOM
                    .displayText('c. Add kg1 UOM.')
                    .clickButton('New')
                    .waitUntilLoaded('',3000)
                    .enterData('Text Field','UnitMeasure','kg1')
                    .enterData('Text Field','Symbol','kg')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .selectComboBoxRowNumber('Decimals',3,0)
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM','lb1','strUnitMeasure',1)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '2.20462')
                    .clickButton('Save')
                    .waitUntilLoaded('')
                    .displayText('======== kg1 UOM added ========"')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    //d. Add LB UOM
                    .displayText('d. Add Other UOM to LB.')
                    .doubleClickSearchRowValue('lb1', 'strUnitMeasure', 1)
                    .waitUntilLoaded('icinventoryuom',3000)

                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM','10-lb bag1','strUnitMeasure',1)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '10.000000')

                    .selectGridComboBoxRowValue('Conversion',2,'colOtherUOM','kg1','strUnitMeasure',1)
                    .enterGridData('Conversion', 2, 'dblConversionToStock', '0.453592')
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('======== Add UOM Done ========')
                    .waitUntilLoaded('')
                    .displayText('===== 10. Add Inventory UOM DONE =====')
                    .done();
            },
            continueOnFail: true
        })

              .continueIf({
                    expected: true,
                    actual: function (win,next) {
                        return win.down('#grdSearch').store.getCount() != 0;
                    },
                    success: function(next){
                        new iRely.FunctionalTest().start(t, next)
                            .displayText('======== Add UOM Done ========')
                            .waitUntilLoaded('')
                            .displayText('===== 10. Add Inventory UOM DONE =====')
                            .done();
                    },
                    continueOnFail: true
                })


        .clickMenuScreen('Categories','Screen')

        .filterGridRecords('Search', 'FilterGrid', 'Item Category1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Category already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //Add Category - Inventory Type
                    .displayText('===== 11. Add New Category - Inventory Type =====')
                    .clickButton('New')
                    .waitUntilLoaded('iccategory',3000)
                    .enterData('Text Field','CategoryCode','Item Category1')
                    .enterData('Text Field','Description','Item Category1 desc')
                    .selectComboBoxRowNumber('InventoryType',2,0)
                    .selectComboBoxRowNumber('CostingMethod',2,0)
                    .selectGridComboBoxRowValue('Tax',1,'colTaxClass','Tax Class A','strTaxClass',1)

                    .displayText('===== Setup GL Accounts=====')
                    .clickTab('GL Accounts')
                    .waitUntilLoaded('',3000)
                    .clickButton('AddRequired')
                    .waitUntilLoaded('',3000)
                    .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
                    .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Inventory')
                    .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Cost of Goods')
                    .verifyGridData('GlAccounts', 4, 'colAccountCategory', 'Sales Account')
                    .verifyGridData('GlAccounts', 5, 'colAccountCategory', 'Inventory In-Transit')
                    .verifyGridData('GlAccounts', 6, 'colAccountCategory', 'Inventory Adjustment')

                    .selectGridComboBoxRowValue('GlAccounts', 1, 'colAccountId', '20022-0001-001', 'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts', 2, 'colAccountId', '15012-0001-001', 'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts', 3, 'colAccountId', '50012-0001-001', 'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts', 4, 'colAccountId', '40012-0001-001', 'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts', 5, 'colAccountId', '16012-0001-001', 'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts', 6, 'colAccountId', '50022-0001-001', 'strAccountId',1)
                    .clickButton('Save')
                    .waitUntilLoaded('')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .displayText('===== 11. Add New Category - Inventory Type DONE =====')
                    .done();
            },
            continueOnFail: true
        })


        .filterGridRecords('Search', 'FilterGrid', 'OC Category1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Category already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)

                    //Add Category - Other Charge Type
                    .displayText('===== 12. Add New Category - Other Charge Type =====')
                    .clickButton('New')
                    .waitUntilLoaded('iccategory',3000)
                    .clickTab('Detail')
                    .enterData('Text Field','CategoryCode','OC Category1')
                    .enterData('Text Field','Description','OC Category1 desc')
                    .selectComboBoxRowNumber('InventoryType',6,0)
                    .selectComboBoxRowNumber('CostingMethod',2,0)
                    .selectGridComboBoxRowValue('Tax',1,'colTaxClass','Tax Class A','strTaxClass',1)

                    .displayText('===== Setup GL Accounts=====')
                    .clickTab('GL Accounts')
                    .waitUntilLoaded('',3000)
                    .clickButton('AddRequired')
                    .waitUntilLoaded('',3000)
                    .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
                    .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Other Charge Income')
                    .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Other Charge Expense')
                    .selectGridComboBoxRowValue('GlAccounts', 1, 'colAccountId', '20022-0001-001', 'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts', 2, 'colAccountId', '49012-0001-001', 'strAccountId',1)
                    .selectGridComboBoxRowValue('GlAccounts', 3, 'colAccountId', '59012-0001-001', 'strAccountId',1)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Add Category - Other Charge Type Done =====')
                    .displayText('===== 12. Add New Category - Other Charge Type DONE =====')
                    .done();
            },
            continueOnFail: true
        })


        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('======== Add UOM Done ========')
                    .waitUntilLoaded('')
                    .displayText('===== 12. Add New Category - Other Charge Type DONE =====')
                    .done();
            },
            continueOnFail: true
        })


        //Add Commodity
        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Commodity1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Commodity already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('===== 13. Add Commodity - Item =====')
                    .clickButton('New')
                    .waitUntilLoaded('iccommodity',3000)
                    .enterData('Text Field','CommodityCode','Commodity1')
                    .enterData('Text Field','Description','Commodity1 desc')
                    //.clickCheckBox('ExchangeTraded',true)
                    //.enterData('Text Field','DecimalsOnDpr','6.00')
                    //.enterData('Text Field','ConsolidateFactor','6.00')

                    .selectGridComboBoxRowValue('Uom',1,'colUOMCode','lb1','strUnitMeasure')
                    .clickGridCheckBox('Uom', 1,'colUOMStockUnit', 'lb1', 'ysnStockUnit', true)
                    .waitUntilLoaded('',3000)
                    .selectGridComboBoxRowValue('Uom',2,'colUOMCode','10-lb bag1','strUnitMeasure')
                    .waitUntilLoaded('',3000)
                    .selectGridComboBoxRowValue('Uom',3,'colUOMCode','kg1','strUnitMeasure')
                    .waitUntilLoaded('',3000)

                    .verifyGridData('Uom', 1, 'colUOMUnitQty', '1')
                    .verifyGridData('Uom', 2, 'colUOMUnitQty', '10')
                    .verifyGridData('Uom', 3, 'colUOMUnitQty', '2.20462')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== 13. Add Commodity - Item DONE =====')
                    .done();
            },
            continueOnFail: true
        })


          .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .waitUntilLoaded('')
                    .displayText('===== 13. Add Commodity - Item DONE =====')
                    .done();
            },
            continueOnFail: true
        })




        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded('')
        .filterGridRecords('Search', 'FilterGrid', 'Item A1')
        .waitUntilLoaded()


        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Commodity already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //Add Item
                    .displayText('===== 14. Add Item =====')
                    .waitUntilLoaded('',3000)
                    .clickButton('New')
                    .waitUntilLoaded('icitem',3000)
                    .enterData('Text Field','ItemNo','Item A1')
                    .enterData('Text Field','Description','Item A1 desc')
                    .selectComboBoxRowValue('Type', 'Inventory', 'Type',1)
                    .selectComboBoxRowValue('Category', 'Item Category1', 'Category',1)
                    .selectComboBoxRowValue('Commodity', 'Commodity1', 'Commodity',1)
                    .selectComboBoxRowNumber('LotTracking',4,0)
                    .verifyData('Combo Box','Tracking','Item Level')

                    .displayText('===== Setup Item UOM =====')
                    .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1.000000')
                    .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '10.000000')
                    .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '2.204620')


                    .displayText('===== Setup Item Location=====')
                    .clickTab('Setup')
                    .waitUntilLoaded('',3000)
                    .clickTab('Location')
                    .clickButton('AddLocation')
                    .waitUntilLoaded('icitemlocation',3000)
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'lb1', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'lb1', 'ReceiveUom',0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Setup Item Location - 0001 Done=====')

                    .clickButton('AddLocation')
                    .waitUntilLoaded('icitemlocation',3000)
                    .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'lb1', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'lb1', 'ReceiveUom',0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Setup Item Location - 0002 Done=====')

                    .displayText('===== Setup Item Pricing=====')
                    .clickTab('Pricing')
                    .waitUntilLoaded('')

                    .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
                    .enterGridData('Pricing', 1, 'dblLastCost', '10')
                    .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                    .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                    .enterGridData('Pricing', 1, 'dblAmountPercent', '40')
                    .verifyGridData('Pricing', 1, 'dblSalePrice', '14')

                    .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
                    .enterGridData('Pricing', 2, 'dblLastCost', '10')
                    .enterGridData('Pricing', 2, 'dblStandardCost', '10')
                    .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
                    .enterGridData('Pricing', 2, 'dblAmountPercent', '40')
                    .verifyGridData('Pricing', 2, 'dblSalePrice', '14')

                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Setup Item Pricing Done=====')
                    .displayText('===== 14. Add Item Done =====')
                    .done();
            },
            continueOnFail: true
        })


        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .waitUntilLoaded('')
                    .displayText('===== 14. Add Item Done =====')
                    .done();
            },
            continueOnFail: true
        })


        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded('')
        .filterGridRecords('Search', 'FilterGrid', 'Freight1')
        .waitUntilLoaded()


        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Commodity already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //Add Other Charge Item - Freight1
                    .displayText('===== 15. Add Other Charge Item - Freight1 =====')
                    .waitUntilLoaded('',3000)
                    .clickButton('New')
                    .waitUntilLoaded('icitem',3000)
                    .enterData('Text Field','ItemNo','Freight1')
                    .enterData('Text Field','Description','Freight1 desc')
                    .selectComboBoxRowValue('Type', 'Other Charge', 'Type',1)
                    .selectComboBoxRowValue('Category', 'OC Category1', 'Category',1)
                    .selectComboBoxRowValue('Commodity', 'Commodity1', 'Commodity',1)
                    .verifyData('Combo Box','LotTracking','No',0)
                    .verifyData('Combo Box','Tracking','Item Level',0)

                    .displayText('===== Setup Item UOM =====')
                    .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1.000000')
                    .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '10.000000')
                    .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '2.204620')


                    .displayText('===== Setup Item Location=====')
                    .clickTab('Setup')
                    .waitUntilLoaded('',3000)
                    .clickTab('Location')
                    .clickButton('AddLocation')
                    .waitUntilLoaded('icitemlocation',3000)
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'lb1', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'lb1', 'ReceiveUom',0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Setup Item Location - 0001 Done=====')

                    .clickButton('AddLocation')
                    .waitUntilLoaded('icitemlocation',3000)
                    .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'lb1', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'lb1', 'ReceiveUom',0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Setup Item Location - 0002 Done=====')

                    .displayText('===== Setup Item Pricing=====')
                    .clickTab('Setup')
                    .waitUntilLoaded('')
                    .clickTab('Cost')
                    .waitUntilLoaded('')
                    .clickCheckBox('InventoryCost',false)
                    .clickCheckBox('Accrue',true)
                    .selectComboBoxRowValue('M2M', 'No', 'M2M',0)
                    .clickCheckBox('Price',false)
                    .selectComboBoxRowNumber('CostType',1,0)
                    //.selectComboBoxRowValue('CostType', 'Discount', 'CostType',3,1)
                    .selectComboBoxRowNumber('CostMethod',1,0)
                    //.selectComboBoxRowValue('CostMethod', 'Per Unit', 'CostMethod',1,1)
                    .enterData('Text Field','Amount','1.50')
                    .selectComboBoxRowValue('CostUOM', 'lb1', 'CostUOM',0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Setup Item Pricing Done=====')
                    .displayText('===== 15. Add Other Charge Item - Freight1 DONE =====')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .waitUntilLoaded('')
                    .displayText('===== 15. Add Other Charge Item - Freight1 DONE =====')
                    .done();
            },
            continueOnFail: true
        })


        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded('')
        .filterGridRecords('Search', 'FilterGrid', 'Discount1')
        .waitUntilLoaded()


        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Commodity already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //Add Other Charge Item - Discount1
                    .displayText('===== 16. Add Other Charge Item - Discount1 =====')
                    .waitUntilLoaded('',3000)
                    .clickButton('New')
                    .waitUntilLoaded('icitem',3000)
                    .enterData('Text Field','ItemNo','Discount1')
                    .enterData('Text Field','Description','Discount1 desc')
                    .selectComboBoxRowValue('Type', 'Other Charge', 'Type',1)
                    .selectComboBoxRowValue('Category', 'OC Category1', 'Category',1)
                    .selectComboBoxRowValue('Commodity', 'Commodity1', 'Commodity',1)
                    .verifyData('Combo Box','LotTracking','No',0)
                    .verifyData('Combo Box','Tracking','Item Level',0)

                    .displayText('===== Setup Item UOM =====')
                    .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1.000000')
                    .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '10.000000')
                    .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '2.204620')


                    .displayText('===== Setup Item Location=====')
                    .clickTab('Setup')
                    .waitUntilLoaded('',3000)
                    .clickTab('Location')
                    .clickButton('AddLocation')
                    .waitUntilLoaded('icitemlocation',3000)
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'lb1', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'lb1', 'ReceiveUom',0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Setup Item Location - 0001 Done=====')

                    .clickButton('AddLocation')
                    .waitUntilLoaded('icitemlocation',3000)
                    .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'lb1', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'lb1', 'ReceiveUom',0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Setup Item Location - 0002 Done=====')

                    .displayText('===== Setup Other Charge Cost =====')
                    .clickTab('Setup')
                    .waitUntilLoaded('')
                    .clickTab('Cost')
                    .waitUntilLoaded('')
                    .clickCheckBox('InventoryCost',false)
                    .clickCheckBox('Accrue',false)
                    .selectComboBoxRowValue('M2M', 'No', 'M2M',0)
                    .clickCheckBox('Price',true)
                    .selectComboBoxRowNumber('CostType',3,0)
                    //.selectComboBoxRowValue('CostType', 'Discount', 'CostType',3,1)
                    .selectComboBoxRowNumber('CostMethod',1,0)
                    //.selectComboBoxRowValue('CostMethod', 'Per Unit', 'CostMethod',1,1)
                    .enterData('Text Field','Amount','1.20')
                    .selectComboBoxRowValue('CostUOM', 'lb1', 'CostUOM',0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== Setup Other Charge Cost Done =====')
                    .displayText('===== 16. Add Other Charge Item - Discount1 DONE =====')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .displayText('===== 16. Add Other Charge Item - Discount1 DONE =====')
                    .done();
            },
            continueOnFail: true
        })



        .clickMenuFolder('Purchasing (Accounts Payable)')
        .waitUntilLoaded('')
        .clickMenuScreen('Vendors')
        .waitUntilLoaded('')

        .filterGridRecords('Search', 'FilterGrid', 'Item Vendor1')
        .waitUntilLoaded()


        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //Add Vendors
                    .displayText('===== 17. Create Item Vendor =====')
                    .clickButton('New')
                    .waitUntilLoaded('emcreatenewentity',3000)
                    .enterData('Text Field','Name','Item Vendor1')
                    .enterData('Text Field','Contact','Item Vendor1-C1')
                    .enterData('Text Field','Phone','1234567890')
                    .enterData('Text Field','Email','rufil.cabangal@gmail.com')
                    .enterData('Text Field','Address','123 Wide Street')
                    .enterData('Text Field','City','Richmond')
                    .enterData('Text Field','State','IN')
                    .enterData('Text Field','ZipCode','47374')
                    .selectComboBoxRowValue('Timezone', '(UTC-05:00) Indiana (East)', 'Timezone',0)
                    .clickButton('Match')
                    .waitUntilLoaded('emduplicateentities',3000)
                    .clickButton('Add')
                    .enterData('Text Field','Location','Item Vendor1-Loc1')
                    .clickTab('Vendor')
                    .waitUntilLoaded('')
                    .selectGridComboBoxRowValue('VendorTerm',1,'colVendorTerms','Net 30','strTerm')
                    .selectComboBoxRowValue('VendorTerms', 'Net 30', 'VendorTerms',5)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== 17. Create Item Vendor DONE =====')
                    .done();
            },
            continueOnFail: true
        })


        .filterGridRecords('Search', 'FilterGrid', 'Vendor1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('===== 18. Create 3rd Party Vendor =====')
                    .clickMenuFolder('Purchasing (Accounts Payable)')
                    .waitUntilLoaded('',3000)
                    .clickMenuScreen('Vendors')
                    .waitUntilLoaded('',3000)
                    .clickButton('New')
                    .waitUntilLoaded('emcreatenewentity',3000)
                    .enterData('Text Field','Name','3rd Party Vendor1')
                    .enterData('Text Field','Contact','3rd Party Vendor1-C1')
                    .enterData('Text Field','Phone','1234567890')
                    .enterData('Text Field','Email','rufil.cabangal@gmail.com')
                    .enterData('Text Field','Address','789 Narrow Drive')
                    .enterData('Text Field','City','Richmond')
                    .enterData('Text Field','State','IN')
                    .enterData('Text Field','ZipCode','47374')
                    .selectComboBoxRowValue('Timezone', '(UTC-05:00) Indiana (East)', 'Timezone',0)
                    .clickButton('Match')
                    .waitUntilLoaded('emduplicateentities',3000)
                    .clickButton('Add')
                    .enterData('Text Field','Location','3rd Party Vendor1-Loc1')
                    .clickTab('Vendor')
                    .waitUntilLoaded('')
                    .selectGridComboBoxRowValue('VendorTerm',1,'colVendorTerms','Net 30','strTerm')
                    .selectComboBoxRowValue('VendorTerms', 'Net 30', 'VendorTerms',5)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== 18. Create 3rd Party Vendor DONE =====')
                    .done();
            },
            continueOnFail: true
        })

        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickMenuFolder('Purchasing (Accounts Payable)')
                    .waitUntilLoaded('')
                    .displayText('===== 18. Create 3rd Party Vendor DONE =====')
                    .done();
            },
            continueOnFail: true
        })


        .displayText('===== 19. Create Customer =====')
        .clickMenuFolder('Sales (Accounts Receivable)')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Customers')
        .waitUntilLoaded('',3000)

        .filterGridRecords('Search', 'FilterGrid', 'Customer1')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('New')
                    .waitUntilLoaded('emcreatenewentity',3000)
                    .enterData('Text Field','Name','Customer1')
                    .enterData('Text Field','Contact','Customer1-C1')
                    .enterData('Text Field','Phone','0123456789')
                    .enterData('Text Field','Email','rufil.cabangal@gmail.com')
                    .enterData('Text Field','Address','456 Flower Drive')
                    .enterData('Text Field','City','Richmond')
                    .enterData('Text Field','State','IN')
                    .enterData('Text Field','ZipCode','47374')
                    .selectComboBoxRowValue('Timezone', '(UTC-05:00) Indiana (East)', 'Timezone',0)
                    .clickButton('Match')
                    .waitUntilLoaded('emduplicateentities',3000)
                    .clickButton('Add')
                    .enterData('Text Field','Location','Customer1-Loc1')
                    .clickTab('Customer')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('CustomerTerms', 'Net 30', 'CustomerTerms',5)
                    .selectComboBoxRowNumber('CustomerSalesperson',1,0)
                    .clickTab('Locations')
                    .selectGridRowNumber('Location',1)
                    .clickButton('EditLoc')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('Country', 'United States', 'Country',0)
                    .selectComboBoxRowValue('ShipVia', 'UPS', 'ShipVia',0)
                    .selectComboBoxRowValue('TaxGroup', 'Test Group 1', 'TaxGroup',0)
                    .selectComboBoxRowValue('Terms', 'Net 30', 'Terms',5)
                    .selectComboBoxRowValue('Warehouse', '0001 - Fort Wayne', 'Warehouse',0)
                    .selectComboBoxRowValue('FreightTerm', 'Deliver', 'FreightTerm',0)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .clickButton('Save')
                    .waitUntilLoaded('',3000)
                    .clickButton('Close')
                    .waitUntilLoaded('',3000)
                    .displayText('===== 19. Create Customer DONE =====')
                    .done();
            },
            continueOnFail: true
        })

        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .waitUntilLoaded('')
                    .clickMenuFolder('Sales (Accounts Receivable)')
                    .waitUntilLoaded('')
                    .displayText('===== 19. Create Customer DONE =====')
                    .done();
            },
            continueOnFail: true
        })




        .done()
});