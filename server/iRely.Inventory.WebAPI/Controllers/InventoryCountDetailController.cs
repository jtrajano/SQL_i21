using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using System.Data.SqlClient;

namespace iRely.Inventory.WebApi
{
    public class InventoryCountDetailController : BaseApiController<tblICInventoryCountDetail>
    {
        private IInventoryCountDetailBl _bl;

        public InventoryCountDetailController(IInventoryCountDetailBl bl)
            : base(bl)
        {
            _bl = bl;
        }
    }
}