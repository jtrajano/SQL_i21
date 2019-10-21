
CREATE PROCEDURE [dbo].[uspCFGenerateTransactionExportToThirdPartyCSV]
@strWhereClause NVARCHAR(MAX) 
AS

DECLARE @tblCFTransactionId TABLE
(
	intTransactionId INT,
	strEventSequenceId NVARCHAR(MAX) 
)

INSERT INTO @tblCFTransactionId
(
	intTransactionId
)
EXEC ('SELECT intTransactionId FROM tblCFTransaction WHERE ' + @strWhereClause)

  
DECLARE @dtmExportDate DATETIME = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)


DECLARE @loopTransactionId INT = 0


WHILE (SELECT COUNT(1) FROM @tblCFTransactionId WHERE ISNULL(strEventSequenceId,'') = '') > 0
BEGIN
	DECLARE @strEventSequenceId NVARCHAR(MAX)
	SELECT TOP 1 @loopTransactionId = intTransactionId FROM @tblCFTransactionId WHERE ISNULL(strEventSequenceId,'') = ''
	
	EXEC [uspCFGetFactorEventSequenceNumber] @dtmDate = @dtmExportDate , @strEventSequenceId = @strEventSequenceId OUTPUT
	UPDATE @tblCFTransactionId SET strEventSequenceId = @strEventSequenceId WHERE intTransactionId = @loopTransactionId

END



