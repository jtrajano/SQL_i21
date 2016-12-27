CREATE PROCEDURE [dbo].[uspTFRefresh]

@Guid NVARCHAR(150)

AS 

DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid
DELETE FROM tblTFTransactionSummary --WHERE strSummaryGuid = @Guid