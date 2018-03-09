Ext.define('Inventory.model.UnitMeasureLookup', {
    extend: 'Ext.data.Model',
    fields: [
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strSymbol', type: 'string'},
        { name: 'strUnitType', type: 'string'},
        { name: 'intDecimalPlaces', type: 'int', allowNull: true, defaultValue: 6 }
    ],
    proxy: {
        type: 'localstorage',
        id: 'Inventory.model.lookup-unitmeasure'
    }
})