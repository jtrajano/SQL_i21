CREATE PROCEDURE [dbo].[uspTFDefault]

@Guid NVARCHAR(150),
@FormCodeParam NVARCHAR(1000),
@DateFrom DATETIME,
@DateTo DATETIME

AS

DELETE FROM tblTFTransactions --WHERE uniqTransactionGuid = @Guid

INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, dtmDate, dtmReportingPeriodBegin, dtmReportingPeriodEnd, leaf)
VALUES(@Guid, 0, @FormCodeParam, GETDATE(), @DateFrom, @DateTo, 1)