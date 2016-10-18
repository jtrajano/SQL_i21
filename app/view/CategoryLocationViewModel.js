/*
 * File: app/view/CategoryLocationViewModel.js
 *
 * This file was generated by Sencha Architect version 3.1.0.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 5.0.x library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 5.0.x. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('Inventory.view.CategoryLocationViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.iccategorylocation',

    requires: [
        'i21.store.CompanyLocationBuffered',
        //'Inventory.store.PaidOut',
        //'Inventory.store.Class',
        'Store.store.SubCategoryBuffered',
        'Store.store.SubcategoryRegProdBuffered'
    ],

    stores: {
        location: {
            type: 'companylocationbuffered'
        },
        //paidout: {
        //    type: 'storepaidout'
        //},
        class: {
            type: 'stsubcategorybuffered'
        },
        family: {
            type: 'stsubcategorybuffered'
        },
        product: {
            type: 'stsubcategoryregprodbuffered'
        }
    }

});