using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Inventory.Model;
using System.IO;
using LumenWorks.Framework.IO.Csv;
using System.Globalization;
using System.Collections;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportInventoryCountDetails : ImportDataLogic<tblICInventoryCountDetail>
    {
        private Hashtable counts = new Hashtable();

        public ImportInventoryCountDetails()
        {
          
        }

        public ImportInventoryCountDetails(InventoryRepository context, byte[] data)
            : base(context, data)
        {

        }
        protected override string[] GetRequiredFields()
        {
            return new string[] { "location", "item no", "physical count" };
        }

        protected override int GetPrimaryKeyId(ref tblICInventoryCountDetail entity)
        {
            return entity.intInventoryCountDetailId;
        }

        protected override tblICInventoryCountDetail ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            bool valid = true;

            tblICInventoryCountDetail fc = new tblICInventoryCountDetail();
            fc.intEntityUserSecurityId = iRely.Common.Security.GetUserId();
            fc.dblSystemCount = 0;
            fc.ysnRecount = false;
            fc.dblLastCost = 0;
            fc.dblPhysicalCount = 0;

            int? intLocationId;
            int? intItemId;

            tblICInventoryCount fh = null;

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
                    case "location":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Status = REC_SKIP,
                                Message = "Location should not be blank."
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = GetLookUpId<tblSMCompanyLocation>(
                            context,
                            m => m.strLocationName == value,
                            e => e.intCompanyLocationId);
                        if (lu != null)
                        {
                            intLocationId = (int)lu;

                            if (!counts.ContainsKey(intLocationId)) {
                                fh = new tblICInventoryCount();
                                fh.ysnPosted = false;
                                fh.intStatus = 1;
                                fh.intImportFlagInternal = 1; // 1 - Needs to update system count, 0 or NULL - Updated
                                fh.ysnIncludeZeroOnHand = false;
                                fh.ysnIncludeOnHand = false;
                                fh.ysnScannedCountEntry = false;
                                fh.ysnCountByLots = false;
                                fh.ysnCountByPallets = false;
                                fh.ysnRecountMismatch = false;
                                fh.ysnRecount = false;
                                fh.ysnExternal = false;
                                //fh.strCountNo = Common.GetStartingNumber(Common.StartingNumber.InventoryCount);
                                fh.dtmCountDate = DateTime.Today;
                                fh.intLocationId = intLocationId;
                                context.AddNew<tblICInventoryCount>(fh);
                                counts.Add(intLocationId, fh);
                            }
                            else
                            {
                                fh = counts[intLocationId] as tblICInventoryCount;
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
                                Status = REC_SKIP,
                                Message = string.Format("Invalid Location: {0}.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "count group":
                        if (string.IsNullOrEmpty(value))
                        {
                            break;
                        }
                        if (fh != null)
                        {
                            lu = GetLookUpId<tblICCountGroup>(
                                    context,
                                    m => m.strCountGroup == value,
                                    e => e.intCountGroupId);
                            if (lu != null)
                                fh.intCountGroupId = (int?)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_ERROR,
                                    Status = STAT_INNER_COL_SKIP,
                                    Message = string.Format("Invalid Count Group: {0}.", value)
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
                        break;
                    case "description":
                        if (string.IsNullOrEmpty(value))
                            break;
                        if (fh != null)
                            fh.strDescription = value;
                        break;
                    case "date":
                        if (string.IsNullOrEmpty(value))
                            break;
                        if (fh != null)
                            SetDate(value, del => fh.dtmCountDate = del, "Count Date", dr, header, row);
                        break;
                    case "count by lots":
                        if (string.IsNullOrEmpty(value))
                            break;
                        if (fh != null)
                        {
                            SetBoolean(value, del => fh.ysnCountByLots = del);
                        }
                        break;
                    case "count by pallets":
                        if (string.IsNullOrEmpty(value))
                            break;
                        if (fh != null)
                            fh.ysnCountByPallets = true;
                        break;
                    case "item no":
                        var val = value.ToString();
                        if (string.IsNullOrEmpty(val))
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
                            m => m.strItemNo == val,
                            e => e.intItemId);
                        if (lu != null)
                        {
                            intItemId = (int)lu;
                            fc.intItemId = (int)lu;
                            if (fh != null)
                            {
                                //fc.intInventoryCountId = fh.intInventoryCountId;
                                fc.tblICInventoryCount = fh;
                                var il = GetLookUpId<tblICItemLocation>(
                                    context,
                                    m => m.intItemId == fc.intItemId && m.intLocationId == fh.intLocationId,
                                    e => e.intItemLocationId);
                                if (il != null)
                                {
                                    fc.intItemLocationId = (int)il;
                                }
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
                                Status = REC_SKIP,
                                Message = "Invalid Item No: " + val + ". The item does not exist"
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    #region
                    case "physical count":
                        SetDecimal(value, del => fc.dblPhysicalCount = del, "Physical Count", dr, header, row);
                        break;
                    case "pallets":
                        SetDecimal(value, del => fc.dblPallets = del, "Pallets", dr, header, row);
                        if (fh != null && fc.dblPallets > 0)
                            fh.ysnCountByPallets = true;
                        break;
                    case "qty per pallet":
                        SetDecimal(value, del => fc.dblQtyPerPallet = del, "Qty Per Pallet", dr, header, row);
                        if (fh != null && fc.dblQtyPerPallet > 0)
                            fh.ysnCountByPallets = true;
                        break;
                    case "uom":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = STAT_INNER_COL_SKIP,
                                Message = "UOM should not be blank."
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        if (fc != null && fc.intItemId != null)
                        {
                            lu = GetLookUpId<vyuICGetItemUOM>(
                                context,
                                m => m.strUnitMeasure == value && m.intItemId == fc.intItemId,
                                e => e.intItemUOMId);
                            if (lu != null && lu != 0)
                                fc.intItemUOMId = (int)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_ERROR,
                                    Status = STAT_INNER_COL_SKIP,
                                    Message = string.Format("Invalid UOM: {0}.", value)
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
                        break;
                    case "lot no":
                        if (string.IsNullOrEmpty(value))
                        {
                            break;
                        }
                        lu = GetLookUpId<tblICLot>(
                            context,
                            m => m.strLotNumber == value.Trim(),
                            e => e.intLotId);
                        if (lu != null)
                        {
                            fc.intLotId = (int?)lu;
                            fh.ysnCountByLots = true;
                        }
                        else
                        {
                            fh.ysnCountByLots = true;
                            fc.strAutoCreatedLotNumber = value.Trim();
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Status = STAT_INNER_AUTO,
                                Message = string.Format("Lot '{0}' will be auto-created because it does not exists.", value)
                            });
                            dr.Info = INFO_WARN;
                            //dr.Messages.Add(new ImportDataMessage()
                            //{
                            //    Column = header,
                            //    Row = row,
                            //    Type = TYPE_INNER_ERROR,
                            //    Status = STAT_INNER_COL_SKIP,
                            //    Message = string.Format("Invalid Lot Number: {0}.", value)
                            //});
                            //dr.Info = INFO_WARN;
                        }
                        break;
                    case "storage location":
                        if (string.IsNullOrEmpty(value))
                        {
                            break;
                        }
                        lu = GetLookUpId<tblSMCompanyLocationSubLocation>(
                            context,
                            m => m.strSubLocationName == value,
                            e => e.intCompanyLocationSubLocationId);
                        if (lu != null)
                            fc.intSubLocationId = (int?)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = STAT_INNER_COL_SKIP,
                                Message = string.Format("Invalid Storage Location: {0}.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "storage unit":
                        if (string.IsNullOrEmpty(value))
                        {
                            break;
                        }
                        lu = GetLookUpId<tblICStorageLocation>(
                            context,
                            m => m.strName == value,
                            e => e.intStorageLocationId);
                        if (lu != null)
                            fc.intStorageLocationId = (int?)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = STAT_INNER_COL_SKIP,
                                Message = string.Format("Invalid Storage Location: {0}.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    #endregion
                }
            }

            if (!valid)
                return null;

            if (fc != null && fh != null)
            {
                var strCountLine = row.ToString(); //fh.strCountNo + '-' + row.ToString();
                fc.strCountLine = strCountLine;
                fh.tblICInventoryCountDetails.Add(fc);
            }
            //context.AddNew<tblICInventoryCountDetail>(fc);

            return fc;
        }

        public override ImportDataResult Import()
        {
            MemoryStream ms = new MemoryStream(data);
            ImportDataResult dr = new ImportDataResult()
            {
                Info = INFO_SUCCESS
            };

            var hasErrors = false;
            var hasWarnings = false;

            if (!ms.CanRead)
                throw new IOException("Please select a valid file.");
            int row = 0;

            using (CsvReader csv = new CsvReader(new StreamReader(ms), true))
            {
                int fieldCount = csv.FieldCount;
                string[] headers = csv.GetFieldHeaders();
                List<string> missingFields;

                if (!ValidHeaders(headers, out missingFields))
                {
                    dr.Info = INFO_ERROR;
                    dr.Description = "Invalid template format. Some fields were missing.";
                    StringBuilder sb = new StringBuilder();
                    foreach (string s in missingFields)
                    {
                        sb.Append("'" + s + "'" + ", ");
                    }
                    dr.Messages.Add(new ImportDataMessage()
                    {
                        Type = TYPE_INNER_ERROR,
                        Status = "Import Failed",
                        Message = "Invalid template format. Some fields were missing. Missing fields: " +
                            CultureInfo.CurrentCulture.TextInfo.ToTitleCase(sb.ToString().Substring(0, sb.Length - 2))
                    });
                    //throw new FormatException("Invalid template format.");
                    return dr;
                }

                uniqueIds.Clear();

                while (csv.ReadNextRecord())
                {
                    row++;

                    using (var transaction = context.ContextManager.Database.BeginTransaction())
                    {
                        try
                        {
                            LogItems.Clear();
                            dr.IsUpdate = false;

                            try
                            {
                                tblICInventoryCountDetail entity = ProcessRow(row, fieldCount, headers, csv, dr);
                                if (entity != null)
                                {
                                    context.Save();
                                    LogTransaction(ref entity, dr);
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Message = "Record " + (dr.IsUpdate ? "updated" : "imported") + " successfully.",
                                        Row = row,
                                        Status = STAT_INNER_SUCCESS,
                                        Type = TYPE_INNER_INFO
                                    });
                                    if (dr.Info == INFO_ERROR)
                                        hasErrors = true;
                                    if (dr.Info == INFO_WARN)
                                        hasWarnings = true;
                                    transaction.Commit();
                                }
                                else
                                {
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Message = "Invalid values found. Items that were auto created or modified in this record will be rolled back.",
                                        Exception = null,
                                        Row = row,
                                        Status = "Record import failed.",
                                        Type = TYPE_INNER_ERROR
                                    });
                                    dr.Info = INFO_ERROR;
                                    hasErrors = true;
                                    transaction.Rollback();
                                    continue;
                                }
                            }
                            catch(Exception ex)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Message = ex.Message + ". Items that were auto created or modified in this record will be rolled back.",
                                    Exception = null,
                                    Row = row,
                                    Status = "Record import failed.",
                                    Type = TYPE_INNER_ERROR
                                });
                            }
                        }
                        catch (Exception ex)
                        {
                            string message = ex.Message;
                            if (ex.InnerException != null && ex.InnerException.InnerException != null)
                                message = ex.InnerException.InnerException.Message;
                            else
                                message = ex.InnerException.Message;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Message = message + " Items that were auto created or modified in this record will be rolled back.",
                                Exception = ex,
                                Row = row,
                                Status = REC_SKIP,
                                Type = TYPE_INNER_EXCEPTION
                            });
                            dr.Info = INFO_ERROR;
                            hasErrors = true;
                            transaction.Rollback();
                            continue;
                        }
                    }
                }
            }

            dr.Rows = row;

            if (hasWarnings)
                dr.Info = INFO_WARN;

            if (hasErrors)
                dr.Info = INFO_ERROR;

            CalculateSystemCount(dr);

            return dr;
        }

        private void CalculateSystemCount(ImportDataResult dr)
        {
            try
            {
                context.ContextManager.Database.ExecuteSqlCommand("dbo.uspICUpdateSystemCount");
            }
            catch (Exception ex)
            {
                dr.Messages.Add(new ImportDataMessage()
                {
                    Message = "Unable to calculate system count. " + ex.Message + ". Please delete the imported inventory count as this will result to discrepancies in system count.",
                    Exception = ex,
                    Row = -1,
                    Status = TYPE_INNER_ERROR,
                    Type = TYPE_INNER_ERROR
                });
            }
        }
    }
}
