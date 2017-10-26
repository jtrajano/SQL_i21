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
    public class tblICInventoryReceipt : BaseEntity
    {
        public tblICInventoryReceipt()
        {
            this.tblICInventoryReceiptInspections = new List<tblICInventoryReceiptInspection>();
            this.tblICInventoryReceiptItems = new List<tblICInventoryReceiptItem>();
            this.tblICInventoryReceiptCharges = new List<tblICInventoryReceiptCharge>();
        }

        public int intInventoryReceiptId { get; set; }
        public string strReceiptType { get; set; }
        public int? intSourceType { get; set; }
        public int? intEntityVendorId { get; set; }
        public int? intTransferorId { get; set; }
        public int? intLocationId { get; set; }
        public string strReceiptNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public int? intCurrencyId { get; set; }
        public int? intSubCurrencyCents { get; set; }
        public int? intBlanketRelease { get; set; }
        public string strVendorRefNo { get; set; }
        public string strBillOfLading { get; set; }
        public int? intShipViaId { get; set; }
        public int? intShipFromId { get; set; }
        public int? intReceiverId { get; set; }
        public string strVessel { get; set; }
        public int? intFreightTermId { get; set; }
        public int? intShiftNumber { get; set; }
        public decimal? dblInvoiceAmount { get; set; }
        public bool? ysnPrepaid { get; set; }
        public bool? ysnInvoicePaid { get; set; }
        public int? intCheckNo { get; set; }
        public DateTime? dtmCheckDate { get; set; }
        public int? intTrailerTypeId { get; set; }
        public DateTime? dtmTrailerArrivalDate { get; set; }
        public DateTime? dtmTrailerArrivalTime { get; set; }
        public string strSealNo { get; set; }
        public string strSealStatus { get; set; }
        public DateTime? dtmReceiveTime { get; set; }
        public decimal? dblActualTempReading { get; set; }
        public int? intTaxGroupId { get; set; }
        public int? intShipmentId { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intCreatedUserId { get; set; }
        public int? intEntityId { get; set; }
        public bool? ysnOrigin { get; set; }
        public string strWarehouseRefNo { get; set; }
        public DateTime? dtmLastFreeWhseDate { get; set; }

        //[NotMapped] public string strVendorName { get; set; }
        //[NotMapped] public int intVendorEntityId { get; set; }
        //[NotMapped] public string strFobPoint { get; set; }
        //[NotMapped] public string strLocationName { get; set; }
        //[NotMapped] public string strCurrency { get; set; }
        //[NotMapped] public string strFromLocation { get; set; }
        //[NotMapped] public string strUserName { get; set; }
        //[NotMapped] public string strShipFrom { get; set; }
        //[NotMapped] public string strShipVia { get; set; }
        //[NotMapped] public string strFreightTerm { get; set; }
        //private string _vendorName;
        //[NotMapped]
        //public string strVendorName
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_vendorName))
        //            if (vyuICInventoryReceiptLookUp != null)
        //                return vyuICInventoryReceiptLookUp.strVendorName;
        //            else
        //                return null;
        //        else
        //            return _vendorName;
        //    }
        //    set
        //    {
        //        _vendorName = value;
        //    }
        //}
        //private int? _vendorEntity;
        //[NotMapped]
        //public int? intVendorEntityId
        //{
        //    get
        //    {
        //        if (vyuICInventoryReceiptLookUp != null)
        //            return vyuICInventoryReceiptLookUp.intEntityId;
        //        else
        //            return -1;
        //    }
        //    set
        //    {
        //        _vendorEntity = value;
        //    }
        //}
        //private string _fobPoint;
        //[NotMapped]
        //public string strFobPoint
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_fobPoint))
        //            if (vyuICInventoryReceiptLookUp != null)
        //                return vyuICInventoryReceiptLookUp.strFobPoint;
        //            else
        //                return null;
        //        else
        //            return _fobPoint;
        //    }
        //    set
        //    {
        //        _fobPoint = value;
        //    }
        //}
        //private string _locationName;
        //[NotMapped]
        //public string strLocationName
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_locationName))
        //            if (vyuICInventoryReceiptLookUp != null)
        //                return vyuICInventoryReceiptLookUp.strLocationName;
        //            else
        //                return null;
        //        else
        //            return _locationName;
        //    }
        //    set
        //    {
        //        _locationName = value;
        //    }
        //}
        //private string _currencyName;
        //[NotMapped]
        //public string strCurrency
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_currencyName))
        //            if (vyuICInventoryReceiptLookUp != null)
        //                return vyuICInventoryReceiptLookUp.strCurrency;
        //            else
        //                return null;
        //        else
        //            return _currencyName;
        //    }
        //    set
        //    {
        //        _currencyName = value;
        //    }
        //}
        //private string _fromLocation;
        //[NotMapped]
        //public string strFromLocation
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_fromLocation))
        //            if (vyuICInventoryReceiptLookUp != null)
        //                return vyuICInventoryReceiptLookUp.strFromLocation;
        //            else
        //                return null;
        //        else
        //            return _fromLocation;
        //    }
        //    set
        //    {
        //        _fromLocation = value;
        //    }
        //}
        //private string _receiver;
        //[NotMapped]
        //public string strUserName
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_receiver))
        //            if (vyuICInventoryReceiptLookUp != null)
        //                return vyuICInventoryReceiptLookUp.strUserName;
        //            else
        //                return null;
        //        else
        //            return _receiver;
        //    }
        //    set
        //    {
        //        _receiver = value;
        //    }
        //}
        //private string _shipFrom;
        //[NotMapped]
        //public string strShipFrom
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_shipFrom))
        //            if (vyuICInventoryReceiptLookUp != null)
        //                return vyuICInventoryReceiptLookUp.strShipFrom;
        //            else
        //                return null;
        //        else
        //            return _shipFrom;
        //    }
        //    set
        //    {
        //        _shipFrom = value;
        //    }
        //}
        //private string _shipVia;
        //[NotMapped]
        //public string strShipVia
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_shipVia))
        //            if (vyuICInventoryReceiptLookUp != null)
        //                return vyuICInventoryReceiptLookUp.strShipVia;
        //            else
        //                return null;
        //        else
        //            return _shipVia;
        //    }
        //    set
        //    {
        //        _shipVia = value;
        //    }
        //}
        //private string _freightTerm;
        //[NotMapped]
        //public string strFreightTerm
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_freightTerm))
        //            if (vyuICInventoryReceiptLookUp != null)
        //                return vyuICInventoryReceiptLookUp.strFreightTerm;
        //            else
        //                return null;
        //        else
        //            return _freightTerm;
        //    }
        //    set
        //    {
        //        _freightTerm = value;
        //    }
        //}
        public ICollection<tblICInventoryReceiptInspection> tblICInventoryReceiptInspections { get; set; }
        public ICollection<tblICInventoryReceiptItem> tblICInventoryReceiptItems { get; set; }
        public ICollection<tblICInventoryReceiptCharge> tblICInventoryReceiptCharges { get; set; }

        public vyuICInventoryReceiptLookUp vyuICInventoryReceiptLookUp { get; set; }
        public vyuICInventoryReceiptTotals vyuICInventoryReceiptTotals { get; set; }
    }
}
