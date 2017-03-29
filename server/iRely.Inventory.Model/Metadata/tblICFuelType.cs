using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;
using System.ComponentModel.DataAnnotations.Schema;

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

        private string _fuelCategory;
        [NotMapped]
        public string strFuelCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_fuelCategory))
                    if (RinFuelCategory != null)
                        return RinFuelCategory.strRinFuelCategoryCode;
                    else
                        return null;
                else
                    return _fuelCategory;
            }
            set
            {
                _fuelCategory = value;
            }
        }

        private string _feedStock;
        [NotMapped]
        public string strFeedStock
        {
            get
            {
                if (string.IsNullOrEmpty(_feedStock))
                    if (RinFeedStock != null)
                        return RinFeedStock.strRinFeedStockCode;
                    else
                        return null;
                else
                    return _feedStock;
            }
            set
            {
                _feedStock = value;
            }
        }

        private string _fuelCode;
        [NotMapped]
        public string strFuelCode
        {
            get
            {
                if (string.IsNullOrEmpty(_fuelCode))
                    if (RinFuel != null)
                        return RinFuel.strRinFuelCode;
                    else
                        return null;
                else
                    return _fuelCode;
            }
            set
            {
                _fuelCode = value;
            }
        }

        private string _feedStockUOM;
        [NotMapped]
        public string strFeedStockUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_feedStockUOM))
                    if (RinFeedStockUOM != null)
                        return RinFeedStockUOM.strRinFeedStockUOMCode;
                    else
                        return null;
                else
                    return _feedStockUOM;
            }
            set
            {
                _feedStockUOM = value;
            }
        }

        private string _processCode;
        [NotMapped]
        public string strProcessCode
        {
            get
            {
                if (string.IsNullOrEmpty(_processCode))
                    if (RinProcess != null)
                        return RinProcess.strRinProcessCode;
                    else
                        return null;
                else
                    return _processCode;
            }
            set
            {
                _processCode = value;
            }
        }

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
