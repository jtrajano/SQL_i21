Ext.define('Inventory.view.RebuildInventoryViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icrebuildinventory',
    requires: [
        'Inventory.store.BufferedItem',
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
            type: 'icbuffereditem',
            sorters: {
                direction: 'ASC',
                property: 'strItemNo'
            }
        },
        fiscalMonths: {
            type: 'icfiscalperiod'
        }
    },

    data: {
        selectedItem: null,
        inProgress: false
    },

    formulas: {
        description: function(get) {
            if(!get('current.dtmDate'))
                return;
            var month = get('current.strMonth');
            var order = get('current.strPostOrder');
            var item = 'all items';
            try {
                if(get('current.strItemNo'))
                    item = '"' + get('current.strItemNo') + '" item';
            } catch(e) {}
            var year = get('current.dtmDate').getFullYear();
            return 'Rebuild inventory for ' + item + ' in a ' + order.toLowerCase() + ' order from ' + month + ' ' + year + ' onwards including item(s) that are used for production.';
        },
        prompt: function(get) {
            if(!get('current.dtmDate'))
                return;
                
            var month = get('current.strMonth');
            var order = get('current.strPostOrder');
            var item = 'all items';
            try {
                if(get('current.strItemNo'))
                    item = '"' + get('current.strItemNo') + '" item';
            } catch(e) {}
            var year = get('current.dtmDate').getFullYear();

            if (item === 'all items'){
                return 'Inventory for ' + item + ' will be rebuilt from ' + moment(get('current.dtmDate')).format('l') + ' and onwards.<br/><br/>Do you want to continue?';
            }
            return 'Inventory for ' + item + ' will be rebuilt from ' + moment(get('current.dtmDate')).format('l') + ' and onwards. Any Finished Goods will be rebuilt as well if it is used as an ingredient.<br/><br/>Do you want to continue?';
        },
        canPost: function(get) {
            return (get('current.strPostOrder') && get('current.strMonth')) && !get('inProgress'); 
        },
        isInProgress: function(get) {
            return get('inProgress');
        }
    }
});