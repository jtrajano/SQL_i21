using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public static class Constants
    {
        #region Constants
        public const string ACTION_DISCARDED = "Value discarded";
        public const string ACTION_DEFAULTED = "Value set to default";
        public const string ACTION_INSERTED = "Record inserted";
        public const string ACTION_UPDATED = "Record updated";
        public const string ACTION_AUTO_GENERATED = "Value auto-generated";
        public const string ACTION_SKIPPED = "Record skipped";

        public const string STAT_SUCCESS = "Success";
        public const string STAT_FAILED = "Failed";

        public const string TYPE_WARNING = "Warning";
        public const string TYPE_EXCEPTION = "Exception";
        public const string TYPE_ERROR = "Error";
        public const string TYPE_INFO = "Info";

        public const string ICON_ACTION_NEW = "small-new-plus";
        public const string ICON_ACTION_EDIT = "small-edit";
        #endregion
    }
}
