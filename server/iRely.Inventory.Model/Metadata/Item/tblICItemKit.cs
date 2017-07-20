using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemKit : BaseEntity
    {
        public tblICItemKit()
        {
            this.tblICItemKitDetails = new List<tblICItemKitDetail>();
        }
        public int intItemKitId { get; set; }
        public int intItemId { get; set; }
        public string strComponent { get; set; }
        public string strInputType { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
        public ICollection<tblICItemKitDetail> tblICItemKitDetails { get; set; }
    }
}