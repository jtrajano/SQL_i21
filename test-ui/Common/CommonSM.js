
Ext.define('SystemManager.CommonSM', {


    commonLogin: function (t, next){
        var engine = new iRely.TestEngine();
        engine.start(t, next)

            .login('irelyadmin', 'i21by2015', '01')
            .done();
    },


    rightClickMenu: function(next, screenName) {
        var t = this;
        var node = t.engine.getNodeFromMenu('screen', screenName);

            t.diag('Clicking Screen ' + screenName);

            if (node) {
                t.chain(
                    {
                        action: 'rightClick',
                        target: node
                    },
                    {
                        action: 'wait',
                        delay: 1000
                    },
                    next
                )
            }else {
                next();
            }
        },



    getRecordFromMenu: function (type, moduleName) {
        var mainMenu = Ext.ComponentQuery.query('viewport')[0];
        var treeView = mainMenu.down('#trvMenu');
        var menudataSource = treeView.dataSource;
        var startIndex = 0;
        var record = menudataSource.data.items[0];
        while (!(record.data.strType) || record.data.strType.toLowerCase() != type.toLowerCase() && startIndex < menudataSource.count() && startIndex !== -1) {
            record = menudataSource.data.items[menudataSource.findExact('strMenuName', moduleName, startIndex)];
            startIndex = menudataSource.indexOf(record) + 1;
        }
        if ((record.data.strType) && record.data.strType.toLowerCase() == type.toLowerCase()) {
            return record;
        }
        else {
            return undefined;
        }
    },

    getNodeFromMenu: function (type, moduleName) {
        var mainMenu = Ext.ComponentQuery.query('viewport')[0];
        var treeView = mainMenu.down('#trvMenu');
        var record = this.getRecordFromMenu(type, moduleName);

        return treeView.getNodeByRecord(record);
    }

});