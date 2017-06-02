StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region 1. Add Another Company Location for Irelyadmin User and setup default decimals
        .displayText('===== 1. Add Another Company Location for irelyadmin User =====')
        .clickMenuFolder('System Manager','Folder')
        .clickMenuScreen('Users','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        .waitUntilLoaded('ementity')
        .selectComboBoxRowValue('Timezone', '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi', 'Timezone',0)
        .clickTab('User')
        .waitUntilLoaded()
        .selectComboBoxRowValue('UserNumberFormat', '1,234,567.89', 'UserNumberFormat',1)
        .clickTab('User Roles')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 7, 'strLocationName', '0002 - Indianapolis', 'strLocationName')
        .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 7, 'strUserRole', 'ADMIN', 'strUserRole')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('System Manager','Folder')
        //endregion


        .done();

})