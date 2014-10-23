using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICMaterialNMFC : BaseEntity
    {
        public int intMaterialNMFCId { get; set; }
        public int? intExternalSystemId { get; set; }
        public string strInternalCode { get; set; }
        public string strDisplayMember { get; set; }
        public bool ysnDefault { get; set; }
        public bool ysnLocked { get; set; }
        public string strLastUpdateBy { get; set; }
        public DateTime dtmLastUpdateOn { get; set; }
        public int intSort { get; set; }
    }
}
