using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemPricingLevels : ImportDataLogic<tblICItemPricingLevel>
    {

        protected override string[] GetRequiredFields()
        {
            return new string[] { "location", "price level", "uom", "pricing method" };
        }

        protected override int GetPrimaryKeyId(ref tblICItemPricingLevel entity)
        {
            return entity.intItemPricingLevelId;
        }

        protected override tblICItemPricingLevel ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICItemPricingLevel fc = new tblICItemPricingLevel();
            bool valid = true;
            int? intItemId = null;
            int? intItemLocationId = null;
            int? intCompanyLocationId = null;
            tblICItemUOM itemUom = null;
            decimal? salesPrice = 0, msrpPrice = 0, amount = 0, standardCost = 0;

            for (var i = 0; i < fieldCount; i++)
            {
                string header = headers[i];
                string value = csv[header];

                string h = header.ToLower().Trim();
                int? lu = null;

                switch (h)
                {
                    case "item no":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Item with Item No.: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }

                        lu = GetLookUpId<tblICItem>(
                            context,
                            m => m.strItemNo == value,
                            e => e.intItemId);
                        if (lu != null)
                        {
                            fc.intItemId = (int)lu;
                            intItemId = fc.intItemId;
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Item with Item No.: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "location":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Location: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        var locationId = GetLookUpId<tblSMCompanyLocation>(context, 
                            m => m.strLocationName == value, e => e.intCompanyLocationId);
                        if (locationId == null)
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Location: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        var itemLocation = GetLookUpObject<tblICItemLocation>(
                            context,
                            m => m.intLocationId == locationId && m.intItemId == intItemId);

                        if (itemLocation != null)
                        {
                            fc.intLocationId = itemLocation.intLocationId;
                            fc.intItemLocationId = itemLocation.intItemLocationId;
                            intItemLocationId = itemLocation.intItemLocationId;
                            intCompanyLocationId = itemLocation.intLocationId;
                            var pricingItem = GetLookUpObject<tblICItemPricing>(
                                context, m => m.intItemLocationId == intItemLocationId);
                            if (pricingItem != null)
                            {
                                salesPrice = pricingItem.dblSalePrice;
                                msrpPrice = pricingItem.dblMSRPPrice;
                                amount = pricingItem.dblAmountPercent;
                                standardCost = pricingItem.dblStandardCost;
                            }
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Location: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "price level":
                        tblSMCompanyLocationPricingLevel pl = GetLookUpObject<tblSMCompanyLocationPricingLevel>(
                            context,
                            m => m.strPricingLevelName == value && m.intCompanyLocationId == intCompanyLocationId);
                        if (pl != null)
                            fc.strPriceLevel = pl.strPricingLevelName;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Invalid Price Level: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "uom":
                        var uomId = GetLookUpId<tblICUnitMeasure>(context,
                            m => m.strUnitMeasure == value, e => e.intUnitMeasureId);
                        if (uomId == null)
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Invalid Item UOM: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        itemUom = GetLookUpObject<tblICItemUOM>(
                            context,
                            m => m.intUnitMeasureId == uomId && m.intItemId == intItemId);
                        if (itemUom != null)
                        {
                            fc.intItemUnitMeasureId = itemUom.intUnitMeasureId;
                            fc.dblUnit = itemUom.dblUnitQty;
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Invalid Item UOM: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "min":
                        if (string.IsNullOrEmpty(value))
                            break;
                        SetDecimal(value, del => fc.dblMin = del, "Min", dr, header, row);
                        break;
                    case "max":
                        if (string.IsNullOrEmpty(value))
                            break;
                        SetDecimal(value, del => fc.dblMax = del, "Max", dr, header, row);
                        break;
                    case "pricing method":
                        switch (value.ToUpper().Trim())
                        {
                            case "NONE":
                                fc.strPricingMethod = "None";
                                break;
                            case "FIXED DOLLAR AMOUNT":
                                fc.strPricingMethod = "Fixed Dollar Amount";
                                break;
                            case "MARKUP STANDARD COST":
                                fc.strPricingMethod = "Markup Standard Cost";
                                break;
                            case "PERCENT OF MARGIN":
                                fc.strPricingMethod = "Percent of Margin";
                                break;
                            case "DISCOUNT RETAIL PRICE":
                                fc.strPricingMethod = "Discount Retail Price";
                                break;
                            case "MSRP DISCOUNT":
                                fc.strPricingMethod = "MSRP Discount";
                                break;
                            case "PERCENT OF MARGIN (MSRP)":
                                fc.strPricingMethod = "Percent of Margin (MSRP)";
                                break;
                            default:
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Status = STAT_INNER_DEF,
                                    Message = string.Format("Invalid value for Pricing Method: " + value + ". Value set to default: 'None'.")
                                });
                                break;
                        }
                        break;
                    case "amount/percent":
                        if (string.IsNullOrEmpty(value))
                            break;
                        SetDecimal(value, del => fc.dblAmountRate = del, "Amount/Percent", dr, header, row);
                        break;
                    case "unit price":
                        if (string.IsNullOrEmpty(value))
                            break;
                        SetDecimal(value, del => fc.dblUnitPrice = del, "Unit Price", dr, header, row);
                        break;
                    case "commission on":
                        if (string.IsNullOrEmpty(value))
                            break;
                        switch (value.ToUpper().Trim())
                        {
                            case "PERCENT":
                                fc.strCommissionOn = "Percent";
                                break;
                            case "UNITS":
                                fc.strCommissionOn = "Units";
                                break;
                            case "AMOUNT":
                                fc.strCommissionOn = "Amount";
                                break;
                            case "GROSS PROFIT":
                                fc.strCommissionOn = "Gross Profit";
                                break;
                            default:
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Status = STAT_INNER_COL_SKIP,
                                    Message = string.Format("Invalid value for Commission: " + value + ".")
                                });
                                break;
                        }
                        break;
                    case "comm amount/percent":
                        SetDecimal(value, del => fc.dblCommissionRate = del, "Comm Amount/Percent", dr, header, row);
                        break;
                }
            }

            // Calculate unit price
            fc.dblUnitPrice = GetCalculatedUnitPrice(fc.strPricingMethod, (decimal)fc.dblUnitPrice,
                (decimal)salesPrice, (decimal)msrpPrice, (decimal)fc.dblAmountRate, (decimal)fc.dblUnit, (decimal)standardCost);

            if (!valid)
                return null;

            context.AddNew<tblICItemPricingLevel>(fc);
            return fc;
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
