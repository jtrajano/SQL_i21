/**
 * Created by kkarthick on 24-09-2014.
 */
Ext.define('Inventory.view.ManufacturerViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.manufacturer',

    requires:['i21.store.ZipCodeBuffered',
              'i21.store.CountryBuffered']

});
