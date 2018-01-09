using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using Moq;

namespace iRely.Inventory.Test.Import.Fake
{
    public static class FakeExtensions
    {
        public static TRepository Containing<TRepository, TEntity>
            (this TRepository repository, params TEntity[] entities)
            where TRepository : FakeDbSet<TEntity>
            where TEntity : class
        {
            repository.Entities.AddRange(entities);
            return repository;
        }

        public static TRepository Containing<TRepository, TEntity>
            (this TRepository repository, IEnumerable<TEntity> entities)
            where TRepository : FakeDbSet<TEntity>
            where TEntity : class
        {
            repository.Entities.AddRange(entities);
            return repository;
        }

        public static FakeDbSet<TEntity> HavingRepository<TContext, TEntity>
            (this TContext context, Expression<Func<TContext, FakeDbSet<TEntity>>> dbSet)
            where TContext : FakeDbContext
            where TEntity : class
        {
            FakeDbSet<TEntity> entity = Mock.Of<FakeDbSet<TEntity>>();

            Mock.Get(context)
                .Setup(dbSet)
                .Returns(entity);

            return entity;
        }

        public static void Creating<TEntity>
            (this FakeDbSet<TEntity> dbSet, IEnumerable<TEntity> entities)
            where TEntity : class
        {
            var queue = new Queue<TEntity>(entities);

            Mock.Get(dbSet)
                .Setup(c => c.Create())
                .Returns(() => queue.Dequeue());
        }

        public static void Creating<TEntity>
            (this FakeDbSet<TEntity> dbSet, params TEntity[] entities)
            where TEntity : class
        {
            Creating(dbSet, (IEnumerable<TEntity>)entities);
        }
    }
}
