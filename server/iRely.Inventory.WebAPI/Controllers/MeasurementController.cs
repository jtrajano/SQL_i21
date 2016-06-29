using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;
using iRely.Common;

namespace iRely.Inventory.WebApi
{
    public class MeasurementController : BaseApiController<tblICMeasurement>
    {
        public MeasurementController(IMeasurementBl bl)
            : base(bl)
        {
        }
    }
}