using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportInventoryCount : ImportDataLogic<tblICInventoryCount>
    {
        public ImportInventoryCount(DbContext context, byte[] data) : base(context, data)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "location" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intInventoryCountId";
        }

        public override int GetPrimaryKeyValue(tblICInventoryCount entity)
        {
            return entity.intInventoryCountId;
        }

        public override tblICInventoryCount Process(CsvRecord record)
        {
            var entity = new tblICInventoryCount()
            {
                ysnPosted = false,
                intStatus = 1,
                dtmCountDate = DateTime.Today
            };

            var valid = true;

            var lu = GetFieldValue(record, "Location");
            valid = SetLookupId<tblSMCompanyLocation>(record, "Location", e => e.strLocationName == lu, e => e.intCompanyLocationId, e => entity.intLocationId = e, required: true);
            lu = GetFieldValue(record, "Category");
            SetLookupId<tblICCategory>(record, "Category", e => e.strCategoryCode == lu, e => e.intCategoryId, e => entity.intCategoryId = e);
            lu = GetFieldValue(record, "Commodity");
            SetLookupId<tblICCommodity>(record, "Commodity", e => e.strCommodityCode == lu, e => e.intCommodityId, e => entity.intCommodityId = e);
            lu = GetFieldValue(record, "Count Group");
            SetLookupId<tblICCountGroup>(record, "Count Group", e => e.strCountGroup == lu, e => e.intCountGroupId, e => entity.intCountGroupId = e);
            SetDate(record, "Count Date", e => entity.dtmCountDate = e);
            lu = GetFieldValue(record, "Storage Location");
            SetLookupId<tblSMCompanyLocationSubLocation>(record, "Storage Location", e => e.strSubLocationName == lu && e.strClassification == "Inventory" && e.intCompanyLocationId == entity.intLocationId, e => e.intCompanyLocationSubLocationId, e => entity.intSubLocationId = e);
            lu = GetFieldValue(record, "Storage Unit");
            SetLookupId<tblICStorageLocation>(record, "Storage Unit", e => e.strName == lu && e.intLocationId == entity.intLocationId && e.intSubLocationId == entity.intSubLocationId, e => e.intStorageLocationId, e => entity.intStorageLocationId = e);
            SetText(record, "Description", e => entity.strDescription = e);
            SetBoolean(record, "Physical Count)
            if (valid)
                return entity;

            return null;
        }

        protected override tblICInventoryCount ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            
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
