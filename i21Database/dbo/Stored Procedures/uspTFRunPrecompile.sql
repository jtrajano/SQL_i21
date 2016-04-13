CREATE PROCEDURE [dbo].[uspTFRunPrecompile]

@Guid UNIQUEIDENTIFIER,
@TA NVARCHAR(10),
@FormCode NVARCHAR(100),
@ProductCodeId NVARCHAR(MAX)
--,
--@ReportingComponentId INT

AS

DECLARE @count INT
DECLARE @intItemId INT
DECLARE @ICItemMotorFuelTax_intItemMotorFuelTaxId INT
DECLARE	@ICInventoryReceipt_strActualCostId NVARCHAR(50)
DECLARE @ICItemMotorFuelTax_intItemId INT
DECLARE @ICItemMotorFuelTax_intTaxAuthorityId INT
DECLARE @ICItemMotorFuelTax_intProductCodeId INT
DECLARE @ICItem_strItemNo NVARCHAR(MAX)
DECLARE @ICInventoryReceipt_intEntityVendorId INT
DECLARE @ICInventoryReceipt_strBillOfLading NVARCHAR(MAX)
DECLARE @ICInventoryReceipt_intShipViaId INT 
DECLARE @ICInventoryReceiptItem_intItemId INT
DECLARE @ICInventoryReceiptItem_dblReceived NUMERIC(18, 6)
DECLARE @ICInventoryReceiptItem_dblGross NUMERIC(18, 6)
DECLARE @ICInventoryReceiptItem_dblNet NUMERIC(18, 6)
DECLARE @ICInventoryReceiptItemTax_intTaxCodeId INT
DECLARE @ICInventoryReceiptItemTax_dblTax NUMERIC(18, 6)
DECLARE @ICItem_strShortName NVARCHAR(MAX)
DECLARE @ICItem_strType NVARCHAR(100)
DECLARE @ICItem_strDescription NVARCHAR(MAX)	
--AR
DECLARE @ARInvoice_strInvoiceNumber NVARCHAR(50)
DECLARE @ARInvoice_strPONumber NVARCHAR(50)
DECLARE @ARInvoice_strBOLNumber NVARCHAR(50)
DECLARE @ARInvoice_dtmDate DATETIME
DECLARE @ARInvoice_intEntityCustomerId INT
DECLARE @ARInvoice_strShipToCity NVARCHAR(MAX)
DECLARE @ARInvoice_strShipToState NVARCHAR(MAX)
DECLARE @ARInvoice_intCompanyLocationId INT
DECLARE @ARInvoice_dblQtyShipped NUMERIC(18, 6)		
--SM ShipVia
DECLARE @SMEntityShipViaId INT
DECLARE @SMTransporterLicense NVARCHAR(100)
DECLARE @SMTransportationMode NVARCHAR(100)
DECLARE @SMShipVia NVARCHAR(250)
DECLARE @SMFederalId NVARCHAR(50)
--SM CompanyLocation
--DECLARE @intCompanyLoactionId INT
--DECLARE @strCity NVARCHAR(50)
--DECLARE @strState NVARCHAR(50)
--AR AccountStatus
DECLARE @ARAccountStatusId INT
DECLARE @ARAccountStatusCode NVARCHAR(50)
--Entity
DECLARE @ENVendorName NVARCHAR(250)
DECLARE @ENCustomerName NVARCHAR(250)
DECLARE @ENVendorFederalTaxId NVARCHAR(50)
DECLARE @ENCustomerFederalTaxId NVARCHAR(50)
--

