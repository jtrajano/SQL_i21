Ext.define('Inventory.view.RepostInventoryViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icrepostinventory',
    requires: [
        'Inventory.store.Item',
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
            data: [
                { intId: 1, strMonth: 'January' }, 
                { intId: 2, strMonth: 'February' },
                { intId: 3, strMonth: 'March' },
                { intId: 4, strMonth: 'April' },
                { intId: 5, strMonth: 'May' },
                { intId: 6, strMonth: 'June' },
                { intId: 7, strMonth: 'July' },
                { intId: 8, strMonth: 'August' },
                { intId: 9, strMonth: 'September' },
                { intId: 10, strMonth: 'October' },
                { intId: 11, strMonth: 'November' },
                { intId: 12, strMonth: 'December' }
            ],
            fields: [
                { name: 'intId' },
                { name: 'strMonth' }
            ]
        }
    },

    data: {
        selectedItem: null
        // current: {
        //     strMonth: null,
        //     strItemNo: null,
        //     strPostOrder: 'Perpetual'
        // }
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
        }
    }
});