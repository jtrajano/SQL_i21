CREATE PROCEDURE [dbo].[uspSMDuplicateLetter]
	@letterId INT,
	@newLetterId INT OUTPUT
AS
BEGIN

	DECLARE @intCount NVARCHAR

	SELECT @intCount = COUNT(*) FROM [tblSMLetter] WHERE [strName] LIKE 'DUP: ' + (SELECT [strName] FROM [dbo].[tblSMLetter] WHERE intLetterId = @letterId) + '%' 

	INSERT dbo.tblSMLetter([strName], [strDescription], [blbMessage], [strModuleName], [ysnSystemDefined], [intSourceLetterId])
	SELECT CASE @intCount WHEN 0 
		   THEN 'DUP: ' + [strName] 
		   ELSE 'DUP: ' + [strName] + ' (' + @intCount + ')' END,
	[strDescription], 
	[blbMessage], 
	[strModuleName], 
	0,
	@letterId
	FROM dbo.tblSMLetter 
	WHERE [intLetterId] = @letterId;
	
	SET @newLetterId = SCOPE_IDENTITY();

END