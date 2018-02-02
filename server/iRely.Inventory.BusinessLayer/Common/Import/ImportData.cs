using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LumenWorks.Framework.IO.Csv;
using iRely.Inventory.Model;
using System.IO;
using System.Linq.Expressions;
using iRely.Common;
using System.Data.SqlClient;
using System.Globalization;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportData : IDisposable
    {
        private InventoryRepository context;

        public InventoryRepository Context { get { return context; } set { this.context = value; } }

        public ImportData()
        {
            Context = new InventoryRepository();
        }

        public async Task<ImportDataResult> Import(byte[] data, string name)
        {
            try
            {
                var type = Type.GetType("iRely.Inventory.BusinessLayer.Import" + name);
                if(type == null)
                    throw new Exception("Import for " + name + " is not yet supported.");
                var username = iRely.Common.Security.GetUserName();
                var instance = (IImportDataLogic)Activator.CreateInstance(type, Context.ContextManager, data, username);
                
                //instance.Context = Context.ContextManager;
                //instance.Data = data;
                instance.Username = iRely.Common.Security.GetUserName();
                return await instance.Import();
            } catch(Exception ex)
            {
                throw new Exception(ex.Message, ex);
            }
        }

        private async Task<int> SaveLogsToDb(ImportDataResult result)
        {
            return await ImportDataSqlLogger.GetInstance(Context.ContextManager).WriteLogs(result);
        }

        public async Task<ImportDataResult> ImportOrigins(string type)
        {
            var sql = string.Empty;
            var lob = GlobalSettings.Instance.LineOfBusiness;
            var intEntityUserSecurityId = Security.GetEntityId();

            SqlParameter pLob = new SqlParameter("@strLineOfBusiness", lob);
            SqlParameter pType = new SqlParameter("@strType", type);
            SqlParameter pEntityId = new SqlParameter("@intEntityUserSecurityId", Security.GetEntityId());
            sql = "EXEC dbo.uspICImportDataFromOrigin @strLineOfBusiness, @strType, @intEntityUserSecurityId";

            var res = new ImportDataResult()
            {
                Description = $"Import {CultureInfo.CurrentCulture.TextInfo.ToTitleCase(type)} from Origin for {CultureInfo.CurrentCulture.TextInfo.ToTitleCase(lob)}.",
                Type = Constants.TYPE_INFO
            };

            try
            {
                await Context.ContextManager.Database.ExecuteSqlCommandAsync(sql, pLob, pType, pEntityId);
                var msg = new ImportDataMessage()
                {
                    Column = "",
                    Row = -1,
                    Type = Constants.TYPE_INFO,
                    Status = Constants.STAT_SUCCESS,
                    Action = Constants.ACTION_INSERTED,
                    Value = "",
                    Message = $"Import {CultureInfo.CurrentCulture.TextInfo.ToTitleCase(type)} from Origin for {CultureInfo.CurrentCulture.TextInfo.ToTitleCase(lob)} successful."
                };
                res.Type = Constants.TYPE_INFO;
                res.Description = $"Import {CultureInfo.CurrentCulture.TextInfo.ToTitleCase(type)} from Origin for {CultureInfo.CurrentCulture.TextInfo.ToTitleCase(lob)} successful.";
                res.AddMessage(msg);
            }
            catch (Exception ex)
            {
                var msg = new ImportDataMessage()
                {
                    Column = $"Error Importing {CultureInfo.CurrentCulture.TextInfo.ToTitleCase(type)} from Origin for {CultureInfo.CurrentCulture.TextInfo.ToTitleCase(lob)}.",
                    Row = -1,
                    Type = Constants.TYPE_ERROR,
                    Status = Constants.STAT_FAILED,
                    Action = Constants.ACTION_DISCARDED,
                    Exception = ex.InnerException == null ? ex : ex.InnerException,
                    Value = "",
                    Message = ex.InnerException == null ? ex.Message : ex.InnerException.Message,
                };
                res.Type = Constants.TYPE_ERROR;
                res.Description = ex.Message;
                res.AddError(msg);
            }

            try
            {
                await SaveLogsToDb(res);
            }
            catch
            {

            }

            return res;
        }

        public void Dispose()
        {
              
        }
    }
}
