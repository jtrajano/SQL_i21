using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemAccountCategories : ImportDataLogic<tblGLAccountCategory>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "category" };
        }

        protected override tblGLAccountCategory ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblGLAccountCategory fc = new tblGLAccountCategory();
            fc.intConcurrencyId = 1;
            bool valid = true;
            for (var i = 0; i < fieldCount; i++)
            {
                string header = headers[i];
                string value = csv[header];
                string h = header.ToLower().Trim();
                tblGLAccountGroup lu = null;

                switch (h)
                {
                    case "category":
                        if (!SetText(value, del => fc.strAccountCategory = del, "Category", dr, header, row, true))
                            valid = false;
                        break;
                    case "group":
                        lu = GetLookUpObject<tblGLAccountGroup>(
                            context,
                            m => m.strAccountGroup == value);
                        if (lu != null)
                        {
                            fc.strAccountGroupFilter = lu.strAccountGroup;
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = REC_SKIP,
                                Message = "The Account Group " + value + " does not exist."
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "Restricted":
                        SetBoolean(value, del => fc.ysnRestricted = del);
                        break;

                }
            }
            if (!valid)
                return null;

            if (context.GetQuery<tblGLAccountCategory>().Any(t => t.strAccountCategory == fc.strAccountCategory))
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
                        Message = "The record already exists: " + fc.strAccountCategory + ". The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblGLAccountCategory>(context.GetQuery<tblGLAccountCategory>().First(t => t.strAccountCategory == fc.strAccountCategory));

                entry.Property(e => e.strAccountGroupFilter).CurrentValue = fc.strAccountGroupFilter;
                entry.Property(e => e.ysnRestricted).CurrentValue = fc.ysnRestricted;
                entry.Property(e => e.intConcurrencyId).CurrentValue = 1;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.intAccountCategoryId).IsModified = false;
            }
            else
            {
                context.AddNew<tblGLAccountCategory>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblGLAccountCategory entity)
        {
            return entity.intAccountCategoryId;
        }
    }
}
