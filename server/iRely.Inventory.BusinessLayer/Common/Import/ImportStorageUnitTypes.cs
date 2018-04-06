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
    public class ImportStorageUnitTypes : ImportDataLogic<tblICStorageUnitType>
    {
        public ImportStorageUnitTypes(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override Expression<Func<tblICStorageUnitType, bool>> GetUniqueKeyExpression(tblICStorageUnitType entity)
        {
            return (e => e.strStorageUnitType.ToLower().Equals(entity.strStorageUnitType));
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "name" };
        }

        public override tblICStorageUnitType Process(CsvRecord record)
        {
            var entity = new tblICStorageUnitType();
            var valid = true;

            valid = SetText(record, "Name", e => entity.strStorageUnitType = e, required: true);
            SetText(record, "Description", e => entity.strDescription = e, required: false);
            SetText(record, "Internal Code", e => entity.strDescription = e, required: false);
            SetDecimal(record, "Max Weight", e => entity.dblMaxWeight = e);
            SetBoolean(record, "Allows Picking", e => entity.ysnAllowPick = e);
            SetDecimal(record, "Height", e => entity.dblHeight = e);
            SetDecimal(record, "Depth", e => entity.dblDepth = e);
            SetDecimal(record, "Width", e => entity.dblWidth = e);
            SetInteger(record, "Pallet Stack", e => entity.intPalletStack = e);
            SetInteger(record, "Pallet Columns", e => entity.intPalletColumn = e);
            SetInteger(record, "Pallet Rows", e => entity.intPalletRow = e);
            
            var uom = GetFieldValue(record, "Capacity UOM");
            SetLookupId<tblICUnitMeasure>(record, "Capacity UOM", (e => e.strUnitMeasure == uom), e => e.intUnitMeasureId, e => entity.intCapacityUnitMeasureId = e, required: false);
            uom = GetFieldValue(record, "Dimension UOM");
            SetLookupId<tblICUnitMeasure>(record, "Dimension UOM", (e => e.strUnitMeasure == uom), e => e.intUnitMeasureId, e => entity.intDimensionUnitMeasureId = e, required: false);

            if (valid)
                return entity;

            return null;
        }

        protected override string GetPrimaryKeyName()
        {
            return "intStorageUnitTypeId";
        }

        public override int GetPrimaryKeyValue(tblICStorageUnitType entity)
        {
            return entity.intStorageUnitTypeId;
        }
    }
}
