using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemManufacturingMap : EntityTypeConfiguration<tblICItemManufacturing>
    {
        public tblICItemManufacturingMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemId);

            // Table & Column Mappings
            this.ToTable("tblICItemManufacturing");
            this.Property(t => t.dblDepth).HasColumnName("dblDepth");
            this.Property(t => t.dblHeight).HasColumnName("dblHeight");
            this.Property(t => t.dblStandardPalletRatio).HasColumnName("dblStandardPalletRatio");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight");
            this.Property(t => t.dblWidth).HasColumnName("dblWidth");
            this.Property(t => t.intDimensionUOMId).HasColumnName("intDimensionUOMId");
            this.Property(t => t.intInnerUnits).HasColumnName("intInnerUnits");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLayerPerPallet).HasColumnName("intLayerPerPallet");
            this.Property(t => t.intLifeTime).HasColumnName("intLifeTime");
            this.Property(t => t.intNMFCId).HasColumnName("intNMFCId");
            this.Property(t => t.intReceiveLife).HasColumnName("intReceiveLife");
            this.Property(t => t.intRecipeId).HasColumnName("intRecipeId");
            this.Property(t => t.intUnitPerLayer).HasColumnName("intUnitPerLayer");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strGTIN).HasColumnName("strGTIN");
            this.Property(t => t.strLifeTimeType).HasColumnName("strLifeTimeType");
            this.Property(t => t.strMask1).HasColumnName("strMask1");
            this.Property(t => t.strMask2).HasColumnName("strMask2");
            this.Property(t => t.strMask3).HasColumnName("strMask3");
            this.Property(t => t.strMaterialSizeCode).HasColumnName("strMaterialSizeCode");
            this.Property(t => t.strRotationType).HasColumnName("strRotationType");
            this.Property(t => t.ysnRequireCustomerApproval).HasColumnName("ysnRequireCustomerApproval");
            this.Property(t => t.ysnSanitationRequired).HasColumnName("ysnSanitationRequired");
            this.Property(t => t.ysnStrictFIFO).HasColumnName("ysnStrictFIFO");

            this.HasMany(p => p.tblICItemManufacturingUOMs)
                .WithRequired(p => p.tblICItemManufacturing)
                .HasForeignKey(p => p.intItemId);

        }
    }

    public class tblICItemManufacturingUOMMap : EntityTypeConfiguration<tblICItemManufacturingUOM>
    {
        public tblICItemManufacturingUOMMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemManufacturingUOMId);

            // Table & Column Mappings
            this.ToTable("tblICItemManufacturingUOM");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemManufacturingUOMId).HasColumnName("intItemManufacturingUOMId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");

            this.HasRequired(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICItemManufacturingUOMs)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }

}
