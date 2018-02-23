/**
 * Created by LZabala on 10/22/2015.
 */
Ext.define('Inventory.model.InventoryCountDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryCountDetailId',

    fields: [
        { name: 'intInventoryCountDetailId', type: 'int' },
        { name: 'intInventoryCountId', type: 'int',
            reference: {
                type: 'Inventory.model.InventoryCount',
                inverse: {
                    role: 'tblICInventoryCountDetails',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intItemId', type: 'int', allowNull: false },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'intCountGroupId', type: 'int', allowNull: true },
        { name: 'intLotId', type: 'int', allowNull: true },
        { name: 'dblSystemCount', type: 'float' },
        { name: 'dblLastCost', type: 'float' },
        { name: 'strCountLine', type: 'string' },
        { name: 'dblPallets', type: 'float' },
        { name: 'dblQtyPerPallet', type: 'float' },
        { name: 'dblPhysicalCount', type: 'float' },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'strStockUOM', type: 'string' },
        { name: 'intStockUOMId', type: 'int', allowNull: true },
        { name: 'ysnRecount', type: 'boolean' },
        { name: 'intEntityUserSecurityId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string' },
        { name: 'strItemDescription', type: 'string' },
        { name: 'strLotTracking', type: 'string' },
        { name: 'strCategory', type: 'string' },
        { name: 'strLocationName', type: 'string' },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'strLotNo', type: 'string' },
        { name: 'strLotAlias', type: 'string' },
        { name: 'strParentLotAlias', type: 'string' },
        { name: 'strParentLotNo', type: 'string' },
        { name: 'intParentLotId', type: 'int', allowNull: true },
        { name: 'strWeightUOM', type: 'string' },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblWeightQty', type: 'float' },
        { name: 'dblNetQty', type: 'float' },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'dblConversionFactor', type: 'float' },
        { name: 'dblItemUOMConversionFactor', type: 'float' },
        { name: 'dblWeightUOMConversionFactor', type: 'float' },
        { name: 'dblQtyReceived', type: 'float' },
        { name: 'dblQtySold', type: 'float' },
        { name: 'dblPhysicalCountStockUnit', type: 'float',
            persist: false,
            convert: function(value, record){
                var dblPhysicalCount = iRely.Functions.isEmpty(record.get('dblPhysicalCount')) ? 0 : record.get('dblPhysicalCount');
                var dblConversionFactor = iRely.Functions.isEmpty(record.get('dblConversionFactor')) ? 0 : record.get('dblConversionFactor');
                var dblPhysicalCountStockUnit = dblPhysicalCount * dblConversionFactor;
                return dblPhysicalCountStockUnit;
            },
            depends: ['dblPhysicalCount', 'dblConversionFactor']},
        { name: 'dblVariance', type: 'float' ,
            persist: false,
            convert: function(value, record){
                var dblPhysicalCount = iRely.Functions.isEmpty(record.get('dblPhysicalCount')) ? 0 : record.get('dblPhysicalCount');
                var dblSystemCount = iRely.Functions.isEmpty(record.get('dblSystemCount')) ? 0 : record.get('dblSystemCount');
                var dblVariance = dblPhysicalCount - dblSystemCount;

                if(record.get('intCountGroupId')) {
                    var dblQtyReceived = iRely.Functions.isEmpty(record.get('dblQtyReceived')) ? 0 : record.get('dblQtyReceived');
                    var dblQtySold = iRely.Functions.isEmpty(record.get('dblQtySold')) ? 0 : record.get('dblQtySold');
                    dblVariance = dblPhysicalCount - (dblSystemCount + dblQtyReceived - dblQtySold);
                }
                return dblVariance;
            },
            depends: ['dblPhysicalCount', 'dblSystemCount', 'dblQtyReceived', 'dblQtySold']},
        { name: 'strUserName', type: 'string' },
        { name: 'ysnLotted', type: 'boolean' },
        { name: 'intConcurrencyId', type: 'int', allowNull: true }
    ],

    validators: [
        { type: 'presence', field: 'intItemId' },
        { type: 'presence', field: 'intItemUOMId' }
    ],

    validate: function(options) {
        var errors = this.callParent(arguments);

        if (this.get('intLotId')) {
            if (this.get('intSubLocationId') === null || this.get('intSubLocationId') === 0) {
                errors.add({
                    field: 'strSubLocationName',
                    message: "Please select a sub location."
                });   
            } else if (this.get('intStorageLocationId') === null || this.get('intStorageLocationId') === 0) {
                errors.add({
                    field: 'strStorageLocationName',
                    message: "Please select a storage location."
                });
            }
        }

        if(this.get('ysnLotted')) {
            if(this.get('intSubLocationId') === null || this.get('intSubLocationId') === 0) {
                errors.add({
                    field: 'strSubLocationName',
                    message: "Please select a sub location."
                });   
            }

            if(this.get('intStorageLocationId') === null || this.get('intStorageLocationId') === 0) {
                errors.add({
                    field: 'strStorageLocationName',
                    message: "Please select a storage location."
                });   
            }

            if (!this.get('strLotNo')) {
                errors.add({
                    field: 'strLotNo',
                    message: "Please type a lot number or select an existing lot from the Lot Id list."
                });  
            }

            if(this.get('ysnLotWeightsRequired') && ((this.get('intWeightUOMId') === null) || (this.get('dblPhysicalCount') > 0 && this.get('dblWeightQty') === 0 && this.get('dblNetQty') === 0))) {
                errors.add({
                    field: this.get('intWeightUOMId') === null ? 'intWeightUOMId' : this.get('dblWeightQty') === 0 ? 'dblWeightQty': 'intWeightUOMId',
                    message: "Gross/Net UOM and weights are required for item " + this.get('strItemNo')
                });
            }
        }

        return errors;
    }
});