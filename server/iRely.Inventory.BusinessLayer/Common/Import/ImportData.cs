﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LumenWorks.Framework.IO.Csv;
using iRely.Inventory.Model;
using System.IO;
using System.Linq.Expressions;
using iRely.Common;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportData : IDisposable
    {
        private InventoryRepository context;

        public ImportData()
        {
            context = new InventoryRepository();
        }

        public ImportDataResult Import(byte[] data, string name)
        {
            try
            {
                var type = Type.GetType("iRely.Inventory.BusinessLayer.Import" + name);
                var instance = (IImportDataLogic)Activator.CreateInstance(type);

                instance.Context = context;
                instance.Data = data;
                return instance.Import();
            } catch(Exception ex)
            {
                throw new Exception(ex.Message, ex);
            }
        }

        public async Task<ImportDataResult> ImportOrigins(string type)
        {
            var sql = string.Empty;
            if (type == "ItemsOrigins")
                sql = "EXEC uspICDCItemMigration";
            else if (type == "GLAccountsOrigins")
                sql = "uspICDCGLAcctsMigration";
            else if (type == "InventoryReceipts")
                sql = "uspICImportInventoryReceiptOrigins";

            var res = new ImportDataResult()
            {
                Description = "Import from Origins",
                Info = "success"
            };

            try
            {
                await context.ContextManager.Database.ExecuteSqlCommandAsync(sql);
            }
            catch (Exception ex)
            {
                res.Info = "error";
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
