Ext.define('Inventory.view.RepostInventoryViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icrepostinventory',
    requires: [
        'Inventory.store.Item',
        'Inventory.store.FiscalPeriod'
    ],

    stores: {
        postOrderTypes: {
            autoLoad: true,
            data: [
                { intId: 1, strPostOrder: 'Periodic' },
                { intId: 2, strPostOrder: 'Perpetual' }
            ],
            fields: [
                { name: 'intId' },
                { name: 'strPostOrder' },
            ]
        },
        items: {
            type: 'icitem'
        },
        fiscalMonths: {
            type: 'icfiscalperiod'
        }
    },

    data: {
        selectedItem: null
    },

    formulas: {
        description: function(get) {
            var month = get('current.strMonth');
            var order = get('current.strPostOrder');
            var item = 'all items';
            try {
                if(get('current.strItemNo'))
                    item = '"' + get('current.strItemNo') + '" item';
            } catch(e) {}
            var year = get('current.dtmDate').getFullYear();
            return 'Repost inventory for ' + item + ' in a ' + order.toLowerCase() + ' order from ' + month + ' ' + year + ' onwards.';
        },
        prompt: function(get) {
            var month = get('current.strMonth');
            var order = get('current.strPostOrder');
            var item = 'all items';
            try {
                if(get('current.strItemNo'))
                    item = '"' + get('current.strItemNo') + '" item';
            } catch(e) {}
            var year = get('current.dtmDate').getFullYear();
            return 'Inventory will be rebuilt for ' + item + ' from ' + month + '-' + moment(get('current.dtmDate')).format('l') + ' onwards. Do you want to continue?';
        },
        canPost: function(get) {
            return get('current.strPostOrder') && get('current.strMonth'); 
        }
    }
});