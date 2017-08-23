using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemUOMByType
    {
        public int intId { get; set; }
        public int intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public string strSymbol { get; set; }
        public int intItemId { get; set; }
    }
}
