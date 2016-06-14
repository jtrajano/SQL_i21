using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportFeedStocks : ImportDataLogic<tblICRinFeedStock>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "code" };
        }

        protected override tblICRinFeedStock ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICRinFeedStock fc = new tblICRinFeedStock();
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
                    case "code":
                        if (!SetText(value, del => fc.strRinFeedStockCode = del, "Code", dr, header, row, true))
                            valid = false;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICRinFeedStock>().Any(t => t.strRinFeedStockCode == fc.strRinFeedStockCode))
            {
                var entry = context.ContextManager.Entry<tblICRinFeedStock>(context.GetQuery<tblICRinFeedStock>().First(t => t.strRinFeedStockCode == fc.strRinFeedStockCode));

                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strRinFeedStockCode).IsModified = false;
            }
            else
            {
                context.AddNew<tblICRinFeedStock>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICRinFeedStock entity)
        {
            return entity.intRinFeedStockId;
        }
    }
}
