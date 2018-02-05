using iRely.Common;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipmentCharge : BaseEntity
    {
        public tblICInventoryShipmentCharge()
        {
            this.tblICInventoryShipmentChargeTaxes = new List<tblICInventoryShipmentChargeTax>();
        }
        public int intInventoryShipmentChargeId { get; set; }
        public int intInventoryShipmentId { get; set; }
        public int? intContractId { get; set; }
        public int? intContractDetailId { get; set; }
        public int? intChargeId { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public int? intCostUOMId { get; set; }
        public int? intCurrencyId { get; set; }
        public decimal? dblAmount { get; set; }
        public decimal? dblAmountBilled { get; set; }
        public decimal? dblAmountPaid { get; set; }
        public decimal? dblAmountPriced { get; set; }
        public string strAllocatePriceBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public bool? ysnPrice { get; set; }
        public int? intSort { get; set; }
        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblQuantityBilled { get; set; }
        public decimal? dblQuantityPriced { get; set; }
        public int? intTaxGroupId { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblAdjustedTax { get; set; }
        public string strChargesLink { get; set; }
        private string _contractNo;
        [NotMapped]
        public string strContractNumber
        {
            get
            {
                if (vyuICGetInventoryShipmentCharge != null)
                    return vyuICGetInventoryShipmentCharge.strContractNumber;
                else
                    return null;
            }
            set
            {
                _contractNo = value;
            }
        }
        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strItemNo;
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
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strItemDescription;
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
        private string _uom;
        [NotMapped]
        public string strCostUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strCostUOM;
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
        private string _uomType;
        [NotMapped]
        public string strUnitType
        {
            get
            {
                if (string.IsNullOrEmpty(_uomType))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strUnitType;
                    else
                        return null;
                else
                    return _uomType;
            }
            set
            {
                _uomType = value;
            }
        }
        private string _onCostType;
        [NotMapped]
        public string strOnCostType
        {
            get
            {
                if (string.IsNullOrEmpty(_onCostType))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strOnCostType;
                    else
                        return null;
                else
                    return _onCostType;
            }
            set
            {
                _onCostType = value;
            }
        }
        private string _vendorId;
        [NotMapped]
        public string strVendorId
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorId))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strVendorId;
                    else
                        return null;
                else
                    return _vendorId;
            }
            set
            {
                _vendorId = value;
            }
        }
        private string _currency;
        [NotMapped]
        public string strCurrency
        {
            get
            {
                if (string.IsNullOrEmpty(_currency))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strCurrency;
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
        private string _vendorName;
        [NotMapped]
        public string strVendorName
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorName))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strVendorName;
                    else
                        return null;
                else
                    return _vendorName;
            }
            set
            {
                _vendorName = value;
            }
        }

        private string _forexRateType;
        [NotMapped]
        public string strForexRateType
        {
            get
            {
                if (string.IsNullOrEmpty(_forexRateType))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strForexRateType;
                    else
                        return null;
                else
                    return _forexRateType;
            }
            set
            {
                _forexRateType = value;
            }
        }

        private string _chargeTaxGroup;
        [NotMapped]
        public string strTaxGroup
        {
            get
            {
                if (string.IsNullOrEmpty(_chargeTaxGroup))
                    if (vyuICGetInventoryShipmentCharge != null)
                        return vyuICGetInventoryShipmentCharge.strTaxGroup;
                    else
                        return null;
                else
                    return _chargeTaxGroup;
            }
            set
            {
                _chargeTaxGroup = value;
            }
        }

        public tblICInventoryShipment tblICInventoryShipment { get; set; }
        public vyuICGetInventoryShipmentCharge vyuICGetInventoryShipmentCharge { get; set; }
        public ICollection<tblICInventoryShipmentChargeTax> tblICInventoryShipmentChargeTaxes { get; set; }
    }
}
