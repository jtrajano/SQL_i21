CREATE PROCEDURE uspCMValidateSegmentPosting
@intAccountId INT,
@intAccountId1 INT,
@intStructureType INT,
@intBankTransferTypeId INT
AS

DECLARE @intLocationId INT, @intLocationId1 INT
DECLARE @intCompanyId INT, @intCompanyId1 INT


IF @intStructureType = 3
BEGIN
    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenLocations_Swap = 0 AND @intBankTransferTypeId = 4)
    BEGIN
    
        _beginL:
        
        SELECT @intCompanyId = NULL , @intCompanyId1 = NULL

        SELECT TOP 1 @intLocationId = [Location] FROM tblGLAccount A JOIN tblGLTempCOASegment B ON A.intAccountId = B.intAccountId    AND A.intAccountId = @intAccountId
        SELECT TOP 1 @intLocationId1 = [Location] FROM tblGLAccount A JOIN tblGLTempCOASegment B ON A.intAccountId = B.intAccountId    AND A.intAccountId = @intAccountId1

        IF @intAccountId <> @intAccountId1
        BEGIN
            RAISERROR('Posting between locations is not allowed', 16,1)
            GOTO _end
        END
    END

    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenLocations_Forward = 0 AND @intBankTransferTypeId = 3)
        GOTO _beginL


    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenLocations_Forward = 0 AND @intBankTransferTypeId = 2)
        GOTO _beginL

END


IF EXISTS (SELECT TOP 1 1 FROM tblGLAccountStructure WHERE intStructureType = 6 ) AND @intStructureType = 6
BEGIN
    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenCompanies_Swap = 0 AND @intBankTransferTypeId = 4)
    BEGIN
        _beginC:

        SELECT @intCompanyId = NULL , @intCompanyId1 = NULL

        DECLARE @sql nvarchar(max) = 'SELECT TOP 1 @intCompanyId = [Company] FROM tblGLAccount A JOIN tblGLTempCOASegment B ON A.intAccountId = B.intAccountId    AND A.intAccountId = @intAccountId'
        EXEC sys.sp_executesql @sql, N'@intAccountId, @intCompanyId INT OUT', @intAccountId,@intCompanyId OUT
        EXEC sys.sp_executesql @sql, N'@intAccountId, @intCompanyId INT OUT', @intAccountId,@intCompanyId1 OUT

        IF @intCompanyId <> @intCompanyId1
        BEGIN
            RAISERROR('Posting between companies is not allowed', 16,1)
            GOTO _end
        END

    END

    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenCompanies_Forward = 0 AND @intBankTransferTypeId = 3)
        GOTO _beginC


    IF EXISTS (SELECT TOP 1 1 FROM tblCMCompanyPreferenceOption WHERE ysnAllowBetweenCompanies_InTransit = 0 AND @intBankTransferTypeId = 2)
        GOTO _beginC


END

_end: