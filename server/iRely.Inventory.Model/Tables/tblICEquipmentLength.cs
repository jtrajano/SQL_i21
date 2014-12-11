using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICEquipmentLength : BaseEntity
    {
        public int intEquipmentLengthId { get; set; }
        public string strEquipmentLength { get; set; }
        public string strDescription { get; set; }
        public int intSort { get; set; }
    }
}
