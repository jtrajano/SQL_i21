Ext.define('Inventory.domain.receipt.LotReplicationProgress', {
    constructor: function(config) {
        this.initConfig(config);
    },

    config: {
        max: 100,
        min: 0,
        value: 0,
        onchange: undefined
    },

    step: function (value) {
        this.setValue(Math.max(this.getMin(), Math.min(this.getMax(), value)));
        this.onStep();
    },

    onStep: function () {
        var cb = this.getOnchange();
        if(cb) {
            cb(this.getValue(), this.getPercentage());
        }    
    },

    getPercentage: function() {
        return ic.utils.Math.roundWithPrecision(this.getValue() / this.getMax() * 100.00, 0);
    }
});