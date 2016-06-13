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
            return new string[] { "fuel category", "feed stock", "fuel code", "production process", "feed stock uom" };
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
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Fuel Category should not be blank.",
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = GetLookUpId<tblICRinFuelCategory>(context,
                            m => m.strRinFuelCategoryCode == value,
                            e => e.intRinFuelCategoryId);
                        if (lu != null)
                            fc.intRinFuelCategoryId = (int)lu;
                        else
                        {

                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Invalid Fuel Category: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "feed stock":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Feed Stock should not be blank.",
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = InsertAndOrGetLookupId<tblICRinFeedStock>(
                            context,
                            m => m.strRinFeedStockCode == value,
                            e => e.intRinFeedStockId,
                            new tblICRinFeedStock()
                            {
                                strRinFeedStockCode = value,
                                strDescription = value
                            }, out inserted);
                        if (inserted)
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_INFO,
                                Status = STAT_INNER_SUCCESS,
                                Message = "Created new Feed Stock record."
                            });
                        }
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
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Fuel Code should not be blank.",
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = InsertAndOrGetLookupId<tblICRinFuel>(
                            context,
                            m => m.strRinFuelCode == value,
                            e => e.intRinFuelId,
                            new tblICRinFuel()
                            {
                                strRinFuelCode = value,
                                strDescription = value
                            }, out inserted);
                        if (inserted)
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_INFO,
                                Status = STAT_INNER_SUCCESS,
                                Message = "Created new Fuel Code record."
                            });
                        }
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
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Production Process should not be blank.",
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = InsertAndOrGetLookupId<tblICRinProcess>(
                            context,
                            m => m.strRinProcessCode == value,
                            e => e.intRinProcessId,
                            new tblICRinProcess()
                            {
                                strRinProcessCode = value,
                                strDescription = value
                            }, out inserted);
                        if (inserted)
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_INFO,
                                Status = STAT_INNER_SUCCESS,
                                Message = "Created new Production Process record."
                            });
                        }
                        if (lu != null)
                        {
                            fc.intRinProcessId = (int)lu;
                        }
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
                    case "feed stock uom":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Feed Stock UOM should not be blank.",
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        var param = new System.Data.SqlClient.SqlParameter("@strUnitMeasure", value);
                        param.DbType = System.Data.DbType.String;
                        var query = @"SELECT u.intRinFeedStockUOMId, u.intUnitMeasureId, m.strUnitMeasure, m.strSymbol, u.strRinFeedStockUOMCode
                            FROM tblICRinFeedStockUOM u
	                            LEFT OUTER JOIN tblICUnitMeasure m ON u.intUnitMeasureId = m.intUnitMeasureId
                            WHERE m.strUnitMeasure = @strUnitMeasure";

                        IEnumerable<FuelType> storageStores = context.ContextManager.Database.SqlQuery<FuelType>(query, param);
                            try
                            {
                                FuelType store = storageStores.First();

                                if (store != null)
                                    fc.intRinFeedStockUOMId = store.intRinFeedStockUOMId;
                                else
                                {
                                    valid = false;
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Column = header,
                                        Row = row,
                                        Type = TYPE_INNER_WARN,
                                        Message = "Invalid Feed Stock UOM: " + value + '.',
                                        Status = STAT_INNER_COL_SKIP
                                    });
                                    dr.Info = INFO_WARN;
                                }
                            }
                            catch(Exception)
                            {
                                valid = false;
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid Feed Stock UOM: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
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

        private class FuelType
        {
            public int intRinFeedStockUOMId { get; set; }
            public int intUnitMeasureId { get; set; }
            public string strUnitMeasure { get; set; }
            public string strSymbol { get; set; }
            public string strRinFeedStockUOMCode { get; set; }
        }

        protected override int GetPrimaryKeyId(ref tblICFuelType entity)
        {
            return entity.intFuelTypeId;
        }
    }
}
