using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblSMLineOfBusiness : BaseEntity
    {
        public int intLineOfBusinessId { get; set; }
        public string strLineOfBusiness { get; set; }
        public int intEntityId { get; set; }
        public bool ysnVisibleOnWeb { get; set; }
        public string strSICCode { get; set; }
        public string strType { get; set; }
        public int? intSegmentCodeId { get; set; }

        public ICollection<tblICCategory> tblICCategories { get; set; }
    }
}
