using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportManufacturers : ImportDataLogic<tblICManufacturer>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "manufacturer" };
        }

        protected override tblICManufacturer ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICManufacturer fc = new tblICManufacturer();
            bool valid = true;

            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;
                string header = headers[i];
                string value = csv[header];

                string h = header.ToLower().Trim();
                switch (h)
                {
                    case "manufacturer":
                        if (!SetText(value, del => fc.strManufacturer = del, "Manufacturer", dr, header, row, true))
                            valid = false;
                        break;
                }
            }

            if (!valid)
                return null;

            if (!context.GetQuery<tblICManufacturer>().Any(t => t.strManufacturer == fc.strManufacturer))
            {
                context.AddNew<tblICManufacturer>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICManufacturer entity)
        {
            return entity.intManufacturerId;
        }
    }
}
