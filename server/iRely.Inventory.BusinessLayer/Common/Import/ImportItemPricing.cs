using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemPricing : ImportDataLogic<tblICItemPricing>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "location" };
        }

        protected override tblICItemPricing ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICItemPricing fc = new tblICItemPricing()
            {
                strPricingMethod = "None",
                dblLastCost = 0,
                dblStandardCost = 0,
                dblAverageCost = 0,
                dblEndMonthCost = 0,
                dblMSRPPrice = 0,
                dblSalePrice = 0
            };

            bool valid = true;
            string strItemNo = null;
            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;

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
                                Status = REC_SKIP,
                                Message = "Item No should not be blank."
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
                            strItemNo = value;
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Item with Item No.: " + value + '.' + strItemNo,
                                Status = REC_SKIP
                            });
                            dr.Info = TYPE_INNER_WARN;
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
                                Status = REC_SKIP,
                                Message = "Location should not be blank."
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = GetLookUpId<vyuICGetItemLocation>(
                            context,
                            m => m.strLocationName == value && m.strItemNo == strItemNo,
                            e => (int)e.intItemLocationId);
                        if (lu != null)
                            fc.intItemLocationId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Item Location: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = TYPE_INNER_WARN;
                        }
                        break;
                    case "last cost":
                        SetDecimal(value, del => fc.dblLastCost = del, "Last Cost", dr, header, row);
                        break;
                    case "standard cost":
                        SetDecimal(value, del => fc.dblStandardCost = del, "Standard Cost", dr, header, row);
                        break;
                    case "average cost":
                        SetDecimal(value, del => fc.dblAverageCost = del, "Average Cost", dr, header, row);
                        break;
                    case "end month cost":
                        SetDecimal(value, del => fc.dblEndMonthCost = del, "End Month Cost", dr, header, row);
                        break;
                    case "amount/percent":
                        SetDecimal(value, del => fc.dblAmountPercent = del, "Amount/Percent", dr, header, row);
                        break;
                    case "retail price":
                        SetDecimal(value, del => fc.dblSalePrice = del, "Retail Price", dr, header, row);
                        break;
                    case "msrp":
                        SetDecimal(value, del => fc.dblMSRPPrice = del, "MSRP", dr, header, row);
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
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICItemPricing>().Any(t => t.intItemLocationId == fc.intItemLocationId && t.intItemId == fc.intItemId))
            {
                if (!GlobalSettings.Instance.AllowOverwriteOnImport)
                {
                    dr.Info = INFO_ERROR;
                    dr.Messages.Add(new ImportDataMessage()
                    {
                        Type = TYPE_INNER_ERROR,
                        Status = REC_SKIP,
                        Column = headers[0],
                        Row = row,
                        Message = "The item pricing already exists. The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICItemPricing>(context.GetQuery<tblICItemPricing>().First(t => t.intItemLocationId == fc.intItemLocationId && t.intItemId == fc.intItemId));
                entry.Property(e => e.intItemId).CurrentValue = fc.intItemId;
                entry.Property(e => e.intItemLocationId).CurrentValue = fc.intItemLocationId;
                entry.Property(e => e.dblAverageCost).CurrentValue = fc.dblAverageCost;
                entry.Property(e => e.dblAmountPercent).CurrentValue = fc.dblAmountPercent;
                entry.Property(e => e.dblEndMonthCost).CurrentValue = fc.dblEndMonthCost;
                entry.Property(e => e.dblLastCost).CurrentValue = fc.dblLastCost;
                entry.Property(e => e.dblMSRPPrice).CurrentValue = fc.dblMSRPPrice;
                entry.Property(e => e.dblSalePrice).CurrentValue = fc.dblSalePrice;
                entry.Property(e => e.dblStandardCost).CurrentValue = fc.dblStandardCost;
                entry.Property(e => e.strPricingMethod).CurrentValue = fc.strPricingMethod;
                entry.Property(e => e.intItemPricingId).IsModified = false;
            }
            else
            {
                context.AddNew<tblICItemPricing>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICItemPricing entity)
        {
            return entity.intItemPricingId;
        }
    }
}

