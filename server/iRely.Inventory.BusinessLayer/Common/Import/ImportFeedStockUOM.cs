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
    public class ImportFeedStockUOM : ImportDataLogic<tblICRinFeedStockUOM>
    {
        public ImportFeedStockUOM(DbContext context, byte[] data) : base(context, data)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "code", "unit of measure" };
        }

        protected override Expression<Func<tblICRinFeedStockUOM, bool>> GetUniqueKeyExpression(tblICRinFeedStockUOM entity)
        {
            return (e => e.intUnitMeasureId == entity.intUnitMeasureId);
        }

        public override tblICRinFeedStockUOM Process(CsvRecord record)
        {
            var entity = new tblICRinFeedStockUOM();
            var valid = true;
            valid = SetText(record, "Code", e => entity.strRinFeedStockUOMCode = e, true);

            var uom = GetFieldValue(record, "Unit of Measure");
            valid = SetLookupId<tblICUnitMeasure>(record, "Unit of Measure", (e => e.strUnitMeasure == uom), e => e.intUnitMeasureId, e => entity.intUnitMeasureId = e, true);

            if (valid)
                return entity;
            return entity;
        }

        protected override string GetPrimaryKeyName()
        {
            return "intRinFeedStockUOMId";
        }

        public override int GetPrimaryKeyValue(tblICRinFeedStockUOM entity)
        {
            return entity.intRinFeedStockUOMId;
        }
    }
}
