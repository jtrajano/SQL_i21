﻿DECLARE @intDefaultCurrencyID INT 
SELECT TOP 1  @intDefaultCurrencyID=intDefaultCurrencyId  FROM tblSMCompanyPreference
UPDATE tblGLAccount SET  intCurrencyID=@intDefaultCurrencyID WHERE intCurrencyID IS NULL