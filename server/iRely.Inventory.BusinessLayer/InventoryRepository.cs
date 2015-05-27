using iRely.Common;
using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryRepository : Repository
    {
        public InventoryRepository()
            : base(new InventoryEntities())
        {
        }
    }
}
