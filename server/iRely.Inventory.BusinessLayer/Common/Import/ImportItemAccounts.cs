using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemAccounts : ImportDataLogic<tblICItemAccount>
    {
        public ImportItemAccounts(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "gl account category", "gl account id" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemAccountId";
        }

        public override int GetPrimaryKeyValue(tblICItemAccount entity)
        {
            return entity.intItemAccountId;
        }

        public override tblICItemAccount Process(CsvRecord record)
        {
            var entity = new tblICItemAccount();
            var valid = true;
            var lu = GetFieldValue(record, "Item No");
            valid = SetIntLookupId<tblICItem>(record, "Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intItemId = e, required: true);
            lu = GetFieldValue(record, "GL Account Category");
            valid = SetLookupId<tblGLAccountCategory>(record, "GL Account Category", e => e.strAccountCategory == lu, e => e.intAccountCategoryId, e => entity.intAccountCategoryId = e, required: true);
            lu = GetFieldValue(record, "GL Account Id");
            valid = SetLookupId<tblGLAccount>(record, "GL Account Id", e => e.strAccountId == lu, e => e.intAccountId, e => entity.intAccountId = e, required: true);

            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new AccountMatchingPipe(context, ImportResult));
        }

        class AccountMatchingPipe : CsvPipe<tblICItemAccount>
        {
            public AccountMatchingPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemAccount Process(tblICItemAccount input)
            {
                var valid = IsAccountMatchedForCategory(GetFieldValue("GL Account Category"), GetFieldValue("GL Account Id"));
                if (valid)
                    return input;
                return null;
            }

            private bool IsAccountMatchedForCategory(string category, string account)
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
                        AddError("Account Id", $"Invalid Account Id: {account}.");
                    }
                }
                catch (Exception)
                {
                    AddError("Account Id", $"Error validating Account Id: {account}.");
                }
                return false;
            }
        }
        
        class vyuGLAccountDetail
        {
            public int? intAccountId { get; set; }
        }
    }
}
