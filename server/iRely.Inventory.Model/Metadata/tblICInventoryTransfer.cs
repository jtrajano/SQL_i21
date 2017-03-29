using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICInventoryTransfer : BaseEntity
    {
        public tblICInventoryTransfer()
        {
            this.tblICInventoryTransferDetails = new List<tblICInventoryTransferDetail>();
        }

        public int intInventoryTransferId { get; set; }
        public string strTransferNo { get; set; }
        public DateTime? dtmTransferDate { get; set; }
        public string strTransferType { get; set; }
        public int? intSourceType { get; set; }
        public int? intTransferredById { get; set; }
        public string strDescription { get; set; }
        public int? intFromLocationId { get; set; }
        public int? intToLocationId { get; set; }
        public bool? ysnShipmentRequired { get; set; }
        public int? intStatusId { get; set; }
        public int? intShipViaId { get; set; }
        public int? intFreightUOMId { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intCreatedUserId { get; set; }
        public int? intEntityId { get; set; }
        public int? intSort { get; set; }

        public tblSMCompanyLocation FromLocation { get; set; }
        public tblSMCompanyLocation ToLocation { get; set; }
        public tblICStatus tblICStatus { get; set; }
        public ICollection<tblICInventoryTransferDetail> tblICInventoryTransferDetails { get; set; }
        public vyuICGetInventoryTransfer vyuICGetInventoryTransfer { get; set; }

        private string _fromLocation;
        [NotMapped]
        public string strFromLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_fromLocation))
                    if (vyuICGetInventoryTransfer != null)
                        return vyuICGetInventoryTransfer.strFromLocation;
                    else
                        return null;
                else
                    return _fromLocation;
            }
            set
            {
                _fromLocation = value;
            }
        }

        private string _toLocation;
        [NotMapped]
        public string strToLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_toLocation))
                    if (vyuICGetInventoryTransfer != null)
                        return vyuICGetInventoryTransfer.strToLocation;
                    else
                        return null;
                else
                    return _toLocation;
            }
            set
            {
                _toLocation = value;
            }
        }

        private string _status;
        [NotMapped]
        public string strStatus
        {
            get
            {
                if (string.IsNullOrEmpty(_status))
                    if (vyuICGetInventoryTransfer != null)
                        return vyuICGetInventoryTransfer.strStatus;
                    else
                        return null;
                else
                    return _status;
            }
            set
            {
                _status = value;
            }
        }
    }

    public class vyuICGetInventoryTransfer
    {
        public int intInventoryTransferId { get; set; }
        public string strTransferNo { get; set; }
        public DateTime? dtmTransferDate { get; set; }
        public string strTransferType { get; set; }
        public int? intSourceType { get; set; }
        public string strSourceType { get; set; }
        public int? intTransferredById { get; set; }
        public string strTransferredBy { get; set; }
        public string strDescription { get; set; }
        public int? intFromLocationId { get; set; }
        public string strFromLocation { get; set; }
        public int? intToLocationId { get; set; }
        public string strToLocation { get; set; }
        public bool? ysnShipmentRequired { get; set; }
        public int? intStatusId { get; set; }
        public string strStatus { get; set; }
        public bool? ysnPosted { get; set; }
        public int? strUser { get; set; }
        public string strName { get; set; }
        public int? intSort { get; set; }

        public tblICInventoryTransfer tblICInventoryTransfer { get; set; }
    }

    public class tblICInventoryTransferDetail : BaseEntity
    {
        public int intInventoryTransferDetailId { get; set; }
        public int intInventoryTransferId { get; set; }
        public int? intSourceId { get; set; }
        public int? intItemId { get; set; }
        public int? intLotId { get; set; }
        public int? intFromSubLocationId { get; set; }
        public int? intToSubLocationId { get; set; }
        public int? intFromStorageLocationId { get; set; }
        public int? intToStorageLocationId { get; set; }        
        public decimal? dblQuantity { get; set; }
        public int? intItemUOMId { get; set; }
        public int? intItemWeightUOMId { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public int? intNewLotId { get; set; }
        public string strNewLotId { get; set; }
        public decimal? dblCost { get; set; }
        public int? intTaxCodeId { get; set; }
        public decimal? dblFreightRate { get; set; }
        public decimal? dblFreightAmount { get; set; }
        public int? intOwnershipType { get; set; }
        public int? intSort { get; set; }
        public decimal? dblOriginalAvailableQty { get; set; }
        public decimal? dblOriginalStorageQty { get; set; }
        public bool? ysnWeights { get; set; }
        private string _sourceNo;
        [NotMapped]
        public string strSourceNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_sourceNo))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strSourceNumber;
                    else
                        return null;
                else
                    return _sourceNo;
            }
            set
            {
                _sourceNo = value;
            }
        }
        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strItemNo;
                    else
                        return null;
                else
                    return _itemNo;
            }
            set
            {
                _itemNo = value;
            }
        }
        private string _itemDesc;
        [NotMapped]
        public string strItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_itemDesc))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strItemDescription;
                    else
                        return null;
                else
                    return _itemDesc;
            }
            set
            {
                _itemDesc = value;
            }
        }
        private string _lotNo;
        [NotMapped]
        public string strLotNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_lotNo))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strLotNumber;
                    else
                        return null;
                else
                    return _lotNo;
            }
            set
            {
                _lotNo = value;
            }
        }
        private string _fromSubLocation;
        [NotMapped]
        public string strFromSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_fromSubLocation))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strFromSubLocationName;
                    else
                        return null;
                else
                    return _fromSubLocation;
            }
            set
            {
                _fromSubLocation = value;
            }
        }
        private string _toSubLocation;
        [NotMapped]
        public string strToSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_toSubLocation))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strToSubLocationName;
                    else
                        return null;
                else
                    return _toSubLocation;
            }
            set
            {
                _toSubLocation = value;
            }
        }
        private string _fromStorageLocation;
        [NotMapped]
        public string strFromStorageLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_fromStorageLocation))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strFromStorageLocationName;
                    else
                        return null;
                else
                    return _fromStorageLocation;
            }
            set
            {
                _fromStorageLocation = value;
            }
        }
        private string _toStorageLocation;
        [NotMapped]
        public string strToStorageLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_toStorageLocation))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strToStorageLocationName;
                    else
                        return null;
                else
                    return _toStorageLocation;
            }
            set
            {
                _toStorageLocation = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strUnitMeasure;
                    else
                        return null;
                else
                    return _uom;
            }
            set
            {
                _uom = value;
            }
        }
        private string _weightUOM;
        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weightUOM))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strWeightUOM;
                    else
                        return null;
                else
                    return _weightUOM;
            }
            set
            {
                _weightUOM = value;
            }
        }
        private string _taxCode;
        [NotMapped]
        public string strTaxCode
        {
            get
            {
                if (string.IsNullOrEmpty(_taxCode))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strTaxCode;
                    else
                        return null;
                else
                    return _taxCode;
            }
            set
            {
                _taxCode = value;
            }
        }

        private decimal _availQty;
        [NotMapped]
        public decimal dblAvailableQty
        {
            get
            {
                if (vyuICGetInventoryTransferDetail != null)
                    return vyuICGetInventoryTransferDetail.dblAvailableQty ?? 0;
                else
                    return _availQty;
            }
            set
            {
                _availQty = value;
            }
        }
        private string _availableUOM;
        [NotMapped]
        public string strAvailableUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_availableUOM))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strAvailableUOM;
                    else
                        return null;
                else
                    return _availableUOM;
            }
            set
            {
                _availableUOM = value;
            }
        }
        private string _ownershipType;
        [NotMapped]
        public string strOwnershipType
        {
            get
            {
                if (string.IsNullOrEmpty(_ownershipType))
                    if (vyuICGetInventoryTransferDetail != null)
                        return vyuICGetInventoryTransferDetail.strOwnershipType;
                    else
                        return null;
                else
                    return _ownershipType;
            }
            set
            {
                _ownershipType = value;
            }
        }

        public vyuICGetInventoryTransferDetail vyuICGetInventoryTransferDetail { get; set; }
        public tblICInventoryTransfer tblICInventoryTransfer { get; set; }
    }

    public class vyuICGetInventoryTransferDetail
    {
        public int intInventoryTransferId { get; set; }
        public int intInventoryTransferDetailId { get; set; }
        public int? intFromLocationId { get; set; }
        public int? intToLocationId { get; set; }
        public string strTransferNo { get; set; }
        public int? intSourceId { get; set; }
        public string strSourceNumber { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public string strLotNumber { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
        public int? intFromSubLocationId { get; set; }
        public string strFromSubLocationName { get; set; }
        public int? intToSubLocationId { get; set; }
        public string strToSubLocationName { get; set; }
        public int? intFromStorageLocationId { get; set; }
        public string strFromStorageLocationName { get; set; }
        public int? intToStorageLocationId { get; set; }
        public string strToStorageLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public decimal? dblItemUOMCF { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightUOMCF { get; set; }
        public string strTaxCode { get; set; }
        public string strAvailableUOM { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblOnHand { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblReservedQty { get; set; }
        public decimal? dblAvailableQty { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intOwnershipType { get; set; }
        public string strOwnershipType { get; set; }
        public bool? ysnPosted { get; set; }
        public bool? ysnWeights { get; set; }

        public tblICInventoryTransferDetail tblICInventoryTransferDetail { get; set; }
    }
}