DECLARE @query NVARCHAR(MAX)
DECLARE @tblTemp TABLE (
		 intId INT IDENTITY(1,1),
		 intItemId INT,
		 ICItemMotorFuelTax_intItemMotorFuelTaxId INT, 
		 ICInventoryReceipt_strActualCostId NVARCHAR(50), 
		 --ICItemMotorFuelTax_intItemId INT, 
		 ICItemMotorFuelTax_intTaxAuthorityId INT, 
         ICItemMotorFuelTax_intProductCodeId INT, 
		 ICItem_strItemNo NVARCHAR(MAX), 
		 ICInventoryReceipt_intEntityVendorId INT,
		 ICInventoryReceipt_strBillOfLading NVARCHAR(MAX), 
		 ICInventoryReceipt_intShipViaId INT, 
         --ICInventoryReceiptItem_intItemId INT, 
		 ICInventoryReceiptItem_dblReceived NUMERIC(18, 6),
		 ICInventoryReceiptItem_dblGross NUMERIC(18, 6),
		 ICInventoryReceiptItem_dblNet NUMERIC(18, 6),
         ICInventoryReceiptItemTax_intTaxCodeId INT, 
		 ICInventoryReceiptItemTax_dblTax NUMERIC(18, 6),
		 ICItem_strShortName NVARCHAR(MAX), 
		 ICItem_strType NVARCHAR(100), 
		 ICItem_strDescription NVARCHAR(MAX),
		 --AR
		 ARInvoice_strInvoiceNumber NVARCHAR(50), 
		 ARInvoice_strPONumber NVARCHAR(50), 
		 ARInvoice_strBOLNumber NVARCHAR(50), 
		 ARInvoice_dtmDate DATETIME,
		 ARInvoice_intEntityCustomerId INT,
		 ARInvoice_strShipToCity NVARCHAR(MAX), 
		 ARInvoice_strShipToState NVARCHAR(MAX), 
		 ARInvoice_intCompanyLocationId INT, 
		 ARInvoice_dblQtyShipped NUMERIC(18, 6),
		 --SM
		 SMShipVia_intEntityShipViaId INT,
		 SMShipVia_strTransporterLicense NVARCHAR(100),
		 SMShipVia_strTransportationMode NVARCHAR(100),
		 SMShipVia_strShipVia NVARCHAR(250),
		 SMShipVia_strFederalId NVARCHAR(50),
		 --SM CompanyLocation
		--SMintCompanyLoactionId INT,
		--SMstrCity NVARCHAR(50),
		--SMstrState NVARCHAR(50),
		--Entity
		Entity_VendorName NVARCHAR(250),
		Entity_CustomerName NVARCHAR(250),
		Entity_VendorFederalTaxId NVARCHAR(50),
		Entity_CustomerFederalTaxId NVARCHAR(50)
		 )

SET @ProductCodeId = REPLACE(@ProductCodeId,',',''',''')

SET @query = 'SELECT     tblICItem.intItemId, tblICItemMotorFuelTax.intItemMotorFuelTaxId, tblICInventoryReceipt.strActualCostId, tblICItemMotorFuelTax.intTaxAuthorityId, 
                         tblICItemMotorFuelTax.intProductCodeId, tblICItem.strItemNo, tblICInventoryReceipt.intEntityVendorId, tblICInventoryReceipt.strBillOfLading, tblICInventoryReceipt.intShipViaId, 
                         tblICInventoryReceiptItem.dblReceived, tblICInventoryReceiptItem.dblGross, tblICInventoryReceiptItem.dblNet, 
                         tblICInventoryReceiptItemTax.intTaxCodeId, tblICInventoryReceiptItemTax.dblTax, tblICItem.strShortName, tblICItem.strType, tblICItem.strDescription,
						 
						 tblARInvoice.strInvoiceNumber, tblARInvoice.strPONumber, tblARInvoice.strBOLNumber, tblARInvoice.dtmDate, tblARInvoice.intEntityCustomerId, tblARInvoice.strShipToCity, 
                         tblARInvoice.strShipToState, tblARInvoice.intCompanyLocationId, tblARInvoiceDetail.dblQtyShipped,
						 
						 tblSMShipVia.intEntityShipViaId, tblSMShipVia.strTransporterLicense, tblSMShipVia.strTransportationMode, 
						 tblSMShipVia.strShipVia, tblSMShipVia.strFederalId,

						 tblEMEntity.strName AS strVendorName, tblEMEntity_1.strName AS strCustomerName, tblEMEntity.strFederalTaxId AS strVendorFederalTaxId, tblEMEntity_1.strFederalTaxId AS strCustomerFederalTaxId

					FROM tblARInvoiceDetail INNER JOIN
                         tblARInvoice ON tblARInvoiceDetail.intInvoiceId = tblARInvoice.intInvoiceId INNER JOIN
                         tblARInvoiceDetailTax ON tblARInvoiceDetail.intInvoiceDetailId = tblARInvoiceDetailTax.intInvoiceDetailId INNER JOIN
                         tblICItem INNER JOIN
                         tblICItemMotorFuelTax ON tblICItem.intItemId = tblICItemMotorFuelTax.intItemId INNER JOIN
                         tblICInventoryReceiptItem INNER JOIN
                         tblICInventoryReceipt ON tblICInventoryReceiptItem.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId INNER JOIN
                         tblICInventoryReceiptItemTax ON tblICInventoryReceiptItem.intInventoryReceiptItemId = tblICInventoryReceiptItemTax.intInventoryReceiptItemId ON tblICItem.intItemId = tblICInventoryReceiptItem.intItemId ON 
                         tblARInvoice.strActualCostId = tblICInventoryReceipt.strActualCostId INNER JOIN
                         tblSMShipVia ON tblICInventoryReceipt.intShipViaId = tblSMShipVia.intEntityShipViaId INNER JOIN
                         tblAPVendor ON tblICInventoryReceipt.intEntityVendorId = tblAPVendor.intEntityVendorId INNER JOIN
                         tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityCustomerId INNER JOIN
                         tblEMEntity ON tblAPVendor.intEntityVendorId = tblEMEntity.intEntityId INNER JOIN
                         tblEMEntity AS tblEMEntity_1 ON tblARCustomer.intEntityCustomerId = tblEMEntity_1.intEntityId
					WHERE tblICItemMotorFuelTax.intTaxAuthorityId = ''' + @TA + '''
					AND tblICItemMotorFuelTax.intProductCodeId IN (''' + @ProductCodeId + ''')
					AND tblICItem.ysnHasMFTImplication = 0'

