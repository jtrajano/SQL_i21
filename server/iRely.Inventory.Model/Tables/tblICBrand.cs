using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICBrand : BaseEntity
    {
        public int intBrandId { get; set; }
        public string strBrandCode { get; set; }
        public string strBrandName { get; set; }
        public int? intManufacturerId { get; set; }
        public int intSort { get; set; }

        public tblICManufacturer tblICManufacturer { get; set; }
    }
}
