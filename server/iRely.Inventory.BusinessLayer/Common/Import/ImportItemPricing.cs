using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemPricing : ImportDataLogic<tblICItemPricing>
    {
        public ImportItemPricing(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "location" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemPricingId";
        }

        public override int GetPrimaryKeyValue(tblICItemPricing entity)
        {
            return entity.intItemPricingId;
        }

        protected override Expression<Func<tblICItemPricing, bool>> GetUniqueKeyExpression(tblICItemPricing entity)
        {
            return (e => e.intItemLocationId == entity.intItemLocationId && e.intItemId == entity.intItemId);
        }

        public override tblICItemPricing Process(CsvRecord record)
        {
            var entity = new tblICItemPricing()
            {
                strPricingMethod = "None",
                dblLastCost = 0,
                dblStandardCost = 0,
                dblAverageCost = 0,
                dblEndMonthCost = 0,
                dblMSRPPrice = 0,
                dblSalePrice = 0
            };

            var valid = true;

            var lu = GetFieldValue(record, "Item No");
            valid = SetIntLookupId<tblICItem>(record, "Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intItemId = e, required: true);
            lu = GetFieldValue(record, "Location");
            valid = SetLookupId<vyuICGetItemLocation>(record, "Location", e => e.strLocationName == lu && e.intItemId == entity.intItemId, e => e.intItemLocationId, e => entity.intItemLocationId = e, required: true);
            SetDecimal(record, "Last Cost", e => entity.dblLastCost = e);
            SetDecimal(record, "Standard Cost", e => entity.dblStandardCost = e);
            SetDecimal(record, "Average Cost", e => entity.dblAverageCost = e);
            SetDecimal(record, "End Month Cost", e => entity.dblEndMonthCost = e);
            SetDecimal(record, "Amount/Percent", e => entity.dblAmountPercent = e);
            SetDecimal(record, "Retail Price", e => entity.dblSalePrice = e);
            SetDecimal(record, "MSRP", e => entity.dblMSRPPrice = e);
            
            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new PricingMethodPipe(context, ImportResult));
        }

        class PricingMethodPipe : CsvPipe<tblICItemPricing>
        {
            public PricingMethodPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemPricing Process(tblICItemPricing input)
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
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = value,
                            Message = $"Invalid value for Pricing Method: {value}. Value set to default: 'None'."
                        };
                        Result.AddWarning(msg);
                        break;

                }

                return input;
            }
        }
    }
}

