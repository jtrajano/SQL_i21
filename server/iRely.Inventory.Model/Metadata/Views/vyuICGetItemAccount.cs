using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemAccount
    {
        public int intAccountKey { get; set; }
        public int intKey { get; set; }
        public int intItemAccountId { get; set; }
        public int? intItemId { get; set; }
        public int? intAccountId { get; set; }
        public string strAccountId { get; set; }
        public int? intAccountGroupId { get; set; }
        public int? intAccountCategoryId { get; set; }
        public string strAccountGroup { get; set; }
        public string strAccountType { get; set; }
        public string strAccountCategory { get; set; }
        public int? intSort { get; set; }
        public string strAccountDescription { get; set; }

        public vyuICGetItemStock vyuICGetItemStock { get; set; }
    }
}
