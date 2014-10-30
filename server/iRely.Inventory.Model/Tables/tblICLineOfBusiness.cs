using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICLineOfBusiness : BaseEntity
    {
        public int intLineOfBusinessId { get; set; }
        public string strLineOfBusiness { get; set; }
        public int intSort { get; set; }
    }
}
