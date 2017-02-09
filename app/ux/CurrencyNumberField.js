Ext.define('Inventory.ux.CurrencyNumberField', {
    extend: 'Ext.form.field.Number',
    xtype: 'currencynumberfield',
    alias: 'widget.iccurrencynumberfield',
    config: {
        /**
         * @cfg {String} currencySign
         * The currency sign that the currency formatter displays. Defaults to Ext.util.Format.currencySign
         */
        currencySign: null,
        /**
         * @cfg {Boolean} currencyAtEnd
         * This may be set to true to make the currency function append the currency sign to the formatted value.
         * Defaults to Ext.util.Format.currencyAtEnd
         */
        currencyAtEnd: null
    },

    initComponent: function () {
        var me = this;

        // Get currency format defaults from Ext.util.Format

        if (me.currencySign == null) {
            me.currencySign = Ext.util.Format.currencySign;
        }

        if (me.currencyAtEnd == null) {
            me.currencyAtEnd = Ext.util.Format.currencyAtEnd;
        }

        if (me.decimalPrecision == null) {
            me.decimalPrecision = Ext.util.Format.currencyPrecision;
        }

        me.callParent();
    },

    /**
     * Converts a mixed-type value to a raw representation suitable for displaying in the field. This allows controlling
     * how value objects passed to {@link #setValue} are shown to the user.
     *
     * See {@link #rawToValue} for the opposite conversion.
     *
     * Formats value as currency using Ext.util.Format.currency.
     *
     * @param {Object} value The mixed-type value to convert to the raw representation.
     * @return {Object} The converted raw value.
     */
    valueToRaw: function (value) {
        // Only format if it's numeric, otherwise the invalid messaging is not displayed properly
        var val = String(value).replace(this.currencySign, '');
        if (Ext.isNumeric(val)) {
            return Ext.util.Format.currency(value, this.currencySign, this.decimalPrecision, this.currencyAtEnd);
        } else {
            return val;
        }
    },

    /**
     * Converts a raw input field value into a mixed-type value that is suitable for this particular field type. This
     * allows controlling the normalization and conversion of user-entered values into field-type-appropriate values.
     *
     * Removes currency format and converts to numeric.
     *
     * See {@link #valueToRaw} for the opposite conversion.
     *
     * @param {Object} rawValue
     * @return {Object} The converted value.
     * @method
     */
    rawToValue: function (rawValue) {
        var me = this;
        var value = String(rawValue).replace(/[^0-9.]/g, '');
        return Ext.util.Format.round(value, me.decimalPrecision);
    },

    /**
     * Removes Currency formatting and runs all of Number's validations and returns an array of any errors. Note that this first runs Text's
     * validations, so the returned array is an amalgamation of all field errors. The additional validations run test
     * that the value is a number, and that it is within the configured min and max values.
     * @param {Object} [value] The value to get errors for (defaults to the current field value)
     * @return {String[]} All validation errors for this field
     */
    getErrors: function (value) {
        value = arguments.length > 0 ? value : this.processRawValue(this.getRawValue());

        var me = this,
            errors;

        value = me.rawToValue(value);
        errors = me.callParent([value])
        return errors;
    },

    /**
     * @method
     * Template method to do any pre-focus processing.
     * Removes currency formatting before focus.
     * @protected
     * @param {Ext.event.Event} e The event object
     */
    beforeFocus: function () {
        this.setRawValue(this.getValue());
    }
});