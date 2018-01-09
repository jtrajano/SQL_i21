using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Test.Import.Fake
{
    public abstract class FakeDbContext : IEntityDbContext
    {
        public Database Database { get; set; }

        protected FakeDbContext() { }

        public abstract int SaveChanges();
        public abstract void Dispose();
        public abstract Task<int> SaveChangesAsync();
        public abstract DbSet<T> Set<T>() where T : class;
        public abstract DbEntityEntry<T> Entry<T>(T entity) where T : class;
    }
}
