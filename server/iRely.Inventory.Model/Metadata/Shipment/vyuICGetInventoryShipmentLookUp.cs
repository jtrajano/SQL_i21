using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipmentLookUp
    {
        public int? intInventoryShipmentId { get; set; }
        public string strOrderType { get; set; }
        public string strSourceType { get; set; }
        public string strShipFromLocation { get; set; }
        public string strShipFromStreet { get; set; }
        public string strShipFromCity { get; set; }
        public string strShipFromState { get; set; }
        public string strShipFromZipPostalCode { get; set; }
        public string strShipFromCountry { get; set; }
        public string strShipFromAddress { get; set; }
        public string strShipToLocation { get; set; }
        public string strShipToStreet { get; set; }
        public string strShipToCity { get; set; }
        public string strShipToState { get; set; }
        public string strShipToZipPostalCode { get; set; }
        public string strShipToCountry { get; set; }
        public string strShipToAddress { get; set; }
        public string strCustomerNumber { get; set; }
        public string strCustomerName { get; set; }
        public string strFreightTerm { get; set; }
        public string strFobPoint { get; set; }
        public string strShipVia { get; set; }
        public int? intWarehouseInstructionHeaderId { get; set; }
        public string strCurrency { get; set; }

        public tblICInventoryShipment tblICInventoryShipment { get; set; }
    }
}
