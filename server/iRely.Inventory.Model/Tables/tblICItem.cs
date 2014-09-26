using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItem : BaseEntity
    {
        public tblICItem()
        {
            this.tblICItemUOMs = new List<tblICItemUOM>();
            this.tblICItemLocationStores = new List<tblICItemLocationStore>();
            this.tblICItemSales = new tblICItemSales();
            this.tblICItemPOS = new tblICItemPOS();
            this.tblICItemManufacturing = new tblICItemManufacturing();
            this.tblICItemUPCs = new List<tblICItemUPC>();
            this.tblICItemVendorXrefs = new List<tblICItemVendorXref>();
            this.tblICItemCustomerXrefs = new List<tblICItemCustomerXref>();
            this.tblICItemContracts = new List<tblICItemContract>();
            this.tblICItemCertifications = new List<tblICItemCertification>();
        }

        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public int? intManufacturerId { get; set; }
        public int? intBrandId { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public int? intTrackingId { get; set; }
        public string strLotTracking { get; set; }

        public ICollection<tblICItemUOM> tblICItemUOMs { get; set; }
        public ICollection<tblICItemLocationStore> tblICItemLocationStores { get; set; }
        public tblICItemPOS tblICItemPOS { get; set; }
        public tblICItemSales tblICItemSales { get; set; }
        public tblICItemManufacturing tblICItemManufacturing { get; set; }

        public ICollection<tblICItemUPC> tblICItemUPCs { get; set; }
        public ICollection<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public ICollection<tblICItemCustomerXref> tblICItemCustomerXrefs { get; set; }
        public ICollection<tblICItemContract> tblICItemContracts { get; set; }
        public ICollection<tblICItemCertification> tblICItemCertifications { get; set; }

    }

    public class ItemVM : BaseEntity
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public int? intManufacturerId { get; set; }
        public int? intBrandId { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public int? intTrackingId { get; set; }
        public string strLotTracking { get; set; }
    }
}
