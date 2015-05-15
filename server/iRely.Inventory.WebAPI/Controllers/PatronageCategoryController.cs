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
    public class PatronageCategoryController : BaseApiController<tblICPatronageCategory>
    {
        private IPatronageCategoryBl _bl;

        public PatronageCategoryController(IPatronageCategoryBl bl)
            : base(bl)
        {
            _bl = bl;
        }

    }
}
