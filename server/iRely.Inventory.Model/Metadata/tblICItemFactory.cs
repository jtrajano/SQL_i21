using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemFactory : BaseEntity
    {
        public tblICItemFactory()
        {
            this.tblICItemFactoryManufacturingCells = new List<tblICItemFactoryManufacturingCell>();
        }

        public int intItemFactoryId { get; set; }
        public int intItemId { get; set; }
        public int? intFactoryId { get; set; }
        public bool ysnDefault { get; set; }
        public int? intSort { get; set; }

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

        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public tblICItem tblICItem { get; set; }

        public ICollection<tblICItemFactoryManufacturingCell> tblICItemFactoryManufacturingCells { get; set; }
    }

    public class tblICItemFactoryManufacturingCell : BaseEntity
    {
        public int intItemFactoryManufacturingCellId { get; set; }
        public int intItemFactoryId { get; set; }
        public int? intManufacturingCellId { get; set; }
        public bool ysnDefault { get; set; }
        public int? intPreference { get; set; }
        public int? intSort { get; set; }

        private string _cellName;
        [NotMapped]
        public string strCellName
        {
            get
            {
                if (string.IsNullOrEmpty(_cellName))
                    if (vyuICGetItemFactoryManufacturingCell != null)
                        return vyuICGetItemFactoryManufacturingCell.strCellName;
                    else
                        return null;
                else
                    return _cellName;
            }
            set
            {
                _cellName = value;
            }
        }

        public vyuICGetItemFactoryManufacturingCell vyuICGetItemFactoryManufacturingCell { get; set; }
        public tblICItemFactory tblICItemFactory { get; set; }
    }

    public class vyuICGetItemFactoryManufacturingCell
    {
        public int intItemFactoryManufacturingCellId { get; set; }
        public int intItemFactoryId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intFactoryId { get; set; }
        public string strLocationName { get; set; }
        public int? intManufacturingCellId { get; set; }
        public string strCellName { get; set; }
        public string strManufacturingCellDescription { get; set; }
        public bool? ysnDefault { get; set; }
        public int? intPreference { get; set; }
        public int? intSort { get; set; }

        public tblICItemFactoryManufacturingCell tblICItemFactoryManufacturingCell { get; set; }
    }

    public class ItemFactoryVM
    {
        public int intItemFactoryId { get; set; }
        public int intItemId { get; set; }
        public int? intFactoryId { get; set; }
        public bool ysnDefault { get; set; }
        public int? intSort { get; set; }
        public string strLocationName { get; set; }
    }

    
}
