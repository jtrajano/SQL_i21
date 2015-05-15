using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;

namespace iRely.Inventory.WebApi
{
    public class StatusController : BaseApiController<tblICStatus>
    {
        private IStatusBl _bl;

        public StatusController(IStatusBl bl)
            : base(bl)
        {
            _bl = bl;
        }

    }
}
