using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportFuelCodes : ImportDataLogic<tblICRinFuel>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "code" };
        }

        protected override tblICRinFuel ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICRinFuel fc = new tblICRinFuel();
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
                        if (!SetText(value, del => fc.strRinFuelCode = del, "Code", dr, header, row, true))
                            valid = false;
                        if (HasLocalDuplicate(dr, header, value, row))
                            valid = false;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICRinFuel>().Any(t => t.strRinFuelCode == fc.strRinFuelCode))
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
                        Message = "The record already exists: " + fc.strRinFuelCode + ". The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICRinFuel>(context.GetQuery<tblICRinFuel>().First(t => t.strRinFuelCode == fc.strRinFuelCode));

                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strRinFuelCode).IsModified = false;
            }
            else
            {
                context.AddNew<tblICRinFuel>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICRinFuel entity)
        {
            return entity.intRinFuelId;
        }
    }
}
