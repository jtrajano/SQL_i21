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
                                Status = REC_SKIP,
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
                    case "commodity":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICCommodity>(
                            context,
                            m => m.strCommodityCode == value,
                            e => e.intCommodityId);
                        if (lu != null)
                            fc.intCommodityId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Commodity: " + value + '.',
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
                    case "storage unit":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblSMCompanyLocationSubLocation>(
                            context,
                            m => m.strSubLocationName == value && 
                                m.strClassification == "Inventory" &&
                                m.intCompanyLocationId == fc.intLocationId,
                            e => e.intCompanyLocationSubLocationId);
                        if (lu != null)
                            fc.intSubLocationId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Storage Location: {0}.", value),
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "storage location":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICStorageLocation>(
                            context,
                            m => m.strName == value && m.intLocationId == fc.intLocationId && 
                                m.intSubLocationId == fc.intSubLocationId,
                            e => e.intStorageLocationId);
                        if (lu != null)
                            fc.intStorageLocationId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Storage Location: {0}.", value),
                                Status = STAT_INNER_COL_SKIP
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

            var db = (Inventory.Model.InventoryEntities)context.ContextManager;
            fc.strCountNo = db.GetStartingNumber((int)Common.StartingNumber.InventoryCount, fc.intLocationId);

            if (!valid)
                return null;

            if (fc.intCountGroupId != null)
            {
                tblICCountGroup cg = GetLookUpObject<tblICCountGroup>(context,
                    t => t.intCountGroupId == fc.intCountGroupId);
                if (cg != null)
                {
                    fc.ysnCountByLots = cg.ysnCountByLots;
                    fc.ysnCountByPallets = cg.ysnCountByPallets;
                    fc.ysnExternal = cg.ysnExternal;
                    fc.ysnIncludeOnHand = cg.ysnIncludeOnHand;
                    fc.ysnRecountMismatch = cg.ysnRecountMismatch;
                    fc.ysnScannedCountEntry = cg.ysnScannedCountEntry;
                }
            }

            context.AddNew<tblICInventoryCount>(fc);

            // Fetch Items
            if ((bool)fc.ysnCountByLots)
            {
                List<vyuICGetItemStockSummaryByLot> items = GetLookUps<vyuICGetItemStockSummaryByLot>(context,
                    t => t.intLocationId == fc.intLocationId &&
                        (t.intCategoryId == fc.intCategoryId || fc.intCategoryId == null) &&
                        (t.intCommodityId == fc.intCommodityId || fc.intCommodityId == null) &&
                        (t.intStorageLocationId == fc.intStorageLocationId || fc.intStorageLocationId == null) &&
                        (t.intCountGroupId == fc.intCountGroupId || fc.intCountGroupId == null) &&
                        (t.intSubLocationId == fc.intSubLocationId || fc.intSubLocationId == null));
                if (items != null)
                {
                    int count = 0;
                    foreach (var item in items)
                    {
                        tblICInventoryCountDetail detail = new tblICInventoryCountDetail()
                        {
                            intItemId = item.intItemId,
                            intItemLocationId = item.intItemLocationId,
                            intCategoryId = item.intCategoryId,
                            intStorageLocationId = item.intStorageLocationId,
                            intSubLocationId = item.intSubLocationId,
                            intInventoryCountId = fc.intInventoryCountId,
                            intItemUOMId = item.intItemUOMId,
                            dblSystemCount = item.dblOnHand,
                            dblLastCost = item.dblLastCost,
                            strCountLine = fc.strCountNo + "-" + (++count).ToString(),
                            ysnRecount = false,
                            intEntityUserSecurityId = iRely.Common.Security.GetEntityId(),
                            tblICInventoryCount = fc,
                            dblPhysicalCount = 0,
                            intLotId = item.intLotId
                        };
                        context.AddNew<tblICInventoryCountDetail>(detail);
                    }
                }
            }
            else
            {
                List<vyuICGetItemStockSummary> items = GetLookUps<vyuICGetItemStockSummary>(context,
                    t => t.intLocationId == fc.intLocationId &&
                        (t.intCategoryId == fc.intCategoryId || fc.intCategoryId == null) &&
                        (t.intCommodityId == fc.intCommodityId || fc.intCommodityId == null) &&
                        (t.intStorageLocationId == fc.intStorageLocationId || fc.intStorageLocationId == null) &&
                        (t.intCountGroupId == fc.intCountGroupId || fc.intCountGroupId == null) &&
                        (t.intSubLocationId == fc.intSubLocationId || fc.intSubLocationId == null));
                if (items != null)
                {
                    int count = 0;
                    foreach (var item in items)
                    {
                        tblICInventoryCountDetail detail = new tblICInventoryCountDetail()
                        {
                            intItemId = item.intItemId,
                            intItemLocationId = item.intItemLocationId,
                            intCategoryId = item.intCategoryId,
                            intStorageLocationId = item.intStorageLocationId,
                            intSubLocationId = item.intSubLocationId,
                            intInventoryCountId = fc.intInventoryCountId,
                            intItemUOMId = item.intItemUOMId,
                            dblSystemCount = item.dblOnHand,
                            dblLastCost = item.dblLastCost,
                            strCountLine = fc.strCountNo + "-" + (++count).ToString(),
                            ysnRecount = false,
                            intEntityUserSecurityId = iRely.Common.Security.GetEntityId(),
                            tblICInventoryCount = fc,
                            dblPhysicalCount = 0
                        };
                        context.AddNew<tblICInventoryCountDetail>(detail);
                    }
                }
            }

            return fc;
        }
    }
}
