using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetOtherCharges
    {
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strDescription { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public bool? ysnAccrue { get; set; }
        public bool? ysnMTM { get; set; }
        public int? intM2MComputationId { get; set; }
        public string strM2MComputation { get; set; }
        public bool? ysnPrice { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblAmount { get; set; }
        public int? intCostUOMId { get; set; }
        public string strCostUOM { get; set; }
        public string strUnitType { get; set; }
        public string strCostType { get; set; }
        public int? intOnCostTypeId { get; set; }
        public string strOnCostType { get; set; }
        public bool? ysnBasisContract { get; set; }
    }
}
