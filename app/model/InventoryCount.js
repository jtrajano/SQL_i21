/**
 * Created by LZabala on 10/22/2015.
 */
Ext.define('Inventory.model.InventoryCount', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.InventoryCountDetail',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryCountId',

    fields: [
        { name: 'intInventoryCountId', type: 'int' },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'intCategoryId', type: 'int', allowNull: true },
        { name: 'intCommodityId', type: 'int', allowNull: true },
        { name: 'intCountGroupId', type: 'int', allowNull: true },
        { name: 'dtmCountDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strCountNo', type: 'string' },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'strDescription', type: 'string' },
        { name: 'strSubLocation', type: 'string' },
        { name: 'strStorageLocation', type: 'string' },
        { name: 'strShiftNo', type: 'string' },
        { name: 'ysnIncludeZeroOnHand', type: 'boolean' },
        { name: 'ysnIncludeOnHand', type: 'boolean' },
        { name: 'ysnScannedCountEntry', type: 'boolean' },
        { name: 'ysnCountByLots', type: 'boolean' },
        { name: 'strCountBy', type: 'string', defaultValue: 'Item' },
        { name: 'ysnCountByPallets', type: 'boolean' },
        { name: 'ysnRecountMismatch', type: 'boolean' },
        { name: 'ysnExternal', type: 'boolean' },
        { name: 'ysnRecount', type: 'boolean' },
        { name: 'intRecountReferenceId', type: 'int', allowNull: true },
        { name: 'intStatus', type: 'int', allowNull: true },
        { name: 'ysnPosted', type: 'boolean' },
        { name: 'dtmPosted', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intEntityId', type: 'int', allowNull: true },
        { name: 'intLockType', type: 'int', allowNull: true, defaultValue: 1 },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [
        { type: 'presence', field: 'intLocationId' }
    ],

    validate: function (options) {
        var errors = this.callParent(arguments);
        if (!this.get('intLocationId')) {
            errors.add({
                field: 'strLocation',
                message: 'Location must be present.'
            });
        }

        return errors;
    }
});