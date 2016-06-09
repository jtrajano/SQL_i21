using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportBrands : ImportDataLogic<tblICBrand>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "brand code", "brand name" };
        }

        protected override tblICBrand ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICBrand fc = new tblICBrand();
            bool valid = true;

            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;
                string header = headers[i];
                string value = csv[header];

                string h = header.ToLower().Trim();
                int? lu = null;
                bool inserted = false;
                switch (h)
                {
                    case "brand code":
                        if(!SetText(value, del => fc.strBrandCode = del, "Brand Code", dr, header, row, true))
                            valid = false;
                        break;
                    case "brand name":
                        if (!SetText(value, del => fc.strBrandName = del, "Brand Name", dr, header, row, true))
                            valid = false;
                        break;
                    case "manufacturer":
                        if (string.IsNullOrEmpty(value))
                            break;
                        else
                        {
                            lu = InsertAndOrGetLookupId<tblICManufacturer>(
                                context,
                                m => m.strManufacturer == value,
                                e => e.intManufacturerId,
                                new tblICManufacturer()
                                {
                                    strManufacturer = value
                                }, out inserted);
                            if (inserted)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_INFO,
                                    Status = STAT_INNER_SUCCESS,
                                    Message = "Created new Manufacturer record."
                                });
                            }
                            if (lu != null)
                                fc.intManufacturerId = (int)lu;
                            break;
                        }
                }
            }

            if (!valid)
                return null;

            if (!context.GetQuery<tblICBrand>().Any(t => t.strBrandCode == fc.strBrandCode))
            {
                context.AddNew<tblICBrand>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICBrand entity)
        {
            return entity.intBrandId;
        }
    }
}
