using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;

namespace iRely.Inventory.Test.Import.Fake
{
    public abstract class FakeDbSet<TEntity> : DbSet<TEntity>
        where TEntity : class
    {
        private readonly List<TEntity> _entities;
        private readonly IQueryable<TEntity> _query;

        protected FakeDbSet()
        {
            _entities = new List<TEntity>();
            _query = _entities.AsQueryable();
        }

        public List<TEntity> Entities
        {
            get { return _entities; }
        }

        //Type IQueryable.ElementType
        //{
        //    get { return _query.ElementType; }
        //}

        //Expression IQueryable.Expression
        //{
        //    get { return _query.Expression; }
        //}

        //IQueryProvider IQueryable.Provider
        //{
        //    get { return _query.Provider; }
        //}

        //IEnumerator<TEntity> IEnumerable<TEntity>.GetEnumerator()
        //{
        //    return _entities.GetEnumerator();
        //}

        //IEnumerator IEnumerable.GetEnumerator()
        //{
        //    return _entities.GetEnumerator();
        //}

        //public abstract ObservableCollection<TEntity> Local { get; }

        //public abstract TEntity Create();
        //public abstract TDerivedEntity Create<TDerivedEntity>()
        //    where TDerivedEntity : class, TEntity;

        //public abstract TEntity Find(params object[] keyValues);
        //public abstract TEntity Attach(TEntity entity);
        //public abstract TEntity Add(TEntity entity);
        //public abstract TEntity Remove(TEntity entity);
    }
}
