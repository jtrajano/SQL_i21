using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemPOSMap : EntityTypeConfiguration<tblICItemPOS>
    {
        public tblICItemPOSMap()
        {
            
        }
    }

    public class tblICItemPOSCategoryMap : EntityTypeConfiguration<tblICItemPOSCategory>
    {
        public tblICItemPOSCategoryMap()
        {

        }
    }

    public class tblICItemPOSSLAMap : EntityTypeConfiguration<tblICItemPOSSLA>
    {
        public tblICItemPOSSLAMap()
        {

        }
    }
}
