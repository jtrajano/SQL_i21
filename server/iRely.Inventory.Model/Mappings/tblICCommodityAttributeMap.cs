using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCommodityAttributeMap : EntityTypeConfiguration<tblICCommodityAttribute>
    {
        public tblICCommodityAttributeMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityAttributeId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityAttribute");
            this.Property(t => t.intCommodityAttributeId).HasColumnName("intCommodityAttributeId");
            //this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            //this.Property(t => t.strType).HasColumnName("strType");
        }
    }

    public class tblICCommodityClassVariantMap : EntityTypeConfiguration<tblICCommodityClassVariant>
    {
        public tblICCommodityClassVariantMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommodityGradeMap : EntityTypeConfiguration<tblICCommodityGrade>
    {
        public tblICCommodityGradeMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommodityOriginMap : EntityTypeConfiguration<tblICCommodityOrigin>
    {
        public tblICCommodityOriginMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommodityProductLineMap : EntityTypeConfiguration<tblICCommodityProductLine>
    {
        public tblICCommodityProductLineMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommodityProductTypeMap : EntityTypeConfiguration<tblICCommodityProductType>
    {
        public tblICCommodityProductTypeMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommodityRegionMap : EntityTypeConfiguration<tblICCommodityRegion>
    {
        public tblICCommodityRegionMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommoditySeasonMap : EntityTypeConfiguration<tblICCommoditySeason>
    {
        public tblICCommoditySeasonMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

}
