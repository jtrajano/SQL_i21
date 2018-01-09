using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LumenWorks.Framework.IO.Csv;
using System.Linq.Expressions;
using System.Data.Entity;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportCommodityUOM : ImportDataLogic<tblICCommodityUnitMeasure>
    {
        public ImportCommodityUOM(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string GetPrimaryKeyName()
        {
            return "intCommodityUnitMeasureId";
        }

        public override int GetPrimaryKeyValue(tblICCommodityUnitMeasure entity)
        {
            return entity.intCommodityUnitMeasureId;
        }

        protected override Expression<Func<tblICCommodityUnitMeasure, bool>> GetUniqueKeyExpression(tblICCommodityUnitMeasure entity)
        {
            return (e => e.intUnitMeasureId == entity.intUnitMeasureId && e.intCommodityId == entity.intCommodityId);
        }

        public override tblICCommodityUnitMeasure Process(CsvRecord record)
        {
            var entity = new tblICCommodityUnitMeasure();
            var valid = true;

            var lu = GetFieldValue(record, "Commodity Code");
            valid = SetIntLookupId<tblICCommodity>(record, "Commodity Code", (e => e.strCommodityCode == lu), e => e.intCommodityId, e => entity.intCommodityId = e, required: true);
            lu = GetFieldValue(record, "UOM");
            valid = SetLookupId<tblICUnitMeasure>(record, "UOM", (e => e.strUnitMeasure == lu || e.strSymbol == lu), e => e.intUnitMeasureId, e => entity.intUnitMeasureId = e, required: true);
            SetDecimal(record, "Unit Qty", e => entity.dblUnitQty = e);
            SetBoolean(record, "Is Stock Unit", e => entity.ysnStockUnit = e);
            SetBoolean(record, "Is Default UOM", e => entity.ysnDefault = e);

            if (valid)
                return entity;

            return null;
        }
        
        protected override string[] GetRequiredFields()
        {
            return new string[] { "commodity code", "uom", "unit qty" };
        }
    }
}