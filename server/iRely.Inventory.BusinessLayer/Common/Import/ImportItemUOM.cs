using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemUOM : ImportDataLogic<tblICItemUOM>
    {
        public ImportItemUOM(DbContext context, byte[] data) : base(context, data)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "uom", "item no" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemUOMId";
        }

        public override int GetPrimaryKeyValue(tblICItemUOM entity)
        {
            return entity.intItemUOMId;
        }

        protected override Expression<Func<tblICItemUOM, bool>> GetUniqueKeyExpression(tblICItemUOM entity)
        {
            return (e => e.intItemId == entity.intItemId && e.intUnitMeasureId == entity.intUnitMeasureId);
        }

        public override tblICItemUOM Process(CsvRecord record)
        {
            var entity = new tblICItemUOM();
            var valid = true;

            SetText(record, "Unit Type", e => entity.strUnitType = e);
            SetText(record, "UPC Code", e => entity.strLongUPCCode = e);
            SetText(record, "short UPC Code", e => entity.strUpcCode = e);
            SetBoolean(record, "Is Stock Unit", e => entity.ysnStockUnit = e);
            SetBoolean(record, "Allow Purchase", e => entity.ysnAllowPurchase = e);
            SetBoolean(record, "Allow Sale", e => entity.ysnAllowSale = e);
            SetDecimal(record, "Length", e => entity.dblLength = e);
            SetDecimal(record, "Width", e => entity.dblWidth = e);
            SetDecimal(record, "Height", e => entity.dblHeight = e);
            SetDecimal(record, "Volume", e => entity.dblVolume = e);
            SetDecimal(record, "Max Qty", e => entity.dblMaxQty = e);
            valid = SetNonZeroDecimal(record, "Unit Qty", e => entity.dblUnitQty = e);

            var lu = GetFieldValue(record, "Item No");
            valid = SetIntLookupId<tblICItem>(record, "Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intItemId = e, required: true);
            lu = GetFieldValue(record, "UOM");
            valid = SetLookupId<tblICUnitMeasure>(record, "UOM", e => e.strUnitMeasure == lu, e => e.intUnitMeasureId, e => entity.intUnitMeasureId = e, required: true);
            lu = GetFieldValue(record, "Weight UOM");
            SetLookupId<tblICUnitMeasure>(record, "Weight UOM", e => e.strUnitMeasure == lu, e => e.intUnitMeasureId, e => entity.intWeightUOMId = e, required: false);
            lu = GetFieldValue(record, "Dimension UOM");
            SetLookupId<tblICUnitMeasure>(record, "Dimension UOM", e => e.strUnitMeasure == lu, e => e.intUnitMeasureId, e => entity.intDimensionUOMId = e, required: false);
            lu = GetFieldValue(record, "Volume UOM");
            SetLookupId<tblICUnitMeasure>(record, "Volume UOM", e => e.strUnitMeasure == lu, e => e.intUnitMeasureId, e => entity.intVolumeUOMId = e, required: false);

            if (valid)
                return entity;

            return null;
        }
    }
}
