using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class vyuICGetCustomerCurrency
    {
        public int intEntityId { get; set; }
        public string strCustomerNumber { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public string strDescription { get; set; }
        public bool? ysnSubCurrency { get; set; }
        public int? intMainCurrencyId { get; set; }
        public int? intCent { get; set; }
        public int? intDefaultCurrencyId { get; set; }
        public string strDefaultCurrency { get; set; }

    }
}
