﻿using System;
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
        public int intParentCatalogId { get; set; }
        public int strCatalogName { get; set; }
        public int strDescription { get; set; }
        public int intSort { get; set; }
    }
}
