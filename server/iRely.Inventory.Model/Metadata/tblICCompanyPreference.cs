using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCompanyPreference : BaseEntity
    {
        public int intCompanyPreferenceId { get; set; }
        public int? intInheritSetup { get; set; }
        public int? intSort { get; set; }
        public string strLotCondition { get; set; }
        public string strReceiptType { get; set; }
        public int? intReceiptSourceType { get; set; }
        public int? intShipmentOrderType { get; set; }
        public int? intShipmentSourceType { get; set; }
    }
}
