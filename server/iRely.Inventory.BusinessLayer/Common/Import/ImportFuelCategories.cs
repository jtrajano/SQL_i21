using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportFuelCategories : ImportDataLogic<tblICRinFuelCategory>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "fuel category" };
        }

        protected override tblICRinFuelCategory ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICRinFuelCategory fc = new tblICRinFuelCategory();
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
                    case "fuel category":
                        if (!SetText(value, del => fc.strRinFuelCategoryCode = del, "Fuel Category", dr, header, row, true))
                            valid = false;
                        if (HasLocalDuplicate(dr, header, value, row))
                            valid = false;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                    case "equivalence value":
                        fc.strEquivalenceValue = value;
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICRinFuelCategory>().Any(t => t.strRinFuelCategoryCode == fc.strRinFuelCategoryCode))
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
                        Message = "The record already exists: " + fc.strRinFuelCategoryCode + ". The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICRinFuelCategory>(context.GetQuery<tblICRinFuelCategory>().First(t => t.strRinFuelCategoryCode == fc.strRinFuelCategoryCode));
                entry.Property(e => e.strEquivalenceValue).CurrentValue = fc.strEquivalenceValue;
                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strRinFuelCategoryCode).IsModified = false;
            }
            else
            {
                context.AddNew<tblICRinFuelCategory>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICRinFuelCategory entity)
        {
            return entity.intRinFuelCategoryId;
        }
    }
}
