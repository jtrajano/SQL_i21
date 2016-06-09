using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportFuelTypes : ImportDataLogic<tblICFuelType>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "fuel category", "feed stock" };
        }

        protected override tblICFuelType ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICFuelType fc = new tblICFuelType();
            bool valid = true;

            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;
                string header = headers[i];
                string value = csv[header];

                string h = header.ToLower().Trim();
                int? lu = null;
                bool inserted = false;
                switch (h)
                {
                    case "fuel category":
                        lu = GetLookUpId<tblICRinFuelCategory>(context,
                            m => m.strRinFuelCategoryCode == value,
                            e => e.intRinFuelCategoryId);
                        if (lu != null)
                            fc.intRinFuelCategoryId = (int)lu;
                        else
                            valid = false;
                        break;
                    case "feed stock":
                        lu = InsertAndOrGetLookupId<tblICRinFeedStock>(
                            context,
                            m => m.strRinFeedStockCode == value,
                            e => e.intRinFeedStockId,
                            new tblICRinFeedStock()
                            {
                                strRinFeedStockCode = value,
                                strDescription = value
                            }, out inserted);
                        if (lu != null)
                            fc.intRinFeedStockId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Invalid Feed Stock: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "batch no":
                        SetInteger(value, del => fc.intBatchNumber = del, "Batch No", dr, header, row);
                        break;
                    case "ending rin gallons":
                        SetInteger(value, del => fc.intEndingRinGallons = del, "Ending RIN Gallons for Batch", dr, header, row);
                        break;
                    case "equivalence value":
                        fc.strEquivalenceValue = value;
                        break;
                    case "fuel code":
                        lu = InsertAndOrGetLookupId<tblICRinFuel>(
                            context,
                            m => m.strRinFuelCode == value,
                            e => e.intRinFuelId,
                            new tblICRinFuel()
                            {
                                strRinFuelCode = value,
                                strDescription = value
                            }, out inserted);
                        if (lu != null)
                            fc.intRinFuelId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Invalid Fuel Code: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "production process":
                        lu = InsertAndOrGetLookupId<tblICRinProcess>(
                            context,
                            m => m.strRinProcessCode == value,
                            e => e.intRinProcessId,
                            new tblICRinProcess()
                            {
                                strRinProcessCode = value,
                                strDescription = value
                            }, out inserted);
                        if (lu != null)
                            fc.intRinProcessId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Invalid Production Process: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "feed stock uom code":
                        lu = GetLookUpId<tblICRinFeedStockUOM>(context,
                            m => m.strRinFeedStockUOMCode == value,
                            e => e.intRinFeedStockUOMId);
                        if (lu != null)
                            fc.intRinFeedStockUOMId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Invalid Feed Stock UOM: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "feed stock factor":
                        SetDecimal(value, del => fc.dblFeedStockFactor = del, "Feed Stock Factor", dr, header, row);
                        break;
                    case "renewable biomass":
                        SetBoolean(value, del => fc.ysnRenewableBiomass = del);
                        break;
                    case "percent of denaturant":
                        SetDecimal(value, del => fc.dblPercentDenaturant = del, "Percent of Denaturant", dr, header, row);
                        break;
                    case "deduct denaturant":
                        SetBoolean(value, del => fc.ysnDeductDenaturant = del);
                        break;
                }
            }

            if (!valid)
                return null;

            context.AddNew<tblICFuelType>(fc);
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICFuelType entity)
        {
            return entity.intFuelTypeId;
        }
    }
}
