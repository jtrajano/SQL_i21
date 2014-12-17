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
    public class ItemNote : IDisposable
    {
        private Repository _db;

        public ItemNote()
        {
            _db = new Repository(new Inventory.Model.InventoryEntities());
        }

        public IQueryable<tblICItemNote> GetSearchQuery()
        {
            return _db.GetQuery<tblICItemNote>();
        }

        public object GetSearchQuery(int page, int start, int limit, IProjectionSelector selector, CompositeSortSelector sortSelector, Expression<Func<tblICItemNote, bool>> predicate)
        {
            return GetSearchQuery()
                .Where(predicate)
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .Select(selector)
                .AsNoTracking();
        }

        public int GetCount(Expression<Func<tblICItemNote, bool>> predicate)
        {
            return GetSearchQuery().Where(predicate).Count();
        }

        public IQueryable<tblICItemNote> GetItemNotes(int page, int start, int limit, CompositeSortSelector sortSelector, Expression<Func<tblICItemNote, bool>> predicate)
        {
            var query = GetSearchQuery(); //Get Search Query
            return _db.GetQuery<tblICItemNote>()
                .Include(p => p.tblSMCompanyLocation)
                .Where(w => query.Where(predicate).Any(a => a.intItemNoteId == w.intItemNoteId)) //Filter the Main DataSource Based on Search Query
                .OrderBySelector(sortSelector)
                .Skip(start)
                .Take(limit)
                .AsNoTracking();
        }

        public void AddItemNote(tblICItemNote note)
        {
            _db.AddNew<tblICItemNote>(note);
        }

        public void UpdateItemNote(tblICItemNote note)
        {
            _db.UpdateBatch<tblICItemNote>(note);
        }

        public void DeleteItemNote(tblICItemNote note)
        {
            _db.Delete<tblICItemNote>(note);
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
