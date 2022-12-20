DECLARE @intDefaultCurrencyID INT 
SELECT TOP 1  @intDefaultCurrencyID=intDefaultCurrencyId  FROM tblSMCompanyPreference
UPDATE tblGLAccountReallocation  set intCurrencyId = @intDefaultCurrencyID where intCurrencyId IS NULL