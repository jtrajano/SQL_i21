using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICFuelType : BaseEntity
    {
        public int intFuelTypeId { get; set; }
        public int intRinFuelCategoryId { get; set; }
        public int intRinFeedStockId { get; set; }
        public int intBatchNumber { get; set; }
        public int intEndingRinGallons { get; set; }
        public string strEquivalenceValue { get; set; }
        public int intRinFuelId { get; set; }
        public int intRinProcessId { get; set; }
        public int intRinFeedStockUOMId { get; set; }
        public decimal? dblFeedStockFactor { get; set; }
        public bool ysnRenewableBiomass { get; set; }
        public decimal? dblPercentDenaturant { get; set; }
        public bool ysnDeductDenaturant { get; set; }

        public tblICRinFuelCategory RinFuelCategory { get; set; }
        public tblICRinFeedStock RinFeedStock { get; set; }
        public tblICRinFuel RinFuel { get; set; }
        public tblICRinFeedStockUOM RinFeedStockUOM { get; set; }
        public tblICRinProcess RinProcess { get; set; }
    }

    public class FuelTypeVM
    {
        public int intFuelTypeId { get; set; }
        public string strRinFuelTypeCodeId { get; set; }
        public string strRinFeedStockId { get; set; }
        public string strRinFuelId { get; set; }
        public string strRinProcessId { get; set; }
        public string strRinFeedStockUOMId { get; set; }
    }
}
