using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemAccountCategories : ImportDataLogic<tblICCategoryAccount>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "category code", "gl account category", "gl account id" };
        }

        protected override tblICCategoryAccount ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICCategoryAccount fc = new tblICCategoryAccount();
            fc.intConcurrencyId = 1;
            string category = "";
            string accountId = "";
            bool valid = true;
            string glcategory = null, account = null;

            for (var i = 0; i < fieldCount; i++)
            {
                string header = headers[i];
                string value = csv[header];
                string h = header.ToLower().Trim();
                int? lu = null;

                switch (h)
                {
                    case "category":
                    case "category code":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = REC_SKIP,
                                Message = "Category Code should not be blank."
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = GetLookUpId<tblICCategory>(
                            context,
                            m => m.strCategoryCode == value,
                            e => e.intCategoryId);
                        if (lu != null)
                        {
                            fc.intCategoryId = (int)lu;
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
                                Message = "The Category Code" + value + " does not exist."
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
                        category = value;
                        if (lu != null)
                        {
                            fc.intAccountCategoryId = (int)lu;
                            glcategory = value;
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
                                Message = "Account Id should not be blank."
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = GetLookUpId<tblGLAccount>(
                            context,
                            m => m.strAccountId == value,
                            e => e.intAccountId);
                        accountId = value;
                        if (lu != null)
                        {
                            fc.intAccountId = (int)lu;
                            account = value;
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
                                Message = "The Account Id " + value + " does not exist."
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;

                }
            }

            if (fc != null && account != null && category != null)
                valid = IsAccountMatchedForCategory(category, account, dr, "GL Account Id", row);

            if (!valid)
                return null;

            if (context.GetQuery<tblICCategoryAccount>().Any(t => t.intCategoryId == fc.intCategoryId && t.intAccountCategoryId == fc.intAccountCategoryId && t.intAccountId == fc.intAccountId))
            {
                dr.Info = INFO_WARN;
                dr.Messages.Add(new ImportDataMessage()
                {
                    Type = TYPE_INNER_WARN,
                    Status = REC_SKIP,
                    Column = headers[1] + "/"  + headers[2],
                    Row = row,
                    Message = "The record already exists: " + category + " - " + accountId + " . Record skipped."
                });
            }
            else
            {
                context.AddNew<tblICCategoryAccount>(fc);
            }
            return fc;
        }

        class vyuGLAccountDetail
        {
            public int? intAccountId { get; set; }
            public string strAccountCategory { get; set; }
            public string strAccountId { get; set; }
            public string strAccountId1 { get; set; }
            public string strAccountType { get; set; }
            public int? intAccountCategoryId { get; set; }
        }

        private bool IsAccountMatchedForCategory(string category, string account, ImportDataResult dr, string header, int row)
        {
            var p2 = new System.Data.SqlClient.SqlParameter("@p2", account.Trim().Replace("-", ""));
            p2.DbType = System.Data.DbType.String;
            var p1 = new System.Data.SqlClient.SqlParameter("@p1", category.Trim());
            p1.DbType = System.Data.DbType.String;
            var query = "SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory = @p1 AND strAccountId1 = @p2";
            IEnumerable<vyuGLAccountDetail> ships = context.ContextManager.Database.SqlQuery<vyuGLAccountDetail>(query, p1, p2);
            try
            {
                vyuGLAccountDetail ship = ships.FirstOrDefault();

                if (ship != null)
                    return true;
                else
                {
                    dr.Messages.Add(new ImportDataMessage()
                    {
                        Column = header,
                        Row = row,
                        Type = TYPE_INNER_ERROR,
                        Message = "Invalid Account Id: " + account + '.',
                        Status = REC_SKIP
                    });
                    dr.Info = INFO_ERROR;
                }
            }
            catch (Exception e)
            {
                dr.Messages.Add(new ImportDataMessage()
                {
                    Column = header,
                    Row = row,
                    Type = TYPE_INNER_EXCEPTION,
                    Message = "Error validating Account Id: " + account + ". " + e.Message,
                    Status = REC_SKIP
                });
                dr.Info = INFO_ERROR;
            }
            return false;
        }
        protected override int GetPrimaryKeyId(ref tblICCategoryAccount entity)
        {
            return entity.intCategoryAccountId;
        }
    }
}
