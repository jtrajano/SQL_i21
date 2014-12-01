using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemKitDetail : BaseEntity
    {
        public int intItemKitDetailId { get; set; }
        public int intItemKitId { get; set; }
        public int? intItemId { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblPrice { get; set; }
        public int ysnSelected { get; set; }
        public int inSort { get; set; }

        private string _item;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_item))
                    if (tblICItem != null)
                        return tblICItem.strItemNo;
                    else
                        return null;
                else
                    return _item;
            }
            set
            {
                _item = value;
            }
        }
        string _description;
        [NotMapped]
        public string strDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_description))
                    if (tblICItem != null)
                        return tblICItem.strDescription;
                    else
                        return null;
                else
                    return _description;
            }
            set
            {
                _description = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _uom;
            }
            set
            {
                _uom = value;
            }
        }

        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public tblICItemKit tblICItemKit { get; set; }
        public tblICItem tblICItem { get; set; }
    }
}
