using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemAccounts : ImportDataLogic<tblICItemAccount>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "gl account category", "gl account id" };
        }

        protected override tblICItemAccount ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICItemAccount fc = new tblICItemAccount();

            bool valid = true;

            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;

                string header = headers[i];
                string value = csv[header];
                string h = header.ToLower().Trim();
                int? lu = null;

                switch (h)
                {
                    case "item no":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = REC_SKIP,
                                Message = "Item No should not be blank."
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = GetLookUpId<tblICItem>(
                            context,
                            m => m.strItemNo == value,
                            e => e.intItemId);
                        if (lu != null)
                        {
                            fc.intItemId = (int) lu;
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
                                Message = "Invalid Item No: " + value + ". The item does not exist"
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "account category":
                    case "gl account category":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = REC_SKIP,
                                Message = "GL Account Category should not be blank."
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = GetLookUpId<tblGLAccountCategory>(
                            context,
                            m => m.strAccountCategory == value,
                            e => e.intAccountCategoryId);
                        if (lu != null)
                        {
                            fc.intAccountCategoryId = (int) lu;
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
                                Message = "The GL Account Category " + value + " does not exist."
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "account id":
                    case "gl account id":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = REC_SKIP,
                                Message = "GL Account Id should not be blank."
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = GetLookUpId<tblGLAccount>(
                            context,
                            m => m.strAccountId == value,
                            e => e.intAccountId);
                        if (lu != null)
                        {
                            fc.intAccountId = (int) lu;
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
                                Message = "The GL Account Id " + value + " does not exist."
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICItemAccount>().Any(t => t.intItemId == fc.intItemId 
                && (t.intItemAccountId == fc.intItemAccountId || t.intAccountCategoryId == fc.intAccountCategoryId)))
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
                        Message = "The account already exists. The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICItemAccount>(context.GetQuery<tblICItemAccount>().First(
                    t => t.intItemId == fc.intItemId
                && (t.intItemAccountId == fc.intItemAccountId || t.intAccountCategoryId == fc.intAccountCategoryId)));
                entry.Property(e => e.intAccountId).CurrentValue = fc.intAccountId;
                entry.Property(e => e.intAccountCategoryId).CurrentValue = fc.intAccountCategoryId;
                entry.State = System.Data.Entity.EntityState.Modified;
                if (entry.Property(e => e.intAccountId).OriginalValue == fc.intAccountId)
                    entry.Property(e => e.intAccountId).IsModified = false;
                if (entry.Property(e => e.intAccountCategoryId).OriginalValue == fc.intAccountCategoryId)
                    entry.Property(e => e.intAccountCategoryId).IsModified = false;

                if (entry.Property(e => e.intAccountId).IsModified || entry.Property(e => e.intAccountCategoryId).IsModified)
                {
                    LogItems.Add(new ImportLogItem()
                    {
                        ActionIcon = ICON_ACTION_EDIT,
                        Description = "Updated GL Account",
                        ToValue = string.Format("GL Account Category: {0}, GL Account Id: {1}",
                            entry.Property(e => e.strAccountCategory).CurrentValue,
                            entry.Property(e => e.strAccountId).CurrentValue)
                    });
                }
            }
            else
            {
                context.AddNew<tblICItemAccount>(fc);
                LogItems.Add(new ImportLogItem()
                {
                    ActionIcon = ICON_ACTION_NEW,
                    Description = "Created GL Account",
                    FromValue = "",
                    ToValue = string.Format("GL Account Category: {0}, GL Account Id: {1}", fc.strAccountCategory, fc.strAccountId)
                });
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICItemAccount entity)
        {
            return entity.intItemAccountId;
        }

        protected override void LogTransaction(ref tblICItemAccount entity, ImportDataResult dr)
        {
            var id = entity.intItemId;
            if (id != 0)
            {
                string details = string.Empty;
                string comma = ",";
                int count = 0;
                foreach (ImportLogItem item in LogItems)
                {
                    count++;
                    if (count == LogItems.Count && count == 1)
                        comma = "";
                    details += "{\"change\":\"" + item.Description + "\",\"iconCls\":\"" + item.ActionIcon + "\",\"from\":\"" + item.FromValue + "\",\"to\":\"" + item.ToValue + "\",\"leaf\":true}" + comma;
                }

                if (!string.IsNullOrEmpty(details))
                    LogItem(id, "Imported from CSV file.", "Inventory.view.Item", details, dr);
            }
        }
    }
}
