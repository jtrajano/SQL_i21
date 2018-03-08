Ext.define('Inventory.view.ImportLogViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icimportlog',
    data: {
        username: ''
    },

    formulas: {
        duplicatelabel: function(get) {
            return 'Allow Duplicates';
        },
        duration: function(get) {
            return Inventory.Utils.Date.getDuration(get('current.dblTimeSpentInSeconds'));
        },
        messagestyle: function(get) {
            if(get('current.intTotalErrors') > 0) {
                return 'color: red';
            } else if(get('current.intTotalErrors') === 0 && get('current.intTotalWarnings') > 0) {
                return 'color: orange';
            }
            return 'color: green';
        }
    }
});