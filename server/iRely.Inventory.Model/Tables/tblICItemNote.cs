using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemNote : BaseEntity
    {
        public int intItemNoteId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public string strCommentType { get; set; }
        public string strComments { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
