using iRely.Common;
using iRely.Inventory.Model;
using LumenWorks.Framework.IO.Csv;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Validation;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public abstract class ImportDataLogic<T> : IImportDataLogic where T : class, IBaseEntity
    {
        protected DbContext context;
        protected byte[] data;
        protected readonly List<AuditLogItem> logs = new List<AuditLogItem>();
        protected readonly List<T> Entities = new List<T>();
        protected ImportDataResult ImportResult;

        public DbContext Context { get { return context; } set { this.context = value; } }
        public byte[] Data { get { return data; } set { this.data = value; } }
        public List<AuditLogItem> AuditLogItems { get { return logs; } }
        private IPipeChain<T> Pipeline { get; set; }
        private CsvDataReader<T> reader;
        public string Username { get; set; }

        public ImportDataLogic(DbContext context, byte[] data, string username)
        {
            Pipeline = new Pipeline<T>();
            reader = new CsvDataReader<T>(GetRequiredFields());
            reader.ReadNextRecord += Reader_ReadNextRecord;
            this.context = context;
            this.data = data;
            this.Username = username;
            ImportResult = new ImportDataResult()
            {
                Type = Constants.TYPE_INFO,
                Description = "There's nothing to import.",
                Username = username
            };
            Initialize();
        }

        public virtual async Task OnAfterSave()
        {
            await Task.FromResult(0);
        }

        public virtual async Task<ImportDataResult> Import()
        {
            Entities.Clear();
            Context.Configuration.AutoDetectChangesEnabled = false;
            ImportResult.Clear();
            CurrentRecordTracker.Instance.TimeStart = DateTime.UtcNow;

            using (MemoryStream ms = new MemoryStream(data))
            {
                if (!ms.CanRead)
                    throw new IOException("Please select a valid file.");
                using (StreamReader stream = new StreamReader(ms))
                {
                    try
                    {
                        await reader.ReadCsvAsync(stream);
                        if (Entities.Count > 0)
                        {
                            context.Set<T>().AddRange(Entities);
                        }
                        await context.SaveChangesAsync();

                        await OnAfterSave();

                        CurrentRecordTracker.Instance.TimeFinished = DateTime.UtcNow;

                        ImportResult.TotalRows = CurrentRecordTracker.Instance.TotalRecords;
                        ImportResult.RowsImported = Entities.Count;

                        if (ImportResult.Errors > 0)
                        {
                            ImportResult.Type = Constants.TYPE_ERROR;
                            ImportResult.Description = string.Format("Import completed with {0} error(s).", ImportResult.Errors.ToString());
                        }
                        else if (ImportResult.Warnings > 0)
                        {
                            ImportResult.Type = Constants.TYPE_WARNING;
                            ImportResult.Description = string.Format("Import completed with {0} warnings(s).", ImportResult.Warnings.ToString());
                        }
                        else
                        {
                            if (ImportResult.TotalRows <= 0 && ImportResult.RowsImported <= 0)
                            {
                                ImportResult = new ImportDataResult()
                                {
                                    Type = Constants.TYPE_INFO,
                                    Description = "There's nothing to import."
                                };
                            }
                            else
                            {
                                ImportResult.Description = "Import completed.";
                            }
                        }
                    }
                    catch(CsvMissingFieldsException ex)
                    {
                        ImportResult.AddError(new ImportDataMessage()
                        {
                            Type = Constants.TYPE_ERROR,
                            Value = "Template",
                            Action = "Import aborted",
                            Column = "",
                            Exception = ex,
                            Row = 1,
                            Status = Constants.STAT_FAILED,
                            Message = "Invalid template format. Some fields were missing. Missing fields: " + reader.Schema.GetMissingFieldsTextRepresentation()
                        });
                        ImportResult.Type = Constants.TYPE_ERROR;
                        SetLogExceptionDescription(ImportResult, ex);
                        ImportResult.Failed = true;
                    }
                    catch (Exception ex)
                    {
                        ImportResult.Failed = true;
                        ImportResult.Type = Constants.TYPE_EXCEPTION;
                        SetLogExceptionDescription(ImportResult, ex);
                    }
                }
            }

            ImportResult.TimeSpentInSeconds = CurrentRecordTracker.Instance.TimeElapsed;

            try
            {
                ImportResult.LogId = await SaveLogsToDb(ImportResult);
            }
            catch (DbEntityValidationException ex)
            {
                ImportResult.AddWarning(new ImportDataMessage()
                {
                    Type = Constants.TYPE_EXCEPTION,
                    Value = "Save Logs",
                    Action = "Import might be successful but logs were not written to database.",
                    Column = "",
                    Exception = ex,
                    Row = 1,
                    Status = Constants.STAT_FAILED,
                    Message = ex.Message
                });
                ImportResult.Failed = true;
                ImportResult.Type = Constants.TYPE_EXCEPTION;
                SetLogExceptionDescription(ImportResult, ex);
            }
            catch (Exception ex)
            {
                ImportResult.AddWarning(new ImportDataMessage()
                {
                    Type = Constants.TYPE_EXCEPTION,
                    Value = "Save Logs",
                    Action = "Import might be successful but logs were not written to database.",
                    Column = "",
                    Exception = ex,
                    Row = 1,
                    Status = Constants.STAT_FAILED,
                    Message = ex.Message
                });
                ImportResult.Failed = true;
                ImportResult.Type = Constants.TYPE_EXCEPTION;
                SetLogExceptionDescription(ImportResult, ex);
            }

            return ImportResult;
        }

        protected void SetLogExceptionDescription(ImportDataResult result, Exception ex)
        {
            var msg = ex.Message + (ex.InnerException != null ? " -> " + (ex.InnerException.InnerException != null ? ex.InnerException.InnerException.Message : ex.InnerException.Message) : "");
            ImportResult.Description = msg;
        }

        private async Task<int> SaveLogsToDb(ImportDataResult result)
        {
            return await ImportDataSqlLogger.GetInstance(Context).WriteLogs(result);   
        }

        private void Reader_ReadNextRecord(long recordIndex, CsvRecord record, out bool succeeded)
        {
            OnNextRecord(recordIndex, record, out succeeded);
        }

        protected virtual void OnNextRecord(long recordIndex, CsvRecord record, out bool succeeded)
        {
            CurrentRecordTracker.Instance.Record = record;
            CurrentRecordTracker.Instance.TotalRecords = (int)recordIndex + 1;
            succeeded = true;
            var entity = Process(record);
            ExecutePipes(entity);

            if (entity != null)
            {
                if (!GlobalSettings.Instance.AllowDuplicates)
                {
                    if (HasDuplicates(entity))
                    {
                        HandleDuplicates(entity, record);
                        return;
                    }
                    else 
                    {
                        var foundId = -1;
                        T foundEntity = null;
                        var exists = AlreadyExists(entity, out foundId, out foundEntity);
                        if (exists)
                        {
                            if (GlobalSettings.Instance.AllowOverwriteOnImport)
                            {
                                if (foundEntity != null && foundId > 0)
                                {
                                    TransformeEntity(ref foundEntity, ref entity, "intConcurrencyId");
                                    TransformeEntity(ref foundEntity, ref entity, GetPrimaryKeyName());
                                    if (context.Entry<T>(entity).State == EntityState.Unchanged)
                                    {
                                        context.Entry<T>(entity).State = EntityState.Modified;
                                        AddSuccessLog(entity, record, false);
                                    }
                                }
                            }
                            else
                            {
                                HandleIfAlreadyExists(entity, record, foundId);
                                return;
                            }
                        }
                        else
                        {
                            Entities.Add(entity);
                            AddSuccessLog(entity, record);
                        }
                    }
                }
                else
                {

                    var foundId = -1;
                    T foundEntity = null;
                    var exists = AlreadyExists(entity, out foundId, out foundEntity);
                    if (exists)
                    {
                        if (GlobalSettings.Instance.AllowOverwriteOnImport)
                        {
                            if (foundEntity != null && foundId > 0)
                            {
                                TransformeEntity(ref foundEntity, ref entity, "intConcurrencyId");
                                TransformeEntity(ref foundEntity, ref entity, GetPrimaryKeyName());
                                if (context.Entry<T>(entity).State == EntityState.Unchanged)
                                {
                                    context.Entry<T>(entity).State = EntityState.Modified;
                                    AddSuccessLog(entity, record, false); 
                                }
                            }
                        }
                        else
                        {
                            HandleIfAlreadyExists(entity, record, foundId);
                            return;
                        }
                    }
                    else
                    {
                        Entities.Add(entity);
                        AddSuccessLog(entity, record);
                    }
                }
            }
        }

        private void TransformeEntity(ref T e, ref T n, string fieldName)
        {
            PropertyInfo epi = e.GetType().GetProperty(fieldName);
            PropertyInfo npi = n.GetType().GetProperty(fieldName);

            if(epi != null)
            {
                var concurrencyId = epi.GetValue(e, null);
                if(npi != null)
                {
                    npi.SetValue(n, Convert.ChangeType(concurrencyId, epi.PropertyType), null);
                }
            }
        }

        protected void AddSuccessLog(T entity, CsvRecord record, bool isNew = true)
        {
            ImportResult.AddMessage(new ImportDataMessage()
            {
                Type = Constants.TYPE_INFO,
                Status = Constants.STAT_SUCCESS,
                Action = isNew ? Constants.ACTION_INSERTED : Constants.ACTION_UPDATED,
                Column = "",
                Row = record.RecordNo,
                Value = "",
                Exception = null,
                Message = isNew ? "Import successful." : "Update successful."
            });
            ImportResult.Type = Constants.TYPE_INFO;
        }

        public bool HasDuplicates(T entity)
        {
            var expression = GetUniqueKeyExpression(entity);
            if (expression == null)
                return false;
            var hasDuplicate = Entities.AsQueryable<T>().Any<T>(expression);
            return hasDuplicate;
        }

        public virtual string DuplicateFoundMessage()
        {
            return string.Empty;
        }

        public void HandleDuplicates(T entity, CsvRecord record)
        {
            if(GlobalSettings.Instance.ContinueOnFailedImports)
            {
                string fields = record.Schema.GetMissingFieldsTextRepresentation();
                var dupMessage = DuplicateFoundMessage();
                var errorMessage = $"Duplicate records found for record #{record.RecordNo}";
                if (dupMessage != string.Empty)
                    errorMessage = $"{errorMessage}. {dupMessage}";
                ImportResult.AddError(new ImportDataMessage()
                {
                    Type = Constants.TYPE_ERROR,
                    Status = Constants.STAT_FAILED,
                    Action = Constants.ACTION_SKIPPED,
                    Column = fields,
                    Row = record.RecordNo,
                    Value = $"Values of: {fields}.",
                    Exception = null,
                    Message = errorMessage
                });
                ImportResult.Type = Constants.TYPE_WARNING;
            }
            else
                throw new ArgumentOutOfRangeException($"Duplicate records found for record #{record.RecordNo}");
        }

        public bool AlreadyExists(T entity, out int existingId, out T foundEntity)
        {
            var expression = GetUniqueKeyExpression(entity);
            existingId = -1;
            foundEntity = null;

            if (expression == null)
                return false;
            foundEntity = Context.Set<T>().AsNoTracking().FirstOrDefault(expression);

            if (foundEntity != null)
            {
                existingId = GetPrimaryKeyValue(foundEntity);
                return true;
            }
            return false;
        }

        public bool AlreadyExists(T entity, out int existingId)
        {
            var expression = GetUniqueKeyExpression(entity);
            existingId = -1;

            if (expression == null)
                return false;
            var found = Context.Set<T>().AsNoTracking().FirstOrDefault(expression);
            
            if (found != null)
            {
                existingId = GetPrimaryKeyValue(found);
                return true;
            }
            return false;
        }

        public abstract int GetPrimaryKeyValue(T entity);

        public void HandleIfAlreadyExists(T entity, CsvRecord record, int existingId)
        {
            if (GlobalSettings.Instance.ContinueOnFailedImports)
            {
                string fields = record.Schema.GetMissingFieldsTextRepresentation();
                ImportResult.AddError(new ImportDataMessage()
                {
                    Type = Constants.TYPE_ERROR,
                    Status = Constants.STAT_FAILED,
                    Action = Constants.ACTION_SKIPPED,
                    Column = fields,
                    Row = record.RecordNo,
                    Value = $"Values of: {fields}.",
                    Exception = null,
                    Message = $"CSV record #{record.RecordNo} already exists in the database with {GetPrimaryKeyName()} of {existingId.ToString()}."
                });
                ImportResult.Type = Constants.TYPE_WARNING;
            }
            else
                throw new ArgumentOutOfRangeException($"Record #{record.RecordNo} already exists in the database.");
        }

        protected virtual string GetPrimaryKeyName() { return " a primary key of "; }

        public virtual void Initialize() { }
        protected abstract string[] GetRequiredFields();
        protected virtual Expression<Func<T, bool>> GetUniqueKeyExpression(T entity) { return null; }
        public virtual T Process(CsvRecord record) { return default(T); }
        protected void ExecutePipes(T input) { Pipeline.Execute(input); }
        public void AddPipe(IPipe<T> pipe) { Pipeline.Register(pipe); }
        protected virtual string GetViewNamespace() { return string.Empty; }

        protected string GetFieldValue(CsvRecord record, string key, string defaultValue = null)
        {
            return ImportDataLogicHelpers.GetFieldValue(record, key, defaultValue);
        }

        #region Lookups
        /// <summary>
        /// Gets the specified ID property of an existing record in the lookup table. This inserts a new record when the ID does not exists.
        /// </summary>
        /// <typeparam name="T">The table entity.</typeparam>
        /// <param name="context">The Inventory Repository</param>
        /// <param name="predicate">The condition to specify to get the ID</param>
        /// <param name="idProperty">The field that is a reference to the source table.</param>
        /// <param name="newObject">The entity to be inserted when the ID does not exists.</param>
        /// <param name="inserted">Outputs true when a new record is inserted.</param>
        /// <returns></returns>
        protected int? InsertAndOrGetLookupId<J>(Expression<Func<J, bool>> predicate, Expression<Func<J, int>> idProperty, J newObject, out bool inserted) where J : class
        {
            return ImportDataLogicHelpers.InsertAndOrGetLookupId<J>(Context, predicate, idProperty, newObject, out inserted);
        }

        protected int? GetLookUpId<J>(Expression<Func<J, bool>> predicate, Expression<Func<J, int>> idProperty) where J : class
        {
            return ImportDataLogicHelpers.GetLookUpId<J>(Context, predicate, idProperty);
        }

        protected int? GetLookUpId<J>(Expression<Func<J, bool>> predicate, Expression<Func<J, int?>> idProperty) where J : class
        {
            return ImportDataLogicHelpers.GetLookUpId<J>(Context, predicate, idProperty);
        }

        protected J GetLookUpObject<J>(Expression<Func<J, bool>> predicate) where J : class
        {
            return ImportDataLogicHelpers.GetLookUpObject<J>(Context, predicate);
        }

        protected List<J> GetLookUps<J>(Expression<Func<J, bool>> predicate) where J : class
        {
            return ImportDataLogicHelpers.GetLookUps<J>(Context, predicate);
        }
        #endregion

        #region Loggers
        protected async Task LogItem(int id, string action, string viewNamespace)
        {
            try
            {
                int entityId = iRely.Common.Security.GetEntityId();

                //context.ContextManager.Database.ExecuteSqlCommand(
                //    string.Format("uspSMAuditLog @screenName = '{0}', @keyValue = {1}, @entityId = {2}, @actionType = '{3}', @actionIcon='small-import'",
                //    viewNamespace, id.ToString(), entityId, action));

                await context.Database.ExecuteSqlCommandAsync(
                            "uspSMAuditLog @screenName, @keyValue, @entityId, @actionType, @actionIcon",
                            new SqlParameter("screenName", viewNamespace),
                            new SqlParameter("keyValue", id.ToString()),
                            new SqlParameter("entityId", entityId),
                            new SqlParameter("actionType", action),
                            new SqlParameter("actionIcon", "small-import")
                );
            }
            catch (Exception ex)
            {
                throw new Exception($"Can't log to audit trail. {ex.Message}", ex);
            }
        }

        protected async Task LogItem(int id, string action, string viewNamespace, string description, string fromValue, string toValue)
        {
            try
            {
                int entityId = iRely.Common.Security.GetEntityId();

                //context.ContextManager.Database.ExecuteSqlCommand(
                //    string.Format("uspSMAuditLog @screenName = '{0}', @keyValue = {1}, @entityId = {2}, @actionType = '{3}', @changeDescription = '{4}', @fromValue = '{5}', @toValue='{6}', @actionIcon='small-import'",
                //    viewNamespace, id.ToString(), entityId, action, description, fromValue, toValue));

                await context.Database.ExecuteSqlCommandAsync(
                            "uspSMAuditLog @screenName, @keyValue, @entityId, @actionType, @changeDescription, @fromValue, @toValue, @actionIcon",
                            new SqlParameter("screenName", viewNamespace),
                            new SqlParameter("keyValue", id.ToString()),
                            new SqlParameter("entityId", entityId),
                            new SqlParameter("actionType", action),
                            new SqlParameter("changeDescription", description),
                            new SqlParameter("fromValue", fromValue),
                            new SqlParameter("toValue", toValue),
                            new SqlParameter("actionIcon", "small-import")
                );

            }
            catch (Exception ex)
            {
                throw new Exception($"Can't log to audit trail. {ex.Message}", ex);
            }
        }

        protected async Task LogItem(int id, string action, string viewNamespace, string details)
        {
            try
            {
                int entityId = iRely.Common.Security.GetEntityId();

                //context.ContextManager.Database.ExecuteSqlCommand(
                //    string.Format("uspSMAuditLog @screenName = '{0}', @keyValue = {1}, @entityId = {2}, @actionType = '{3}', @details = '{4}', @actionIcon='small-import'",
                //    viewNamespace, id.ToString(), entityId, action, details));

                await context.Database.ExecuteSqlCommandAsync(
                            "uspSMAuditLog @screenName, @keyValue, @entityId, @actionType, @details, @actionIcon",
                            new SqlParameter("screenName", viewNamespace),
                            new SqlParameter("keyValue", id.ToString()),
                            new SqlParameter("entityId", entityId),
                            new SqlParameter("actionType", action),
                            new SqlParameter("details", details),
                            new SqlParameter("actionIcon", "small-import")
                );

            }
            catch (Exception ex)
            {
                throw new Exception($"Can't log to audit trail. {ex.Message}", ex);
            }
        }

        protected async Task LogDetailedItem(int id, string action, string viewNamespace, List<AuditLogItem> items)
        {
            string details = string.Empty;
            string comma = ",";
            int count = 0;
            foreach (AuditLogItem item in items)
            {
                count++;
                if (count == AuditLogItems.Count && count == 1)
                    comma = "";
                details += "{\"change\":\"" + item.Description + "\",\"iconCls\":\"" + item.ActionIcon + "\",\"from\":\"" + item.FromValue + "\",\"to\":\"" + item.ToValue + "\",\"leaf\":true}" + comma;
            }

            if (string.IsNullOrEmpty(details))
                await LogItem(id, "Imported from CSV file.", viewNamespace);
            else
                await LogItem(id, "Imported from CSV file.", viewNamespace, details);
        }

        protected virtual async Task LogTransaction(T entity)
        {
            AuditLogItems.Clear();
            var id = GetPrimaryKeyValue(entity);
            if (id != 0 && !string.IsNullOrEmpty(GetViewNamespace()))
            {
                string details = string.Empty;
                string comma = ",";
                int count = 0;
                foreach (AuditLogItem item in AuditLogItems)
                {
                    count++;
                    if (count == AuditLogItems.Count && count == 1)
                        comma = "";
                    details += "{\"change\":\"" + item.Description + "\",\"iconCls\":\"" + item.ActionIcon + "\",\"from\":\"" + item.FromValue + "\",\"to\":\"" + item.ToValue + "\",\"leaf\":true}" + comma;
                }

                if (string.IsNullOrEmpty(details))
                    await LogItem(id, "Imported from CSV file.", GetViewNamespace());
                else
                    await LogItem(id, "Imported from CSV file.", GetViewNamespace(), details);
            }
        }
        #endregion

        #region Value Resolvers
        public void SetBoolean(CsvRecord record, string header, Action<bool> booleanDelegate)
        {
            ImportDataLogicHelpers.SetBoolean(record, header, booleanDelegate);
        }

        public bool SetNonZeroDecimal(CsvRecord record, string header, Action<decimal> decimalDelegate)
        {
            return ImportDataLogicHelpers.SetNonZeroDecimal(ImportResult, record, header, decimalDelegate);
        }

        public bool SetDecimal(CsvRecord record, string header, Action<decimal> decimalDelegate)
        {
            return ImportDataLogicHelpers.SetDecimal(ImportResult, record, header, decimalDelegate);
        }

        public bool SetInteger(CsvRecord record, string header, Action<int> intDelegate)
        {
            return ImportDataLogicHelpers.SetInteger(ImportResult, record, header, intDelegate);
        }

        public bool SetDate(CsvRecord record, string header, Action<DateTime> dateDelegate)
        {
            return ImportDataLogicHelpers.SetDate(ImportResult, record, header, dateDelegate);
        }

        public bool SetText(CsvRecord record, string header, Action<string> textDelegate, bool required = false)
        {
            return ImportDataLogicHelpers.SetText(ImportResult, record, header, textDelegate, required);
        }

        public bool SetText(string value, Action<string> textDelegate)
        {
            return ImportDataLogicHelpers.SetText(value, textDelegate);
        }

        public bool SetIntLookupId<J>(CsvRecord record, string header, Expression<Func<J, bool>> predicate, Expression<Func<J, int?>> idProperty, Action<int> intDelegate, bool required = false) where J : class
        {
            return ImportDataLogicHelpers.SetIntLookupId<J>(Context, ImportResult, record, header, predicate, idProperty, intDelegate, required);
        }

        public bool SetLookupId<J>(CsvRecord record, string header, Expression<Func<J, bool>> predicate, Expression<Func<J, int?>> idProperty, Action<int?> intDelegate, bool required = false) where J : class
        {
            return ImportDataLogicHelpers.SetLookupId<J>(Context, ImportResult, record, header, predicate, idProperty, intDelegate, required);
        }

        public bool SetFixedLookup(CsvRecord record, string header, Action<string> fixedLUDelegate, IEnumerable<string> list, bool required = false, bool exactMatch = true)
        {
            return ImportDataLogicHelpers.SetFixedLookup(ImportResult, record, header, fixedLUDelegate, list, required, exactMatch);
        }
        #endregion
    }
}
