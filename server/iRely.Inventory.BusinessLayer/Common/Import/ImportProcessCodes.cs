using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportProcessCodes : ImportDataLogic<tblICRinProcess>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "code" };
        }

        protected override tblICRinProcess ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICRinProcess fc = new tblICRinProcess();
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
                        if (!SetText(value, del => fc.strRinProcessCode = del, "Code", dr, header, row, true))
                            valid = false;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICRinProcess>().Any(t => t.strRinProcessCode == fc.strRinProcessCode))
            {
                if (!GlobalSettings.Instance.AllowOverwriteOnImport)
                {
                    dr.Info = INFO_ERROR;
                    dr.Messages.Add(new ImportDataMessage()
                    {
                        Type = TYPE_INNER_ERROR,
                        Status = REC_SKIP,
                        Column = headers[0],
                        Row = row,
                        Message = "The record already exists: " + fc.strRinProcessCode + ". The system does not allow existing records to be modified."
                    });
                    return null;
                }
                var entry = context.ContextManager.Entry<tblICRinProcess>(context.GetQuery<tblICRinProcess>().First(t => t.strRinProcessCode == fc.strRinProcessCode));
                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strRinProcessCode).IsModified = false;
            }
            else
            {
                context.AddNew<tblICRinProcess>(fc);
            }

            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICRinProcess entity)
        {
            return entity.intRinProcessId;
        }
    }
}