SELECT 
	            'Event' = (SELECT strEventSequenceId from @tblCFTransactionId WHERE intTransactionId = tblCFTransaction.intTransactionId)
                , 'Tran Type' = CASE 
						            WHEN (tblCFTransaction.strTransactionType like '%Local%') THEN 11 
						            WHEN (tblCFTransaction.strTransactionType like '%Remote%') THEN 12
						            WHEN (tblCFTransaction.strTransactionType like '%Foreign%') THEN 13
					            END
                , 'Date' = CAST(YEAR(tblCFTransaction.dtmTransactionDate) AS NVARCHAR(4)) + RIGHT('00' + CAST(MONTH(tblCFTransaction.dtmTransactionDate) AS VARCHAR(2)), 2) + RIGHT('00' + CAST(DAY(tblCFTransaction.dtmTransactionDate) AS VARCHAR(2)), 2)
                , 'Time' = RIGHT('00' + CAST(DATEPART(HOUR, tblCFTransaction.dtmTransactionDate) AS VARCHAR(2)), 2) + RIGHT('00' + CAST(DATEPART(MINUTE, tblCFTransaction.dtmTransactionDate)  AS VARCHAR(2)), 2)
                , 'Blank Field' = ''
                , 'Customer Number'  = CASE 
						            WHEN (tblCFTransaction.strTransactionType like '%Foreign%') 
						            THEN '00000000'
						            ELSE dbo.fnCFPadString(tblARCustomer.strCustomerNumber , 8, '0', 'left') 
					            END
                , 'Card Number' = ISNULL(A.strCardNumber, '')
                , 'Vehicle Number' = ISNULL(B.strVehicleNumber, 0)
                , 'Site Number' = ISNULL(C.strSiteNumber, '')
                , 'Gallons' = 'G'
                , 'Product Number' = dbo.fnCFPadString(ISNULL(D.strProductNumber, 0) , 6, '0', 'left') 
                , 'Quantity' = ISNULL(tblCFTransaction.dblQuantity, 0.0)
                , 'Product Description' = ISNULL(D.strProductDescription, '')
                , 'Odometer' = ISNULL(tblCFTransaction.intOdometer, 0)
                , 'Blank Field1' = ''
                , 'Site Number' = ISNULL(C.strSiteNumber, '')
                , 'Tax Group' = CASE 
	               WHEN (SELECT COUNT(1) FROM tblCFFactorTaxGroupXRef WHERE 
						ISNULL(tblCFFactorTaxGroupXRef.intCustomerId,0) = tblCFTransaction.intCustomerId 
						AND strState = C.strTaxState 
						AND tblCFFactorTaxGroupXRef.intCategoryId = I.intCategoryId 
					) > 0
		                THEN (SELECT TOP 1 strFactorTaxGroup FROM tblCFFactorTaxGroupXRef WHERE 
						ISNULL(tblCFFactorTaxGroupXRef.intCustomerId,0) = tblCFTransaction.intCustomerId 
						AND strState = C.strTaxState 
						AND tblCFFactorTaxGroupXRef.intCategoryId = I.intCategoryId 
					)
	                WHEN (SELECT COUNT(1) FROM tblCFFactorTaxGroupXRef WHERE 
						ISNULL(tblCFFactorTaxGroupXRef.intCustomerId,0) = tblCFTransaction.intCustomerId 
						AND strState = C.strTaxState 
						AND ISNULL(tblCFFactorTaxGroupXRef.intCategoryId,0) != I.intCategoryId
					) > 0
		                THEN (SELECT TOP 1 strFactorTaxGroup FROM tblCFFactorTaxGroupXRef WHERE 
						ISNULL(tblCFFactorTaxGroupXRef.intCustomerId,0) = tblCFTransaction.intCustomerId 
						AND strState = C.strTaxState 
						AND ISNULL(tblCFFactorTaxGroupXRef.intCategoryId,0) != I.intCategoryId
					)
	                WHEN (SELECT COUNT(1) FROM tblCFFactorTaxGroupXRef WHERE 
						ISNULL(tblCFFactorTaxGroupXRef.intCustomerId,0) != tblCFTransaction.intCustomerId 
						AND strState = C.strTaxState 
						AND ISNULL(tblCFFactorTaxGroupXRef.intCategoryId,0) != I.intCategoryId
					) > 0
		                THEN (SELECT TOP 1 strFactorTaxGroup FROM tblCFFactorTaxGroupXRef 
						WHERE 
						ISNULL(tblCFFactorTaxGroupXRef.intCustomerId,0) != tblCFTransaction.intCustomerId 
						AND strState = C.strTaxState 
						AND ISNULL(tblCFFactorTaxGroupXRef.intCategoryId,0) != I.intCategoryId
					)
	                ELSE ''
                END
                , 'Tax 1' = cast(ROUND(ISNULL(transView.dblTotalFET, 0.0),2)as numeric(18,2))
                , 'Tax 2' = cast(ROUND(ISNULL(SOTTaxes.dblTaxCalculatedAmount, 0.0) ,2)as numeric(18,2))
                , 'Tax 3' = cast(ROUND(ISNULL(transView.dblTotalSET, 0.0)  ,2)as numeric(18,2))
                , 'Tax 4' = cast(ROUND(ISNULL(transView.dblTotalSST, 0.0),2)as numeric(18,2))
                , 'Tax 5' = cast(ROUND(ISNULL(CityTaxes.dblTaxCalculatedAmount, 0.0),2)as numeric(18,2))
                , 'Tax 6' = cast(ROUND(ISNULL(CountyTaxes.dblTaxCalculatedAmount, 0.0),2)as numeric(18,2))
                , 'Tax 7' = cast(ROUND(0.0,2)as numeric(18,2))
                , 'Pump Price' = cast(ROUND(ISNULL(tblCFTransaction.dblCalculatedGrossPrice, 0.0),5)as numeric(18,5))
                , 'Billing Price' = cast(ROUND(ISNULL(tblCFTransaction.dblCalculatedGrossPrice, 0.0),5)as numeric(18,5))
                , 'Disc 1' =  cast(ROUND(0.0,2)as numeric(18,2))
                , 'Disc 2' =  cast(ROUND(0.0,2)as numeric(18,2))
                , 'Disc 3' =  cast(ROUND(0.0,2)as numeric(18,2))
                , 'Unit Cost' = cast(ROUND(ISNULL(tblCFTransaction.dblTransferCost, 0.0),5)as numeric(18,5))
                , 'Total Amount' = cast(ROUND(ISNULL(tblCFTransaction.dblCalculatedTotalPrice, 0.0),2)as numeric(18,2))
                , 'Total Amount1' = cast(ROUND(ISNULL(tblCFTransaction.dblCalculatedTotalPrice, 0.0),2)as numeric(18,2))
                , 'Sell Host' = dbo.fnCFPadString(ISNULL(C.intPPHostId, 0) , 6, '0', 'left') 
                , 'Buy Host' = CASE WHEN (tblCFTransaction.strTransactionType like '%Foreign%') 
						            THEN '000984'
						            ELSE  dbo.fnCFPadString((SELECT TOP 1 Record FROM [fnCFSplitString]((SELECT TOP 1 strParticipant   FROM tblCFNetwork),',')), 6, '0', 'left') 
					            END
                , 'Blank Field2' = ''
                , 'Blank Field3' = ''
                , 'Blank Field4' = ''
                , 'Blank Field5' = ''
                , 'Blank Field6' = ''
                , 'Blank Field7' = ''
                , 'Blank Field8' = ''
            FROM tblCFTransaction tblCFTransaction
            LEFT JOIN tblCFCard A
                ON tblCFTransaction.intCardId = A.intCardId
            INNER JOIN vyuCFSearchTransaction transView
                ON tblCFTransaction.intTransactionId = transView.intTransactionId
            LEFT JOIN tblCFVehicle B
                ON tblCFTransaction.intVehicleId = B.intVehicleId
            LEFT JOIN tblCFSite C
                ON tblCFTransaction.intSiteId = C.intSiteId
            LEFT JOIN tblCFItem D
                ON tblCFTransaction.intProductId = D.intItemId
            LEFT JOIN tblICItem I 
				ON I.intItemId = D.intARItemId
            LEFT JOIN tblSMTaxGroup E
                ON C.intTaxGroupId = E.intTaxGroupId
            LEFT OUTER JOIN (SELECT intTransactionId, ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
				            FROM   dbo.vyuCFTransactionTax AS SSTTaxes 
				            WHERE  ( strTaxClass LIKE '%SOT%' ) 
				            GROUP  BY intTransactionId) AS SOTTaxes 
	            ON tblCFTransaction.intTransactionId = SOTTaxes.intTransactionId 
            LEFT OUTER JOIN (SELECT intTransactionId, 
						            ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
				            FROM   dbo.vyuCFTransactionTax AS SSTTaxes 
				            WHERE  ( LOWER(strTaxClass) LIKE '%city%' ) 
				            GROUP  BY intTransactionId) AS CityTaxes 
	            ON tblCFTransaction.intTransactionId = CityTaxes.intTransactionId 
            LEFT OUTER JOIN (SELECT intTransactionId, 
						            ISNULL(Sum(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
				            FROM   dbo.vyuCFTransactionTax AS SSTTaxes 
				            WHERE  ( LOWER(strTaxClass) LIKE '%county%' ) 
				            GROUP  BY intTransactionId) AS CountyTaxes 
	            ON tblCFTransaction.intTransactionId = CountyTaxes.intTransactionId 
            LEFT JOIN tblARCustomer tblARCustomer 
	            ON tblCFTransaction.intCustomerId = tblARCustomer.intEntityId
            LEFT JOIN tblCFNetwork N
                ON tblCFTransaction.intNetworkId = N.intNetworkId
			WHERE tblCFTransaction.intTransactionId IN (SELECT intTransactionId from @tblCFTransactionId)  
			ORDER BY tblCFTransaction.intTransactionId ASC


	



