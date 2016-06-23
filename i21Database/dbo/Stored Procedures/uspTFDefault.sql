CREATE PROCEDURE [dbo].[uspTFDefault]

@Guid NVARCHAR(150),
@FormReport NVARCHAR(1000),
@DateFrom DATETIME,
@DateTo DATETIME

AS

DELETE FROM tblTFTransactions

INSERT INTO tblTFTransactions (uniqTransactionGuid, intTaxAuthorityId, strFormCode, dtmDate, dtmReportingPeriodBegin, dtmReportingPeriodEnd, leaf)VALUES(@Guid, 0, @FormReport, @DateFrom, @DateFrom, @DateTo, 1)

