﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCategoryAccount : BaseEntity
    {
        public int intCategoryAccountId { get; set; }
        public int intCategoryId { get; set; }
        public int? intAccountCategoryId { get; set; }
        public int? intAccountId { get; set; }
        public int? intSort { get; set; }

        private string _accountid;
        [NotMapped]
        public string strAccountId
        {
            get
            {
                if (string.IsNullOrEmpty(_accountid))
                    if (tblGLAccount != null)
                        return tblGLAccount.strAccountId;
                    else
                        return null;
                else
                    return _accountid;
            }
            set
            {
                _accountid = value;
            }
        }
        private string _description;
        [NotMapped]
        public string strDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_description))
                    if (tblGLAccount != null)
                        return tblGLAccount.strDescription;
                    else
                        return null;
                else
                    return _description;
            }
            set
            {
                _description = value;
            }
        }
        private string _accountGroup;
        [NotMapped]
        public string strAccountGroup
        {
            get
            {
                if (string.IsNullOrEmpty(_accountGroup))
                    if (tblGLAccount != null)
                        return tblGLAccount.strAccountGroup;
                    else
                        return null;
                else
                    return _accountGroup;
            }
            set
            {
                _accountGroup = value;
            }
        }
        private string _accountCategory;
        [NotMapped]
        public string strAccountCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_accountCategory))
                    if (tblGLAccountCategory != null)
                        return tblGLAccountCategory.strAccountCategory;
                    else
                        return null;
                else
                    return _accountCategory;
            }
            set
            {
                _accountCategory = value;
            }
        }

        public tblICCategory tblICCategory { get; set; }
        public tblGLAccount tblGLAccount { get; set; }
        public tblGLAccountCategory tblGLAccountCategory { get; set; }
    }
}
