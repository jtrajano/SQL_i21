﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public sealed class GlobalSettings
    {
        private GlobalSettings()
        {
        }
        private static GlobalSettings instance;

        public static GlobalSettings Instance
        {
            get
            {
                if (instance == null)
                    instance = new GlobalSettings();
                return instance;
            }
        }

        public bool AllowOverwriteOnImport { get; set; }
        public string LineOfBusiness { get; set; }
        public bool AllowDuplicates { get; set; }
        public string FileName { get; set; }
        public string FileType { get; set; }
        public string ImportType { get; set; }
        public bool ContinueOnFailedImports { get; set; } = true;
        public bool VerboseLog { get; set; } = false;
    }
}
