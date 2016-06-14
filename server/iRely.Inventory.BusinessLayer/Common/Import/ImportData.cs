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

        public void Dispose()
        {
            
        }
    }
}
