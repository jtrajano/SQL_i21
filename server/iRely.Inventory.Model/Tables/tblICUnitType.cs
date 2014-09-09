using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICUnitType : BaseEntity
    {
        public int intUnitTypeId { get; set; }
        public int strUnitType { get; set; }
        public int strDescription { get; set; }
        public int strInternalCode { get; set; }
        public int intCapacityUnitMeasureId { get; set; }
        public double dblMaxWeight { get; set; }
        public bool ysnAllowPick { get; set; }
        public int intDimensionUnitMeasureId { get; set; }
        public double dblHeight { get; set; }
        public double dblDepth { get; set; }
        public double dblWidth { get; set; }
        public int intPalletStack { get; set; }
        public int intPalletColumn { get; set; }
        public int intPalletRow { get; set; }
    }
}
