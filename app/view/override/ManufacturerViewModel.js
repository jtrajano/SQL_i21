/**
 * Created by kkarthick on 24-09-2014.
 */
Ext.define('Inventory.view.override.ManufacturerViewModel', {
    override: 'Inventory.view.ManufacturerViewModel',

    requires:['i21.store.ZipCodeBuffered',
              'i21.store.CountryBuffered']

});
