using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptItemLot
    {
        public int intInventoryReceiptItemLotId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public string strReceiptNumber { get; set; }
        public string strReceiptType { get; set; }
        public string strOrderNumber { get; set; }
        public string strLocationName { get; set; }
        public string strSourceType { get; set; }
        public string strSourceNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public string strBillOfLading { get; set; }
        public bool? ysnPosted { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strItemUOM { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public decimal? dblNetWeight { get; set; }
        public decimal? dblCost { get; set; }
        public int? intUnitPallet { get; set; }
        public decimal? dblStatedGrossPerUnit { get; set; }
        public decimal? dblStatedTarePerUnit { get; set; }
        public string strContainerNo { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strGarden { get; set; }
        public string strMarkings { get; set; }
        public int? intOriginId { get; set; }
        public string strOrigin { get; set; }
        public int? intGradeId { get; set; }
        public string strGrade { get; set; }
        public int? intSeasonCropYear { get; set; }
        public string strVendorLotId { get; set; }
        public DateTime? dtmManufacturedDate { get; set; }
        public string strRemarks { get; set; }
        public string strCondition { get; set; }
        public DateTime? dtmCertified { get; set; }
        public DateTime? dtmExpiryDate { get; set; }
        public int? intSort { get; set; }
        public int? intParentLotId { get; set; }
        public string strParentLotNumber { get; set; }
        public string strParentLotAlias { get; set; }
        public decimal? dblStatedNetPerUnit { get; set; }
        public decimal? dblStatedTotalNet { get; set; }
        public decimal? dblPhysicalVsStated { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }

        public tblICInventoryReceiptItemLot tblICInventoryReceiptItemLot { get; set; }
    }
}
