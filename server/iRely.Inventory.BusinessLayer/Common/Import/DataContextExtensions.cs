using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public static class DataContextExtensions
    {
        public static async Task<TContext> BulkInsert<TContext, TEntity>(this TContext context, TEntity entity, int count, int batchSize)
            where TContext : DbContext
            where TEntity : class
        {
            context.Set<TEntity>().Add(entity);
            if(count % batchSize == 0)
            {
                await context.SaveChangesAsync();
                context.Dispose();
                context = (TContext)Activator.CreateInstance(typeof(TContext));
                context.Configuration.AutoDetectChangesEnabled = false;
            }
            return context;
        }
    }
}
