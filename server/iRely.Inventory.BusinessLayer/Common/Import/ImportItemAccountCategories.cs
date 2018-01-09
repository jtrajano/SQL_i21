using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemAccountCategories : ImportDataLogic<tblICCategoryAccount>
    {
        public ImportItemAccountCategories(DbContext context, byte[] data) : base(context, data)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "category code", "gl account category", "gl account id" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intCategoryAccountId";
        }

        public override int GetPrimaryKeyValue(tblICCategoryAccount entity)
        {
            return entity.intCategoryAccountId;
        }

        protected override Expression<Func<tblICCategoryAccount, bool>> GetUniqueKeyExpression(tblICCategoryAccount entity)
        {
            return (e => e.intCategoryId == entity.intCategoryId && e.intAccountCategoryId == entity.intAccountCategoryId);
        }

        public override tblICCategoryAccount Process(CsvRecord record)
        {
            var entity = new tblICCategoryAccount();
            var valid = true;

            var lu = GetFieldValue(record, "Category Code");
            valid = SetIntLookupId<tblICCategory>(record, "Category Code", e => e.strCategoryCode == lu, e => e.intCategoryId, e => entity.intCategoryId = e, required: true);
            
            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new GLAccountPipe(context, ImportResult));
        }

        class GLAccountPipe : CsvPipe<tblICCategoryAccount>
        {
            public GLAccountPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICCategoryAccount Process(tblICCategoryAccount input)
            {
                if (input == null)
                    return null;
                string category = "";
                string accountId = "";
                string glcategory = null, account = null;

                var valueCategory = GetFieldValue("GL Account Category");
                if (string.IsNullOrEmpty(valueCategory)) return null;
               
                var lu = ImportDataLogicHelpers.GetLookUpId<tblGLAccountCategory>(Context, m => m.strAccountCategory == valueCategory, e => e.intAccountCategoryId);
                category = valueCategory;
                if (lu != null)
                {
                    input.intAccountCategoryId = (int)lu;
                    glcategory = valueCategory;
                }
                else
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "GL Account Category",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = valueCategory,
                        Message = $"The GL Account Category {valueCategory} does not exist.",
                    };
                    Result.AddError(msg);
                    return null;
                }

                var valueId = ImportDataLogicHelpers.GetFieldValue(Record, "GL Account Id");
                if (string.IsNullOrEmpty(valueId)) return null;
                lu = ImportDataLogicHelpers.GetLookUpId<tblGLAccount>(Context, m => m.strAccountId == valueId, e => e.intAccountId);
                accountId = valueId;
                if (lu != null)
                {
                    input.intAccountId = (int)lu;
                    account = valueId;
                }
                else
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "GL Account Id",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = valueId,
                        Message = $"The GL Account Id {valueId} does not exist.",
                    };
                    Result.AddError(msg);
                    return null;
                }

                if (account != null && category != null)
                {
                    var valid = IsAccountMatchedForCategory(Record, category, account, Result);
                    if (!valid)
                        return null;
                }

                return input;
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

            private bool IsAccountMatchedForCategory(CsvRecord record, string category, string account, ImportDataResult Result)
            {
                var p2 = new System.Data.SqlClient.SqlParameter("@p2", account.Trim().Replace("-", ""));
                p2.DbType = System.Data.DbType.String;
                var p1 = new System.Data.SqlClient.SqlParameter("@p1", category.Trim());
                p1.DbType = System.Data.DbType.String;
                var query = "SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory = @p1 AND strAccountId1 = @p2";
                IEnumerable<vyuGLAccountDetail> ships = Context.Database.SqlQuery<vyuGLAccountDetail>(query, p1, p2);
                try
                {
                    vyuGLAccountDetail ship = ships.FirstOrDefault();

                    if (ship != null)
                        return true;
                    else
                    {
                        var msg = new ImportDataMessage()
                        {
                            Column = "GL Account Id",
                            Row = record.RecordNo,
                            Type = Constants.TYPE_ERROR,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = account,
                            Message = $"Invalid Account Id: {account} or the Account Id does not belong to the {category} GL account category.",
                        };
                        Result.AddError(msg);
                        return false;
                    }
                }
                catch (Exception e)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "GL Account Id",
                        Row = record.RecordNo,
                        Type = Constants.TYPE_EXCEPTION,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = account,
                        Message = $"Error validating Account Id: {account}. {e.Message}",
                    };
                    Result.AddError(msg);
                    return false;
                }
            }
        }
    }
}
