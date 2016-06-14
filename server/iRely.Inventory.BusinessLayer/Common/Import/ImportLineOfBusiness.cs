using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportLineOfBusiness : ImportDataLogic<tblICLineOfBusiness>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "line of business" };
        }

        protected override tblICLineOfBusiness ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICLineOfBusiness fc = new tblICLineOfBusiness();
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
                    case "line of business":
                        if(!SetText(value, del => fc.strLineOfBusiness = del, "Line of Business", dr, header, row, true))
                            valid = false;
                        break;
                }
            }

            if(!valid)
                return null;

            if (!context.GetQuery<tblICLineOfBusiness>().Any(t => t.strLineOfBusiness == fc.strLineOfBusiness))
            {
                context.AddNew<tblICLineOfBusiness>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICLineOfBusiness entity)
        {
            return entity.intLineOfBusinessId;
        }
    }
}
