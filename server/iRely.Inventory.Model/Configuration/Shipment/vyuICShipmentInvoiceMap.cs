using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICShipmentInvoiceMap : EntityTypeConfiguration<vyuICShipmentInvoice>
    {
        public vyuICShipmentInvoiceMap()
        {
            this.HasKey(t => t.intInventoryShipmentItemId);
            this.ToTable("vyuICShipmentInvoice2");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.intInventoryShipmentChargeId).HasColumnName("intInventoryShipmentChargeId");
            this.Property(t => t.strShipmentNumber).HasColumnName("strShipmentNumber");
            this.Property(t => t.dtmShipDate).HasColumnName("dtmShipDate");
            this.Property(t => t.strCustomer).HasColumnName("strCustomer");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strDestination).HasColumnName("strDestination");
            this.Property(t => t.strBOLNumber).HasColumnName("strBOLNumber");
            this.Property(t => t.strOrderType).HasColumnName("strOrderType");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.dblUnitCost).HasColumnName("dblUnitCost");
            this.Property(t => t.dblShipmentQty).HasColumnName("dblShipmentQty");
            this.Property(t => t.dblInTransitQty).HasColumnName("dblInTransitQty");
            this.Property(t => t.dblInvoiceQty).HasColumnName("dblInvoiceQty");
            this.Property(t => t.dblShipmentLineTotal).HasColumnName("dblShipmentLineTotal");
            this.Property(t => t.dblInTransitTotal).HasColumnName("dblInTransitTotal");
            this.Property(t => t.dblInvoiceLineTotal).HasColumnName("dblInvoiceLineTotal");
            this.Property(t => t.dblShipmentTax).HasColumnName("dblShipmentTax");
            this.Property(t => t.dblInvoiceTax).HasColumnName("dblInvoiceTax");
            this.Property(t => t.dblOpenQty).HasColumnName("dblOpenQty");
            this.Property(t => t.dblItemsReceivable).HasColumnName("dblItemsReceivable");
            this.Property(t => t.dblTaxesReceivable).HasColumnName("dblTaxesReceivable");
            this.Property(t => t.dtmLastInvoiceDate).HasColumnName("dtmLastInvoiceDate");
            this.Property(t => t.strAllVouchers).HasColumnName("strAllVouchers");
            this.Property(t => t.strFilterString).HasColumnName("strFilterString");
            this.Property(t => t.dtmCreated).HasColumnName("dtmCreated");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");

        }
    }
}
