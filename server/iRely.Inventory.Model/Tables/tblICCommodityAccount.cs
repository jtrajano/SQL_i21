﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCommodityAccount : BaseEntity
    {
        public int intCommodityAccountId { get; set; }
        public int intCommodityId { get; set; }
        public int? intLocationId { get; set; }
        public string strAccountDescription { get; set; }
        public int? intAccountId { get; set; }
        public int intSort { get; set; }

        public tblICCommodity tblICCommodity { get; set; }
        public tblGLAccount tblGLAccount { get; set; }
    }
}
