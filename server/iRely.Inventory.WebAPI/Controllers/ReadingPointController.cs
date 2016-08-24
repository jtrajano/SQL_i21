using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using iRely.Common;

namespace iRely.Inventory.WebApi
{
    public class ReadingPointController : BaseApiController<tblICReadingPoint>
    {
        public ReadingPointController(IReadingPointBl bl)
            : base(bl)
        {
        }
    }
}