CREATE FUNCTION dbo.fnCMGetDetailsOfCharges
(
	@intEntityId AS INT
)
RETURNS NVARCHAR(50)
BEGIN
    DECLARE @strDetailsOfCharges NVARCHAR(50)

    SELECT TOP 1 @strDetailsOfCharges = strDetailsOfCharges FROM tblEMEntityEFTInformation WHERE intEntityId = @intEntityId
    IF ISNULL(@strDetailsOfCharges,'') = ''
    SELECT TOP 1 @strDetailsOfCharges = strDetailsOfCharges FROM tblAPCompanyPreference

    RETURN @strDetailsOfCharges

END