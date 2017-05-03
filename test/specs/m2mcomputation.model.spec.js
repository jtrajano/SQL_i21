UnitTestEngine.testModel({
    name: 'Inventory.model.M2MComputation',
    base: 'iRely.BaseEntity',
    idProperty: 'intM2MComputationId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intM2MComputationId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "strM2MComputationId",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        []
    ]
});