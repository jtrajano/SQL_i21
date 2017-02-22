CREATE PROCEDURE [dbo].[uspTFDefault]

@Guid NVARCHAR(150),
@FormCodeParam NVARCHAR(MAX),
@DateFrom DATETIME,
@DateTo DATETIME

AS

DELETE FROM tblTFTransaction --WHERE uniqTransactionGuid = @Guid

INSERT INTO tblTFTransaction (uniqTransactionGuid, intTaxAuthorityId, strFormCode, strProductCode, dtmDate, dtmReportingPeriodBegin, dtmReportingPeriodEnd, leaf)
VALUES(@Guid, 0, @FormCodeParam, 'No record found.', GETDATE(), @DateFrom, @DateTo, 1)