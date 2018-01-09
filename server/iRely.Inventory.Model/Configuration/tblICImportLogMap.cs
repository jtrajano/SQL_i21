using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICImportLogMap : EntityTypeConfiguration<tblICImportLog>
    {
        public tblICImportLogMap()
        {
            this.HasKey(e => e.intImportLogId);

            this.ToTable("tblICImportLog");
            this.Property(e => e.strDescription).HasMaxLength(500);
            this.Property(e => e.strType).HasMaxLength(100);
            this.Property(e => e.strFileType).HasMaxLength(200);
            this.Property(e => e.strFileName).HasMaxLength(300);
            this.Property(e => e.strLineOfBusiness).HasMaxLength(200);
            this.Property(e => e.dblTimeSpentInSeconds).HasPrecision(18, 6);
        }
    }
}
