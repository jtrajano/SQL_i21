CREATE PROCEDURE [dbo].[uspSMInsertModule]
	@strApplicationName NVARCHAR(30),
	@strModule NVARCHAR(30),
	@strAppCode NVARCHAR(5) = '',
	@ysnSupported BIT = 1,
	@ysnCustomerModule BIT = 1,
	@intSort INT = 0,
	@ysnFirst bit = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE intModuleId = 100001)
BEGIN
	SET IDENTITY_INSERT tblSMModule ON
	
	INSERT INTO tblSMModule(intModuleId, strApplicationName, strModule, strAppCode, ysnSupported, ysnCustomerModule, intSort)
	SELECT 100001, @strApplicationName, @strModule, @strAppCode, @ysnSupported, @ysnCustomerModule, 100001
	
	SET IDENTITY_INSERT tblSMModule OFF

	SET @ysnFirst = 1
END

