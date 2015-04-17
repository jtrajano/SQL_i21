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
            this.tblICInventoryTransferNotes = new List<tblICInventoryTransferNote>();
        }

        public int intInventoryTransferId { get; set; }
        public string strTransferNo { get; set; }
        public DateTime? dtmTransferDate { get; set; }
        public string strTransferType { get; set; }
        public int? intTransferredById { get; set; }
        public string strDescription { get; set; }
        public int? intFromLocationId { get; set; }
        public int? intToLocationId { get; set; }
        public bool? ysnShipmentRequired { get; set; }
        public int? intCarrierId { get; set; }
        public int? intFreightUOMId { get; set; }
        public int? intAccountCategoryId { get; set; }
        public int? intAccountId { get; set; }
        public int? intSort { get; set; }

        private string _accountDesc;
        [NotMapped]
        public string strAccountDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_accountDesc))
                    if (tblGLAccount != null)
                        return tblGLAccount.strDescription;
                    else
                        return null;
                else
                    return _accountDesc;
            }
            set
            {
                _accountDesc = value;
            }
        }

        public tblSMCompanyLocation FromLocation { get; set; }
        public tblSMCompanyLocation ToLocation { get; set; }
        public tblGLAccount tblGLAccount { get; set; }
        public ICollection<tblICInventoryTransferDetail> tblICInventoryTransferDetails { get; set; }
        public ICollection<tblICInventoryTransferNote> tblICInventoryTransferNotes { get; set; }
    }

    public class tblICInventoryTransferDetail : BaseEntity
    {
        public int intInventoryTransferDetailId { get; set; }
        public int intInventoryTransferId { get; set; }
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
        public decimal? dblNetWeight { get; set; }
        public int? intNewLotId { get; set; }
        public string strNewLotId { get; set; }
        public decimal? dblCost { get; set; }
        public int? intCreditAccountId { get; set; }
        public int? intDebitAccountId { get; set; }
        public int? intTaxCodeId { get; set; }
        public decimal? dblFreightRate { get; set; }
        public decimal? dblFreightAmount { get; set; }
        public int? intSort { get; set; }

        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (tblICItem != null)
                        return tblICItem.strItemNo;
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
                    if (tblICItem != null)
                        return tblICItem.strDescription;
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
                    if (tblICLot != null)
                        return tblICLot.strLotNumber;
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
        private string _newLotNo;
        [NotMapped]
        public string strNewLotNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_newLotNo))
                    if (NewLot != null)
                        return NewLot.strLotNumber;
                    else
                        return null;
                else
                    return _newLotNo;
            }
            set
            {
                _newLotNo = value;
            }
        }
        private string _fromSubLocation;
        [NotMapped]
        public string strFromSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_fromSubLocation))
                    if (FromSubLocation != null)
                        return FromSubLocation.strSubLocationName;
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
                    if (ToSubLocation != null)
                        return ToSubLocation.strSubLocationName;
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
                    if (FromStorageLocation != null)
                        return FromStorageLocation.strName;
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
                    if (ToStorageLocation != null)
                        return ToStorageLocation.strName;
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
                    if (tblICItemUOM != null)
                        return tblICItemUOM.strUnitMeasure;
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
                    if (WeightUOM != null)
                        return WeightUOM.strUnitMeasure;
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
        private string _creditAccount;
        [NotMapped]
        public string strCreditAccountId
        {
            get
            {
                if (string.IsNullOrEmpty(_creditAccount))
                    if (CreditAccount != null)
                        return CreditAccount.strAccountId;
                    else
                        return null;
                else
                    return _creditAccount;
            }
            set
            {
                _creditAccount = value;
            }
        }
        private string _creditAccountDescription;
        [NotMapped]
        public string strCreditAccountDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_creditAccountDescription))
                    if (CreditAccount != null)
                        return CreditAccount.strDescription;
                    else
                        return null;
                else
                    return _creditAccountDescription;
            }
            set
            {
                _creditAccountDescription = value;
            }
        }
        private string _debitAccount;
        [NotMapped]
        public string strDebitAccountId
        {
            get
            {
                if (string.IsNullOrEmpty(_debitAccount))
                    if (DebitAccount != null)
                        return DebitAccount.strAccountId;
                    else
                        return null;
                else
                    return _debitAccount;
            }
            set
            {
                _debitAccount = value;
            }
        }
        private string _debitAccountDescription;
        [NotMapped]
        public string strDebitAccountDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_debitAccountDescription))
                    if (DebitAccount != null)
                        return DebitAccount.strDescription;
                    else
                        return null;
                else
                    return _debitAccountDescription;
            }
            set
            {
                _debitAccountDescription = value;
            }
        }
        private string _taxCode;
        [NotMapped]
        public string strTaxCode
        {
            get
            {
                if (string.IsNullOrEmpty(_taxCode))
                    if (tblSMTaxCode != null)
                        return tblSMTaxCode.strTaxCode;
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

        public tblICInventoryTransfer tblICInventoryTransfer { get; set; }

        public tblICItem tblICItem { get; set; }
        public tblICLot tblICLot { get; set; }
        public tblICLot NewLot { get; set; }
        public tblSMCompanyLocationSubLocation FromSubLocation { get; set; }
        public tblSMCompanyLocationSubLocation ToSubLocation { get; set; }
        public tblICStorageLocation FromStorageLocation { get; set; }
        public tblICStorageLocation ToStorageLocation { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
        public tblICItemUOM WeightUOM { get; set; }
        public tblGLAccount CreditAccount { get; set; }
        public tblGLAccount DebitAccount { get; set; }
        public tblSMTaxCode tblSMTaxCode { get; set; }
    }

    public class tblICInventoryTransferNote : BaseEntity
    {
        public int intInventoryTransferNoteId { get; set; }
        public int intInventoryTransferId { get; set; }
        public string strNoteType { get; set; }
        public string strNotes { get; set; }
        public int? intSort { get; set; }

        public tblICInventoryTransfer tblICInventoryTransfer { get; set; }
    }

    public class TransferVM
    {
        public int intInventoryTransferId { get; set; }
        public string strTransferNo { get; set; }
        public DateTime? dtmTransferDate { get; set; }
        public string strTransferType { get; set; }
        public string strDescription { get; set; }
        public int? intFromLocationId { get; set; }
        public string strFromLocation { get; set; }
        public int? intToLocationId { get; set; }
        public string strToLocation { get; set; }
        public bool? ysnShipmentRequired { get; set; }
        public int? intSort { get; set; }
    }

}
