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
        public string strBrand { get; set; }
        public string strDescription { get; set; }
        public int intSort { get; set; }
    }
}
