using iRely.Common;
using LumenWorks.Framework.IO.Csv;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public abstract class ImportDataLogic<T> : IImportDataLogic
    {
        public class InvalidItem
        {
            public string Message { get; set;}
            public string Header { get;set;}
            public string Value { get;set;}
        }

        public const string STAT_INNER_COL_SKIP = "This optional field is ignored.";
        public const string REC_SKIP = "Record skipped";
        public const string STAT_INNER_DEF = "Set to default value";
        public const string STAT_INNER_AUTO = "Auto-created";

        public const string STAT_INNER_SUCCESS = "Success";
        public const string TYPE_INNER_WARN = "Warning";
        public const string TYPE_INNER_EXCEPTION = "Exception";
        public const string TYPE_INNER_ERROR = "Error";
        public const string TYPE_INNER_INFO = "Info";

        public const string INFO_WARN = "warning";
        public const string INFO_ERROR = "error";
        public const string INFO_SUCCESS = "success";

        public const string ICON_ACTION_NEW = "small-new-plus";
        public const string ICON_ACTION_EDIT = "small-edit";

        protected InventoryRepository context;
        protected byte[] data;
        protected readonly List<ImportLogItem> logs = new List<ImportLogItem>();
        protected readonly List<InvalidItem> invalidItems = new List<InvalidItem>();
        protected readonly Dictionary<string, string> uniqueIds = new Dictionary<string, string>(new CaseInsensitiveComparer());

        private class CaseInsensitiveComparer : IEqualityComparer<string>
        {
            public bool Equals(string x, string y)
            {
                return x.ToLower().Equals(y.ToLower());
            }

            public int GetHashCode(string obj)
            {
                return obj.ToLower().GetHashCode();
            }
        }

        public ImportDataLogic()
        {
            
        }

        public ImportDataLogic(InventoryRepository context, byte[] data)
        {
            this.context = context;
            this.data = data;
        }

        public List<ImportLogItem> LogItems
        {
            get 
            {
                return logs; 
            }
        }

        protected abstract string[] GetRequiredFields();

        protected bool ValidHeaders(string[] headers, out List<string> missingFields)
        {
            string[] requiredFields = GetRequiredFields();
            List<string> mf = new List<string>();

            if (requiredFields.Length == 0)
            {
                missingFields = mf;
                return true;
            }

            int validCnt = 0;
            for (int i = 0; i < requiredFields.Length; i++)
            {
                string r = requiredFields[i].Trim().ToLower();
                bool found = false;
                for (int j = 0; j < headers.Length; j++)
                {
                    string h = headers[j].Trim().ToLower();
                    if (h == r)
                    {
                        validCnt++;
                        found = true;
                        break;
                    }
                }
                if (!found)
                    mf.Add(r);
            }

            missingFields = mf;
            return validCnt == requiredFields.Length;
        }

        protected bool HasLocalDuplicate(ImportDataResult dr, string field, string value, int row)
        {
            if (string.IsNullOrEmpty(value))
                return false;

            if (uniqueIds.ContainsKey(value))
            {
                dr.Info = INFO_ERROR;
                dr.Messages.Add(new ImportDataMessage()
                {
                    Type = TYPE_INNER_ERROR,
                    Status = REC_SKIP,
                    Column = field,
                    Row = row,
                    Message = "Duplicate record(s) found: " + value
                });
                return true;
            }
            uniqueIds.Add(value, value);
            return false;
        }
        
        public virtual ImportDataResult Import()
        {
            ImportDataResult dr = new ImportDataResult()
            {
                Info = INFO_SUCCESS
            };
            using (MemoryStream ms = new MemoryStream(data))
            {
                var hasErrors = false;
                var hasWarnings = false;

                if (!ms.CanRead)
                    throw new IOException("Please select a valid file.");
                int row = 0;
                using (StreamReader stream = new StreamReader(ms))
                {
                    using (CsvReader csv = new CsvReader(stream, true))
                    {
                        int fieldCount = csv.FieldCount;
                        string[] headers = csv.GetFieldHeaders();
                        List<string> missingFields;

                        if (!ValidHeaders(headers, out missingFields))
                        {
                            dr.Info = INFO_ERROR;
                            dr.Description = "Invalid template format. Some fields were missing.";
                            StringBuilder sb = new StringBuilder();
                            foreach (string s in missingFields)
                            {
                                sb.Append("'" + s + "'" + ", ");
                            }
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Type = TYPE_INNER_ERROR,
                                Status = "Import Failed",
                                Message = "Invalid template format. Some fields were missing. Missing fields: " +
                                    CultureInfo.CurrentCulture.TextInfo.ToTitleCase(sb.ToString().Substring(0, sb.Length - 2))
                            });
                            //throw new FormatException("Invalid template format.");
                            return dr;
                        }

                        uniqueIds.Clear();

                        while (csv.ReadNextRecord())
                        {
                            row++;

                            using (var transaction = context.ContextManager.Database.BeginTransaction())
                            {
                                try
                                {
                                    LogItems.Clear();
                                    dr.IsUpdate = false;
                                    T entity = ProcessRow(row, fieldCount, headers, csv, dr);
                                    if (entity != null)
                                    {
                                        context.Save();
                                        LogTransaction(ref entity, dr);
                                        dr.Messages.Add(new ImportDataMessage()
                                        {
                                            Message = "Record " + (dr.IsUpdate ? "updated" : "imported") + " successfully.",
                                            Row = row,
                                            Status = STAT_INNER_SUCCESS,
                                            Type = TYPE_INNER_INFO
                                        });
                                        if (dr.Info == INFO_ERROR)
                                            hasErrors = true;
                                        if (dr.Info == INFO_WARN)
                                            hasWarnings = true;
                                        transaction.Commit();
                                    }
                                    else
                                    {
                                        dr.Messages.Add(new ImportDataMessage()
                                        {
                                            Message = "Invalid values found. Items that were auto created or modified in this record will be rolled back.",
                                            Exception = null,
                                            Row = row,
                                            Status = "Record import failed.",
                                            Type = TYPE_INNER_ERROR
                                        });
                                        dr.Info = INFO_ERROR;
                                        hasErrors = true;
                                        transaction.Rollback();
                                        continue;
                                    }
                                }
                                catch (Exception ex)
                                {
                                    string message = ex.Message;
                                    if (ex.InnerException != null && ex.InnerException.InnerException != null)
                                        message = ex.InnerException.InnerException.Message;
                                    else
                                        message = ex.InnerException.Message;
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Message = message + " Items that were auto created or modified in this record will be rolled back.",
                                        Exception = ex,
                                        Row = row,
                                        Status = REC_SKIP,
                                        Type = TYPE_INNER_EXCEPTION
                                    });
                                    dr.Info = INFO_ERROR;
                                    hasErrors = true;
                                    transaction.Rollback();
                                    continue;
                                }
                            }
                        }
                    }
                }
                dr.Rows = row;

                if (hasWarnings)
                    dr.Info = INFO_WARN;

                if (hasErrors)
                    dr.Info = INFO_ERROR;
            }

            return dr;
        }

        protected virtual void LogTransaction(ref T entity, ImportDataResult dr)
        {
            LogItems.Clear();
            var id = GetPrimaryKeyId(ref entity);
            if (id != 0 && !string.IsNullOrEmpty(GetViewNamespace()))
            {
                string details = string.Empty;
                string comma = ",";
                int count = 0;
                foreach (ImportLogItem item in LogItems)
                {
                    count++;
                    if (count == LogItems.Count && count == 1)
                        comma = "";
                    details += "{\"change\":\"" + item.Description + "\",\"iconCls\":\"" + item.ActionIcon + "\",\"from\":\"" + item.FromValue + "\",\"to\":\"" + item.ToValue + "\",\"leaf\":true}" + comma;
                }

                if (string.IsNullOrEmpty(details))
                    LogItem(id, "Imported from CSV file.", GetViewNamespace(), dr);
                else
                    LogItem(id, "Imported from CSV file.", GetViewNamespace(), details, dr);
            }
        }

        protected abstract T ProcessRow(int row, int fieldCount, string[] headers, CsvReader csv, ImportDataResult dr);
        protected abstract int GetPrimaryKeyId(ref T entity);
        protected virtual string GetViewNamespace()
        {
            return string.Empty;
        }

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
        protected static int? InsertAndOrGetLookupId<J>(InventoryRepository context, Expression<Func<J, bool>> predicate, Expression<Func<J, int>> idProperty, J newObject, out bool inserted) where J : class
        {
            if (context.GetQuery<J>().Any<J>(predicate))
            {
                inserted = false;
                var entry = context.ContextManager.Entry<J>(context.GetQuery<J>().First<J>(predicate));
                return entry.Property(idProperty).CurrentValue;
            }
            else
            {
                // Insert new record when cannot not found.
                context.AddNew<J>(newObject);
                inserted = true;
                var entry = context.ContextManager.Entry<J>(newObject);
                context.Save();
                return entry.Property(idProperty).CurrentValue;
            }
        }

        protected static int? GetLookUpId<J>(InventoryRepository context, Expression<Func<J, bool>> predicate, Expression<Func<J, int>> idProperty) where J : class
        {
            if (context.GetQuery<J>().Any<J>(predicate))
            {
                var entry = context.ContextManager.Entry<J>(context.GetQuery<J>().First<J>(predicate));
                return entry.Property(idProperty).CurrentValue;
            }
            return null;
        }

        protected static J GetLookUpObject<J>(InventoryRepository context, Expression<Func<J, bool>> predicate) where J : class
        {
            if (context.GetQuery<J>().Any<J>(predicate))
            {
                var entry = context.ContextManager.Entry<J>(context.GetQuery<J>().First<J>(predicate));
                return entry.Entity;
            }
            return null;
        }

        protected static List<J> GetLookUps<J>(InventoryRepository context, Expression<Func<J, bool>> predicate) where J : class
        {
            if (context.GetQuery<J>().Any<J>(predicate))
            {
                return context.GetQuery<J>().Where<J>(predicate).ToList<J>();
            }
            return null;
        }

        protected void LogItem(int id, string action, string viewNamespace, ImportDataResult dr)
        {
            try
            {
                int entityId = iRely.Common.Security.GetEntityId();

                //context.ContextManager.Database.ExecuteSqlCommand(
                //    string.Format("uspSMAuditLog @screenName = '{0}', @keyValue = {1}, @entityId = {2}, @actionType = '{3}', @actionIcon='small-import'",
                //    viewNamespace, id.ToString(), entityId, action));

                context.ContextManager.Database.ExecuteSqlCommand(
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
                dr.Messages.Add(new ImportDataMessage()
                {
                    Message = "Can't log to audit trail." + ex.Message,
                    Type = TYPE_INNER_EXCEPTION
                });
                dr.Info = INFO_WARN;
            }
        }

        protected void LogItem(int id, string action, string viewNamespace, string description, string fromValue, string toValue, ImportDataResult dr)
        {
            try
            {
                int entityId = iRely.Common.Security.GetEntityId();

                //context.ContextManager.Database.ExecuteSqlCommand(
                //    string.Format("uspSMAuditLog @screenName = '{0}', @keyValue = {1}, @entityId = {2}, @actionType = '{3}', @changeDescription = '{4}', @fromValue = '{5}', @toValue='{6}', @actionIcon='small-import'",
                //    viewNamespace, id.ToString(), entityId, action, description, fromValue, toValue));

                context.ContextManager.Database.ExecuteSqlCommand(
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
                dr.Messages.Add(new ImportDataMessage()
                {
                    Message = "Can't log to audit trail." + ex.Message,
                    Type = TYPE_INNER_EXCEPTION
                });
                dr.Info = INFO_WARN;
            }
        }

        protected void LogItem(int id, string action, string viewNamespace, string details, ImportDataResult dr)
        {
            try
            {
                int entityId = iRely.Common.Security.GetEntityId();

                //context.ContextManager.Database.ExecuteSqlCommand(
                //    string.Format("uspSMAuditLog @screenName = '{0}', @keyValue = {1}, @entityId = {2}, @actionType = '{3}', @details = '{4}', @actionIcon='small-import'",
                //    viewNamespace, id.ToString(), entityId, action, details));

                context.ContextManager.Database.ExecuteSqlCommand(
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
                dr.Messages.Add(new ImportDataMessage()
                {
                    Message = "Can't log to audit trail." + ex.Message,
                    Type = TYPE_INNER_EXCEPTION
                });
                dr.Info = INFO_WARN;
            }
        }

        protected void LogDetailedItem(int id, string action, string viewNamespace, List<ImportLogItem> items, ImportDataResult dr)
        {
            string details = string.Empty;
            string comma = ",";
            int count = 0;
            foreach (ImportLogItem item in items)
            {
                count++;
                if (count == LogItems.Count && count == 1)
                    comma = "";
                details += "{\"change\":\"" + item.Description + "\",\"iconCls\":\"" + item.ActionIcon + "\",\"from\":\"" + item.FromValue + "\",\"to\":\"" + item.ToValue + "\",\"leaf\":true}" + comma;
            }

            if (string.IsNullOrEmpty(details))
                LogItem(id, "Imported from CSV file.", viewNamespace, dr);
            else
                LogItem(id, "Imported from CSV file.", viewNamespace, details, dr);
        }

        public InventoryRepository Context
        {
            get
            {
                return context;
            }
            set
            {
                this.context = value;
            }
        }

        public byte[] Data
        {
            get
            {
                return data;
            }
            set
            {
                this.data = value;
            }
        }

        public static void SetBoolean(string value, Action<bool> booleanDelegate)
        {
            try
            {
                if (value.Trim().ToLower() == "yes" || value.Trim().ToLower() == "no")
                    value = value.Trim().ToLower() == "yes" ? "true" : "false";
                if (value.Trim() == "1" || value.Trim() == "0")
                    value = value.Trim() == "1" ? "true" : "false";
                booleanDelegate(bool.Parse(value));
            }
            catch (Exception)
            {
                booleanDelegate(false);
            }
        }

        public static bool SetNonZeroDecimal(string value, Action<decimal> decimalDelegate, string caption, ImportDataResult dr, string header, int row)
        {
            if (string.IsNullOrEmpty(value))
                return false;

            try
            {
                decimal val = decimal.Parse(value);
                if (val <= 0)
                {
                    dr.Messages.Add(new ImportDataMessage()
                    {
                        Column = header,
                        Row = row,
                        Type = TYPE_INNER_ERROR,
                        Status = STAT_INNER_COL_SKIP,
                        Message = string.Format("Invalid value for {0}. {1}", caption, "Should be greater than zero.")
                    });
                    dr.Info = INFO_WARN;
                    return false;
                }
                decimalDelegate(decimal.Parse(value));
                return true;
            }
            catch (Exception ex)
            {
                dr.Messages.Add(new ImportDataMessage()
                {
                    Column = header,
                    Row = row,
                    Type = TYPE_INNER_ERROR,
                    Status = STAT_INNER_COL_SKIP,
                    Message = string.Format("Invalid value for {0}. {1}", caption, ex.Message)
                });
                dr.Info = INFO_WARN;
                return false;
            }
        }

        public static bool SetDecimal(string value, Action<decimal> decimalDelegate, string caption, ImportDataResult dr, string header, int row)
        {
            if (string.IsNullOrEmpty(value))
                return false;

            try
            {
                decimalDelegate(decimal.Parse(value));
                return true;
            }
            catch (Exception ex)
            {
                dr.Messages.Add(new ImportDataMessage()
                {
                    Column = header,
                    Row = row,
                    Type = TYPE_INNER_ERROR,
                    Status = STAT_INNER_COL_SKIP,
                    Message = string.Format("Invalid value for {0}. {1}", caption, ex.Message)
                });
                dr.Info = INFO_WARN;
                return false;
            }
        }

        public static bool SetInteger(string value, Action<int> intDelegate, string caption, ImportDataResult dr, string header, int row)
        {
            if (string.IsNullOrEmpty(value))
                return false;
            try
            {
                intDelegate(int.Parse(value));
                return true;
            }
            catch (Exception ex)
            {
                dr.Messages.Add(new ImportDataMessage()
                {
                    Column = header,
                    Row = row,
                    Type = TYPE_INNER_ERROR,
                    Status = STAT_INNER_COL_SKIP,
                    Message = string.Format("Invalid value for {0}. {1}", caption, ex.Message)
                });
                dr.Info = INFO_WARN;
                return false;
            }
        }

        public static bool SetDate(string value, Action<DateTime> dateDelegate, string caption, ImportDataResult dr, string header, int row)
        {
            if (string.IsNullOrEmpty(value))
                return false;
            try
            {
                dateDelegate(DateTime.Parse(value));
                return true;
            }
            catch (Exception ex)
            {
                dr.Messages.Add(new ImportDataMessage()
                {
                    Column = header,
                    Row = row,
                    Type = TYPE_INNER_ERROR,
                    Status = STAT_INNER_COL_SKIP,
                    Message = string.Format("Error parsing date for {0}. {1}", caption, ex.Message)
                });
                dr.Info = INFO_WARN;
                return false;
            }
        }

        public static bool SetText(string value, Action<string> textDelegate, string caption, ImportDataResult dr, string header, int row, bool required = false)
        {
            if (!string.IsNullOrEmpty(value.Trim()))
            {
                textDelegate(value.Trim());
                return true;
            }
            else
            {
                dr.Messages.Add(new ImportDataMessage()
                {
                    Column = header,
                    Row = row,
                    Type = required ? TYPE_INNER_ERROR : TYPE_INNER_WARN,
                    Status = required ? REC_SKIP : STAT_INNER_COL_SKIP,
                    Message = string.Format(required ? "The value for {0} should not be blank." : "The value for {0} is blank.", caption)
                });
                dr.Info = required ? INFO_ERROR : INFO_WARN;
                return false;
            }
        }

        public static bool SetText(string value, Action<string> textDelegate)
        {
            if (!string.IsNullOrEmpty(value.Trim()))
            {
                textDelegate(value.Trim());
                return true;
            }
            return false;
        }

        public static bool SetFixedLookup(string value, Action<string> fixedLUDelegate, string caption, IEnumerable<string> list, ImportDataResult dr, string header, int row, bool required = false)
        {
            if (!string.IsNullOrEmpty(value.Trim()))
            {
                if (list.Any(p => p.Trim().ToLower() == value.Trim().ToLower()))
                {
                    fixedLUDelegate(value.Trim());
                    return true;
                }
                dr.Messages.Add(new ImportDataMessage()
                {
                    Column = header,
                    Row = row,
                    Type = required ? TYPE_INNER_ERROR : TYPE_INNER_WARN,
                    Status = required ? REC_SKIP : STAT_INNER_COL_SKIP,
                    Message = string.Format("{0} is not a valid item in {1}.", value, caption)
                });
                dr.Info = required ? INFO_ERROR : INFO_WARN;
                return false;
            }
            else
            {
                dr.Messages.Add(new ImportDataMessage()
                {
                    Column = header,
                    Row = row,
                    Type = required ? TYPE_INNER_ERROR : TYPE_INNER_WARN,
                    Status = required ? REC_SKIP : STAT_INNER_COL_SKIP,
                    Message = string.Format(required ? "The value for {0} should not be blank." : "The value for {0} is blank.", caption)
                });
                dr.Info = required ? INFO_ERROR : INFO_WARN;
                return false;
            }
        }
    }
}
