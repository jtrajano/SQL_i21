CREATE PROCEDURE [dbo].[uspAPValidateVoucherImport]
	@UserId INT,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@isValid BIT OUTPUT
AS


DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NOT NULL, 
    [dtmDate] DATETIME NOT NULL,
	[intLogType] INT NOT NULL
)

IF(@UserId <= 0)
BEGIN
	INSERT INTO @log
	SELECT 'You cannot import without user.', @UserId, GETDATE(), 1
END

--MAKE SURE USER HAS DEFAULT LOCATION
DECLARE @userLocation INT;
SELECT @userLocation = A.intCompanyLocationId FROM tblSMCompanyLocation A
		INNER JOIN tblSMUserSecurity B ON A.intCompanyLocationId = B.intCompanyLocationId
WHERE intEntityUserSecurityId = @UserId

IF(@userLocation IS NULL OR @userLocation <= 0)
BEGIN
	INSERT INTO @log
	SELECT 'Please setup default location on user screen.', @UserId, GETDATE(), 2
END