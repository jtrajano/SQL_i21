using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemPOSCategory : BaseEntity
    {
        public int intItemPOSCategoryId { get; set; }
        public int intItemId { get; set; }
        public int intCategoryId { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
    }

    public class tblICItemPOSSLA : BaseEntity
    {
        public int intItemPOSSLAId { get; set; }
        public int intItemId { get; set; }
        public string strSLAContract { get; set; }
        public double dblContractPrice { get; set; }
        public bool ysnServiceWarranty { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
