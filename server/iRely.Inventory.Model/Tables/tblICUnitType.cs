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
        public string strUnitType { get; set; }
        public string strDescription { get; set; }
        public string strInternalCode { get; set; }
        public int intCapacityUnitMeasureId { get; set; }
        public decimal? dblMaxWeight { get; set; }
        public bool ysnAllowPick { get; set; }
        public int intDimensionUnitMeasureId { get; set; }
        public decimal? dblHeight { get; set; }
        public decimal? dblDepth { get; set; }
        public decimal? dblWidth { get; set; }
        public int? intPalletStack { get; set; }
        public int? intPalletColumn { get; set; }
        public int? intPalletRow { get; set; }

        public tblICUnitMeasure CapacityUnitMeasures { get; set; }
        public tblICUnitMeasure DimensionUnitMeasures { get; set; }
    }
}
