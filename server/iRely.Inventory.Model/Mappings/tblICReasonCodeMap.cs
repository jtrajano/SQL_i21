using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICReasonCodeMap : EntityTypeConfiguration<tblICReasonCode>
    {
        public tblICReasonCodeMap()
        {
            // Primary Key
            this.HasKey(t => t.intReasonCodeId);

            // Table & Column Mappings
            this.ToTable("tblICReasonCode");
            this.Property(t => t.dtmLastUpdatedOn).HasColumnName("dtmLastUpdatedOn");
            this.Property(t => t.intReasonCodeId).HasColumnName("intReasonCodeId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strLastUpdatedBy).HasColumnName("strLastUpdatedBy");
            this.Property(t => t.strLotTransactionType).HasColumnName("strLotTransactionType");
            this.Property(t => t.strReasonCode).HasColumnName("strReasonCode");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.ysnExplanationRequired).HasColumnName("ysnExplanationRequired");
            this.Property(t => t.ysnReduceAvailableTime).HasColumnName("ysnReduceAvailableTime");
        }
    }
}
