using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportDataResult
    {
        public int LogId { get; set; }
        public string Username { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
        private List<ImportDataMessage> _messages;
        public bool IsUpdate { get; set; }
        public int TotalRows { get; set; }
        public int RowsImported { get; set; }
        public int RowsUpdated { get; set; }
        public double TimeSpentInSeconds { get; set; }
        private int _errors = 0;
        private int _warnings = 0;
        public bool Failed { get; set; }

        public int Errors { get { return _errors; } }
        public int Warnings { get { return _warnings; } }
        public bool HasMessages { get { return Messages.Count > 0; } }

        public ImportDataResult()
        {
            _messages = new List<ImportDataMessage>();
        }

        public List<ImportDataMessage> Messages
        {
            get { return _messages; }
            set { _messages = value; }
        }

        public void AddError(ImportDataMessage msg)
        {
            Messages.Add(msg);
            _errors++;
        }

        public void AddWarning(ImportDataMessage msg)
        {
            Messages.Add(msg);
            _warnings++;
        }

        public void AddMessage(ImportDataMessage msg)
        {
            Messages.Add(msg);
        }

        public void Clear()
        {
            _messages.Clear();
            _warnings = 0;
            _errors = 0;
            TotalRows = 0;
            RowsImported = 0;
        }
    }
}
