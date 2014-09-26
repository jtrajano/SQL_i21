using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemVendorXref : BaseEntity
    {
        public int intItemVendorXrefId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public string strStoreName { get; set; }
        public int intVendorId { get; set; }
        public string strVendorProduct { get; set; }
        public string strProductDescription { get; set; }
        public double dblConversionFactor { get; set; }
        public int intUnitMeasureId { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
