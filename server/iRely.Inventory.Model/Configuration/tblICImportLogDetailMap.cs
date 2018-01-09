using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICImportLogDetailMap : EntityTypeConfiguration<tblICImportLogDetail>
    {
        public tblICImportLogDetailMap()
        {
            this.HasKey(e => e.intImportLogDetailId);

            this.ToTable("tblICImportLogDetail");
            this.Property(e => e.strAction).HasMaxLength(100);
            this.Property(e => e.strValue).HasMaxLength(200);
            this.Property(e => e.strMessage).HasMaxLength(500);
            this.Property(e => e.strType).HasMaxLength(200);
            this.Property(e => e.strField).HasMaxLength(100);
            this.Property(e => e.strStatus).HasMaxLength(100);
            this.HasRequired(e => e.tblICImportLog)
                .WithMany(e => e.tblICImportLogDetails)
                .HasForeignKey(e => e.intImportLogId);
        }
    }
}
