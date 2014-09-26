using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemCertification : BaseEntity
    {
        public int intItemCertificationId { get; set; }
        public int intItemId { get; set; }
        public int intCertificationId { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
        public tblICCertification tblICCertification { get; set; }
    }
}
