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
    public class ImportUnitOfMeasurement : ImportDataLogic<tblICUnitMeasure>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "unit type", "unit of measure" };
        }

        private List<string> unitTypes;

        public ImportUnitOfMeasurement(DbContext context, byte[] data, string username) : base(context, data, username)
        {
            unitTypes = new List<string>();
            unitTypes.AddRange(new string[] {
                "Area", "Length", "Quantity", "Time", "Volume", "Weight", "Packed"
            });
        }

        protected override Expression<Func<tblICUnitMeasure, bool>> GetUniqueKeyExpression(tblICUnitMeasure entity)
        {
            return (e => e.strUnitMeasure == entity.strUnitMeasure);
        }

        public override tblICUnitMeasure Process(CsvRecord record)
        {
            var entity = new tblICUnitMeasure();
            var valid = true;

            valid = SetText(record, "Unit of Measure", e => entity.strUnitMeasure = e, true);
            SetText(record, "Symbol", e => entity.strSymbol = e, false);
            valid = SetFixedLookup(record, "Unit Type", e => entity.strUnitType = e, unitTypes, true);

            if (valid)
                return entity;

            return null;
        }

        protected override string GetPrimaryKeyName()
        {
            return "intUnitMeasureId";
        }

        public override int GetPrimaryKeyValue(tblICUnitMeasure entity)
        {
            return entity.intUnitMeasureId;
        }
    }
}
