using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICManufacturingCell : BaseEntity
    {
        public int intManufacturingCellId { get; set; }
        public string strCellName { get; set; }
        public string strDescription { get; set; }
        public int? intLocationId { get; set; }
        public string strStatus { get; set; }
        public decimal? dblStdCapacity { get; set; }
        public int? intStdUnitMeasureId { get; set; }
        public int? intStdCapacityRateId { get; set; }
        public decimal? dblStdLineEfficiency { get; set; }
        public bool ysnIncludeSchedule { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblSMCompanyLocation != null)
                        return tblSMCompanyLocation.strLocationName;
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
        private string _capUOM;
        [NotMapped]
        public string strCapacityUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_capUOM))
                    if (CapacityUnitMeasure != null)
                        return CapacityUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _capUOM;
            }
            set
            {
                _capUOM = value;
            }
        }
        private string _capRateUOM;
        [NotMapped]
        public string strCapacityRateUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_capRateUOM))
                    if (CapacityRateUnitMeasure != null)
                        return CapacityRateUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _capRateUOM;
            }
            set
            {
                _capRateUOM = value;
            }
        }

        public ICollection<tblICManufacturingCellPackType> tblICManufacturingCellPackTypes { get; set; }

        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public tblICUnitMeasure CapacityUnitMeasure { get; set; }
        public tblICUnitMeasure CapacityRateUnitMeasure { get; set; }
    }

    public class tblICManufacturingCellPackType : BaseEntity
    {
        public int intManufacturingCellPackTypeId { get; set; }
        public int intManufacturingCellId { get; set; }
        public int? intPackTypeId { get; set; }
        public decimal? dblLineCapacity { get; set; }
        public int? intLineCapacityUnitMeasureId { get; set; }
        public int? intLineCapacityRateUnitMeasureId { get; set; }
        public decimal? dblLineEfficiencyRate { get; set; }
        public int intSort { get; set; }

        private string _pack;
        [NotMapped]
        public string strPackName
        {
            get
            {
                if (string.IsNullOrEmpty(_pack))
                    if (tblICPackType != null)
                        return tblICPackType.strPackName;
                    else
                        return null;
                else
                    return _pack;
            }
            set
            {
                _pack = value;
            }
        }
        private string _packdescription;
        [NotMapped]
        public string strDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_packdescription))
                    if (tblICPackType != null)
                        return tblICPackType.strDescription;
                    else
                        return null;
                else
                    return _packdescription;
            }
            set
            {
                _packdescription = value;
            }
        }
        private string _capUOM;
        [NotMapped]
        public string strCapacityUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_capUOM))
                    if (CapacityUnitMeasure != null)
                        return CapacityUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _capUOM;
            }
            set
            {
                _capUOM = value;
            }
        }
        private string _capRateUOM;
        [NotMapped]
        public string strCapacityRateUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_capRateUOM))
                    if (CapacityRateUnitMeasure != null)
                        return CapacityRateUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _capRateUOM;
            }
            set
            {
                _capRateUOM = value;
            }
        }

        public tblICManufacturingCell tblICManufacturingCell { get; set; }
        public tblICUnitMeasure CapacityUnitMeasure { get; set; }
        public tblICUnitMeasure CapacityRateUnitMeasure { get; set; }
        public tblICPackType tblICPackType { get; set; }
        
    }
}
