using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipment : BaseEntity
    {
        public tblICInventoryShipment()
        {
            this.tblICInventoryShipmentItems = new List<tblICInventoryShipmentItem>();
            this.tblICInventoryShipmentCharges = new List<tblICInventoryShipmentCharge>();
        }

        public int intInventoryShipmentId { get; set; }
        public string strShipmentNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public int? intOrderType { get; set; }
        public int? intSourceType { get; set; }
        public string strReferenceNumber { get; set; }
        public DateTime? dtmRequestedArrivalDate { get; set; }
        public int? intShipFromLocationId { get; set; }
        public int? intEntityCustomerId { get; set; }
        public int? intShipToLocationId { get; set; }
        public int? intFreightTermId { get; set; }
        public int? intCurrencyId { get; set; }
        public string strFreeTime { get; set; }
        public string strBOLNumber { get; set; }
        public int? intShipViaId { get; set; }
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
        public int? intEntityId { get; set; }
        public int? intCreatedUserId { get; set; }
        public int? intShipToCompanyLocationId { get; set; }

        private string _shipFromLocation;
        [NotMapped]
        public string strShipFromLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_shipFromLocation))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipFromLocation;
                    else
                        return null;
                else
                    return _shipFromLocation;
            }
            set
            {
                _shipFromLocation = value;
            }
        }

        private string _strShipFromStreet;
        [NotMapped]
        public string strShipFromStreet
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromStreet))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipFromStreet;
                    else
                        return null;
                else
                    return _strShipFromStreet;
            }
            set
            {
                _strShipFromStreet = value;
            }
        }

        private string _strShipFromCity;
        [NotMapped]
        public string strShipFromCity
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromCity))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipFromCity;
                    else
                        return null;
                else
                    return _strShipFromCity;
            }
            set
            {
                _strShipFromCity = value;
            }
        }

        private string _strShipFromState;
        [NotMapped]
        public string strShipFromState
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromState))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipFromState;
                    else
                        return null;
                else
                    return _strShipFromState;
            }
            set
            {
                _strShipFromState = value;
            }
        }

        private string _strShipFromZipPostalCode;
        [NotMapped]
        public string strShipFromZipPostalCode
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromZipPostalCode))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipFromZipPostalCode;
                    else
                        return null;
                else
                    return _strShipFromZipPostalCode;
            }
            set
            {
                _strShipFromZipPostalCode = value;
            }
        }

        private string _strShipFromCountry;
        [NotMapped]
        public string strShipFromCountry
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipFromCountry))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipFromCountry;
                    else
                        return null;
                else
                    return _strShipFromCountry;
            }
            set
            {
                _strShipFromCountry = value;
            }
        }

        private string _shipToLocation;
        [NotMapped]
        public string strShipToLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_shipToLocation))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipToLocation;
                    else
                        return null;
                else
                    return _shipToLocation;
            }
            set
            {
                _shipToLocation = value;
            }
        }

        private string _strShipToStreet;
        [NotMapped]
        public string strShipToStreet
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToStreet))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipToStreet;
                    else
                        return null;
                else
                    return _strShipToStreet;
            }
            set
            {
                _strShipToStreet = value;
            }
        }

        private string _strShipToCity;
        [NotMapped]
        public string strShipToCity
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToCity))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipToCity;
                    else
                        return null;
                else
                    return _strShipToCity;
            }
            set
            {
                _strShipToCity = value;
            }
        }

        private string _strShipToState;
        [NotMapped]
        public string strShipToState
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToState))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipToState;
                    else
                        return null;
                else
                    return _strShipToState;
            }
            set
            {
                _strShipToState = value;
            }
        }

        private string _strShipToZipPostalCode;
        [NotMapped]
        public string strShipToZipPostalCode
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToZipPostalCode))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipToZipPostalCode;
                    else
                        return null;
                else
                    return _strShipToZipPostalCode;
            }
            set
            {
                _strShipToZipPostalCode = value;
            }
        }

        private string _strShipToCountry;
        [NotMapped]
        public string strShipToCountry
        {
            get
            {
                if (string.IsNullOrEmpty(_strShipToCountry))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipToCountry;
                    else
                        return null;
                else
                    return _strShipToCountry;
            }
            set
            {
                _strShipToCountry = value;
            }
        }

        private string _custName;
        [NotMapped]
        public string strCustomerName
        {
            get
            {
                if (string.IsNullOrEmpty(_custName))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strCustomerName;
                    else
                        return null;
                else
                    return _custName;
            }
            set
            {
                _custName = value;
            }
        }

        private int? _warehouseId;
        [NotMapped]
        public int? intWarehouseInstructionHeaderId
        {
            get
            {
                if (vyuICGetInventoryShipmentLookUp != null)
                    return vyuICGetInventoryShipmentLookUp.intWarehouseInstructionHeaderId;
                else
                    return null;
            }
            set
            {
                _warehouseId = value;
            }
        }

        private string _shipVia;
        [NotMapped]
        public string strShipVia
        {
            get
            {
                if (string.IsNullOrEmpty(_shipVia))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strShipVia;
                    else
                        return null;
                else
                    return _shipVia;
            }
            set
            {
                _shipVia = value;
            }
        }

        private string _currency;
        [NotMapped]
        public string strCurrency
        {
            get
            {
                if (string.IsNullOrEmpty(_currency))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strCurrency;
                    else
                        return null;
                else
                    return _currency;
            }
            set
            {
                _currency = value;
            }
        }

        private string _freightTerm;
        [NotMapped]
        public string strFreightTerm
        {
            get
            {
                if (string.IsNullOrEmpty(_freightTerm))
                    if (vyuICGetInventoryShipmentLookUp != null)
                        return vyuICGetInventoryShipmentLookUp.strFreightTerm;
                    else
                        return null;
                else
                    return _freightTerm;
            }
            set
            {
                _freightTerm = value;
            }
        }

        public vyuICGetInventoryShipmentLookUp vyuICGetInventoryShipmentLookUp { get; set; }
        public ICollection<tblICInventoryShipmentItem> tblICInventoryShipmentItems { get; set; }
        public ICollection<tblICInventoryShipmentCharge> tblICInventoryShipmentCharges { get; set; }        
    }
}
