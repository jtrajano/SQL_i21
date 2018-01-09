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
    public class ImportManufacturers : ImportDataLogic<tblICManufacturer>
    {
        public ImportManufacturers(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "manufacturer" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intManufacturerId";
        }

        protected override Expression<Func<tblICManufacturer, bool>> GetUniqueKeyExpression(tblICManufacturer entity)
        {
            return e => e.strManufacturer == entity.strManufacturer;
        }

        public override int GetPrimaryKeyValue(tblICManufacturer entity)
        {
            return entity.intManufacturerId;
        }

        public override tblICManufacturer Process(CsvRecord record)
        {
            var entity = new tblICManufacturer();
            var valid = true;

            valid = SetText(record, "Manufacturer", e => entity.strManufacturer = e, required: true);

            if (valid)
                return entity;

            return null;
        }
    }
}
