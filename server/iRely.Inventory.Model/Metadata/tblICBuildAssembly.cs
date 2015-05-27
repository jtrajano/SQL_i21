using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICBuildAssembly : BaseEntity
    {
        public tblICBuildAssembly()
        {
            this.tblICBuildAssemblyDetails = new List<tblICBuildAssemblyDetail>();
        }

        public int intBuildAssemblyId { get; set; }
        public DateTime? dtmBuildDate { get; set; }
        public int? intItemId { get; set; }
        public string strBuildNo { get; set; }
        public int? intLocationId { get; set; }
        public decimal? dblBuildQuantity { get; set; }
        public decimal? dblCost { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intItemUOMId { get; set; }
        public string strDescription { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intEntityId { get; set; }
        public int? intCreatedUserId { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICBuildAssemblyDetail> tblICBuildAssemblyDetails { get; set; }

        public tblICItem tblICItem { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }

    }

    public class tblICBuildAssemblyDetail : BaseEntity
    {
        public int intBuildAssemblyDetailId { get; set; }
        public int intBuildAssemblyId { get; set; }
        public int? intItemId { get; set; }
        public int? intSubLocationId { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUOMId { get; set; }
        public decimal? dblCost { get; set; }
        public int? intSort { get; set; }

        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (tblICItem != null)
                        return tblICItem.strItemNo;
                    else
                        return null;
                else
                    return _itemNo;
            }
            set
            {
                _itemNo = value;
            }
        }
        private string _itemDesc;
        [NotMapped]
        public string strItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_itemDesc))
                    if (tblICItem != null)
                        return tblICItem.strDescription;
                    else
                        return null;
                else
                    return _itemDesc;
            }
            set
            {
                _itemDesc = value;
            }
        }
        private string _subLocationName;
        [NotMapped]
        public string strSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocationName))
                    if (tblSMCompanyLocationSubLocation != null)
                        return tblSMCompanyLocationSubLocation.strSubLocationName;
                    else
                        return null;
                else
                    return _subLocationName;
            }
            set
            {
                _subLocationName = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (tblICItemUOM != null)
                        return tblICItemUOM.strUnitMeasure;
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

        public tblICBuildAssembly tblICBuildAssembly { get; set; }

        public tblICItem tblICItem { get; set; }
        public tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
    }

    public class BuildAssemblyVM
    {
        public int intBuildAssemblyId { get; set; }
        public DateTime? dtmBuildDate { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strBuildNo { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public string strDescription { get; set; }
        
    }

}
