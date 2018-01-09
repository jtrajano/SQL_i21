using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public interface IImportDataLogic
    {
        Task<ImportDataResult> Import();
        DbContext Context { get; set; }
        byte[] Data { get; set; }
        string Username { get; set; }
    }
}
