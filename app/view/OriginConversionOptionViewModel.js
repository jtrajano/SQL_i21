/*
 * File: app/view/OriginConversionOptionViewModel.js
 *
 * This file was generated by Sencha Architect version 3.2.0.
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

Ext.define('Inventory.view.OriginConversionOptionViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icoriginconversionoption',

    data: {
        lineOfBusiness: '',
        currentTask: 'LOB'
    },

    formulas: {
        hasLob: function(get) {
            return !iRely.Functions.isEmpty(get('lineOfBusiness'));
        },
        
        disableLob: function(get) {
            return get('currentTask') !== 'LOB' && get('currentTask') !== 'UOM';
        },

        disableUOM: function(get) {
            return (get('currentTask') !== 'UOM' && get('currentTask') != 'LOB') || !get('hasLob');
        },

        disableLocations: function(get) {
            return get('currentTask') !== 'Locations' || !get('hasLob');
        },

        disableCommodity: function(get) {
            return get('currentTask') !== 'Commodity' || !get('hasLob') || get('lineOfBusiness') !== 'Grain';
        },

        disableCategoryClass: function(get) {
            return get('currentTask') !== 'CategoryClass' || !get('hasLob');
        },

        disableCategoryGLAccts: function(get) {
            return get('currentTask') !== 'CategoryGLAccts' || !get('hasLob');
        },

        disableAdditionalGLAccts: function(get) {
            return get('currentTask') !== 'AdditionalGLAccts' || !get('hasLob');
        },

        disableItems: function(get) {
            return get('currentTask') !== 'Items' || !get('hasLob');
        },

        disableItemGLAccts: function(get) {
            return get('currentTask') !== 'ItemGLAccts' || !get('hasLob');
        },

        disableBalance: function(get) {
            return get('currentTask') !== 'Balance' || !get('hasLob');
        },
        
        disableRecipeFormula: function(get){
            return get('currentTask') !== 'RecipeFormula' || !get('hasLob') || get('lineOfBusiness') !== 'Petro';
        }
    }
});