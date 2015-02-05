using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
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
        public int? intItemLocationId { get; set; }
        public string strCommentType { get; set; }
        public string strComments { get; set; }
        public int? intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblICItemLocation != null)
                        return tblICItemLocation.strLocationName;
                    else
                        return null;
                else
                    return _location;
            }
            set
            {
                _location = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblICItemLocation tblICItemLocation { get; set; }
        
    }
}
