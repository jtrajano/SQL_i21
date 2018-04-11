using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemPricingLevels : ImportDataLogic<tblICItemPricingLevel>
    {
        public ImportItemPricingLevels(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "location", "price level", "uom", "pricing method" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemPricingLevelId";
        }

        public override int GetPrimaryKeyValue(tblICItemPricingLevel entity)
        {
            return entity.intItemPricingLevelId;
        }

        //public override string DuplicateFoundMessage()
        //{
        //    return "Pricing levels cannot have the same effective date.";
        //}

        //protected override Expression<Func<tblICItemPricingLevel, bool>> GetUniqueKeyExpression(tblICItemPricingLevel entity)
        //{
        //    return (e => e.intItemPricingLevelId == entity.intItemPricingLevelId);
        //}

        public override tblICItemPricingLevel Process(CsvRecord record)
        {
            var entity = new tblICItemPricingLevel();
            var valid = true;

            SetDecimal(record, "Min", e => entity.dblMin = e);
            SetDecimal(record, "Max", e => entity.dblMax = e);
            SetDecimal(record, "Amount/Percent", e => entity.dblAmountRate = e);
            SetDecimal(record, "Unit Price", e => entity.dblUnitPrice = e);
            SetDecimal(record, "Comm Amount/Percent", e => entity.dblCommissionRate = e);
            SetDate(record, "Effective Date", e => entity.dtmEffectiveDate = e);
            var lu = GetFieldValue(record, "Item No");
            valid = SetIntLookupId<tblICItem>(record, "Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intItemId = e, required: true);
            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new PricingMethodPipe(context, ImportResult));
            AddPipe(new CommissionOnPipe(context, ImportResult));
            AddPipe(new LocationPipe(context, ImportResult));
            AddPipe(new PriceLevelPipe(context, ImportResult));
            AddPipe(new UOMPipe(context, ImportResult));
            AddPipe(new PricingPipe(context, ImportResult));
        }

        class PricingMethodPipe : CsvPipe<tblICItemPricingLevel>
        {
            public PricingMethodPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemPricingLevel Process(tblICItemPricingLevel input)
            {
                var value = GetFieldValue("Pricing Method");
                switch (value.ToUpper().Trim())
                {
                    case "NONE":
                        input.strPricingMethod = "None";
                        break;
                    case "FIXED DOLLAR AMOUNT":
                        input.strPricingMethod = "Fixed Dollar Amount";
                        break;
                    case "MARKUP STANDARD COST":
                        input.strPricingMethod = "Markup Standard Cost";
                        break;
                    case "PERCENT OF MARGIN":
                        input.strPricingMethod = "Percent of Margin";
                        break;
                    case "DISCOUNT RETAIL PRICE":
                        input.strPricingMethod = "Discount Retail Price";
                        break;
                    case "MSRP DISCOUNT":
                        input.strPricingMethod = "MSRP Discount";
                        break;
                    case "PERCENT OF MARGIN (MSRP)":
                        input.strPricingMethod = "Percent of Margin (MSRP)";
                        break;
                    case "MARKUP LAST COST":
                        input.strPricingMethod = "Markup Last Cost";
                        break;
                    case "MARKUP AVG COST":
                        input.strPricingMethod = "Markup Avg Cost";
                        break;
                    default:
                        var msg = new ImportDataMessage()
                        {
                            Column = "Pricing Method",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_WARNING,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_DEFAULTED,
                            Exception = null,
                            Value = value,
                            Message = $"Invalid value for Pricing Method: {value}. Value set to default: 'None'.",
                        };
                        AddMessage(msg.Column, msg.Message, msg.Value, msg.Type, msg.Status, msg.Action);
                        break;
                }
                return input;
            }
        }

        class CommissionOnPipe : CsvPipe<tblICItemPricingLevel>
        {
            public CommissionOnPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemPricingLevel Process(tblICItemPricingLevel input)
            {
                if (input == null)
                    return input;
                var value = GetFieldValue("Commission On");
                switch (value.ToUpper().Trim())
                {
                    case "PERCENT":
                        input.strCommissionOn = "Percent";
                        break;
                    case "UNITS":
                        input.strCommissionOn = "Units";
                        break;
                    case "AMOUNT":
                        input.strCommissionOn = "Amount";
                        break;
                    case "GROSS PROFIT":
                        input.strCommissionOn = "Gross Profit";
                        break;
                    default:
                        var msg = new ImportDataMessage()
                        {
                            Column = "GL Account Category",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_WARNING,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_DEFAULTED,
                            Exception = null,
                            Value = value,
                            Message = $"Invalid value for Commission: {value}. Value set to default: 'None'.",
                        };
                        AddMessage(msg.Column, msg.Message, msg.Value, msg.Type, msg.Status, msg.Action);
                        break;
                }
                return input;
            }
        }

        class LocationPipe : CsvPipe<tblICItemPricingLevel>
        {
            public LocationPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemPricingLevel Process(tblICItemPricingLevel input)
            {
                if (input == null)
                    return input;
                var value = GetFieldValue("Location");
                if(string.IsNullOrEmpty(value))
                {
                    AddError("Location", "Location should not be blank.");
                    return null;
                }

                var locationId = ImportDataLogicHelpers.GetLookUpId<tblSMCompanyLocation>(Context, m => m.strLocationName == value, e => e.intCompanyLocationId);
                if (locationId == null)
                {
                    AddError("Location", "Can't find location.");
                    return null;
                }
                
                var itemLocation = ImportDataLogicHelpers.GetLookUpObject<tblICItemLocation>(Context, m => m.intLocationId == locationId && m.intItemId == input.intItemId);

                if (itemLocation != null)
                {
                    input.tblICItemLocation = itemLocation;
                    input.intItemLocationId = itemLocation.intItemLocationId;
                    input.intLocationId = itemLocation.intLocationId;
                }
                else
                {
                    AddError("Location", "Can't find location.");
                    return null;
                }

                return input;
            }
        }

        class PriceLevelPipe : CsvPipe<tblICItemPricingLevel>
        {
            public PriceLevelPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemPricingLevel Process(tblICItemPricingLevel input)
            {
                if (input == null)
                    return input;
                var lu = GetFieldValue("Price Level");
                var valid = true;
                valid = ImportDataLogicHelpers.SetIntLookupId<tblSMCompanyLocationPricingLevel>(Context, Result, Record, "Price Level", e => e.strPricingLevelName == lu && e.intCompanyLocationId == input.intLocationId,
                        e => e.intCompanyLocationPricingLevelId, e => input.intItemPricingLevelId = e, required: true);

                if(!valid)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Location",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_ERROR,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = lu,
                        Message = $"Invalid Price Level {lu}.",
                    };
                    AddError("Location", "Invalid Price Level");
                    return null;
                }
                input.strPriceLevel = lu;
                return input;
            }
        }

        class UOMPipe : CsvPipe<tblICItemPricingLevel>
        {
            public UOMPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemPricingLevel Process(tblICItemPricingLevel input)
            {
                if (input == null)
                    return input;
                var value = GetFieldValue("UOM");
                if (string.IsNullOrEmpty(value))
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "UOM",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_ERROR,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"UOM must not be blank.",
                    };
                    AddError("UOM", "UOM must not be blank.");
                    return null;
                }

                var uomId = ImportDataLogicHelpers.GetLookUpId<tblICUnitMeasure>(Context, m => m.strUnitMeasure == value, e => e.intUnitMeasureId);

                if (uomId == null)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "UOM",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_ERROR,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Invalid UOM {value}.",
                    };
                    AddError("UOM", "Invalid UOM");
                    return null;
                }
                var itemUom = ImportDataLogicHelpers.GetLookUpObject<tblICItemUOM>(Context, m => m.intUnitMeasureId == uomId && m.intItemId == input.intItemId);
                if (itemUom != null)
                {
                    input.intItemUnitMeasureId = itemUom.intItemUOMId;
                    input.dblUnit = itemUom.dblUnitQty;
                }
                else
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "UOM",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_ERROR,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Invalid UOM {value}.",
                    };
                    AddError("UOM", "Invalid UOM");
                    return null;
                }

                return input;
            }
        }

        class PricingPipe : CsvPipe<tblICItemPricingLevel>
        {
            public PricingPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemPricingLevel Process(tblICItemPricingLevel input)
            {
                if (input == null)
                    return input;
                var intItemLocationId = input.intItemLocationId;
                var intCompanyLocationId = input.intLocationId;
                var pricingItem = ImportDataLogicHelpers.GetLookUpObject<tblICItemPricing>(Context, m => m.intItemLocationId == intItemLocationId);
                if (pricingItem != null)
                {
                    var salesPrice = pricingItem.dblSalePrice;
                    var msrpPrice = pricingItem.dblMSRPPrice;
                    var amount = pricingItem.dblAmountPercent;
                    var standardCost = pricingItem.dblStandardCost;

                    input.dblUnitPrice = GetCalculatedUnitPrice(input.strPricingMethod, (decimal)input.dblUnitPrice,
                (decimal)salesPrice, (decimal)msrpPrice, (decimal)input.dblAmountRate, (decimal)input.dblUnit, (decimal)standardCost);
                }

                return input;
            }

            private decimal GetCalculatedUnitPrice(string pricingMethod, decimal originalRetailPrice, decimal salesPrice, decimal msrpPrice,
            decimal amount, decimal quantity, decimal standardCost)
            {
                decimal retailPrice = 0.0M;

                switch (pricingMethod)
                {
                    case "Discount Retail Price":
                        salesPrice = salesPrice - (salesPrice * (amount / 100));
                        retailPrice = salesPrice * quantity;
                        break;
                    case "MSRP Discount":
                        msrpPrice = msrpPrice - (msrpPrice * (amount / 100));
                        retailPrice = msrpPrice * quantity;
                        break;
                    case "Percent of Margin (MSRP)":
                        var percent = amount / 100;
                        salesPrice = ((msrpPrice - standardCost) * percent) + standardCost;
                        retailPrice = salesPrice * quantity;
                        break;
                    case "Fixed Dollar Amount":
                        salesPrice = standardCost + amount;
                        retailPrice = salesPrice * quantity;
                        break;
                    case "Markup Standard Cost":
                        var markup = standardCost * (amount / 100);
                        salesPrice = standardCost + markup;
                        retailPrice = salesPrice * quantity;
                        break;
                    case "Percent of Margin":
                        salesPrice = standardCost / (1 - (amount / 100));
                        retailPrice = salesPrice * quantity;
                        break;
                    default:
                        retailPrice = originalRetailPrice;
                        break;
                }

                return retailPrice;
            }
        }
    }
}
