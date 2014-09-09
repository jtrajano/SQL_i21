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
        public int intRinFuelTypeId { get; set; }
        public int intRinFeedStockId { get; set; }
        public int intBatchNumber { get; set; }
        public int intEndingRinGallons { get; set; }
        public int intEquivalenceValue { get; set; }
        public int intRinFuelId { get; set; }
        public int intRinProcessId { get; set; }
        public int intRinFeedStockUOMId { get; set; }
        public double dblFeedStockFactor { get; set; }
        public bool ysnRenewableBiomass { get; set; }
        public double dblPercentDenaturant { get; set; }
        public bool ysnDeductDenaturant { get; set; }
    }
}
