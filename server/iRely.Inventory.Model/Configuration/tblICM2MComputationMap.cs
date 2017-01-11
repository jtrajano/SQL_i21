using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICM2MComputationMap: EntityTypeConfiguration<tblICM2MComputation>
    {
        public tblICM2MComputationMap()
        {
            // Primary Key
            this.HasKey(t => t.intM2MComputationId);

            // Table & Column Mappings
            this.ToTable("tblICM2MComputation");
            this.Property(t => t.intM2MComputationId).HasColumnName("intM2MComputationId");
            this.Property(t => t.strM2MComputation).HasColumnName("strM2MComputation");
        }
    }
}
