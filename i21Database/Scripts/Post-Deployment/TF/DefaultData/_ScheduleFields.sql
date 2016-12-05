
PRINT 'START TF Schedule Fields'
DECLARE @ScheduleFieldTemplateId INT

SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 1 AND strColumn = 'strTransporterName' END

SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 1 AND strColumn = 'strTransporterFederalTaxId' END

SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 1 AND strColumn = 'strTransporterName' END


SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 1 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 1 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 1 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 1 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 1 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 1 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 1 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 1 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 1 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 1 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(1, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 1 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 2 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 2 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 2 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 2 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 2 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 2 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 2 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 2 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 2 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 2 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 2 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 2 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 2 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(2, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 2 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 3 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 3 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 3 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 3 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 3 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 3 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 3 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 3 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 3 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 3 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 3 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 3 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 3 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(3, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 3 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 4 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 4 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 4 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 4 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 4 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 4 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 4 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 4 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 4 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 4 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 4 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 4 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 4 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(4, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 4 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 5 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 5 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 5 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 5 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 5 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 5 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 5 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 5 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 5 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 5 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 5 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 5 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 5 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(5, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 5 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 6 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 6 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 6 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 6 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 6 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 6 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 6 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 6 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 6 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 6 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 6 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 6 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 6 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(6, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 6 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 7 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 7 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 7 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 7 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 7 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 7 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 7 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 7 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 7 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 7 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 7 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 7 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 7 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(7, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 7 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 8 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 8 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 8 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 8 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 8 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 8 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 8 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 8 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 8 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 8 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 8 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 8 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 8 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(8, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 8 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 9 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 9 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 9 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 9 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 9 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 9 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 9 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 9 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 9 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 9 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 9 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 9 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 9 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(9, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 9 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 10 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 10 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 10 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 10 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 10 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 10 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 10 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 10 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 10 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 10 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 10 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 10 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 10 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(10, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 10 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 11 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 11 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 11 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 11 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 11 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 11 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 11 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 11 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 11 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 11 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 11 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 11 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 11 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(11, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 11 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 12 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 12 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 12 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 12 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 12 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 12 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 12 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 12 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 12 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 12 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 12 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 12 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 12 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(12, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 12 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 13 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 13 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 13 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 13 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 13 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 13 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 13 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 13 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 13 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 13 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 13 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 13 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 13 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(13, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 13 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 14 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 14 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 14 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 14 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 14 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 14 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 14 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 14 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 14 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 14 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 14 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 14 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 14 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(14, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 14 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 15 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 15 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 15 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 15 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 15 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 15 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 15 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 15 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 15 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 15 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 15 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 15 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 15 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(15, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 15 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 16 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 16 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 16 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 16 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 16 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 16 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 16 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 16 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 16 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 16 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 16 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 16 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 16 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(16, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 16 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 17 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 17 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 17 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 17 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 17 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 17 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 17 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 17 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 17 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 17 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 17 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 17 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 17 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(17, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 17 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 18 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 18 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 18 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 18 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 18 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 18 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 18 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 18 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 18 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 18 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 18 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 18 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 18 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(18, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 18 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 46 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 46 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 46 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 46 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 46 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 46 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 46 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 46 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 46 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 46 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 46 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 46 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 46 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(46, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 46 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 47 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 47 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 47 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 47 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 47 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 47 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 47 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 47 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 47 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 47 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 47 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 47 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 47 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(47, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 47 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 48 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 48 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 48 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 48 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 48 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 48 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 48 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 48 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 48 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 48 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 48 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 48 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 48 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(48, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 48 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 49 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 49 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 49 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 49 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 49 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 49 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 49 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 49 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 49 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 49 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 49 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 49 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 49 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(49, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 49 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 19 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 19 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 19 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 19 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 19 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 19 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 19 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 19 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 19 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 19 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 19 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 19 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 19 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 19 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(19, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 19 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 20 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 20 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 20 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 20 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 20 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 20 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 20 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 20 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 20 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 20 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 20 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 20 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 20 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 20 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(20, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 20 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 21 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 21 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 21 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 21 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 21 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 21 AND strColumn = 'strDestinationState' END

SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 21 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 21 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 21 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 21 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 21 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 21 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 21 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 21 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(21, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 21 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 22 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 22 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 22 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 22 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 22 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 22 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 22 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 22 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 22 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 22 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 22 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 22 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 22 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 22 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(22, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 22 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 23 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 23 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 23 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 23 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 23 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 23 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 23 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 23 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 23 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 23 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 23 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 23 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 23 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 23 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(23, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 23 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 24 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 24 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 24 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 24 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 24 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 24 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 24 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 24 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 24 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 24 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 24 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 24 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 24 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 24 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(24, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 24 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 25 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 25 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 25 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 25 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 25 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 25 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 25 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 25 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 25 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 25 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 25 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 25 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 25 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 25 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(25, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 25 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 26 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 26 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 26 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 26 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 26 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 26 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 26 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 26 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 26 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 26 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 26 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 26 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 26 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 26 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(26, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 26 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 27 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 27 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 27 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 27 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 27 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 27 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 27 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 27 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 27 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 27 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 27 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 27 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 27 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 27 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(27, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 27 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 28 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 28 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 28 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 28 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 28 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 28 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 28 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 28 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 28 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 28 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 28 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 28 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 28 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 28 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(28, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 28 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 29 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 29 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 29 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 29 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 29 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 29 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 29 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 29 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 29 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 29 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 29 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 29 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 29 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 29 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(29, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 29 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 30 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 30 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 30 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 30 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 30 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 30 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 30 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 30 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 30 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 30 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 30 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 30 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 30 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 30 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(30, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 30 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 31 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 31 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 31 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 31 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 31 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 31 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 31 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 31 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 31 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 31 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 31 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 31 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 31 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 31 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(31, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 31 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 32 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 32 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 32 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 32 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 32 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 32 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 32 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 32 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 32 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 32 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 32 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 32 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 32 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 32 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(32, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 32 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 33 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 33 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 33 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 33 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 33 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 33 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 33 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 33 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 33 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 33 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 33 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 33 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 33 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 33 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(33, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 33 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 34 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 34 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 34 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 34 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 34 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 34 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 34 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 34 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 34 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 34 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 34 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 34 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 34 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 34 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(34, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 34 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 37 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 37 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 37 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 37 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 37 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 37 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 37 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 37 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 37 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 37 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 37 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 37 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 37 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 37 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(37, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 37 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 50 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 50 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 50 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 50 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 50 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 50 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 50 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 50 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 50 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 50 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 50 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 50 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 50 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 50 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(50, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 50 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 51 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 51 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 51 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 51 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 51 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 51 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 51 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 51 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 51 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 51 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 51 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 51 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 51 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 51 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(51, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 51 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 52 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 52 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 52 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 52 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 52 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 52 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 52 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 52 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 52 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 52 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 52 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 52 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 52 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 52 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(52, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 52 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 53 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 53 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 53 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 53 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 53 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 53 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 53 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 53 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 53 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 53 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 53 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 53 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 53 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 53 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(53, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 53 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 54 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 54 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 54 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 54 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 54 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 54 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 54 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 54 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 54 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 54 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 54 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 54 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 54 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 54 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(54, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 54 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 55 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 55 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 55 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 55 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 55 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 55 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 55 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 55 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 55 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 55 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 55 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 55 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 55 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 55 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(55, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 55 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 56 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 56 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 56 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 56 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 56 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 56 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 56 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 56 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 56 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 56 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 56 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 56 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 56 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 56 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(56, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 56 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 57 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 57 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 57 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 57 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 57 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 57 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 57 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 57 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 57 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 57 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 57 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 57 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 57 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 57 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(57, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 57 AND strColumn = 'dblBillQty' END


--==========================
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 58 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 58 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 58 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 58 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 58 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 58 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 58 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 58 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 58 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 58 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 58 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 58 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 58 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 58 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(58, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 58 AND strColumn = 'dblBillQty' END


SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 59 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 59 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 59 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 59 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 59 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 59 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 59 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 59 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 59 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 59 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 59 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 59 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 59 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 59 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(59, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 59 AND strColumn = 'dblBillQty' END


SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 60 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 60 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 60 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 60 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 60 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 60 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 60 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 60 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 60 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 60 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 60 AND strColumn = 'dblBillQty' END


SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 61 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 61 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 61 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 61 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 61 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 61 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 61 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 61 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 61 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 61 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 61 AND strColumn = 'dblBillQty' END


SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 62 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 62 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 62 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 62 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 62 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 62 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 62 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 62 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 62 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 62 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 62 AND strColumn = 'dblBillQty' END


SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 63 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 63 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 63 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 63 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 63 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 63 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 63 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 63 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 63 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 63 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 63 AND strColumn = 'dblBillQty' END



SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 64 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 64 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 64 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 64 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 64 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 64 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 64 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 64 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 64 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 64 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 64 AND strColumn = 'dblBillQty' END


SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 65 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 65 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 65 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 65 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 65 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 65 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 65 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 65 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 65 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 65 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 65 AND strColumn = 'dblBillQty' END

SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 66 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 66 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 66 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 66 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 66 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 66 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 66 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 66 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 66 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 66 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 66 AND strColumn = 'dblBillQty' END

SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 67 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 67 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 67 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 67 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 67 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 67 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 67 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 67 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 67 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 67 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 67 AND strColumn = 'dblBillQty' END


SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 69 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 69 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 69 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 69 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 69 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 69 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 69 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 69 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 69 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 69 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 69 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 69 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 69 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 69 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(69, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 69 AND strColumn = 'dblBillQty' END


SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 70 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 70 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 70 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 70 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 70 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 70 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 70 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 70 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 70 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 70 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 70 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 70 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 70 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 70 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(70, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 70 AND strColumn = 'dblBillQty' END




SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 71 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 71 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 71 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 71 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 71 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 71 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 71 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 71 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 71 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 71 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 71 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 71 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 71 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 71 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(71, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 71 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 72 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 72 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 72 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 72 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 72 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 72 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 72 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 72 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 72 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 72 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 72 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 72 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 72 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 72 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(72, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 72 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 73 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 73 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 73 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 73 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 73 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 73 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 73 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 73 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 73 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 73 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 73 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 73 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 73 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 73 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(73, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 73 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 74 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 74 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 74 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 74 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 74 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 74 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 74 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 74 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 74 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 74 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 74 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 74 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 74 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 74 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(74, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 74 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 75 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 75 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 75 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 75 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 75 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 75 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 75 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 75 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 75 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 75 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 75 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 75 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 75 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 75 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(75, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 75 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 76 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 76 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 76 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 76 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 76 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 76 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 76 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 76 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 76 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 76 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 76 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 76 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 76 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 76 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(76, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 76 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 77 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 77 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 77 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 77 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 77 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 77 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 77 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 77 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 77 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 77 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 77 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 77 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 77 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 77 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(77, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 77 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 78 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 78 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 78 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 78 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 78 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 78 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 78 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 78 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 78 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 78 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 78 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 78 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 78 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 78 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(78, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 78 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 79 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 79 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 79 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 79 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 79 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 79 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strTerminalControlNumber', 'Terminal', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Terminal' WHERE intReportingComponentId = 79 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strCustomerName', 'Sold To', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Sold To' WHERE intReportingComponentId = 79 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 79 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'dtmDate', 'Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date' WHERE intReportingComponentId = 79 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'strInvoiceNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'strInvoiceNumber', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 79 AND strColumn = 'strInvoiceNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 79 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 79 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 79 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(79, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 79 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 80 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 80 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 80 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 80 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 80 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 80 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 80 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 80 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 80 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 80 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 80 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 80 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 80 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(80, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 80 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 81 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 81 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 81 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 81 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 81 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 81 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 81 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 81 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 81 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 81 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 81 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 81 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 81 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(81, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 81 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 82 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 82 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 82 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 82 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 82 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 82 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 82 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 82 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 82 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 82 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 82 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 82 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 82 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(82, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 82 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 83 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 83 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 83 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 83 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 83 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 83 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 83 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 83 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 83 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 83 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 83 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 83 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 83 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(83, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 83 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 84 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 84 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 84 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 84 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 84 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 84 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 84 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 84 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 84 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 84 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 84 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 84 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 84 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(84, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 84 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 85 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 85 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 85 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 85 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 85 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 85 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 85 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 85 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 85 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 85 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 85 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 85 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 85 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(85, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 85 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 86 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 86 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 86 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 86 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 86 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 86 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 86 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 86 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 86 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 86 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 86 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 86 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 86 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(86, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 86 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 87 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 87 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 87 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 87 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 87 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 87 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 87 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 87 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 87 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 87 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 87 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 87 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 87 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(87, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 87 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 88 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'strTransporterName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'strTransporterName', 'Transporter Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter Name' WHERE intReportingComponentId = 88 AND strColumn = 'strTransporterName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransporterFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'strTransporterFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'strTransporterFederalTaxId', 'Transporter FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Transporter FEIN' WHERE intReportingComponentId = 88 AND strColumn = 'strTransporterFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 88 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 88 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 88 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'strVendorName', 'Vendor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor Name' WHERE intReportingComponentId = 88 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'strVendorFederalTaxId', 'Vendor FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Vendor FEIN' WHERE intReportingComponentId = 88 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'dtmDate', 'Date Received', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Date Received' WHERE intReportingComponentId = 88 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 88 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'dblNet', 'Net Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net Gals' WHERE intReportingComponentId = 88 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'dblGross', 'Gross Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross Gals' WHERE intReportingComponentId = 88 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblBillQty')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 88 AND strColumn = 'dblBillQty')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(88, 'dblBillQty', 'Billed Gals', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Billed Gals' WHERE intReportingComponentId = 88 AND strColumn = 'dblBillQty' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 60 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strConsignorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consignor Name' WHERE intReportingComponentId = 60 AND strColumn = 'strConsignorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strConsignorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consigner FEIN' WHERE intReportingComponentId = 60 AND strColumn = 'strConsignorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strVendorName', 'Seller Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller Name' WHERE intReportingComponentId = 60 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller FEIN' WHERE intReportingComponentId = 60 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 60 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 60 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strCustomerName', 'Customer Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer Name' WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 60 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 60 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'dtmDate', 'Document Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Date' WHERE intReportingComponentId = 60 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 60 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'dblGross', 'Gross', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross' WHERE intReportingComponentId = 60 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 60 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(60, 'dblNet', 'Net', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net' WHERE intReportingComponentId = 60 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 61 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strConsignorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consignor Name' WHERE intReportingComponentId = 61 AND strColumn = 'strConsignorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strConsignorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consigner FEIN' WHERE intReportingComponentId = 61 AND strColumn = 'strConsignorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strVendorName', 'Seller Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller Name' WHERE intReportingComponentId = 61 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller FEIN' WHERE intReportingComponentId = 61 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 61 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 61 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strCustomerName', 'Customer Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer Name' WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 61 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 61 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'dtmDate', 'Document Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Date' WHERE intReportingComponentId = 61 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 61 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'dblGross', 'Gross', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross' WHERE intReportingComponentId = 61 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 61 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(61, 'dblNet', 'Net', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net' WHERE intReportingComponentId = 61 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 62 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strConsignorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consignor Name' WHERE intReportingComponentId = 62 AND strColumn = 'strConsignorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strConsignorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consigner FEIN' WHERE intReportingComponentId = 62 AND strColumn = 'strConsignorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strVendorName', 'Seller Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller Name' WHERE intReportingComponentId = 62 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller FEIN' WHERE intReportingComponentId = 62 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 62 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 62 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strCustomerName', 'Customer Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer Name' WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 62 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 62 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'dtmDate', 'Document Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Date' WHERE intReportingComponentId = 62 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 62 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'dblGross', 'Gross', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross' WHERE intReportingComponentId = 62 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 62 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(62, 'dblNet', 'Net', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net' WHERE intReportingComponentId = 62 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 63 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strConsignorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consignor Name' WHERE intReportingComponentId = 63 AND strColumn = 'strConsignorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strConsignorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consigner FEIN' WHERE intReportingComponentId = 63 AND strColumn = 'strConsignorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strVendorName', 'Seller Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller Name' WHERE intReportingComponentId = 63 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller FEIN' WHERE intReportingComponentId = 63 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 63 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 63 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strCustomerName', 'Customer Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer Name' WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 63 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 63 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'dtmDate', 'Document Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Date' WHERE intReportingComponentId = 63 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 63 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'dblGross', 'Gross', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross' WHERE intReportingComponentId = 63 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 63 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(63, 'dblNet', 'Net', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net' WHERE intReportingComponentId = 63 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 64 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strConsignorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consignor Name' WHERE intReportingComponentId = 64 AND strColumn = 'strConsignorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strConsignorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consigner FEIN' WHERE intReportingComponentId = 64 AND strColumn = 'strConsignorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strVendorName', 'Seller Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller Name' WHERE intReportingComponentId = 64 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller FEIN' WHERE intReportingComponentId = 64 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 64 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 64 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strCustomerName', 'Customer Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer Name' WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 64 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 64 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'dtmDate', 'Document Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Date' WHERE intReportingComponentId = 64 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 64 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'dblGross', 'Gross', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross' WHERE intReportingComponentId = 64 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 64 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(64, 'dblNet', 'Net', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net' WHERE intReportingComponentId = 64 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 65 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strConsignorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consignor Name' WHERE intReportingComponentId = 65 AND strColumn = 'strConsignorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strConsignorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consigner FEIN' WHERE intReportingComponentId = 65 AND strColumn = 'strConsignorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strVendorName', 'Seller Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller Name' WHERE intReportingComponentId = 65 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller FEIN' WHERE intReportingComponentId = 65 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 65 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 65 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strCustomerName', 'Customer Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer Name' WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 65 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 65 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'dtmDate', 'Document Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Date' WHERE intReportingComponentId = 65 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 65 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'dblGross', 'Gross', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross' WHERE intReportingComponentId = 65 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 65 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(65, 'dblNet', 'Net', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net' WHERE intReportingComponentId = 65 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 66 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strConsignorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consignor Name' WHERE intReportingComponentId = 66 AND strColumn = 'strConsignorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strConsignorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consigner FEIN' WHERE intReportingComponentId = 66 AND strColumn = 'strConsignorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strVendorName', 'Seller Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller Name' WHERE intReportingComponentId = 66 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller FEIN' WHERE intReportingComponentId = 66 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 66 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 66 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strCustomerName', 'Customer Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer Name' WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 66 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 66 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'dtmDate', 'Document Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Date' WHERE intReportingComponentId = 66 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 66 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'dblGross', 'Gross', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross' WHERE intReportingComponentId = 66 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 66 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(66, 'dblNet', 'Net', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net' WHERE intReportingComponentId = 66 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 67 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strConsignorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consignor Name' WHERE intReportingComponentId = 67 AND strColumn = 'strConsignorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strConsignorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consigner FEIN' WHERE intReportingComponentId = 67 AND strColumn = 'strConsignorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strVendorName', 'Seller Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller Name' WHERE intReportingComponentId = 67 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller FEIN' WHERE intReportingComponentId = 67 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 67 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 67 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strCustomerName', 'Customer Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer Name' WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 67 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 67 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'dtmDate', 'Document Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Date' WHERE intReportingComponentId = 67 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 67 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'dblGross', 'Gross', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross' WHERE intReportingComponentId = 67 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 67 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(67, 'dblNet', 'Net', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net' WHERE intReportingComponentId = 67 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 68 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strConsignorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strConsignorName', 'Consignor Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consignor Name' WHERE intReportingComponentId = 68 AND strColumn = 'strConsignorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strConsignorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strConsignorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strConsignorFederalTaxId', 'Consigner FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Consigner FEIN' WHERE intReportingComponentId = 68 AND strColumn = 'strConsignorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strVendorName', 'Seller Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller Name' WHERE intReportingComponentId = 68 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strVendorFederalTaxId', 'Seller FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Seller FEIN' WHERE intReportingComponentId = 68 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strTransportationMode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strTransportationMode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strTransportationMode', 'Mode', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Mode' WHERE intReportingComponentId = 68 AND strColumn = 'strTransportationMode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 68 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strCustomerName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strCustomerName', 'Customer Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer Name' WHERE intReportingComponentId = 68 AND strColumn = 'strCustomerName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strCustomerFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strCustomerFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strCustomerFederalTaxId', 'Customer FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Customer FEIN' WHERE intReportingComponentId = 68 AND strColumn = 'strCustomerFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 68 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dtmDate')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'dtmDate')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'dtmDate', 'Document Date', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Date' WHERE intReportingComponentId = 68 AND strColumn = 'dtmDate' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strBillOfLading')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'strBillOfLading')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'strBillOfLading', 'Document Number', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Document Number' WHERE intReportingComponentId = 68 AND strColumn = 'strBillOfLading' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'dblGross', 'Gross', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Gross' WHERE intReportingComponentId = 68 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblNet')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 68 AND strColumn = 'dblNet')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(68, 'dblNet', 'Net', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Net' WHERE intReportingComponentId = 68 AND strColumn = 'dblNet' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 41 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(41, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 41 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 41 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(41, 'strVendorName', 'Supplier Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Supplier Name' WHERE intReportingComponentId = 41 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 41 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(41, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 41 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 41 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(41, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 41 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 41 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(41, 'strVendorFederalTaxId', 'Supplier FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Supplier FEIN' WHERE intReportingComponentId = 41 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorLicenseNumber')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 41 AND strColumn = 'strVendorLicenseNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(41, 'strVendorLicenseNumber', 'Indiana TID', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Indiana TID' WHERE intReportingComponentId = 41 AND strColumn = 'strVendorLicenseNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 41 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(41, 'dblGross', 'Total Gals Purchased', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Total Gals Purchased' WHERE intReportingComponentId = 41 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblTax')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 41 AND strColumn = 'dblTax')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(41, 'dblTax', 'GUT Paid to Supplier', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'GUT Paid to Supplier' WHERE intReportingComponentId = 41 AND strColumn = 'dblTax' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 42 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(42, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 42 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 42 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(42, 'strVendorName', 'Supplier Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Supplier Name' WHERE intReportingComponentId = 42 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 42 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(42, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 42 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 42 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(42, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 42 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 42 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(42, 'strVendorFederalTaxId', 'Supplier FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Supplier FEIN' WHERE intReportingComponentId = 42 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorLicenseNumber')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 42 AND strColumn = 'strVendorLicenseNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(42, 'strVendorLicenseNumber', 'Indiana TID', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Indiana TID' WHERE intReportingComponentId = 42 AND strColumn = 'strVendorLicenseNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 42 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(42, 'dblGross', 'Total Gals Purchased', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Total Gals Purchased' WHERE intReportingComponentId = 42 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblTax')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 42 AND strColumn = 'dblTax')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(42, 'dblTax', 'GUT Paid to Supplier', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'GUT Paid to Supplier' WHERE intReportingComponentId = 42 AND strColumn = 'dblTax' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 43 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(43, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 43 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 43 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(43, 'strVendorName', 'Supplier Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Supplier Name' WHERE intReportingComponentId = 43 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 43 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(43, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 43 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 43 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(43, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 43 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 43 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(43, 'strVendorFederalTaxId', 'Supplier FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Supplier FEIN' WHERE intReportingComponentId = 43 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorLicenseNumber')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 43 AND strColumn = 'strVendorLicenseNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(43, 'strVendorLicenseNumber', 'Indiana TID', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Indiana TID' WHERE intReportingComponentId = 43 AND strColumn = 'strVendorLicenseNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 43 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(43, 'dblGross', 'Total Gals Purchased', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Total Gals Purchased' WHERE intReportingComponentId = 43 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblTax')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 43 AND strColumn = 'dblTax')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(43, 'dblTax', 'GUT Paid to Supplier', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'GUT Paid to Supplier' WHERE intReportingComponentId = 43 AND strColumn = 'dblTax' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strProductCode')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 44 AND strColumn = 'strProductCode')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(44, 'strProductCode', 'Product Code', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Product Code' WHERE intReportingComponentId = 44 AND strColumn = 'strProductCode' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorName')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 44 AND strColumn = 'strVendorName')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(44, 'strVendorName', 'Supplier Name', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Supplier Name' WHERE intReportingComponentId = 44 AND strColumn = 'strVendorName' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strOriginState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 44 AND strColumn = 'strOriginState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(44, 'strOriginState', 'Origin State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Origin State' WHERE intReportingComponentId = 44 AND strColumn = 'strOriginState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strDestinationState')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 44 AND strColumn = 'strDestinationState')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(44, 'strDestinationState', 'Destination State', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Destination State' WHERE intReportingComponentId = 44 AND strColumn = 'strDestinationState' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorFederalTaxId')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 44 AND strColumn = 'strVendorFederalTaxId')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(44, 'strVendorFederalTaxId', 'Supplier FEIN', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Supplier FEIN' WHERE intReportingComponentId = 44 AND strColumn = 'strVendorFederalTaxId' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'strVendorLicenseNumber')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 44 AND strColumn = 'strVendorLicenseNumber')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(44, 'strVendorLicenseNumber', 'Indiana TID', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Indiana TID' WHERE intReportingComponentId = 44 AND strColumn = 'strVendorLicenseNumber' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblGross')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 44 AND strColumn = 'dblGross')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(44, 'dblGross', 'Total Gals Purchased', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'Total Gals Purchased' WHERE intReportingComponentId = 44 AND strColumn = 'dblGross' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'dblTax')
IF NOT EXISTS(SELECT TOP 1 intReportingComponentId FROM tblTFScheduleFields WHERE intReportingComponentId = 44 AND strColumn = 'dblTax')
BEGIN INSERT INTO tblTFScheduleFields([intReportingComponentId],[strColumn],[strCaption],[strFormat],[strFooter],[intWidth] ,[intScheduleFieldTemplateId]) VALUES(44, 'dblTax', 'GUT Paid to Supplier', NULL, 'No', '0', @ScheduleFieldTemplateId) END 
ELSE
BEGIN UPDATE tblTFScheduleFields SET strCaption = 'GUT Paid to Supplier' WHERE intReportingComponentId = 44 AND strColumn = 'dblTax' END
SET @ScheduleFieldTemplateId = (SELECT TOP 1 intScheduleFieldTemplateId from tblTFScheduleFieldTemplate WHERE strColumn = 'NULL')

PRINT 'END TF Schedule Fields'