using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICSkuMap : EntityTypeConfiguration<tblICSku>
    {
        public tblICSkuMap()
        {
            // Primary Key
            this.HasKey(t => t.intSKUId);

            // Table & Column Mappings
            this.ToTable("tblICSku");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity");
            this.Property(t => t.dblWeightPerUnit).HasColumnName("dblWeightPerUnit");
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.dtmProductionDate).HasColumnName("dtmProductionDate");
            this.Property(t => t.dtmReceiveDate).HasColumnName("dtmReceiveDate");
            this.Property(t => t.intContainerId).HasColumnName("intContainerId");
            this.Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLayerPerPallet).HasColumnName("intLayerPerPallet");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.intOwnerId).HasColumnName("intOwnerId");
            this.Property(t => t.intParentSKUId).HasColumnName("intParentSKUId");
            this.Property(t => t.intReasonId).HasColumnName("intReasonId");
            this.Property(t => t.intSKUId).HasColumnName("intSKUId");
            this.Property(t => t.intSKUStatusId).HasColumnName("intSKUStatusId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.intUnitPerLayer).HasColumnName("intUnitPerLayer");
            this.Property(t => t.intWeightPerUnitMeasureId).HasColumnName("intWeightPerUnitMeasureId");
            this.Property(t => t.strBatch).HasColumnName("strBatch");
            this.Property(t => t.strComment).HasColumnName("strComment");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            this.Property(t => t.strLotCode).HasColumnName("strLotCode");
            this.Property(t => t.strSerialNo).HasColumnName("strSerialNo");
            this.Property(t => t.strSKU).HasColumnName("strSKU");
            this.Property(t => t.ysnSanitized).HasColumnName("ysnSanitized");
        }
    }
}
