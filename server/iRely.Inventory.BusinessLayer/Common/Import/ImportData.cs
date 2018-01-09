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
                Description = "Import from Origin",
                Type = Constants.TYPE_INFO
            };

            try
            {
                await Context.ContextManager.Database.ExecuteSqlCommandAsync(sql, pLob, pType, pEntityId);
            }
            catch (Exception ex)
            {
                res.Type = Constants.TYPE_ERROR;
                res.Description = ex.Message;
                res.Messages.Add(new ImportDataMessage()
                {
                    Type = "Error",
                    Status = "Import Failed",
                    Message = ex.Message,
                    Exception = ex
                });
            }

            return res;
        }

        public void Dispose()
        {
              
        }
    }
}
