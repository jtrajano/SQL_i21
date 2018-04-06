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
    public class ImportStorageLocations : ImportDataLogic<tblICStorageLocation>
    {
        public ImportStorageLocations(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "name", "storage location", "location" };
        }

        protected override Expression<Func<tblICStorageLocation, bool>> GetUniqueKeyExpression(tblICStorageLocation entity)
        {
            return (e => e.strName.ToLower().Equals(entity.strName.ToLower()));
        }

        protected override string GetPrimaryKeyName()
        {
            return "intStorageLocationId";
        }

        public override int GetPrimaryKeyValue(tblICStorageLocation entity)
        {
            return entity.intStorageLocationId;
        }

        public override tblICStorageLocation Process(CsvRecord record)
        {
            var entity = new tblICStorageLocation();
            var valid = true;

            valid = SetText(record, "Name", e => entity.strName = e, required: true);
            SetText(record, "Description", e => entity.strDescription = e);
            SetText(record, "Aisle", e => entity.strUnitGroup = e);
            SetDecimal(record, "Min Batch Size", e => entity.dblMinBatchSize = e);
            SetDecimal(record, "Batch Size", e => entity.dblBatchSize = e);
            SetDecimal(record, "Pack Factor", e => entity.dblPackFactor = e);
            SetDecimal(record, "Effective Depth", e => entity.dblEffectiveDepth = e);
            SetDecimal(record, "Units Per Foot", e => entity.dblUnitPerFoot = e);
            SetDecimal(record, "Residual Units", e => entity.dblResidualUnit= e);
            SetInteger(record, "Sequence", e => entity.intSequence= e);
            SetBoolean(record, "Active", e => entity.ysnActive = e);
            SetInteger(record, "X Position", e => entity.intRelativeX = e);
            SetInteger(record, "Y Position", e => entity.intRelativeY = e);
            SetInteger(record, "Z Position", e => entity.intRelativeZ = e);
            SetBoolean(record, "Allow Consume", e => entity.ysnAllowConsume = e);
            SetBoolean(record, "Allow Multiple Items", e => entity.ysnAllowMultipleItem = e);
            SetBoolean(record, "Allow Multiple Lots", e => entity.ysnAllowMultipleLot = e);
            SetBoolean(record, "Merge On Move", e => entity.ysnMergeOnMove = e);
            SetBoolean(record, "Cycle Counted", e => entity.ysnCycleCounted = e);
            SetBoolean(record, "Default Warehouse Staging Unit", e => entity.ysnDefaultWHStagingUnit = e);

            var lu = GetFieldValue(record, "Storage Unit Type");
            SetLookupId<tblICStorageUnitType>(record, "Storage Unit Type", (e => e.strStorageUnitType == lu), e => e.intStorageUnitTypeId, e => entity.intStorageUnitTypeId = e, required: false);
            lu = GetFieldValue(record, "Location");
            SetLookupId<tblSMCompanyLocation>(record, "Location", (e => e.strLocationName == lu), e => e.intCompanyLocationId, e => entity.intLocationId = e, required: true);
            lu = GetFieldValue(record, "Storage Location");
            SetLookupId<tblSMCompanyLocationSubLocation>(record, "Storage Location", (e => e.strSubLocationName == lu), e => e.intCompanyLocationSubLocationId, e => entity.intSubLocationId = e, required: true);
            lu = GetFieldValue(record, "Restriction Type");
            SetLookupId<tblICRestriction>(record, "Restriction Type", (e => e.strDisplayMember == lu), e => e.intRestrictionId, e => entity.intRestrictionId = e, required: false);
            lu = GetFieldValue(record, "Parent Unit");
            SetLookupId<tblICStorageLocation>(record, "Parent Unit", (e => e.strName == lu), e => e.intStorageLocationId, e => entity.intParentStorageLocationId = e, required: false);
            lu = GetFieldValue(record, "Batch Size UOM");
            SetLookupId<tblICUnitMeasure>(record, "Batch Size UOM", (e => e.strUnitMeasure == lu), e => e.intUnitMeasureId, e => entity.intBatchSizeUOMId = e, required: false);
            lu = GetFieldValue(record, "Commodity");
            SetLookupId<tblICCommodity>(record, "Commodity", (e => e.strCommodityCode == lu), e => e.intCommodityId, e => entity.intCommodityId = e, required: false);

            if (valid)
                return entity;

            return null;
        }
    }
}
