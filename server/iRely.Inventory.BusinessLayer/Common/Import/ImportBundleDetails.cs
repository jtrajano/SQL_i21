using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportBundleDetails : ImportDataLogic<tblICItem>
    {
        public ImportBundleDetails(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "bundle type", "detail item no", "detail qty", "detail uom" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemId";
        }

        protected override Expression<Func<tblICItem, bool>> GetUniqueKeyExpression(tblICItem entity)
        {
            return (e => e.strItemNo == entity.strItemNo);
        }

        public override int GetPrimaryKeyValue(tblICItem entity)
        {
            return entity.intItemId;
        }

        public override tblICItem Process(CsvRecord record)
        {
            var entity = new tblICItem
            {
                strStatus = "Active",
                ysnListBundleSeparately = false,
                strType = "Bundle",
                strInventoryTracking = "Item Level",
                strLotTracking = "No",
                ysnLotWeightsRequired = false,
                intLifeTime = 0,
                ysnTaxable = false,
                ysnDropShip = false,
                ysnLandedCost = false,
                ysnCommisionable = false,
                ysnSpecialCommission = false
            };
            var valid = true;

            valid = SetText(record, "Item No", e => entity.strItemNo = e, required: true);
            SetText(record, "Description", e => entity.strDescription = e);
            SetText(record, "Short Name", e => entity.strShortName = e);
            var type = GetFieldValue(record, "Bundle Type", "Kit");
            SetText(type, e => entity.strBundleType = e);
            var lu = GetFieldValue(record, "Commodity");
            SetLookupId<tblICCommodity>(record, "Commodity", e => e.strCommodityCode == lu, e => e.intCommodityId, e => entity.intCommodityId = e);
            lu = GetFieldValue(record, "Category");
            SetLookupId<tblICCategory>(record, "Category", e => e.strCategoryCode == lu, e => e.intCategoryId, e => entity.intCategoryId = e);
            lu = GetFieldValue(record, "Brand");
            SetLookupId<tblICBrand>(record, "Brand", e => e.strBrandName == lu, e => e.intBrandId, e => entity.intBrandId = e);
            lu = GetFieldValue(record, "Manufacturer");
            SetLookupId<tblICManufacturer>(record, "Manufacturer", e => e.strManufacturer == lu, e => e.intManufacturerId, e => entity.intManufacturerId = e);
            SetBoolean(record, "List Separately", e => entity.ysnListBundleSeparately = e);

            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new BundleDetailPipe(Context, ImportResult));
        }

        protected override void OnNextRecord(long recordIndex, CsvRecord record, out bool succeeded)
        {
            CurrentRecordTracker.Instance.Record = record;
            CurrentRecordTracker.Instance.TotalRecords = (int)recordIndex + 1;
            succeeded = true;

            var entity = Process(record);
            var strItemNo = entity.strItemNo;
            var existing = Entities.FirstOrDefault(e => e.strItemNo == strItemNo);
            if (existing == null)
            {
                if (!GlobalSettings.Instance.AllowDuplicates)
                {
                    var existingId = -1;
                    if (HasDuplicates(entity))
                    {
                        HandleDuplicates(entity, record);
                        return;
                    }
                    else if (AlreadyExists(entity, out existingId))
                    {
                        HandleIfAlreadyExists(entity, record, existingId);
                        return;
                    }
                }
                Entities.Add(entity);
            }
            else
            {
                entity = existing;
            }

            ExecutePipes(entity);

            AddSuccessLog(entity, record);
        }

        class BundleDetailPipe : CsvPipe<tblICItem>
        {
            public BundleDetailPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var parent = input;
                var child = new tblICItemBundle
                {
                    ysnAddOn = false,
                    dblQuantity = 1
                };
                var valid = true;
                var lu = GetFieldValue("Detail Item No");
                valid = ImportDataLogicHelpers.SetIntLookupId<tblICItem>(Context, Result, Record, "Detail Item No", e => e.strItemNo == lu, e => e.intItemId, e => child.intBundleItemId = e, required: true);
                ImportDataLogicHelpers.SetDecimal(Result, Record, "Detail Qty", e => child.dblQuantity = e);
                lu = GetFieldValue("Detail UOM");
                valid = ImportDataLogicHelpers.SetLookupId<vyuICGetItemUOM>(Context, Result, Record, "Detail UOM", e => e.strUnitMeasure == lu && e.intItemId == child.intBundleItemId,
                    e => e.intItemUOMId, e => child.intItemUnitMeasureId = e);
                ImportDataLogicHelpers.SetDecimal(Result, Record, "Detail Mark Up/Down", e => child.dblMarkUpOrDown = e);
                ImportDataLogicHelpers.SetDate(Result, Record, "Detail Begin Date", e => child.dtmBeginDate = e);
                ImportDataLogicHelpers.SetDate(Result, Record, "Detail End Date", e => child.dtmEndDate = e);

                if (valid)
                    parent.tblICItemBundles.Add(child);

                return parent;
            }
        }
    }
}
