using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICContainerTypeMap : EntityTypeConfiguration<tblICContainerType>
    {
        public tblICContainerTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intContainerTypeId);

            // Table & Column Mappings
            this.ToTable("tblICContainerType");
            this.Property(t => t.dblDepth).HasColumnName("dblDepth").HasPrecision(18, 6);
            this.Property(t => t.dblHeight).HasColumnName("dblHeight").HasPrecision(18, 6);
            this.Property(t => t.dblMaxWeight).HasColumnName("dblMaxWeight").HasPrecision(18, 6);
            this.Property(t => t.dblPalletWeight).HasColumnName("dblPalletWeight").HasPrecision(18, 6);
            this.Property(t => t.dblWidth).HasColumnName("dblWidth").HasPrecision(18, 6);
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.intContainerTypeId).HasColumnName("intContainerTypeId");
            this.Property(t => t.intDimensionUnitMeasureId).HasColumnName("intDimensionUnitMeasureId");
            this.Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intTareUnitMeasureId).HasColumnName("intTareUnitMeasureId");
            this.Property(t => t.intWeightUnitMeasureId).HasColumnName("intWeightUnitMeasureId");
            this.Property(t => t.strContainerDescription).HasColumnName("strContainerDescription");
            this.Property(t => t.strDisplayMember).HasColumnName("strDisplayMember");
            this.Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            this.Property(t => t.ysnAllowMultipleItems).HasColumnName("ysnAllowMultipleItems");
            this.Property(t => t.ysnAllowMultipleLots).HasColumnName("ysnAllowMultipleLots");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.ysnLocked).HasColumnName("ysnLocked");
            this.Property(t => t.ysnMergeOnMove).HasColumnName("ysnMergeOnMove");
            this.Property(t => t.ysnReusable).HasColumnName("ysnReusable");
        }
    }
}
