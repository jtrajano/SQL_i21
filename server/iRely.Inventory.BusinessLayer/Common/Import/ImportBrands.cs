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
    public class ImportBrands : ImportDataLogic<tblICBrand>
    {
        public ImportBrands(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "brand code", "brand name" };
        }

        protected override Expression<Func<tblICBrand, bool>> GetUniqueKeyExpression(tblICBrand entity)
        {
            return (e => e.strBrandCode == entity.strBrandCode);
        }

        public override tblICBrand Process(CsvRecord record)
        {
            var entity = new tblICBrand();
            var valid = true;

            valid = SetText(record, "Brand Code", e => entity.strBrandCode = e, true);
            valid = SetText(record, "Brand Name", e => entity.strBrandName = e, false);

            var manufacturer = GetFieldValue(record, "Manufacturer");
            SetLookupId<tblICManufacturer>(record, "Manufacturer", (e => e.strManufacturer == manufacturer), e => e.intManufacturerId, e => entity.intManufacturerId = e, false);

            if (valid)
                return entity;

            return null;
        }

        protected override string GetPrimaryKeyName()
        {
            return "intBrandId";
        }

        public override int GetPrimaryKeyValue(tblICBrand entity)
        {
            return entity.intBrandId;
        }
    }
}
