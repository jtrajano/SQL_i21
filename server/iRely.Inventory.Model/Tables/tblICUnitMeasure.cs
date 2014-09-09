using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICUnitMeasure : BaseEntity
    {
        public int intUnitMeasureId { get; set; }
        public int strUnitMeasure { get; set; }
        public int strSymbol { get; set; }
        public int strUnitType { get; set; }
        public bool ysnDefault { get; set; }
    }
}
