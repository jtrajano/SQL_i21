﻿--THIS WILL UPDATE THE tblAPBill.intContactId
--IF(EXISTS(SELECT 1 FROM tblAPBill WHERE intContactId NOT IN (SELECT intEntityId FROM tblEntityContact