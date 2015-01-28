﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemStock : BaseEntity
    {
        public int intItemStockId { get; set; }
        public int intItemId { get; set; }
        public int? intLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblLastCountRetail { get; set; }
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
