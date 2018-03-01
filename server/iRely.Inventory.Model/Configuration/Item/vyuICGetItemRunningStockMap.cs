using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemRunningStockMap : EntityTypeConfiguration<vyuICGetItemRunningStock>
    {
        public vyuICGetItemRunningStockMap()
        {
            this.HasKey(t => t.intKey);

            this.ToTable("vyuICGetItemRunningStock");
        }
    }
}
