using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportInventoryCount : ImportDataLogic<tblICInventoryCount>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "location" };
        }

        protected override int GetPrimaryKeyId(ref tblICInventoryCount entity)
        {
            return entity.intInventoryCountId;
        }

        protected override tblICInventoryCount ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICInventoryCount fc = new tblICInventoryCount();
            fc.ysnPosted = false;
            fc.intStatus = 1;
            fc.strCountNo = Common.GetStartingNumber(Common.StartingNumber.InventoryCount);
            fc.dtmCountDate = DateTime.Today;

            bool valid = true;

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
                        lu = GetLookUpId<tblSMCompanyLocation>(
                            context,
                            m => m.strLocationName == value,
                            e => e.intCompanyLocationId);
                        if (lu != null)
                            fc.intLocationId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Location: {0}.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "category":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICCategory>(
                            context,
                            m => m.strCategoryCode == value,
                            e => e.intCategoryId);
                        if (lu != null)
                            fc.intCategoryId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Category item: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "count group":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICCountGroup>(
                            context,
                            m => m.strCountGroup == value,
                            e => e.intCountGroupId);
                        if (lu != null)
                            fc.intCountGroupId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Count Group item: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "count date":
                        if (string.IsNullOrEmpty(value))
                            break;
                        SetDate(value, del => fc.dtmCountDate = del, "Count Date", dr, header, row);
                        break;
                    case "sub location":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblSMCompanyLocationSubLocation>(
                            context,
                            m => m.strSubLocationName == value,
                            e => e.intCompanyLocationSubLocationId);
                        if (lu != null)
                            fc.intSubLocationId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Sub Location: {0}.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "storage location":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICStorageLocation>(
                            context,
                            m => m.strName == value,
                            e => e.intStorageLocationId);
                        if (lu != null)
                            fc.intStorageLocationId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Storage Location: {0}.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                    case "include zero on hand":
                        SetBoolean(value, del => fc.ysnIncludeZeroOnHand = del);
                        break;
                    case "include on hand":
                        SetBoolean(value, del => fc.ysnIncludeOnHand = del);
                        break;
                    case "scanned count entry":
                        SetBoolean(value, del => fc.ysnScannedCountEntry = del);
                        break;
                    case "count by lots":
                        SetBoolean(value, del => fc.ysnCountByLots = del);
                        break;
                    case "count by pallets":
                        SetBoolean(value, del => fc.ysnCountByPallets = del);
                        break;
                    case "recount mismatch":
                        SetBoolean(value, del => fc.ysnRecountMismatch = del);
                        break;
                    case "external":
                        SetBoolean(value, del => fc.ysnExternal = del);
                        break;
                    case "recount":
                        SetBoolean(value, del => fc.ysnRecount = del);
                        break;
                    case "reference count":
                        SetInteger(value, del => fc.intRecountReferenceId = del, "Reference Count", dr, header, row);
                        break;
                }
            }

            if (!valid)
                return null;

            context.AddNew<tblICInventoryCount>(fc);

            return fc;
        }
    }
}
