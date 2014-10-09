using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Web;

using iRely.Common;
using iRely.Inventory.Model;
using IdeaBlade.Core;
using IdeaBlade.Linq;

namespace iRely.Inventory.BRL
{
    public class Document : IDisposable
    {
        private Repository _db;

        public Document()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICDocument> GetSearchQuery()
        {
            return _db.GetQuery<tblICDocument>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICDocument, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICDocument, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICDocument> GetDocuments(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICDocument, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICDocument>()
                .Where(w => query.Where(predicate).Any(a => a.intDocumentId == w.intDocumentId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddDocument(tblICDocument document)
        {
            _db.AddNew<tblICDocument>(document);
        }

        public void UpdateDocument(tblICDocument document)
        {
            _db.UpdateBatch<tblICDocument>(document);
        }

        public void DeleteDocument(tblICDocument document)
        {
            _db.Delete<tblICDocument>(document);
        }

        public SaveResult Save(bool continueOnConflict)
        {
            return _db.Save(continueOnConflict);
        }
        
        public void Dispose()
        {
            _db.Dispose();
        }
    }
}
