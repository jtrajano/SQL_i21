using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public interface IImportDataLogic
    {
        ImportDataResult Import();
        InventoryRepository Context { get; set; }
        byte[] Data { get; set; }
    }
}
