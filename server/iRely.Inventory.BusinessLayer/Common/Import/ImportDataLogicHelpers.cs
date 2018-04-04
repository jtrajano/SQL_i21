using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity;
using System.Data.Entity.Core.Objects;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public sealed class ImportDataLogicHelpers
    {
        public static IEnumerable<PropertyInfo> GetPropertyByAttribute(Type entity, Type attribute)
        {
            return entity.GetProperties().Where(prop => Attribute.IsDefined(prop, attribute));
        }

        public static PropertyInfo GetPrimaryKey(Type entity)
        {
            var key = GetPropertyByAttribute(entity, typeof(KeyAttribute)).FirstOrDefault();
            if (key == null)
            {
                key = GetPrimaryKeyFromCustomAttribute(entity).FirstOrDefault();
            }
            return key;
        }

        public static string GetPrimaryKeyFromFluent(DbContext context, Type entity)
        {
            ObjectContext objectContext = ((IObjectContextAdapter) context).ObjectContext;
            return objectContext.MetadataWorkspace
                .GetType(entity.Name, entity.Namespace, System.Data.Entity.Core.Metadata.Edm.DataSpace.CSpace)
                .MetadataProperties
                .Where(mp => mp.Name == "KeyMembers")
                .FirstOrDefault().Value.ToString();
        }

        public static IEnumerable<PropertyInfo> GetPrimaryKeyFromCustomAttribute(Type entity)
        {
            return (from property in entity.GetProperties()
                    where Attribute.IsDefined(property, typeof(KeyAttribute))
                    orderby ((ColumnAttribute)property.GetCustomAttributes(false).Single(
                        attr => attr is ColumnAttribute)).Order ascending
                    select property).ToList();
        }

        public static string GetFieldValue(CsvRecord record, string key, string defaultValue = null)
        {
            if (record.Schema.Fields.Contains(key))
            {
                return record[key];
            }
            return defaultValue == null ? string.Empty : defaultValue;
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
        public static int? InsertAndOrGetLookupId<J>(DbContext context, Expression<Func<J, bool>> predicate, Expression<Func<J, int>> idProperty, J newObject, out bool inserted) where J : class
        {
            if (context.Set<J>().Any<J>(predicate))
            {
                inserted = false;
                var entry = context.Entry<J>(context.Set<J>().First<J>(predicate));
                return entry.Property(idProperty).CurrentValue;
            }
            else
            {
                // Insert new record when cannot not found.
                context.Set<J>().Add(newObject);
                inserted = true;
                var entry = context.Entry<J>(newObject);
                context.SaveChanges();
                return entry.Property(idProperty).CurrentValue;
            }
        }

        public static int? GetLookUpId<J>(DbContext context, Expression<Func<J, bool>> predicate, Expression<Func<J, int>> idProperty) where J : class
        {
            if (context.Set<J>().Any<J>(predicate))
            {
                var entry = context.Entry<J>(context.Set<J>().First<J>(predicate));
                return entry.Property(idProperty).CurrentValue;
            }
            return null;
        }

        public static int? GetLookUpId<J>(DbContext context, Expression<Func<J, bool>> predicate, Expression<Func<J, int?>> idProperty) where J : class
        {
            if (context.Set<J>().Any<J>(predicate))
            {
                var entry = context.Entry<J>(context.Set<J>().First<J>(predicate));
                return entry.Property(idProperty).CurrentValue;
            }
            return null;
        }

        public static int GetIntLookUpId<J>(DbContext context, Expression<Func<J, bool>> predicate, Expression<Func<J, int?>> idProperty) where J : class
        {
            if (context.Set<J>().Any<J>(predicate))
            {
                var entry = context.Entry<J>(context.Set<J>().First<J>(predicate));
                return (int) entry.Property(idProperty).CurrentValue;
            }
            return 0;
        }

        public static J GetLookUpObject<J>(DbContext context, Expression<Func<J, bool>> predicate) where J : class
        {
            if (context.Set<J>().Any<J>(predicate))
            {
                var entry = context.Entry<J>(context.Set<J>().First<J>(predicate));
                return entry.Entity;
            }
            return null;
        }

        public static List<J> GetLookUps<J>(DbContext context, Expression<Func<J, bool>> predicate) where J : class
        {
            if (context.Set<J>().Any<J>(predicate))
            {
                return context.Set<J>().Where<J>(predicate).ToList<J>();
            }
            return null;
        }

        public static void SetBoolean(CsvRecord record, string header, Action<bool> booleanDelegate)
        {
            try
            {
                var value = "false";
                if (GetFieldValue(record, header, "").Trim().ToLower() == "yes" || GetFieldValue(record, header, "").Trim().ToLower() == "no")
                    value = GetFieldValue(record, header, "").Trim().ToLower() == "yes" ? "true" : "false";
                if (GetFieldValue(record, header, "").Trim() == "1" || GetFieldValue(record, header, "").Trim() == "0")
                    value = GetFieldValue(record, header, "").Trim() == "1" ? "true" : "false";
                booleanDelegate(bool.Parse(value));
            }
            catch (Exception)
            {
                booleanDelegate(false);
            }
        }

        public static bool SetNonZeroDecimal(ImportDataResult ImportResult, CsvRecord record, string header, Action<decimal> decimalDelegate)
        {
            var value = GetFieldValue(record, header, "");
            if (string.IsNullOrEmpty(value.Trim()))
            {
                return false;
            }

            try
            {
                decimal val = decimal.Parse(value);
                if (val <= 0)
                {
                    ImportResult.AddWarning(new ImportDataMessage()
                    {
                        Column = header,
                        Row = record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Value = value,
                        Status = Constants.STAT_FAILED,
                        Exception = null,
                        Action = Constants.ACTION_DISCARDED,
                        Message = string.Format("Invalid value for {0}. {1}", header, "Should be greater than zero.")
                    });
                    return false;
                }
                decimalDelegate(decimal.Parse(value));
                return true;
            }
            catch (Exception ex)
            {
                ImportResult.Messages.Add(new ImportDataMessage()
                {
                    Column = header,
                    Row = record.RecordNo,
                    Type = Constants.TYPE_WARNING,
                    Value = value,
                    Status = Constants.STAT_FAILED,
                    Exception = ex,
                    Action = Constants.ACTION_DISCARDED,
                    Message = string.Format("Invalid value for {0}. {1}", header, ex.Message)
                });
                return false;
            }
        }

        public static bool SetDecimal(ImportDataResult ImportResult, CsvRecord record, string header, Action<decimal> decimalDelegate)
        {
            var value = GetFieldValue(record, header, "");
            if (string.IsNullOrEmpty(value.Trim()))
            {
                return false;
            }

            try
            {
                decimalDelegate(decimal.Parse(value));
                return true;
            }
            catch (Exception ex)
            {
                ImportResult.AddWarning(new ImportDataMessage()
                {
                    Column = header,
                    Row = record.RecordNo,
                    Type = Constants.TYPE_WARNING,
                    Value = value,
                    Status = Constants.STAT_FAILED,
                    Exception = ex,
                    Action = Constants.ACTION_DISCARDED,
                    Message = string.Format("Invalid value for {0}. {1}", header, ex.Message)
                });
                return false;
            }
        }

        public static bool SetInteger(ImportDataResult ImportResult, CsvRecord record, string header, Action<int> intDelegate)
        {
            var value = GetFieldValue(record, header, "");
            if (string.IsNullOrEmpty(value.Trim()))
            {
                return false;
            }

            try
            {
                intDelegate(int.Parse(value));
                return true;
            }
            catch (Exception ex)
            {
                ImportResult.AddWarning(new ImportDataMessage()
                {
                    Column = header,
                    Row = record.RecordNo,
                    Type = Constants.TYPE_WARNING,
                    Value = value,
                    Status = Constants.STAT_FAILED,
                    Exception = ex,
                    Action = Constants.ACTION_DISCARDED,
                    Message = string.Format("Invalid value for {0}. {1}", header, ex.Message)
                });
                return false;
            }
        }

        public static bool SetDate(ImportDataResult ImportResult, CsvRecord record, string header, Action<DateTime> dateDelegate)
        {
            if (string.IsNullOrEmpty(GetFieldValue(record, header)))
                return false;
            try
            {
                dateDelegate(DateTime.Parse(GetFieldValue(record, header)));
                return true;
            }
            catch (Exception ex)
            {
                ImportResult.AddWarning(new ImportDataMessage()
                {
                    Column = header,
                    Row = record.RecordNo,
                    Type = Constants.TYPE_WARNING,
                    Value = GetFieldValue(record, header),
                    Status = Constants.STAT_FAILED,
                    Exception = ex,
                    Action = Constants.ACTION_DISCARDED,
                    Message = string.Format("Error parsing date for {0}. {1}", header, ex.Message)
                });
                return false;
            }
        }

        public static bool SetText(ImportDataResult ImportResult, CsvRecord record, string header, Action<string> textDelegate, bool required = false)
        {
            if (!string.IsNullOrEmpty(GetFieldValue(record, header, "").Trim()))
            {
                textDelegate(GetFieldValue(record, header, "").Trim());
                return true;
            }
            else
            {
                var msg = new ImportDataMessage()
                {
                    Column = header,
                    Row = record.RecordNo,
                    Type = required ? Constants.TYPE_ERROR : Constants.TYPE_WARNING,
                    Status = required ? Constants.STAT_FAILED : Constants.STAT_SUCCESS,
                    Action = required ? Constants.ACTION_SKIPPED : Constants.ACTION_DISCARDED,
                    Exception = null,
                    Value = GetFieldValue(record, header, ""),
                    Message = string.Format(required ? "The value for {0} should not be blank." : "The value for {0} is blank.", header)
                };
                if (required)
                    ImportResult.AddError(msg);
                else
                {
                    if(GlobalSettings.Instance.VerboseLog)
                        ImportResult.AddWarning(msg);
                }
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

        public static bool SetLookupId<J>(DbContext context, ImportDataResult ImportResult, CsvRecord record, string header, Expression<Func<J, bool>> predicate, Expression<Func<J, int?>> idProperty, Action<int?> intDelegate, bool required = false, string defaultValue = "") where J : class
        {
            var id = GetLookUpId<J>(context, predicate, idProperty);
            intDelegate(id);

            if (id == null)
            {
                var msg = new ImportDataMessage()
                {
                    Column = header,
                    Row = record.RecordNo,
                    Type = required ? Constants.TYPE_ERROR : Constants.TYPE_WARNING,
                    Status = required ? Constants.STAT_FAILED : Constants.STAT_SUCCESS,
                    Action = required ? Constants.ACTION_SKIPPED : Constants.ACTION_DISCARDED,
                    Exception = null,
                    Value = GetFieldValue(record, header, defaultValue),
                    Message = string.IsNullOrEmpty(GetFieldValue(record, header, defaultValue)) ? string.Format(required ? "The value for {0} should not be blank." : "The value for {0} is blank.", header) :
                        string.Format("Invalid value for '{0}'. '{1}' does not exists.", header, GetFieldValue(record, header, defaultValue))
                };
                if (required)
                    ImportResult.AddError(msg);
                else
                {
                    if (GlobalSettings.Instance.VerboseLog)
                        ImportResult.AddWarning(msg);
                }
            }
            return id != null;
        }

        public static bool SetIntLookupId<J>(DbContext context, ImportDataResult ImportResult, CsvRecord record, string header, Expression<Func<J, bool>> predicate, Expression<Func<J, int?>> idProperty, Action<int> intDelegate, bool required = false) where J : class
        {
            var id = GetIntLookUpId<J>(context, predicate, idProperty);
            intDelegate(id);

            if (id == 0)
            {
                var msg = new ImportDataMessage()
                {
                    Column = header,
                    Row = record.RecordNo,
                    Type = required ? Constants.TYPE_ERROR : Constants.TYPE_WARNING,
                    Status = required ? Constants.STAT_FAILED : Constants.STAT_SUCCESS,
                    Action = required ? Constants.ACTION_SKIPPED : Constants.ACTION_DISCARDED,
                    Exception = null,
                    Value = GetFieldValue(record, header),
                    Message = string.IsNullOrEmpty(GetFieldValue(record, header)) ? string.Format(required ? "The value for {0} should not be blank." : "The value for {0} is blank.", header) :
                        string.Format("Invalid value for '{0}'. '{1}' does not exists.", header, GetFieldValue(record, header))
                };
                if (required)
                    ImportResult.AddError(msg);
                else
                {
                    if (GlobalSettings.Instance.VerboseLog)
                        ImportResult.AddWarning(msg);
                }
            }
            return id != 0;
        }

        public static bool SetFixedLookup(ImportDataResult ImportResult, CsvRecord record, string header, Action<string> fixedLUDelegate, IEnumerable<string> list, bool required = false, bool exactMatch = true)
        {
            if (!string.IsNullOrEmpty(GetFieldValue(record, header, "").Trim()))
            {
                if (exactMatch)
                {
                    if (list.Any(p => p.Trim().ToLower() == GetFieldValue(record, header, "").Trim().ToLower()))
                    {
                        fixedLUDelegate(GetFieldValue(record, header, "").Trim());
                        return true;
                    }
                }
                else
                {
                    if (list.Any(p => p.Trim().ToLower().Contains(GetFieldValue(record, header, "").Trim().ToLower())))
                    {
                        fixedLUDelegate(GetFieldValue(record, header, "").Trim());
                        return true;
                    }
                }
                var msg = new ImportDataMessage()
                {
                    Column = header,
                    Row = record.RecordNo,
                    Type = required ? Constants.TYPE_ERROR : Constants.TYPE_WARNING,
                    Status = required ? Constants.STAT_FAILED : Constants.STAT_SUCCESS,
                    Action = required ? Constants.ACTION_SKIPPED : Constants.ACTION_DISCARDED,
                    Exception = null,
                    Value = GetFieldValue(record, header, ""),
                    Message = string.Format("{0} is not a valid item in {1}.", GetFieldValue(record, header, ""), header)
                };
                if (required)
                    ImportResult.AddError(msg);
                else
                    ImportResult.AddWarning(msg);
                return false;
            }
            else
            {
                var msg = new ImportDataMessage()
                {
                    Column = header,
                    Row = record.RecordNo,
                    Type = required ? Constants.TYPE_ERROR : Constants.TYPE_WARNING,
                    Status = required ? Constants.STAT_FAILED : Constants.STAT_SUCCESS,
                    Action = required ? Constants.ACTION_SKIPPED : Constants.ACTION_DISCARDED,
                    Exception = null,
                    Value = GetFieldValue(record, header, ""),
                    Message = string.Format(required ? "The value for {0} should not be blank." : "The value for {0} is blank.", header)
                };
                if (required)
                    ImportResult.AddError(msg);
                else
                {
                    if (GlobalSettings.Instance.VerboseLog)
                        ImportResult.AddWarning(msg);
                }
                return false;
            }
        }
    }
}
