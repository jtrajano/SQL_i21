using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using iRely.Common;

namespace iRely.Inventory.WebApi
{
    public class M2MComputationController : BaseApiController<tblICM2MComputation>
    {
        private IM2MComputationBl _bl;

        public M2MComputationController(IM2MComputationBl bl)
            : base(bl)
        {
            _bl = bl;
        }
    }
}
