using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportFuelCategories : ImportDataLogic<tblICRinFuelCategory>
    {
        public ImportFuelCategories(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "fuel category" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intRinFuelCategoryId";
        }

        public override int GetPrimaryKeyValue(tblICRinFuelCategory entity)
        {
            return entity.intRinFuelCategoryId;
        }

        protected override Expression<Func<tblICRinFuelCategory, bool>> GetUniqueKeyExpression(tblICRinFuelCategory entity)
        {
            return e => e.strRinFuelCategoryCode == entity.strRinFuelCategoryCode;
        }

        public override tblICRinFuelCategory Process(CsvRecord record)
        {
            var entity = new tblICRinFuelCategory();
            var valid = true;

            valid = SetText(record, "Fuel Category", e => entity.strRinFuelCategoryCode = e, required: true);
            SetText(record, "Description", e => entity.strDescription = e, required: false);
            SetText(record, "Equivalence Value", e => entity.strEquivalenceValue = e);
            if (valid)
                return entity;

            return null;
        }
    }
}
