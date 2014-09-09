using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICTag : BaseEntity
    {
        public int intTagId { get; set; }
        public int strTagNumber { get; set; }
        public int strDescription { get; set; }
        public int strMessage { get; set; }
        public bool ysnHazMat { get; set; }
    }
}
