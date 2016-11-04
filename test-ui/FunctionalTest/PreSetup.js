StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region 1. Add Another Company Location for Irelyadmin User
        .displayText('===== 1. Add Another Company Location for irelyadmin User =====')
        .clickMenuFolder('System Manager','Folder')
        .clickMenuScreen('Users','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        .waitUntilLoaded('ementity')
        .selectComboBoxRowValue('Timezone', '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi', 'Timezone',0)
        .clickTab('User')
        .waitUntilLoaded()
        .clickTab('User Roles')
        .waitUntilLoaded()
        .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 2, 'strLocationName', '0002 - Indianapolis', 'strLocationName')
        .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 2, 'strUserRole', 'ADMIN', 'strUserRole')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        //endregion


        .done();

})