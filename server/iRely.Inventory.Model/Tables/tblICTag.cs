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
        public string strTagNumber { get; set; }
        public string strDescription { get; set; }
        public string strMessage { get; set; }
        public bool ysnHazMat { get; set; }
    }
}
