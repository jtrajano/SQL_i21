
CREATE PROCEDURE [dbo].[uspGLGetOverrideGLAccount]
(
	@intAccountId INT, -- Overriding Account
	@intAccountId1 INT, -- Account that will be overriden
	@intStructureType INT = 3,
    @intBankTransferTypeId INT,
    @intAccountOverride INT OUT
)
AS
BEGIN

IF @intStructureType = 3
IF NOT EXISTS( 
		SELECT 1 FROM tblCMCompanyPreferenceOption WHERE ysnOverrideLocationSegment_InTransit = 1 AND @intBankTransferTypeId = 2 UNION 
		SELECT 1 FROM tblCMCompanyPreferenceOption WHERE ysnOverrideLocationSegment_Forward = 1 AND @intBankTransferTypeId = 3 UNION
		SELECT 1 FROM tblCMCompanyPreferenceOption WHERE ysnOverrideLocationSegment_Swap = 1 AND @intBankTransferTypeId IN (4, 5) 
	)
    BEGIN
    SET @intAccountOverride =@intAccountId1
    GOTO _end
    END

IF @intStructureType = 6
IF NOT EXISTS( 
		SELECT 1 FROM tblCMCompanyPreferenceOption WHERE ysnOverrideCompanySegment_InTransit = 1 AND @intBankTransferTypeId = 2 UNION 
		SELECT 1 FROM tblCMCompanyPreferenceOption WHERE ysnOverrideCompanySegment_Forward = 1 AND @intBankTransferTypeId = 3 UNION
		SELECT 1 FROM tblCMCompanyPreferenceOption WHERE ysnOverrideCompanySegment_Swap = 1 AND @intBankTransferTypeId IN (4, 5)
	)
    BEGIN
    SET @intAccountOverride =@intAccountId1
    GOTO _end
    END

IF NOT EXISTS(SELECT 1 FROM tblGLAccountStructure WHERE intStructureType = @intStructureType)
BEGIN
	SET @intAccountOverride = @intAccountId1
	GOTO _end
END


DECLARE @strAccountId NVARCHAR(30) ,@strAccountId1 NVARCHAR(30) , @msg NVARCHAR(100)
SELECT @strAccountId = strAccountId from tblGLAccount where intAccountId = @intAccountId
SELECT @strAccountId1 = strAccountId from tblGLAccount where intAccountId = @intAccountId1

IF @strAccountId IS NULL
BEGIN
	SET @msg = 'Overriding Account Id is not existing GL Account for Gain/Loss'
	GOTO _raiserror
END
IF @strAccountId1 IS NULL
BEGIN
	SET @msg = 'Account Id To Override is not existing GL Account for Gain/Loss'
	GOTO _raiserror
END



DECLARE @intStart INT, @intEnd INT, @intLength INT, @intDividerCount INT
SELECT @intDividerCount = count(1)  from tblGLAccountStructure WHERE strType <> 'Divider' and intStructureType < @intStructureType

SELECT @intStart = SUM(intLength) + @intDividerCount from tblGLAccountStructure WHERE strType <> 'Divider' and intStructureType < @intStructureType -- location
SELECT @intLength = intLength from tblGLAccountStructure WHERE intStructureType = @intStructureType -- lob
SELECT @intEnd = @intStart + @intLength

DECLARE @strSegment NVARCHAR(10) 
SELECT @strSegment = SUBSTRING(@strAccountId,@intStart+1,@intLength)
declare @intL int = len(@strAccountId)
declare @str NVARCHAR(30)=''
DECLARE @i int = 1
WHILE @i <= @intL
BEGIN
	if @i > @intStart and @i < @intEnd
	BEGIN
		SELECT @str+= @strSegment
		SET @i = @i + @intLength
	END
	ELSE
	BEGIN
		SELECT @str+= SUBSTRING(@strAccountId1, @i, 1)
		SET @i=@i+1
	END
END


IF @str = ''
BEGIN
	SET @msg = 'Unknown error overriding GL Account'
	GOTO _raiserror
END
ELSE
IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccount WHERE strAccountId = @str)
BEGIN
	SET @msg = @str + ' Not an existing account for override for Gain/Loss.'
	GOTO _raiserror
END
ELSE
BEGIN
	SELECT @intAccountOverride = intAccountId FROM tblGLAccount WHERE strAccountId = @str
	GOTO _end
END

_raiserror:
	RAISERROR (@msg ,16,1)

_end:


END