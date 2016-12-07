DECLARE @ReportingComponentId NVARCHAR(10)
DECLARE @intTaxAuthorityId INT

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN

SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '1')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '1', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '2')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '2', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '3')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '3', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '4')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '4', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '5')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '5', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '6')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '6', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '7')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '7', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '8')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '8', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '9')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '9', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '10')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '10', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '11')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '11', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '12')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '12', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '13')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '13', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '14')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '14', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '15')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '15', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '16')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '16', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '17')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '17', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '18')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '18', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '19')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '19', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '20')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '20', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '21')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '21', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '22')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '22', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '23')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '23', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '24')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '24', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '25')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '25', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '26')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '26', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '27')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '27', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '28')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '28', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '29')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '29', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '30')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '30', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '31')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '31', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '32')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '32', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '33')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '33', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '34')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '34', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '37')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '37', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '40')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '40', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '41')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '41', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '42')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '42', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '43')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '43', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '44')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '44', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '45')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '45', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '46')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '46', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '47')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '47', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '48')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '48', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '49')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '49', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '50')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '50', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '51')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '51', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '52')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '52', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '56')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '56', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '57')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '57', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '58')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '58', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '59')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '59', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '60')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '60', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '61')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '61', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '62')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '62', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '63')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '63', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '64')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '64', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '65')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '65', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '66')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '66', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '67')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '67', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '68')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '68', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '69')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '69', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '70')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '70', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '71')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '71', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '72')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '72', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '73')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '73', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '74')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '74', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '75')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '75', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '76')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '76', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '77')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '77', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '78')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '78', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '79')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '79', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '80')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '80', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '81')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '81', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '82')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '82', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '83')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '83', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '84')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '84', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '85')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '85', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '86')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '86', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '87')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '87', '1', '2')
END
SET @ReportingComponentId = (SELECT TOP 1 intReportingComponentId FROM tblTFFilingPacket WHERE intReportingComponentId = '88')
IF @ReportingComponentId IS NULL
BEGIN
INSERT INTO [tblTFFilingPacket]([intTaxAuthorityId],[intReportingComponentId],[ysnStatus],[intFrequency])
VALUES(@intTaxAuthorityId, '88', '1', '2')
END

END