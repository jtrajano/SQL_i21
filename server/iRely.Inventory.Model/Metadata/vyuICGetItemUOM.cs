using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemUOM
    {
        public int intItemUOMId { get; set; }
        public int intItemId { get; set; }
        public int intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblWeight { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public string strUpcCode { get; set; }
        public string strLongUPCCode { get; set; }
        public bool? ysnStockUnit { get; set; }
        public bool? ysnAllowPurchase { get; set; }
        public bool? ysnAllowSale { get; set; }
        public decimal? dblLength { get; set; }
        public decimal? dblWidth { get; set; }
        public decimal? dblHeight { get; set; }
        public int? intDimensionUOMId { get; set; }
        public string strDimensionUOM { get; set; }
        public decimal? dblVolume { get; set; }
        public int? intVolumeUOMId { get; set; }
        public string strVolumeUOM { get; set; }
        public decimal? dblMaxQty { get; set; }
    }
}
