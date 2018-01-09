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
using System.Data.Entity;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportInventoryCountDetails : ImportDataLogic<tblICInventoryCount>
    {
        public ImportInventoryCountDetails(DbContext context, byte[] data) : base(context, data)
        {
            
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "location", "item no", "physical count" };
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
            var entity = new tblICInventoryCount
            {
                ysnPosted = false,
                intStatus = 1,
                intImportFlagInternal = 1, // 1 - Needs to update system count, 0 or NULL - Updated
                ysnIncludeZeroOnHand = false,
                ysnIncludeOnHand = false,
                ysnScannedCountEntry = false,
                ysnCountByLots = false,
                ysnCountByPallets = false,
                ysnRecountMismatch = false,
                ysnRecount = false,
                ysnExternal = false,
                dtmCountDate = DateTime.Today
            };
            var valid = true;
            SetDate(record, "Date", e => entity.dtmCountDate = e);
            SetText(record, "Description", e => entity.strDescription = e);
            SetBoolean(record, "Count By Lots", e => entity.ysnCountByLots = e);
            SetBoolean(record, "Count By Pallets", e => entity.ysnCountByPallets = e);

            var lu = GetFieldValue(record, "Location");
            valid = valid && SetLookupId<tblSMCompanyLocation>(record, "Location", e => e.strLocationName == lu, e => e.intCompanyLocationId, e => entity.intLocationId = e, required: true);

            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new InventoryCountDetailPipe(Context, ImportResult));
        }

        class InventoryCountDetailPipe : CsvPipe<tblICInventoryCount>
        {
            public InventoryCountDetailPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
                
            }

            protected override tblICInventoryCount Process(tblICInventoryCount input)
            {
                var parent = input;
                var child = new tblICInventoryCountDetail();

                var lu = GetFieldValue("Item No");
                var valid = ImportDataLogicHelpers.SetLookupId<tblICItem>(Context, Result, Record, "Item No", e => e.strItemNo == lu, e => e.intItemId, e => child.intItemId = e, required: true);
                valid = valid && ImportDataLogicHelpers.SetLookupId<tblICItemLocation>(Context, Result, Record, "Item Location", e => e.intItemId == child.intItemId && e.intLocationId == parent.intLocationId,
                    e => e.intItemLocationId, e => child.intItemLocationId = e, required: true, defaultValue: "");
                if (child.dblPallets > 0 || child.dblQtyPerPallet > 0)
                    parent.ysnCountByPallets = true;

                lu = GetFieldValue("UOM");
                ImportDataLogicHelpers.SetLookupId<vyuICGetItemUOM>(Context, Result, Record, "UOM", e => e.strUnitMeasure == lu && e.intItemId == child.intItemId,
                    e => e.intItemUOMId, e => child.intItemUOMId = e);
                lu = GetFieldValue("Lot No");
                if (!string.IsNullOrEmpty(lu))
                {
                    ImportDataLogicHelpers.SetLookupId<tblICLot>(Context, Result, Record, "Lot No", e => e.strLotNumber == lu, e => e.intLotId, e => child.intLotId = e);
                    parent.ysnCountByLots = true;
                    if (child.intLotId != null)
                    {
                        child.strAutoCreatedLotNumber = lu;
                        AddMessage("Lot No", $"Lot {lu} will be auto-created because it does not exists.",
                            lu, Constants.TYPE_WARNING, Constants.STAT_FAILED, Constants.ACTION_AUTO_GENERATED);
                    }
                }

                child.intEntityUserSecurityId = iRely.Common.Security.GetUserId();
                child.dblSystemCount = 0;
                child.ysnRecount = false;
                child.dblLastCost = 0;
                child.dblPhysicalCount = 0;

                lu = GetFieldValue("Count Group");
                ImportDataLogicHelpers.SetLookupId<tblICCountGroup>(Context, Result, Record, "Count Group", e => e.strCountGroup == lu, e => e.intCountGroupId, e => child.intCountGroupId = e);
                ImportDataLogicHelpers.SetDecimal(Result, Record, "Physical Count", e => child.dblPhysicalCount = e);
                ImportDataLogicHelpers.SetDecimal(Result, Record, "Pallets", e => child.dblPallets = e);
                ImportDataLogicHelpers.SetDecimal(Result, Record, "Qty Per Pallet", e => child.dblQtyPerPallet = e);
                lu = GetFieldValue("Storage Location");
                ImportDataLogicHelpers.SetLookupId<tblSMCompanyLocationSubLocation>(Context, Result, Record, "Storage Location", e => e.strSubLocationName == lu, e => e.intCompanyLocationSubLocationId, e => child.intSubLocationId = e);
                lu = GetFieldValue("Storage Unit");
                ImportDataLogicHelpers.SetLookupId<tblICStorageLocation>(Context, Result, Record, "Storage Unit", e => e.strName == lu, e => e.intStorageLocationId, e => child.intStorageLocationId = e);

                child.strCountLine = Record.RecordNo.ToString();
                parent.tblICInventoryCountDetails.Add(child);

                return parent;
            }
        }

        protected override void OnNextRecord(long recordIndex, CsvRecord record, out bool succeeded)
        {
            CurrentRecordTracker.Instance.Record = record;
            CurrentRecordTracker.Instance.TotalRecords = (int)recordIndex + 1;
            succeeded = true;

            var entity = Process(record);
            var locationId = entity.intLocationId;
            var existing = Entities.FirstOrDefault(e => e.intLocationId == locationId);
            if(existing == null)
            {
                Entities.Add(entity);
            }
            else
            {
                entity = existing;
            }

            ExecutePipes(entity);

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

            AddSuccessLog(entity, record);
        }

        public override async Task OnAfterSave()
        {
            await CalculateSystemCount(ImportResult);
        }

        private async Task CalculateSystemCount(ImportDataResult dr)
        {
            try
            {
                await Context.Database.ExecuteSqlCommandAsync("dbo.uspICUpdateSystemCount");
            }
            catch (Exception ex)
            {
                dr.Failed = true;
                dr.Description = "Unable to calculate system count. " + ex.Message + ". Please delete the imported inventory count as this will result to discrepancies in system count.";
                dr.AddError(new ImportDataMessage
                {
                    Message = "Unable to calculate system count. " + ex.Message + ". Please delete the imported inventory count as this will result to discrepancies in system count.",
                    Exception = ex,
                    Row = -1,
                    Status = Constants.STAT_FAILED,
                    Type = Constants.TYPE_ERROR,
                    Value = "",
                    Action = "Aborted",
                    Column = ""
                });
            }
        }
    }
}
