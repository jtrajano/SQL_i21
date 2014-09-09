﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICRinFuelType : BaseEntity
    {
        public int intRinFuelTypeId { get; set; }
        public int strRinFuelTypeCode { get; set; }
        public int strDescription { get; set; }
        public double dblEquivalenceValue { get; set; }
        public int intSort { get; set; }
    }
}
