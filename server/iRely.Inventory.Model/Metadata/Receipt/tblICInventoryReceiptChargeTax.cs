﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryReceiptChargeTax : BaseEntity
    {
        public int intInventoryReceiptChargeTaxId { get; set; }
        public int intInventoryReceiptChargeId { get; set; }
        public int? intTaxGroupId { get; set; }
        public int? intTaxCodeId { get; set; }
        public int? intTaxClassId { get; set; }
        public string strTaxableByOtherTaxes { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? dblRate { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblAdjustedTax { get; set; }
        public int? intTaxAccountId { get; set; }
        public bool? ysnTaxAdjusted { get; set; }
        public bool? ysnTaxOnly { get; set; }
        public bool? ysnCheckoffTax { get; set; }
        public string strTaxCode { get; set; }
        public int? intSort { get; set; }

        public tblICInventoryReceiptCharge tblICInventoryReceiptCharge { get; set; }
    }
}
