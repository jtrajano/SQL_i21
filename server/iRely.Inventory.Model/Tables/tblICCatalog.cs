using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCatalog : BaseEntity
    {
        public int intCatalogId { get; set; }
        public int? intParentCatalogId { get; set; }
        public string strCatalogName { get; set; }
        public string strDescription { get; set; }
        public bool ysnLeaf { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICCategory> tblICCategories { get; set; }

        public tblICCatalog ParentCatalog { get; set; }
        public ICollection<tblICCatalog> children { get; set; }
    }
}
