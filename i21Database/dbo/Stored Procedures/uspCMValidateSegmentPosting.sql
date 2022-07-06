

CREATE PROCEDURE uspCMValidateSegmentPosting
@intAccountId INT,
@intAccountId1 INT,
@intStructureType INT,
@intBankTransferTypeId INT
AS

DECLARE @strLocationId nvarchar(10), @strLocationId1  nvarchar(10)
DECLARE @strCompanyId  nvarchar(10), @strCompanyId1  nvarchar(10)


IF @intStructureType = 3
BEGIN
    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenLocations_Swap = 0 AND @intBankTransferTypeId = 4)
    BEGIN
    
        _beginL:
        
        SELECT @strLocationId = '' , @strLocationId1 = ''

        SELECT TOP 1 @strLocationId = [Location] FROM tblGLTempCOASegment WHERE intAccountId = @intAccountId
        SELECT TOP 1 @strLocationId1 = [Location] FROM tblGLTempCOASegment WHERE intAccountId = @intAccountId1

        IF @strLocationId <> @strLocationId1
        BEGIN
            RAISERROR('Posting between locations is not allowed', 16,1)
            GOTO _end
        END
		ELSE
			GOTO _end
    END

    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenLocations_Forward = 0 AND @intBankTransferTypeId = 3)
        GOTO _beginL


    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenLocations_InTransit = 0 AND @intBankTransferTypeId = 2)
        GOTO _beginL

END


IF EXISTS (SELECT TOP 1 1 FROM tblGLAccountStructure WHERE intStructureType = 6 ) AND @intStructureType = 6
BEGIN
    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenCompanies_Swap = 0 AND @intBankTransferTypeId = 4)
    BEGIN
        _beginC:

        SELECT @strCompanyId = '' , @strCompanyId1 = ''

        DECLARE @sql nvarchar(max) = 'SELECT TOP 1 @strCompanyId = [Company] FROM tblGLTempCOASegment WHERE intAccountId = @intAccountId'
        EXEC sys.sp_executesql @sql, N'@intAccountId INT, @strCompanyId NVARCHAR(10) OUT', @intAccountId,@strCompanyId OUT
        EXEC sys.sp_executesql @sql, N'@intAccountId INT, @strCompanyId NVARCHAR(10) OUT', @intAccountId1,@strCompanyId1 OUT

        IF @strCompanyId <> @strCompanyId1
        BEGIN
            RAISERROR('Posting between companies is not allowed', 16,1)
            GOTO _end
        END
		ELSE
			GOTO _end

    END

    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenCompanies_Forward = 0 AND @intBankTransferTypeId = 3)
        GOTO _beginC


    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenCompanies_InTransit = 0 AND @intBankTransferTypeId = 2)
        GOTO _beginC


END

_end: