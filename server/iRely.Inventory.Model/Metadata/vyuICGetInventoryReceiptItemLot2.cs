using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptItemLot2 : BaseEntity
    {
        public int intInventoryReceiptItemLotId { get; set;}
        public int intInventoryReceiptItemId { get;set;}
        public int? intLotId { get;set;}
        public string strLotNumber { get;set;}
        public string strLotAlias { get;set;}
        public int? intSubLocationId { get;set;}
        public int? intStorageLocationId { get;set;}
        public int? intItemUnitMeasureId { get;set;}
        public decimal? dblQuantity { get;set;}
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public decimal? dblCost { get; set; }
        public int? intNoPallet { get;set;}
        public int? intUnitPallet { get;set;}
        public decimal? dblStatedGrossPerUnit { get; set; }
        public decimal? dblStatedTarePerUnit { get; set; }
        public string strContainerNo { get;set;}
        public int? intEntityVendorId { get;set;}
        public string strGarden { get;set;}
        public string strMarkings { get;set;}
        public int? intOriginId { get;set;}
        public int? intGradeId { get;set;}
        public int? intSeasonCropYear { get;set;}
        public string strVendorLotId { get;set;}
        public DateTime? dtmManufacturedDate { get;set;}
        public string strRemarks { get;set;}
        public string strCondition { get;set;}
        public DateTime? dtmCertified { get;set;}
        public DateTime? dtmExpiryDate { get; set; }
        public int? intParentLotId { get;set;}
        public string strParentLotNumber { get;set;}
        public string strParentLotAlias { get;set;}
        public int? intSort { get;set;}
        public decimal? dblNetWeight { get;set;}
        public string strUnitMeasure { get;set;}
        public string strUnitType { get;set;}
        public decimal? dblUnitQty { get; set; }
        public string strItemUOM { get;set;}
        public string strWeightUOM { get;set;}
        public decimal? dblLotUOMConvFactor { get; set; }
        public string strStorageLocation { get;set;}
        public string strSubLocationName { get;set;}
        public string strVendorId { get;set;}
        public string strOrigin { get;set;}
        public string strGrade { get;set;}
    }
}
