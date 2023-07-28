--liquibase formatted sql

-- changeset Von:fnCMGetDetailsOfCharges.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION dbo.fnCMGetDetailsOfCharges
(
	@intEntityEFTInfoId AS INT
)
RETURNS NVARCHAR(50)
BEGIN
    DECLARE @strDetailsOfCharges NVARCHAR(50)

    SELECT TOP 1 @strDetailsOfCharges = strDetailsOfCharges FROM tblEMEntityEFTInformation WHERE intEntityEFTInfoId = @intEntityEFTInfoId
    IF ISNULL(@strDetailsOfCharges,'') = ''
    SELECT TOP 1 @strDetailsOfCharges = strDetailsOfCharges FROM tblAPCompanyPreference

    RETURN @strDetailsOfCharges

END



