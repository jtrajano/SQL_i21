using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICInventoryReceipt : BaseEntity
    {
        public tblICInventoryReceipt()
        {
            this.tblICInventoryReceiptInspections = new List<tblICInventoryReceiptInspection>();
            this.tblICInventoryReceiptItems = new List<tblICInventoryReceiptItem>();
        }

        public int intInventoryReceiptId { get; set; }
        public string strReceiptNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public int intVendorId { get; set; }
        public string strReceiptType { get; set; }
        public int? intSourceId { get; set; }
        public int intBlanketRelease { get; set; }
        public int? intLocationId { get; set; }
        public int? intWarehouseId { get; set; }
        public string strVendorRefNo { get; set; }
        public string strBillOfLading { get; set; }
        public int? intShipViaId { get; set; }
        public int intReceiptSequenceNo { get; set; }
        public int intBatchNo { get; set; }
        public int? intTermId { get; set; }
        public int intProductOrigin { get; set; }
        public string strReceiver { get; set; }
        public int? intCurrencyId { get; set; }
        public string strVessel { get; set; }
        public string strAPAccount { get; set; }
        public string strBillingStatus { get; set; }
        public string strOrderNumber { get; set; }
        public int? intFreightTermId { get; set; }
        public string strDeliveryPoint { get; set; }
        public string strAllocateFreight { get; set; }
        public string strFreightBilledBy { get; set; }
        public int intShiftNumber { get; set; }
        public string strNotes { get; set; }
        public string strCalculationBasis { get; set; }
        public decimal? dblUnitWeightMile { get; set; }
        public decimal? dblFreightRate { get; set; }
        public decimal? dblFuelSurcharge { get; set; }
        public decimal? dblInvoiceAmount { get; set; }
        public bool ysnInvoicePaid { get; set; }
        public int intCheckNo { get; set; }
        public DateTime dteCheckDate { get; set; }
        public int? intTrailerTypeId { get; set; }
        public DateTime? dteTrailerArrivalDate { get; set; }
        public DateTime? dteTrailerArrivalTime { get; set; }
        public string strSealNo { get; set; }
        public string strSealStatus { get; set; }
        public DateTime? dteReceiveTime { get; set; }
        public decimal? dblActualTempReading { get; set; }

        public virtual ICollection<tblICInventoryReceiptInspection> tblICInventoryReceiptInspections { get; set; }
        public virtual ICollection<tblICInventoryReceiptItem> tblICInventoryReceiptItems { get; set; }
    }

    public class tblICInventoryReceiptItem : BaseEntity
    {
        public tblICInventoryReceiptItem()
        {
            this.tblICInventoryReceiptItemLots = new List<tblICInventoryReceiptItemLot>();
            this.tblICInventoryReceiptItemTaxes = new List<tblICInventoryReceiptItemTax>();
        }

        public int intInventoryReceiptItemId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int intLineNo { get; set; }
        public int intItemId { get; set; }
        public int intUnitMeasureId { get; set; }
        public int intNoPackages { get; set; }
        public decimal? dblExpPackageWeight { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblUnitRetail { get; set; }
        public decimal? dblLineTotal { get; set; }
        public decimal? dblGrossMargin { get; set; }
        public int intSort { get; set; }

        public virtual tblICInventoryReceipt tblICInventoryReceipt { get; set; }

        public virtual ICollection<tblICInventoryReceiptItemLot> tblICInventoryReceiptItemLots { get; set; }
        public virtual ICollection<tblICInventoryReceiptItemTax> tblICInventoryReceiptItemTaxes { get; set; }
    }

    public class tblICInventoryReceiptItemLot : BaseEntity
    {
        public int intInventoryReceiptItemLotId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public string strParentLotId { get; set; }
        public string strLotId { get; set; }
        public string strContainerNo { get; set; }
        public decimal? dblQuantity { get; set; }
        public int intUnits { get; set; }
        public int intUnitUOMId { get; set; }
        public int intUnitPallet { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public int intWeightUOMId { get; set; }
        public decimal? dblStatedGrossPerUnit { get; set; }
        public decimal? dblStatedTarePerUnit { get; set; }
        public int? intStorageBinId { get; set; }
        public int intGarden { get; set; }
        public string strGrade { get; set; }
        public int? intOriginId { get; set; }
        public int intSeasonCropYear { get; set; }
        public string strVendorLotId { get; set; }
        public DateTime dtmManufacturedDate { get; set; }
        public string strRemarks { get; set; }
        public int intSort { get; set; }

        public virtual tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
    }

    public class tblICInventoryReceiptItemTax : BaseEntity
    {
        public int intInventoryReceiptItemTaxId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int intTaxCodeId { get; set; }
        public bool ysnSelected { get; set; }
        public int intSort { get; set; }

        public virtual tblICInventoryReceiptItem tblICInventoryReceiptItem { get; set; }
    }

    public class tblICInventoryReceiptInspection : BaseEntity
    {
        public int intInventoryReceiptInspectionId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int intQAPropertyId { get; set; }
        public bool ysnSelected { get; set; }
        public int intSort { get; set; }

        public virtual tblICInventoryReceipt tblICInventoryReceipt { get; set; }
    }
}