INSERT INTO @tblTemp
EXEC(@query)
	SET @count = (select count(intItemId) from @tblTemp)
		WHILE(@count > 0)
			BEGIN
				SET @intItemId = (select intItemId from @tblTemp where intId = @count)
					INSERT INTO tblTFReportingComponentItem (intReportingComponentId, intItemId) values(2, @intItemId)

					 SET @ICItemMotorFuelTax_intItemMotorFuelTaxId = (select ICItemMotorFuelTax_intItemMotorFuelTaxId from @tblTemp where intId = @count)
					 SET @ICInventoryReceipt_strActualCostId = (select ICInventoryReceipt_strActualCostId from @tblTemp where intId = @count)
					 --SET @ICItemMotorFuelTax_intItemId = (select ICItemMotorFuelTax_intItemId from @tblTemp where intId = @count)
					 SET @ICItemMotorFuelTax_intTaxAuthorityId = (select ICItemMotorFuelTax_intTaxAuthorityId from @tblTemp where intId = @count)
					 SET @ICItemMotorFuelTax_intProductCodeId = (select ICItemMotorFuelTax_intProductCodeId from @tblTemp where intId = @count)
					 SET @ICItem_strItemNo = (select ICItem_strItemNo from @tblTemp where intId = @count) 
					 SET @ICInventoryReceipt_intEntityVendorId = (select ICInventoryReceipt_intEntityVendorId from @tblTemp where intId = @count)
					 SET @ICInventoryReceipt_strBillOfLading = (select ICInventoryReceipt_strBillOfLading from @tblTemp where intId = @count)
					 SET @ICInventoryReceipt_intShipViaId = (select ICInventoryReceipt_intShipViaId from @tblTemp where intId = @count) 
					 --SET @ICInventoryReceiptItem_intItemId = (select ICInventoryReceiptItem_intItemId from @tblTemp where intId = @count)
					 SET @ICInventoryReceiptItem_dblReceived = (select ICInventoryReceiptItem_dblReceived from @tblTemp where intId = @count)
					 SET @ICInventoryReceiptItem_dblGross = (select ICInventoryReceiptItem_dblGross from @tblTemp where intId = @count)
					 SET @ICInventoryReceiptItem_dblNet = (select ICInventoryReceiptItem_dblNet from @tblTemp where intId = @count)
					 SET @ICInventoryReceiptItemTax_intTaxCodeId = (select ICInventoryReceiptItemTax_intTaxCodeId from @tblTemp where intId = @count)
					 SET @ICInventoryReceiptItemTax_dblTax = (select ICInventoryReceiptItemTax_dblTax from @tblTemp where intId = @count)
					 SET @ICItem_strShortName = (select ICItem_strShortName from @tblTemp where intId = @count)
					 SET @ICItem_strType = (select ICItem_strType from @tblTemp where intId = @count)
					 SET @ICItem_strDescription = (select ICItem_strDescription from @tblTemp where intId = @count)
					 --AR
					 SET @ARInvoice_strInvoiceNumber = (select ARInvoice_strInvoiceNumber from @tblTemp where intId = @count)
					 SET @ARInvoice_strPONumber = (select ARInvoice_strPONumber from @tblTemp where intId = @count) 
					 SET @ARInvoice_strBOLNumber = (select ARInvoice_strBOLNumber from @tblTemp where intId = @count)
					 SET @ARInvoice_dtmDate = (select ARInvoice_dtmDate from @tblTemp where intId = @count)
					 SET @ARInvoice_intEntityCustomerId = (select ARInvoice_intEntityCustomerId from @tblTemp where intId = @count)
					 SET @ARInvoice_strShipToCity = (select ARInvoice_strShipToCity from @tblTemp where intId = @count) 
					 SET @ARInvoice_strShipToState = (select ARInvoice_strShipToState from @tblTemp where intId = @count)
					 SET @ARInvoice_intCompanyLocationId = (select ARInvoice_intCompanyLocationId from @tblTemp where intId = @count)
					 SET @ARInvoice_dblQtyShipped = (select ARInvoice_dblQtyShipped from @tblTemp where intId = @count)
					 --SM
					 SET @SMEntityShipViaId = (select SMShipVia_intEntityShipViaId from @tblTemp where intId = @count)
					 SET @SMTransporterLicense = (select SMShipVia_strTransporterLicense from @tblTemp where intId = @count)
					 SET @SMTransportationMode = (select SMShipVia_strTransportationMode from @tblTemp where intId = @count)
					 SET @SMShipVia = (select SMShipVia_strShipVia from @tblTemp where intId = @count)
					 SET @SMFederalId = (select SMShipVia_strFederalId from @tblTemp where intId = @count)

					--Entity
					 SET @ENVendorName = (select Entity_VendorName from @tblTemp where intId = @count)
					 SET @ENCustomerName = (select Entity_CustomerName from @tblTemp where intId = @count)
					 SET @ENVendorFederalTaxId = (select Entity_VendorFederalTaxId from @tblTemp where intId = @count)
					 SET @ENCustomerFederalTaxId = (select Entity_CustomerFederalTaxId from @tblTemp where intId = @count)

					INSERT INTO tblTFTransactions 
							(
							strFormCode,
							intTaxAuthorityId,
							intItemId,
							intItemMotorFuelTaxId,
							strActualCostId,
							--intItemId,
							intProductCodeId,
							strProductCode,
							strItemNo,
							intEntityVendorId,
							strBillOfLading,
							intShipViaId,
							--intItemId,
							dblReceived,
							dblGross,
							dblNet,
							intTaxCodeId,
							dblTax,
							strShortName,
							strType,
							strDescription,
							--AR
							strInvoiceNumber,
							strPONumber,
							strBOLNumber,
							dtmDate,
							intEntityCustomerId,
							strShipToCity,
							strShipToState,
							intCompanyLocationId,
							dblQtyShipped,
							--SM ShipVia
							intEntityShipViaId,
							strTransporterLicense,
							strTransportationMode,
							strShipVia,
							strFederalId,
							--Entity
							strVendorName,
							strCustomerName,
							strVendorFederalTaxId,
							strCustomerFederalTaxId,
							leaf
							) 
					 VALUES(
							@FormCode,
							@TA,
						    @intItemId,
							@ICItemMotorFuelTax_intItemMotorFuelTaxId,
							@ICInventoryReceipt_strActualCostId,
							--@ICItemMotorFuelTax_intItemId,
							@ICItemMotorFuelTax_intProductCodeId,
							(SELECT strProductCode FROM tblTFProductCode WHERE intProductCodeId = @ICItemMotorFuelTax_intProductCodeId),
							@ICItem_strItemNo,
							@ICInventoryReceipt_intEntityVendorId,
							@ICInventoryReceipt_strBillOfLading,
							@ICInventoryReceipt_intShipViaId, 
							--@ICInventoryReceiptItem_intItemId,
							@ICInventoryReceiptItem_dblReceived,
							@ICInventoryReceiptItem_dblGross,
							@ICInventoryReceiptItem_dblNet,
							@ICInventoryReceiptItemTax_intTaxCodeId,
							@ICInventoryReceiptItemTax_dblTax,
							@ICItem_strShortName,
							@ICItem_strType,
							@ICItem_strDescription,
							--AR
							 @ARInvoice_strInvoiceNumber, 
							 @ARInvoice_strPONumber, 
							 @ARInvoice_strBOLNumber, 
							 @ARInvoice_dtmDate,
							 @ARInvoice_intEntityCustomerId,
							 @ARInvoice_strShipToCity, 
							 @ARInvoice_strShipToState, 
							 @ARInvoice_intCompanyLocationId, 
							 @ARInvoice_dblQtyShipped,
							 --SM ShipVia
							 @SMEntityShipViaId,
							 @SMTransporterLicense,
							 @SMTransportationMode,
							 @SMShipVia,
							 @SMFederalId,
							--Entity
							 @ENVendorName,
							 @ENCustomerName,
							 @ENVendorFederalTaxId,
							 @ENCustomerFederalTaxId,
							 0
					 )
				SET @count = @count - 1
			END