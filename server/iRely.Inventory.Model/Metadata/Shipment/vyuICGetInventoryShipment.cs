using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipment
    {
        public int intInventoryShipmentId { get; set; }
        public string strShipmentNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public int? intOrderType { get; set; }
        public string strOrderType { get; set; }
        public int? intSourceType { get; set; }
        public string strSourceType { get; set; }
        public string strReferenceNumber { get; set; }
        public DateTime? dtmRequestedArrivalDate { get; set; }
        public int? intShipFromLocationId { get; set; }
        public string strShipFromLocation { get; set; }
        public string strShipFromStreet { get; set; }
        public string strShipFromCity { get; set; }
        public string strShipFromState { get; set; }
        public string strShipFromZipPostalCode { get; set; }
        public string strShipFromCountry { get; set; }
        public string strShipFromAddress { get; set; }
        public int? intShipToCompanyLocationId { get; set; }
        public string strShipToLocation { get; set; }
        public string strShipToStreet { get; set; }
        public string strShipToCity { get; set; }
        public string strShipToState { get; set; }
        public string strShipToZipPostalCode { get; set; }
        public string strShipToCountry { get; set; }
        public string strShipToAddress { get; set; }
        public int? intEntityCustomerId { get; set; }
        public string strCustomerNumber { get; set; }
        public string strCustomerName { get; set; }
        public int? intShipToLocationId { get; set; }
        public int? intFreightTermId { get; set; }
        public string strFreightTerm { get; set; }
        public string strFobPoint { get; set; }
        public string strBOLNumber { get; set; }
        public int? intShipViaId { get; set; }
        public string strShipVia { get; set; }
        public string strVessel { get; set; }
        public string strProNumber { get; set; }
        public string strDriverId { get; set; }
        public string strSealNumber { get; set; }
        public string strDeliveryInstruction { get; set; }
        public DateTime? dtmAppointmentTime { get; set; }
        public DateTime? dtmDepartureTime { get; set; }
        public DateTime? dtmArrivalTime { get; set; }
        public DateTime? dtmDeliveredDate { get; set; }
        public string strReceivedBy { get; set; }
        public string strComment { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intWarehouseInstructionHeaderId { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public string strFreeTime { get; set; }
    }
}
