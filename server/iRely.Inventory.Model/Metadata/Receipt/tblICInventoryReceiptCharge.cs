using iRely.Common;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryReceiptCharge : BaseEntity
    {
        public tblICInventoryReceiptCharge()
        {
            this.tblICInventoryReceiptChargeTaxes = new List<tblICInventoryReceiptChargeTax>();
        }
        public int intInventoryReceiptChargeId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intContractId { get; set; }
        public int? intContractDetailId { get; set; }
        public int? intChargeId { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public int? intCostUOMId { get; set; }
        public decimal? dblAmount { get; set; }
        public string strAllocateCostBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public bool? ysnPrice { get; set; }
        public string strChargeEntity { get; set; }
        public decimal? dblAmountBilled { get; set; }
        public decimal? dblAmountPaid { get; set; }
        public decimal? dblAmountPriced { get; set; }
        public int? intSort { get; set; }
        public int? intCurrencyId { get; set; }
        //     public decimal? dblExchangeRate { get; set; }
        //     public int? intCent { get; set; }
        public bool? ysnSubCurrency { get; set; }
        public decimal? dblTax { get; set; }
        public int? intTaxGroupId { get; set; }

        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }
        public decimal? dblQuantity { get; set; }
        public string strChargesLink { get; set; }

        //private string _contractNo;
        //[NotMapped]
        //public string strContractNumber
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_contractNo))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strContractNumber;
        //            else
        //                return null;
        //        else
        //            return _contractNo;
        //    }
        //    set
        //    {
        //        _contractNo = value;
        //    }
        //}
        //private string _itemNo;
        //[NotMapped]
        //public string strItemNo
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_itemNo))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strItemNo;
        //            else
        //                return null;
        //        else
        //            return _itemNo;
        //    }
        //    set
        //    {
        //        _itemNo = value;
        //    }
        //}
        //private string _itemDesc;
        //[NotMapped]
        //public string strItemDescription
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_itemDesc))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strItemDescription;
        //            else
        //                return null;
        //        else
        //            return _itemDesc;
        //    }
        //    set
        //    {
        //        _itemDesc = value;
        //    }
        //}
        //private string _uom;
        //[NotMapped]
        //public string strCostUOM
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_uom))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strCostUOM;
        //            else
        //                return null;
        //        else
        //            return _uom;
        //    }
        //    set
        //    {
        //        _uom = value;
        //    }
        //}
        //private string _uomType;
        //[NotMapped]
        //public string strUnitType
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_uomType))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strUnitType;
        //            else
        //                return null;
        //        else
        //            return _uomType;
        //    }
        //    set
        //    {
        //        _uomType = value;
        //    }
        //}
        //private string _onCostType;
        //[NotMapped]
        //public string strOnCostType
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_onCostType))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strOnCostType;
        //            else
        //                return null;
        //        else
        //            return _onCostType;
        //    }
        //    set
        //    {
        //        _onCostType = value;
        //    }
        //}
        //private string _vendorId;
        //[NotMapped]
        //public string strVendorId
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_vendorId))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strVendorId;
        //            else
        //                return null;
        //        else
        //            return _vendorId;
        //    }
        //    set
        //    {
        //        _vendorId = value;
        //    }
        //}
        //private string _vendorName;
        //[NotMapped]
        //public string strVendorName
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_vendorName))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strVendorName;
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

        //private string _currency;
        //[NotMapped]
        //public string strCurrency
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_currency))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strCurrency;
        //            else
        //                return null;
        //        else
        //            return _currency;
        //    }
        //    set
        //    {
        //        _currency = value;
        //    }
        //}

        //private string _chargeTaxGroup;
        //[NotMapped]
        //public string strTaxGroup
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_chargeTaxGroup))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strTaxGroup;
        //            else
        //                return null;
        //        else
        //            return _chargeTaxGroup;
        //    }
        //    set
        //    {
        //        _chargeTaxGroup = value;
        //    }
        //}

        //private string _forexRateType;
        //[NotMapped]
        //public string strForexRateType
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_forexRateType))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strForexRateType;
        //            else
        //                return null;
        //        else
        //            return _forexRateType;
        //    }
        //    set
        //    {
        //        _forexRateType = value;
        //    }
        //}

        //private string _costType;
        //[NotMapped]
        //public string strCostType
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_costType))
        //            if (vyuICGetInventoryReceiptCharge != null)
        //                return vyuICGetInventoryReceiptCharge.strCostType;
        //            else
        //                return null;
        //        else
        //            return _costType;
        //    }
        //    set
        //    {
        //        _costType = value;
        //    }
        //}

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        //public vyuICGetInventoryReceiptCharge vyuICGetInventoryReceiptCharge { get; set; }
        public ICollection<tblICInventoryReceiptChargeTax> tblICInventoryReceiptChargeTaxes { get; set; }
    }

}
