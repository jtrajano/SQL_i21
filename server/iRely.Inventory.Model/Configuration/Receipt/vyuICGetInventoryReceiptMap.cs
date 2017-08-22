using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptMap : EntityTypeConfiguration<vyuICGetInventoryReceipt>
    {
        public vyuICGetInventoryReceiptMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceipt");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.strReceiptType).HasColumnName("strReceiptType");
            this.Property(t => t.intSourceType).HasColumnName("intSourceType");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.intTransferorId).HasColumnName("intTransferorId");
            this.Property(t => t.strTransferor).HasColumnName("strTransferor");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.dtmReceiptDate).HasColumnName("dtmReceiptDate");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.intSubCurrencyCents).HasColumnName("intSubCurrencyCents");
            this.Property(t => t.intBlanketRelease).HasColumnName("intBlanketRelease");
            this.Property(t => t.strVendorRefNo).HasColumnName("strVendorRefNo");
            this.Property(t => t.strBillOfLading).HasColumnName("strBillOfLading");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.strShipVia).HasColumnName("strShipVia");
            this.Property(t => t.intShipFromId).HasColumnName("intShipFromId");
            this.Property(t => t.strShipFrom).HasColumnName("strShipFrom");
            this.Property(t => t.intReceiverId).HasColumnName("intReceiverId");
            this.Property(t => t.strReceiver).HasColumnName("strReceiver");
            this.Property(t => t.strVessel).HasColumnName("strVessel");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.strFreightTerm).HasColumnName("strFreightTerm");
            this.Property(t => t.strFobPoint).HasColumnName("strFobPoint");
            this.Property(t => t.intShiftNumber).HasColumnName("intShiftNumber");
            this.Property(t => t.dblInvoiceAmount).HasColumnName("dblInvoiceAmount").HasPrecision(18, 6);
            this.Property(t => t.ysnPrepaid).HasColumnName("ysnPrepaid");
            this.Property(t => t.ysnInvoicePaid).HasColumnName("ysnInvoicePaid");
            this.Property(t => t.intCheckNo).HasColumnName("intCheckNo");
            this.Property(t => t.dtmCheckDate).HasColumnName("dtmCheckDate");
            this.Property(t => t.intTrailerTypeId).HasColumnName("intTrailerTypeId");
            this.Property(t => t.dtmTrailerArrivalDate).HasColumnName("dtmTrailerArrivalDate");
            this.Property(t => t.dtmTrailerArrivalTime).HasColumnName("dtmTrailerArrivalTime");
            this.Property(t => t.strSealNo).HasColumnName("strSealNo");
            this.Property(t => t.strSealStatus).HasColumnName("strSealStatus");
            this.Property(t => t.dtmReceiveTime).HasColumnName("dtmReceiveTime");
            this.Property(t => t.dblActualTempReading).HasColumnName("dblActualTempReading").HasPrecision(18, 6);
            this.Property(t => t.intShipmentId).HasColumnName("intShipmentId");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.strTaxGroup).HasColumnName("strTaxGroup");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strEntityName).HasColumnName("strEntityName");
            this.Property(t => t.strActualCostId).HasColumnName("strActualCostId");
            this.Property(t => t.strWarehouseRefNo).HasColumnName("strWarehouseRefNo");
            this.Property(t => t.dblSubTotal).HasColumnName("dblSubTotal").HasPrecision(38, 6);
            this.Property(t => t.dblTotalTax).HasColumnName("dblTotalTax").HasPrecision(38, 6);
            this.Property(t => t.dblTotalCharges).HasColumnName("dblTotalCharges").HasPrecision(38, 6);
            this.Property(t => t.dblTotalGross).HasColumnName("dblTotalGross").HasPrecision(38, 6);
            this.Property(t => t.dblTotalNet).HasColumnName("dblTotalNet").HasPrecision(38, 6);
            this.Property(t => t.dblGrandTotal).HasColumnName("dblGrandTotal").HasPrecision(38, 6);
        }
    }
}
