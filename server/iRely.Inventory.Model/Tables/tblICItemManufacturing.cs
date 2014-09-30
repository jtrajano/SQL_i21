using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemManufacturing : BaseEntity
    {
        public tblICItemManufacturing()
        {
            this.tblICItemManufacturingUOMs = new List<tblICItemManufacturingUOM>();
        }

        public int intItemManufacturingId { get; set; }
        public int intItemId { get; set; }
        public bool ysnRequireCustomerApproval { get; set; }
        public int intRecipeId { get; set; }
        public bool ysnSanitationRequired { get; set; }
        public int intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
        public int intReceiveLife { get; set; }
        public string strGTIN { get; set; }
        public string strRotationType { get; set; }
        public int intNMFCId { get; set; }
        public bool ysnStrictFIFO { get; set; }
        public int intDimensionUOMId { get; set; }
        public double dblHeight { get; set; }
        public double dblWidth { get; set; }
        public double dblDepth { get; set; }
        public int intWeightUOMId { get; set; }
        public double dblWeight { get; set; }
        public int intMaterialPackTypeId { get; set; }
        public string strMaterialSizeCode { get; set; }
        public int intInnerUnits { get; set; }
        public int intLayerPerPallet { get; set; }
        public int intUnitPerLayer { get; set; }
        public double dblStandardPalletRatio { get; set; }
        public string strMask1 { get; set; }
        public string strMask2 { get; set; }
        public string strMask3 { get; set; }

        public ICollection<tblICItemManufacturingUOM> tblICItemManufacturingUOMs { get; set; }
        public tblICItem tblICItem { get; set; }
    }

    public class tblICItemManufacturingUOM : BaseEntity
    {
        public int intItemManufacturingUOMId { get; set; }
        public int intItemManufacturingId { get; set; }
        public int intUnitMeasureId { get; set; }
        public int intSort { get; set; }

        public tblICItemManufacturing tblICItemManufacturing { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
    }

}
