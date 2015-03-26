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
    public class tblICInventoryAdjustment : BaseEntity
    {
        public tblICInventoryAdjustment()
        {
            this.tblICInventoryAdjustmentDetails = new List<tblICInventoryAdjustmentDetail>();
            this.tblICInventoryAdjustmentNotes = new List<tblICInventoryAdjustmentNote>();
        }

        public int intInventoryAdjustmentId { get; set; }
        public int? intLocationId { get; set; }
        public DateTime? dtmAdjustmentDate { get; set; }
        public int? intAdjustmentType { get; set; }
        public string strAdjustmentNo { get; set; }
        public string strDescription { get; set; }
        public int? intSort { get; set; }
      
        [NotMapped]
        public string strAdjustmentType
        {
            get
            {
                switch (intAdjustmentType)
                {
                    case 1:
                        return "Quantity Change";
                    case 2:
                        return "UOM Change";
                    case 3:
                        return "Item Change";
                    case 4:
                        return "Lot Status Change";
                    case 5:
                        return "Lot Id Change";
                    case 6:
                        return "Expiry Date Change";
                    default :
                        return "";
                }
            }
        }

        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public ICollection<tblICInventoryAdjustmentDetail> tblICInventoryAdjustmentDetails { get; set; }
        public ICollection<tblICInventoryAdjustmentNote> tblICInventoryAdjustmentNotes { get; set; }
    }

    public class AdjustmentVM : BaseEntity
    {
        [Key]
        public int intInventoryAdjustmentId { get; set; }
        public int? intLocationId { get; set; }
        public DateTime? dtmAdjustmentDate { get; set; }
        public int? intAdjustmentType { get; set; }
        public string strAdjustmentNo { get; set; }
        public string strDescription { get; set; }
        public int? intSort { get; set; }
        public string strLocationName { get; set; }
        public string strAdjustmentType { get; set; }
    }

    public class tblICInventoryAdjustmentDetail : BaseEntity
    {
        public int intInventoryAdjustmentDetailId { get; set; }
        public int intInventoryAdjustmentId { get; set; }
        public int? intItemId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }
        public int? intLotId { get; set; }
        public int? intNewLotId { get; set; }
        public decimal? dblNewQuantity { get; set; }
        public int? intNewItemUOMId { get; set; }
        public int? intNewItemId { get; set; }
        public decimal? dblNewPhysicalCount { get; set; }
        public DateTime? dtmNewExpiryDate { get; set; }
        public int? intNewLotStatusId { get; set; }
        public int? intAccountCategoryId { get; set; }
        public int? intCreditAccountId { get; set; }
        public int? intDebitAccountId { get; set; }
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
        private string _newItemNo;
        [NotMapped]
        public string strNewItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_newItemNo))
                    if (NewItem != null)
                        return NewItem.strItemNo;
                    else
                        return null;
                else
                    return _newItemNo;
            }
            set
            {
                _newItemNo = value;
            }
        }
        private string _newItemDesc;
        [NotMapped]
        public string strNewItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_newItemDesc))
                    if (NewItem != null)
                        return NewItem.strDescription;
                    else
                        return null;
                else
                    return _newItemDesc;
            }
            set
            {
                _newItemDesc = value;
            }
        }
        private string _subLocation;
        [NotMapped]
        public string strSubLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocation))
                    if (tblSMCompanyLocationSubLocation != null)
                        return tblSMCompanyLocationSubLocation.strSubLocationName;
                    else
                        return null;
                else
                    return _subLocation;
            }
            set
            {
                _subLocation = value;
            }
        }
        private string _storageLocation;
        [NotMapped]
        public string strStorageLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_storageLocation))
                    if (tblICStorageLocation != null)
                        return tblICStorageLocation.strName;
                    else
                        return null;
                else
                    return _storageLocation;
            }
            set
            {
                _storageLocation = value;
            }
        }
        private string _lotNumber;
        [NotMapped]
        public string strLotNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_lotNumber))
                    if (tblICLot != null)
                        return tblICLot.strLotNumber;
                    else
                        return null;
                else
                    return _lotNumber;
            }
            set
            {
                _lotNumber = value;
            }
        }
        private decimal? _lotQty;
        [NotMapped]
        public decimal? dblLotQty
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblQty;
                else
                    return null;
            }
            set
            {
                _lotQty = value;
            }
        }
        private decimal? _lotUnitCost;
        [NotMapped]
        public decimal? dblLotUnitCost
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblLastCost;
                else
                    return null;
            }
            set
            {
                _lotUnitCost = value;
            }
        }
        private decimal? _lotWeightPerUnit;
        [NotMapped]
        public decimal? dblLotWeightPerUnit
        {
            get
            {
                if (tblICLot != null)
                    return tblICLot.dblWeightPerQty;
                else
                    return null;
            }
            set
            {
                _lotWeightPerUnit = value;
            }
        }
        private string _newLotNumber;
        [NotMapped]
        public string strNewLotNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_newLotNumber))
                    if (NewLot != null)
                        return NewLot.strLotNumber;
                    else
                        return null;
                else
                    return _newLotNumber;
            }
            set
            {
                _newLotNumber = value;
            }
        }
        private string _newItemUOM;
        [NotMapped]
        public string strNewItemUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_newItemUOM))
                    if (tblICItemUOM != null)
                        return tblICItemUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _newItemUOM;
            }
            set
            {
                _newItemUOM = value;
            }
        }
        private string _newLotStatus;
        [NotMapped]
        public string strNewLotStatus
        {
            get
            {
                if (string.IsNullOrEmpty(_newLotStatus))
                    if (tblICLotStatus != null)
                        return tblICLotStatus.strPrimaryStatus;
                    else
                        return null;
                else
                    return _newLotStatus;
            }
            set
            {
                _newLotStatus = value;
            }
        }
        private string _accountCategory;
        [NotMapped]
        public string strAccountCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_accountCategory))
                    if (tblGLAccountCategory != null)
                        return tblGLAccountCategory.strAccountCategory;
                    else
                        return null;
                else
                    return _accountCategory;
            }
            set
            {
                _accountCategory = value;
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
        private string _debitAccountDesc;
        [NotMapped]
        public string strDebitAccountDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_debitAccountDesc))
                    if (DebitAccount != null)
                        return DebitAccount.strDescription;
                    else
                        return null;
                else
                    return _debitAccountDesc;
            }
            set
            {
                _debitAccountDesc = value;
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
        private string _creditAccountDesc;
        [NotMapped]
        public string strCreditAccountDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_creditAccountDesc))
                    if (CreditAccount != null)
                        return CreditAccount.strDescription;
                    else
                        return null;
                else
                    return _creditAccountDesc;
            }
            set
            {
                _creditAccountDesc = value;
            }
        }
        

        public tblICInventoryAdjustment tblICInventoryAdjustment { get; set; }
        public tblICItem tblICItem { get; set; }
        public tblICItem NewItem { get; set; }
        public tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation { get; set; }
        public tblICStorageLocation tblICStorageLocation { get; set; }
        public tblICLot tblICLot { get; set; }
        public tblICLot NewLot { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
        public tblICLotStatus tblICLotStatus { get; set; }
        public tblGLAccountCategory tblGLAccountCategory { get; set; }
        public tblGLAccount DebitAccount { get; set; }
        public tblGLAccount CreditAccount { get; set; }
    }

    public class tblICInventoryAdjustmentNote : BaseEntity
    {
        public int intInventoryAdjustmentNoteId { get; set; }
        public int intInventoryAdjustmentId { get; set; }
        public string strDescription { get; set; }
        public string strNotes { get; set; }
        public int? intSort { get; set; }

        public tblICInventoryAdjustment tblICInventoryAdjustment { get; set; }
    }
}
