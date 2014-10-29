using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICPackType : BaseEntity
    {
        public int intPackTypeId { get; set; }
        public string strPackName { get; set; }
        public string strDescription { get; set; }

        public ICollection<tblICPackTypeDetail> tblICPackTypeDetails { get; set; }
    }

    public class tblICPackTypeDetail : BaseEntity
    {
        public int intPackTypeDetailId { get; set; }
        public int intPackTypeId { get; set; }
        public int intSourceUnitMeasureId { get; set; }
        public int intTargetUnitMeasureId { get; set; }
        public decimal? dblConversionFactor { get; set; }
        public int intSort { get; set; }

        private string _sourceunitmeasure;
        [NotMapped]
        public string strSourceUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_sourceunitmeasure))
                    if (SourceUnitMeasure != null)
                        return SourceUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _sourceunitmeasure;
            }
            set
            {
                _sourceunitmeasure = value;
            }
        }
        private string _targetunitmeasure;
        [NotMapped]
        public string strTargetUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_targetunitmeasure))
                    if (TargetUnitMeasure != null)
                        return TargetUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _targetunitmeasure;
            }
            set
            {
                _targetunitmeasure = value;
            }
        }

        public tblICPackType tblICPackType { get; set; }
        public tblICUnitMeasure SourceUnitMeasure { get; set; }
        public tblICUnitMeasure TargetUnitMeasure { get; set; }
    }
}
