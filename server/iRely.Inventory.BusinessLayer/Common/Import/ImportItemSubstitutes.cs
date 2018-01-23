using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemSubstitutes : ImportDataLogic<tblICItemSubstitute>
    {
        public ImportItemSubstitutes(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        public override int GetPrimaryKeyValue(tblICItemSubstitute entity)
        {
            return entity.intItemSubstituteId;
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "substitute item no", "substitute uom", "substitute qty" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemSubstituteId";
        }

        public override tblICItemSubstitute Process(CsvRecord record)
        {
            var entity = new tblICItemSubstitute();
            var valid = true;

            var lu = GetFieldValue(record, "Item No");
            valid = SetIntLookupId<tblICItem>(record, "Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intItemId = e, required: true);
            lu = GetFieldValue(record, "Substitute Item No");
            valid = SetIntLookupId<tblICItem>(record, "Substitute Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intSubstituteItemId = e, required: true);
            lu = GetFieldValue(record, "Substitute UOM");
            valid = SetLookupId<vyuICGetItemUOM>(record, "Substitute UOM", e => e.strUnitMeasure == lu && e.intItemId == entity.intSubstituteItemId, e => e.intItemUOMId, e => entity.intItemUOMId = e, required: true);
            SetDecimal(record, "Substitute Qty", e => entity.dblQuantity = e);
            SetDecimal(record, "Substitute Mark Up/Down", e => entity.dblMarkUpOrDown = e);
            SetDate(record, "Substitute Begin Date", e => entity.dtmBeginDate = e);
            SetDate(record, "Substitute End Date", e => entity.dtmEndDate = e);

            if (valid)
                return entity;

            return null;
        }
    }
}
