using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemAddons : ImportDataLogic<tblICItemAddOn>
    {
        public ImportItemAddons(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        public override int GetPrimaryKeyValue(tblICItemAddOn entity)
        {
            return entity.intItemAddOnId;
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "add-on item no", "add-on uom", "add-on qty" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemAddOnId";
        }

        public override tblICItemAddOn Process(CsvRecord record)
        {
            var entity = new tblICItemAddOn();
            var valid = true;

            var lu = GetFieldValue(record, "Item No");
            valid = SetIntLookupId<tblICItem>(record, "Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intItemId = e, required: true);
            lu = GetFieldValue(record, "Add-on Item No");
            valid = SetIntLookupId<tblICItem>(record, "Add-on Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intAddOnItemId = e, required: true);
            lu = GetFieldValue(record, "Add-on UOM");
            valid = SetLookupId<vyuICGetItemUOM>(record, "Add-on UOM", e => e.strUnitMeasure == lu && e.intItemId == entity.intAddOnItemId, e => e.intItemUOMId, e => entity.intItemUOMId = e, required: true);
            SetDecimal(record, "Add-on Qty", e => entity.dblQuantity = e);

            if (valid)
                return entity;

            return null;
        }
    }
}
