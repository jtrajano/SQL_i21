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
    }
}
