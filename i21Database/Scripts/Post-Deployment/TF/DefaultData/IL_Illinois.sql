-- Declare the Tax Authority Code that will be used all throughout Indiana Default Data
PRINT ('Deploying Illinois Tax Forms')
DECLARE @TaxAuthorityCode NVARCHAR(10) = 'IL'
	, @TaxAuthorityId INT
SELECT @TaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = @TaxAuthorityCode


-- Product Codes
/* Generate script for Product Codes. Specify Tax Authority Id to filter out specific Product Codes only.
select 'UNION ALL SELECT intProductCodeId = ' + CAST(intProductCodeId AS NVARCHAR(10)) 
	+ CASE WHEN strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + strProductCode + ''''  END
	+ CASE WHEN strDescription IS NULL THEN ', strDescription = NULL' ELSE ', strDescription = ''' + strDescription + ''''  END
	+ CASE WHEN strProductCodeGroup IS NULL THEN ', strProductCodeGroup = NULL' ELSE ', strProductCodeGroup = ''' + strProductCodeGroup + ''''  END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END 
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intProductCodeId ELSE intMasterId END) AS NVARCHAR(20))
from tblTFProductCode
where intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @ProductCodes AS TFProductCodes

INSERT INTO @ProductCodes (
	intProductCodeId
    , strProductCode
    , strDescription
    , strProductCodeGroup
    , strNote
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intProductCodeId = 369, strProductCode = '065', strDescription = 'Gasoline', strProductCodeGroup = 'Gasoline Products', strNote = NULL, intMasterId = 369
UNION ALL SELECT intProductCodeId = 370, strProductCode = '124', strDescription = 'Gasohol', strProductCodeGroup = 'Gasoline Products', strNote = NULL, intMasterId = 370
UNION ALL SELECT intProductCodeId = 371, strProductCode = '123', strDescription = 'Alcohol', strProductCodeGroup = 'Gasoline Products', strNote = NULL, intMasterId = 371
UNION ALL SELECT intProductCodeId = 372, strProductCode = 'E00', strDescription = 'Ethanol (100%)', strProductCodeGroup = 'Gasoline Products', strNote = NULL, intMasterId = 372
UNION ALL SELECT intProductCodeId = 373, strProductCode = 'E11', strDescription = 'Ethanol (11%)', strProductCodeGroup = 'Gasoline Products', strNote = NULL, intMasterId = 373
UNION ALL SELECT intProductCodeId = 374, strProductCode = '091', strDescription = 'Cooking oil/fat (waste oil, etc)', strProductCodeGroup = 'Special Fuel Products -- Undyed', strNote = NULL, intMasterId = 374
UNION ALL SELECT intProductCodeId = 375, strProductCode = '142', strDescription = 'Kerosene - Undyed', strProductCodeGroup = 'Special Fuel Products -- Undyed', strNote = NULL, intMasterId = 375
UNION ALL SELECT intProductCodeId = 376, strProductCode = '160', strDescription = 'Diesel Fuel - Undyed', strProductCodeGroup = 'Special Fuel Products -- Undyed', strNote = NULL, intMasterId = 376
UNION ALL SELECT intProductCodeId = 377, strProductCode = '285', strDescription = 'Soy Oil', strProductCodeGroup = 'Special Fuel Products -- Undyed', strNote = NULL, intMasterId = 377
UNION ALL SELECT intProductCodeId = 378, strProductCode = 'B00', strDescription = 'Biodiesel - Undyed (100%)', strProductCodeGroup = 'Special Fuel Products -- Undyed', strNote = NULL, intMasterId = 378
UNION ALL SELECT intProductCodeId = 379, strProductCode = 'B11', strDescription = 'Biodiesel - Undyed (11%)', strProductCodeGroup = 'Special Fuel Products -- Undyed', strNote = NULL, intMasterId = 379
UNION ALL SELECT intProductCodeId = 380, strProductCode = '072', strDescription = 'Kerosene - Dyed', strProductCodeGroup = 'Special Fuel Products -- Dyed', strNote = NULL, intMasterId = 380
UNION ALL SELECT intProductCodeId = 381, strProductCode = '228', strDescription = 'Diesel Fuel - Dyed', strProductCodeGroup = 'Special Fuel Products -- Dyed', strNote = NULL, intMasterId = 381
UNION ALL SELECT intProductCodeId = 382, strProductCode = 'D00', strDescription = 'Biodiesel - Dyed (100%)', strProductCodeGroup = 'Special Fuel Products -- Dyed', strNote = NULL, intMasterId = 382
UNION ALL SELECT intProductCodeId = 383, strProductCode = 'D11', strDescription = 'Biodiesel - Dyed (11%)', strProductCodeGroup = 'Special Fuel Products -- Dyed', strNote = NULL, intMasterId = 383
UNION ALL SELECT intProductCodeId = 384, strProductCode = '073', strDescription = 'Dyed 1-K Reporting Only', strProductCodeGroup = 'Aviation and Other Fuel Products', strNote = NULL, intMasterId = 384
UNION ALL SELECT intProductCodeId = 385, strProductCode = '125', strDescription = 'Aviation Gasoline (AvGas)', strProductCodeGroup = 'Aviation and Other Fuel Products', strNote = NULL, intMasterId = 385
UNION ALL SELECT intProductCodeId = 386, strProductCode = '130', strDescription = 'Jet Fuel', strProductCodeGroup = 'Aviation and Other Fuel Products', strNote = NULL, intMasterId = 386
UNION ALL SELECT intProductCodeId = 387, strProductCode = '145', strDescription = 'Undyed 1-K Reporting Only', strProductCodeGroup = 'Aviation and Other Fuel Products', strNote = NULL, intMasterId = 387
UNION ALL SELECT intProductCodeId = 388, strProductCode = '054', strDescription = 'Propane (LP)', strProductCodeGroup = 'Alternative Fuels Products - For On Road Use', strNote = NULL, intMasterId = 388
UNION ALL SELECT intProductCodeId = 389, strProductCode = '224', strDescription = 'Compressed Natural Gas (CNG)', strProductCodeGroup = 'Alternative Fuels Products - For On Road Use', strNote = NULL, intMasterId = 389
UNION ALL SELECT intProductCodeId = 390, strProductCode = '225', strDescription = 'Liquid Natural Gas (LNG)', strProductCodeGroup = 'Alternative Fuels Products - For On Road Use', strNote = NULL, intMasterId = 390
UNION ALL SELECT intProductCodeId = 391, strProductCode = '998', strDescription = 'Motor Fuel Product - (gaseous state)', strProductCodeGroup = 'Other - Use When Your Product Is Not Listed', strNote = NULL, intMasterId = 391
UNION ALL SELECT intProductCodeId = 392, strProductCode = '999', strDescription = 'Motor Fuel Product - (liquid state)', strProductCodeGroup = 'Other - Use When Your Product Is Not Listed', strNote = NULL, intMasterId = 392
UNION ALL SELECT intProductCodeId = 1410, strProductCode = 'E10', strDescription = 'Ethanol (10%)', strProductCodeGroup = 'Gasoline Products', strNote = NULL, intMasterId = 1410
UNION ALL SELECT intProductCodeId = 1411, strProductCode = 'B10', strDescription = 'Biodiesel - Undyed (10%)', strProductCodeGroup = 'Special Fuel Products -- Undyed', strNote = NULL, intMasterId = 1411
UNION ALL SELECT intProductCodeId = 1412, strProductCode = 'D10', strDescription = 'Biodiesel - Dyed (10%)', strProductCodeGroup = 'Special Fuel Products -- Dyed', strNote = NULL, intMasterId = 1412
UNION ALL SELECT intProductCodeId = 2441, strProductCode = 'B02', strDescription = 'Biodiesel - Undyed (2%)', strProductCodeGroup = 'Special Fuel Products -- Undyed', strNote = NULL, intMasterId = 2441
UNION ALL SELECT intProductCodeId = 2442, strProductCode = 'B05', strDescription = 'Biodiesel - Undyed (5%)', strProductCodeGroup = 'Special Fuel Products -- Undyed', strNote = NULL, intMasterId = 2442
UNION ALL SELECT intProductCodeId = 2443, strProductCode = 'D02', strDescription = 'Biodiesel - Dyed (2%)', strProductCodeGroup = 'Special Fuel Products -- Dyed', strNote = NULL, intMasterId = 2443
UNION ALL SELECT intProductCodeId = 2444, strProductCode = 'D05', strDescription = 'Biodiesel - Dyed (5%)', strProductCodeGroup = 'Special Fuel Products -- Dyed', strNote = NULL, intMasterId = 2444
UNION ALL SELECT intProductCodeId = 2445, strProductCode = 'E06', strDescription = 'Ethanol (6%)', strProductCodeGroup = 'Gasoline Products', strNote = NULL, intMasterId = 2445
UNION ALL SELECT intProductCodeId = 2446, strProductCode = 'E08', strDescription = 'Ethanol (8%)', strProductCodeGroup = 'Gasoline Products', strNote = NULL, intMasterId = 2446
UNION ALL SELECT intProductCodeId = 2447, strProductCode = 'E75', strDescription = 'Ethanol (75%)', strProductCodeGroup = 'Gasoline Products', strNote = NULL, intMasterId = 2447

EXEC uspTFUpgradeProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ProductCodes = @ProductCodes


-- Terminal Control Numbers
/* Generate script for Terminal Control Numbers. Specify Tax Authority Id to filter out specific Terminal Control Numbers only.
select 'UNION ALL SELECT intTerminalControlNumberId = ' + CAST(intTerminalControlNumberId AS NVARCHAR(10)) 
	+ CASE WHEN strTerminalControlNumber IS NULL THEN ', strTerminalControlNumber = NULL' ELSE ', strTerminalControlNumber = ''' + strTerminalControlNumber + ''''  END
	+ CASE WHEN strName IS NULL THEN ', strName = NULL' ELSE ', strName = ''' + strName + ''''  END
	+ CASE WHEN strAddress IS NULL THEN ', strAddress = NULL' ELSE ', strAddress = ''' + strAddress + ''''  END
	+ CASE WHEN strCity IS NULL THEN ', strCity = NULL' ELSE ', strCity = ''' + strCity + '''' END 
	+ CASE WHEN dtmApprovedDate IS NULL THEN ', dtmApprovedDate = NULL' ELSE ', dtmApprovedDate = ''' + CAST(dtmApprovedDate AS NVARCHAR(50)) + '''' END 
	+ CASE WHEN strZip IS NULL THEN ', strZip = NULL' ELSE ', strZip = ''' + strZip + '''' END 
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intTerminalControlNumberId ELSE intMasterId END) AS NVARCHAR(20))
from tblTFTerminalControlNumber
where intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @TerminalControlNumbers AS TFTerminalControlNumbers

INSERT INTO @TerminalControlNumbers(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTerminalControlNumberId = 411, strTerminalControlNumber = 'T-36-IL-3300', strName = 'Valero Terminaling & Distribution', strAddress = '3600 W 131st Street', strCity = 'Alsip', dtmApprovedDate = NULL, strZip = '60803', intMasterId = 411
UNION ALL SELECT intTerminalControlNumberId = 412, strTerminalControlNumber = 'T-36-IL-3301', strName = 'BP Products North America Inc', strAddress = '1111 Elmhurst Rd', strCity = 'Elk Grove Village', dtmApprovedDate = NULL, strZip = '60007', intMasterId = 412
UNION ALL SELECT intTerminalControlNumberId = 413, strTerminalControlNumber = 'T-36-IL-3302', strName = 'BP Products North America Inc', strAddress = '4811 South Harlem Avenue', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 413
UNION ALL SELECT intTerminalControlNumberId = 414, strTerminalControlNumber = 'T-36-IL-3303', strName = 'BP Products North America Inc', strAddress = '100 East Standard Oil Road', strCity = 'Rochelle', dtmApprovedDate = NULL, strZip = '61068', intMasterId = 414
UNION ALL SELECT intTerminalControlNumberId = 415, strTerminalControlNumber = 'T-36-IL-3304', strName = 'CITGO - Mt.  Prospect', strAddress = '2316 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 415
UNION ALL SELECT intTerminalControlNumberId = 416, strTerminalControlNumber = 'T-36-IL-3305', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '8500 West 68th Street', strCity = 'Argo', dtmApprovedDate = NULL, strZip = '60501-0409', intMasterId = 416
UNION ALL SELECT intTerminalControlNumberId = 417, strTerminalControlNumber = 'T-36-IL-3306', strName = 'Buckeye Terminals, LLC - Rockford', strAddress = '1511 South Meridian Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102-', intMasterId = 417
UNION ALL SELECT intTerminalControlNumberId = 418, strTerminalControlNumber = 'T-36-IL-3307', strName = 'Marathon Mt. Prospect', strAddress = '3231 Busse Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005-4610', intMasterId = 418
UNION ALL SELECT intTerminalControlNumberId = 419, strTerminalControlNumber = 'T-36-IL-3308', strName = 'Marathon Oil Rockford', strAddress = '7312 Cunningham Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102', intMasterId = 419
UNION ALL SELECT intTerminalControlNumberId = 420, strTerminalControlNumber = 'T-36-IL-3310', strName = 'NuStar Terminal Services, Inc - Blue Island', strAddress = '3210 West 131st Street', strCity = 'Blue Island', dtmApprovedDate = NULL, strZip = '60406-2364', intMasterId = 420
UNION ALL SELECT intTerminalControlNumberId = 421, strTerminalControlNumber = 'T-36-IL-3311', strName = 'ExxonMobil Oil Corp.', strAddress = '2312 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 421
UNION ALL SELECT intTerminalControlNumberId = 422, strTerminalControlNumber = 'T-36-IL-3312', strName = 'Petroleum Fuel & Terminal - Forest View', strAddress = '4801 South Harlem', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 422
UNION ALL SELECT intTerminalControlNumberId = 423, strTerminalControlNumber = 'T-36-IL-3313', strName = 'Buckeye Terminals, LLC - Kankakee', strAddress = '275 North 2750 West Road', strCity = 'Kankakee', dtmApprovedDate = NULL, strZip = '60901', intMasterId = 423
UNION ALL SELECT intTerminalControlNumberId = 424, strTerminalControlNumber = 'T-36-IL-3315', strName = 'Buckeye Terminals, LLC - Argo', strAddress = '8600 West 71st. Street', strCity = 'Argo', dtmApprovedDate = NULL, strZip = '60501', intMasterId = 424
UNION ALL SELECT intTerminalControlNumberId = 425, strTerminalControlNumber = 'T-36-IL-3316', strName = 'Shell Oil Products US', strAddress = '1605 E. Algonquin Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 425
UNION ALL SELECT intTerminalControlNumberId = 426, strTerminalControlNumber = 'T-36-IL-3317', strName = 'CITGO - Lemont', strAddress = '135th & New Avenue', strCity = 'Lemont', dtmApprovedDate = NULL, strZip = '60439', intMasterId = 426
UNION ALL SELECT intTerminalControlNumberId = 427, strTerminalControlNumber = 'T-36-IL-3318', strName = 'CITGO - Arlington Heights', strAddress = '2304 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 427
UNION ALL SELECT intTerminalControlNumberId = 428, strTerminalControlNumber = 'T-36-IL-3320', strName = 'Magellan Pipeline Company, L.P.', strAddress = '10601 Franklin Avenue', strCity = 'Franklin Park', dtmApprovedDate = NULL, strZip = '60131', intMasterId = 428
UNION ALL SELECT intTerminalControlNumberId = 429, strTerminalControlNumber = 'T-36-IL-3325', strName = 'Aircraft Service International, Inc.', strAddress = 'Chicago O''Hare Int''l Airport', strCity = 'Chicago', dtmApprovedDate = NULL, strZip = '60666', intMasterId = 429
UNION ALL SELECT intTerminalControlNumberId = 430, strTerminalControlNumber = 'T-36-IL-3326', strName = 'United Parcel Service Inc', strAddress = '3300 Airport Dr', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61109', intMasterId = 430
UNION ALL SELECT intTerminalControlNumberId = 431, strTerminalControlNumber = 'T-36-IL-3375', strName = 'ExxonMobil Oil Corporation', strAddress = '12909 High Road', strCity = 'Lockport', dtmApprovedDate = NULL, strZip = '60441-', intMasterId = 431
UNION ALL SELECT intTerminalControlNumberId = 432, strTerminalControlNumber = 'T-36-IL-3376', strName = 'Aircraft Service International, Inc.', strAddress = 'Midway Airport', strCity = 'Chicago', dtmApprovedDate = NULL, strZip = '60638', intMasterId = 432
UNION ALL SELECT intTerminalControlNumberId = 433, strTerminalControlNumber = 'T-36-IL-3377', strName = 'IMTT-Illinois', strAddress = '24420 W Durkee Road', strCity = 'Channahon', dtmApprovedDate = NULL, strZip = '60410', intMasterId = 433
UNION ALL SELECT intTerminalControlNumberId = 434, strTerminalControlNumber = 'T-36-IL-3378', strName = 'Oiltanking Joliet', strAddress = '27100 South Frontage Rd', strCity = 'Channahon', dtmApprovedDate = NULL, strZip = '60410', intMasterId = 434
UNION ALL SELECT intTerminalControlNumberId = 435, strTerminalControlNumber = 'T-37-IL-3351', strName = 'BP Products North America Inc', strAddress = '1000 BP Lane', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 435
UNION ALL SELECT intTerminalControlNumberId = 436, strTerminalControlNumber = 'T-37-IL-3353', strName = 'Phillips 66 PL - Hartford', strAddress = '2150 Delmar', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 436
UNION ALL SELECT intTerminalControlNumberId = 437, strTerminalControlNumber = 'T-37-IL-3354', strName = 'Hartford Wood River Terminal', strAddress = '900 North Delmar', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 437
UNION ALL SELECT intTerminalControlNumberId = 438, strTerminalControlNumber = 'T-37-IL-3356', strName = 'Buckeye Terminals, LLC - Hartford', strAddress = '220 E Hawthorne Street', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048-', intMasterId = 438
UNION ALL SELECT intTerminalControlNumberId = 439, strTerminalControlNumber = 'T-37-IL-3358', strName = 'Marathon Champaign', strAddress = '511 S. Staley Road', strCity = 'Champaign', dtmApprovedDate = NULL, strZip = '61821', intMasterId = 439
UNION ALL SELECT intTerminalControlNumberId = 440, strTerminalControlNumber = 'T-37-IL-3360', strName = 'Marathon Robinson', strAddress = '12345 E 1050th Ave', strCity = 'Robinson', dtmApprovedDate = NULL, strZip = '62454', intMasterId = 440
UNION ALL SELECT intTerminalControlNumberId = 441, strTerminalControlNumber = 'T-37-IL-3361', strName = 'HWRT Terminal - Norris City', strAddress = 'Rural Route 2', strCity = 'Norris City', dtmApprovedDate = NULL, strZip = '62869', intMasterId = 441
UNION ALL SELECT intTerminalControlNumberId = 442, strTerminalControlNumber = 'T-37-IL-3364', strName = 'Growmark, Inc.', strAddress = 'Rt 49 South', strCity = 'Ashkum', dtmApprovedDate = NULL, strZip = '60911', intMasterId = 442
UNION ALL SELECT intTerminalControlNumberId = 443, strTerminalControlNumber = 'T-37-IL-3365', strName = 'Buckeye Terminals, LLC - Decatur', strAddress = '266 E Shafer Drive', strCity = 'Forsyth', dtmApprovedDate = NULL, strZip = '62535', intMasterId = 443
UNION ALL SELECT intTerminalControlNumberId = 444, strTerminalControlNumber = 'T-37-IL-3366', strName = 'Phillips 66 PL - E. St.  Louis', strAddress = '3300 Mississippi Ave', strCity = 'Cahokia', dtmApprovedDate = NULL, strZip = '62206', intMasterId = 444
UNION ALL SELECT intTerminalControlNumberId = 445, strTerminalControlNumber = 'T-37-IL-3368', strName = 'Buckeye Terminals, LLC - Effingham', strAddress = '18264 N US Hwy 45', strCity = 'Effingham', dtmApprovedDate = NULL, strZip = '62401', intMasterId = 445
UNION ALL SELECT intTerminalControlNumberId = 446, strTerminalControlNumber = 'T-37-IL-3369', strName = 'Buckeye Terminals, LLC - Harristown', strAddress = '600 E. Lincoln Memorial Pky', strCity = 'Harristown', dtmApprovedDate = NULL, strZip = '62537', intMasterId = 446
UNION ALL SELECT intTerminalControlNumberId = 447, strTerminalControlNumber = 'T-37-IL-3371', strName = 'Magellan Pipeline Company, L.P.', strAddress = '16490 East 100 North Rd.', strCity = 'Heyworth', dtmApprovedDate = NULL, strZip = '61745', intMasterId = 447
UNION ALL SELECT intTerminalControlNumberId = 448, strTerminalControlNumber = 'T-37-IL-3372', strName = 'Growmark, Inc.', strAddress = '18349 State Hwy 29', strCity = 'Petersburg', dtmApprovedDate = NULL, strZip = '62675', intMasterId = 448
UNION ALL SELECT intTerminalControlNumberId = 449, strTerminalControlNumber = 'T-43-IL-3729', strName = 'Omega Partners III, LLC', strAddress = '1402 S Delmare', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048-0065', intMasterId = 449
UNION ALL SELECT intTerminalControlNumberId = 450, strTerminalControlNumber = 'T-72-IL-0001', strName = 'West Shore Pipeline Company - Arlington Heights', strAddress = '3400 South Badger Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 450
UNION ALL SELECT intTerminalControlNumberId = 451, strTerminalControlNumber = 'T-72-IL-0002', strName = 'West Shore Pipeline Company - Forest View', strAddress = '5027 South Harlem Avenue', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 451
UNION ALL SELECT intTerminalControlNumberId = 452, strTerminalControlNumber = 'T-72-IL-0003', strName = 'West Shore Pipeline Company - Arlington Heights', strAddress = '3223 Busse Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 452
UNION ALL SELECT intTerminalControlNumberId = 453, strTerminalControlNumber = 'T-72-IL-0004', strName = 'West Shore Pipeline Company - Rockford', strAddress = '7245 Cunningham Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102', intMasterId = 453
UNION ALL SELECT intTerminalControlNumberId = 454, strTerminalControlNumber = 'T-72-IL-0005', strName = 'IMTT - Lemont', strAddress = '13589 Main Street', strCity = 'Lemont', dtmApprovedDate = NULL, strZip = '60439', intMasterId = 454

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = @TaxAuthorityCode, @TerminalControlNumbers = @TerminalControlNumbers


-- Tax Category
/* Generate script for Tax Categories. Specify Tax Authority Id to filter out specific Tax Categories only.
select 'UNION ALL SELECT intTaxCategoryId = ' + CAST(intTaxCategoryId AS NVARCHAR(10))
	+ CASE WHEN strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + strState + ''''  END
	+ CASE WHEN strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + strTaxCategory + ''''  END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intTaxCategoryId ELSE intMasterId END) AS NVARCHAR(20))
from tblTFTaxCategory
where intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @TaxCategories AS TFTaxCategory

INSERT INTO @TaxCategories(
	intTaxCategoryId
	, strState
	, strTaxCategory
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTaxCategoryId = 5, strState = 'IL', strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', intMasterId = 5
UNION ALL SELECT intTaxCategoryId = 6, strState = 'IL', strTaxCategory = 'IL Excise Tax Diesel Clear', intMasterId = 6
UNION ALL SELECT intTaxCategoryId = 35, strState = 'IL', strTaxCategory = 'IL Excise Tax Combustible Gases', intMasterId = 35
UNION ALL SELECT intTaxCategoryId = 36, strState = 'IL', strTaxCategory = 'IL Underground Storage Tank (UST)', intMasterId = 36
UNION ALL SELECT intTaxCategoryId = 37, strState = 'IL', strTaxCategory = 'IL Environment Impact Fee (EIF)', intMasterId = 37

EXEC uspTFUpgradeTaxCategories @TaxAuthorityCode = @TaxAuthorityCode, @TaxCategories = @TaxCategories


-- Reporting Component
/* Generate script for Reporting Components. Specify Tax Authority Id to filter out specific Reporting Components only.
select 'UNION ALL SELECT intReportingComponentId = ' + CAST(intReportingComponentId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strFormName IS NULL THEN ', strFormName = NULL' ELSE ', strFormName = ''' + strFormName + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strScheduleName IS NULL THEN ', strScheduleName = NULL' ELSE ', strScheduleName = ''' + strScheduleName + '''' END 
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strNote IS NULL THEN ', strNote = NULL' ELSE ', strNote = ''' + strNote + '''' END
	+ CASE WHEN strTransactionType IS NULL THEN ', strTransactionType = NULL' ELSE ', strTransactionType = ''' + strTransactionType + '''' END
	+ CASE WHEN intPositionId IS NULL THEN ', intPositionId = NULL' ELSE ', intPositionId = ' + CAST(intPositionId AS NVARCHAR(10)) END
	+ CASE WHEN strSPInventory IS NULL THEN ', strSPInventory = NULL' ELSE ', strSPInventory = ''' + strSPInventory + '''' END
	+ CASE WHEN strSPInvoice IS NULL THEN ', strSPInvoice = NULL' ELSE ', strSPInvoice = ''' + strSPInvoice + '''' END
	+ CASE WHEN strSPRunReport IS NULL THEN ', strSPRunReport = NULL' ELSE ', strSPRunReport = ''' + strSPRunReport + '''' END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intReportingComponentId ELSE intMasterId END) AS NVARCHAR(20))
from tblTFReportingComponent
where intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @ReportingComponent AS TFReportingComponent

INSERT INTO @ReportingComponent(
	intReportingComponentId
	, strFormCode
	, strFormName
	, strScheduleCode
	, strScheduleName
	, strType
	, strNote
	, strTransactionType
	, intPositionId
	, strSPInventory
	, strSPInvoice
	, strSPRunReport
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intReportingComponentId = 1157, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'A', strScheduleName = 'Gasoline Products Produced, Acquired, Received, or Transported in IL', strType = 'Received, MFT-free Only', strNote = 'ReceiptType=1;TaxType=1', strTransactionType = '', intPositionId = 10, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1157
UNION ALL SELECT intReportingComponentId = 1158, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'A', strScheduleName = 'Gasoline Products Produced, Acquired, Received, or Transported in IL', strType = 'Received, UST-/EIF-free Only', strNote = 'ReceiptType=1;TaxType=2', strTransactionType = '', intPositionId = 20, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1158
UNION ALL SELECT intReportingComponentId = 1159, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'A', strScheduleName = 'Gasoline Products Produced, Acquired, Received, or Transported in IL', strType = 'Received, Both MFT- and UST-/EIF-free', strNote = 'ReceiptType=1;TaxType=3', strTransactionType = '', intPositionId = 30, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1159
UNION ALL SELECT intReportingComponentId = 1160, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'A', strScheduleName = 'Gasoline Products Produced, Acquired, Received, or Transported in IL', strType = 'Imported, MFT-free Only', strNote = 'ReceiptType=2;TaxType=1', strTransactionType = '', intPositionId = 40, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1160
UNION ALL SELECT intReportingComponentId = 1161, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'A', strScheduleName = 'Gasoline Products Produced, Acquired, Received, or Transported in IL', strType = 'Imported, UST-/EIF-free Only', strNote = 'ReceiptType=2;TaxType=2', strTransactionType = '', intPositionId = 50, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1161
UNION ALL SELECT intReportingComponentId = 1162, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'A', strScheduleName = 'Gasoline Products Produced, Acquired, Received, or Transported in IL', strType = 'Imported, Both MFT- and UST-/EIF-free', strNote = 'ReceiptType=2;TaxType=3', strTransactionType = '', intPositionId = 60, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1162
UNION ALL SELECT intReportingComponentId = 1163, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DA', strScheduleName = 'Dyed Diesel Products Produced, Acquired, Received, or Transported in IL', strType = 'Received, MFT-free Only', strNote = 'ReceiptType=1;TaxType=1', strTransactionType = '', intPositionId = 70, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1163
UNION ALL SELECT intReportingComponentId = 1164, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DA', strScheduleName = 'Dyed Diesel Products Produced, Acquired, Received, or Transported in IL', strType = 'Received, UST-/EIF-free Only', strNote = 'ReceiptType=1;TaxType=2', strTransactionType = '', intPositionId = 80, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1164
UNION ALL SELECT intReportingComponentId = 1165, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DA', strScheduleName = 'Dyed Diesel Products Produced, Acquired, Received, or Transported in IL', strType = 'Received, Both MFT- and UST-/EIF-free', strNote = 'ReceiptType=1;TaxType=3', strTransactionType = '', intPositionId = 90, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1165
UNION ALL SELECT intReportingComponentId = 1166, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DA', strScheduleName = 'Dyed Diesel Products Produced, Acquired, Received, or Transported in IL', strType = 'Imported, MFT-free Only', strNote = 'ReceiptType=2;TaxType=1', strTransactionType = '', intPositionId = 100, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1166
UNION ALL SELECT intReportingComponentId = 1167, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DA', strScheduleName = 'Dyed Diesel Products Produced, Acquired, Received, or Transported in IL', strType = 'Imported, UST-/EIF-free Only', strNote = 'ReceiptType=2;TaxType=2', strTransactionType = '', intPositionId = 110, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1167
UNION ALL SELECT intReportingComponentId = 1168, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DA', strScheduleName = 'Dyed Diesel Products Produced, Acquired, Received, or Transported in IL', strType = 'Imported, Both MFT- and UST-/EIF-free', strNote = 'ReceiptType=2;TaxType=3', strTransactionType = '', intPositionId = 120, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1168
UNION ALL SELECT intReportingComponentId = 1169, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LA', strScheduleName = 'Fuels Other Than Gasoline and Speical Fuels Produced, Acquired, Received, or Transported in IL', strType = 'Received', strNote = 'ReceiptType=1', strTransactionType = '', intPositionId = 130, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1169
UNION ALL SELECT intReportingComponentId = 1170, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LA', strScheduleName = 'Fuels Other Than Gasoline and Speical Fuels Produced, Acquired, Received, or Transported in IL', strType = 'Imported', strNote = 'ReceiptType=2', strTransactionType = '', intPositionId = 140, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1170
UNION ALL SELECT intReportingComponentId = 1179, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SA', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Produced, Acquired, Received, or Transported into IL', strType = 'Received, MFT-free Only', strNote = 'ReceiptType=1;TaxType=1', strTransactionType = '', intPositionId = 190, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1179
UNION ALL SELECT intReportingComponentId = 1180, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SA', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Produced, Acquired, Received, or Transported into IL', strType = 'Received, UST-/EIF-free Only', strNote = 'ReceiptType=1;TaxType=2', strTransactionType = '', intPositionId = 200, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1180
UNION ALL SELECT intReportingComponentId = 1181, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SA', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Produced, Acquired, Received, or Transported into IL', strType = 'Received, Both MFT- and UST-/EIF-free', strNote = 'ReceiptType=1;TaxType=3', strTransactionType = '', intPositionId = 210, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1181
UNION ALL SELECT intReportingComponentId = 1182, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SA', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Produced, Acquired, Received, or Transported into IL', strType = 'Imported, MFT-free Only', strNote = 'ReceiptType=2;TaxType=1', strTransactionType = '', intPositionId = 220, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1182
UNION ALL SELECT intReportingComponentId = 1183, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SA', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Produced, Acquired, Received, or Transported into IL', strType = 'Imported, UST-/EIF-free Only', strNote = 'ReceiptType=2;TaxType=2', strTransactionType = '', intPositionId = 230, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1183
UNION ALL SELECT intReportingComponentId = 1184, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SA', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Produced, Acquired, Received, or Transported into IL', strType = 'Imported, Both MFT- and UST-/EIF-free', strNote = 'ReceiptType=2;TaxType=3', strTransactionType = '', intPositionId = 240, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1184
UNION ALL SELECT intReportingComponentId = 1185, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'B', strScheduleName = 'Gasoline Sold to Federal Government etc', strType = '', strNote = '', strTransactionType = NULL, intPositionId = 250, strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL, intMasterId = 1185
UNION ALL SELECT intReportingComponentId = 1186, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DB', strScheduleName = 'Dyed Diesel Sold to Federal Government etc', strType = '', strNote = '', strTransactionType = NULL, intPositionId = 260, strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL, intMasterId = 1186
UNION ALL SELECT intReportingComponentId = 1187, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LB', strScheduleName = 'UST/EIF Exemption for Sales of Aviation Fuels, Kerosene, and Diesel', strType = 'Diesel Sold to Railroads', strNote = '', strTransactionType = '', intPositionId = 270, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1187
UNION ALL SELECT intReportingComponentId = 1188, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LB', strScheduleName = 'UST/EIF Exemption for Sales of Aviation Fuels, Kerosene, and Diesel', strType = 'Diesel Sold to Ships etc', strNote = '', strTransactionType = '', intPositionId = 280, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1188
UNION ALL SELECT intReportingComponentId = 1189, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LB', strScheduleName = 'UST/EIF Exemption for Sales of Aviation Fuels, Kerosene, and Diesel', strType = 'Kerosene Sold to Air Carriers', strNote = '', strTransactionType = '', intPositionId = 290, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1189
UNION ALL SELECT intReportingComponentId = 1190, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LB', strScheduleName = 'UST/EIF Exemption for Sales of Aviation Fuels, Kerosene, and Diesel', strType = 'Aviation Fuel Sold to Air Carriers', strNote = '', strTransactionType = '', intPositionId = 300, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1190
UNION ALL SELECT intReportingComponentId = 1191, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LB', strScheduleName = 'UST/EIF Exemption for Sales of Aviation Fuels, Kerosene, and Diesel', strType = '1-k Kerosene Sold to Air Carriers', strNote = '', strTransactionType = '', intPositionId = 310, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1191
UNION ALL SELECT intReportingComponentId = 1192, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SB', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Sold to Federal Government etc', strType = '', strNote = '', strTransactionType = NULL, intPositionId = 320, strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL, intMasterId = 1192
UNION ALL SELECT intReportingComponentId = 1193, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'C', strScheduleName = 'Sales and Transfers of Gasoline Products Delivered to Points Outside of IL', strType = '', strNote = '', strTransactionType = '', intPositionId = 330, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1193
UNION ALL SELECT intReportingComponentId = 1194, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DC', strScheduleName = 'Sales and Transfers of Dyed Diesel Delivered to Points Outside of IL', strType = '', strNote = '', strTransactionType = '', intPositionId = 340, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1194
UNION ALL SELECT intReportingComponentId = 1195, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LC', strScheduleName = 'Sales and Transfers of Other Fuels Delivered to Points Outside of IL', strType = '', strNote = '', strTransactionType = '', intPositionId = 350, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1195
UNION ALL SELECT intReportingComponentId = 1196, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SC', strScheduleName = 'Sales and Transfers of Special Fuel (Excluding Dyed Diesel) Delivered to Points Outside of IL', strType = '', strNote = '', strTransactionType = '', intPositionId = 360, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1196
UNION ALL SELECT intReportingComponentId = 1197, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'D', strScheduleName = 'Gasoline Products Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'MFT-free Only', strNote = 'TaxType=1', strTransactionType = '', intPositionId = 370, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1197
UNION ALL SELECT intReportingComponentId = 1198, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'D', strScheduleName = 'Gasoline Products Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'UST-/EIF-free Only', strNote = 'TaxType=2', strTransactionType = '', intPositionId = 380, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1198
UNION ALL SELECT intReportingComponentId = 1199, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'D', strScheduleName = 'Gasoline Products Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'Both MFT- and UST-/EIF-free', strNote = 'TaxType=3', strTransactionType = '', intPositionId = 390, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1199
UNION ALL SELECT intReportingComponentId = 1200, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DD', strScheduleName = 'Dyed Diesel Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'MFT-free Only', strNote = 'TaxType=1', strTransactionType = '', intPositionId = 400, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1200
UNION ALL SELECT intReportingComponentId = 1201, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DD', strScheduleName = 'Dyed Diesel Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'UST-/EIF-free Only', strNote = 'TaxType=2', strTransactionType = '', intPositionId = 410, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1201
UNION ALL SELECT intReportingComponentId = 1202, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DD', strScheduleName = 'Dyed Diesel Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'Both MFT- and UST-/EIF-free', strNote = 'TaxType=3', strTransactionType = '', intPositionId = 420, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1202
UNION ALL SELECT intReportingComponentId = 1203, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LD', strScheduleName = 'Other Fuels Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'Aviation Fuel', strNote = '', strTransactionType = '', intPositionId = 430, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1203
UNION ALL SELECT intReportingComponentId = 1204, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LD', strScheduleName = 'Other Fuels Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = '1-k Kerosene', strNote = '', strTransactionType = '', intPositionId = 440, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1204
UNION ALL SELECT intReportingComponentId = 1205, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LD', strScheduleName = 'Other Fuels Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'Other', strNote = '', strTransactionType = '', intPositionId = 450, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1205
UNION ALL SELECT intReportingComponentId = 1206, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SD', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'MFT-free Only', strNote = 'TaxType=1', strTransactionType = '', intPositionId = 460, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1206
UNION ALL SELECT intReportingComponentId = 1207, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SD', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'UST-/EIF-free Only', strNote = 'TaxType=2', strTransactionType = '', intPositionId = 470, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1207
UNION ALL SELECT intReportingComponentId = 1208, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SD', strScheduleName = 'Special Fuel (Excluding Dyed Diesel) Sold Tax- and Fee-Free in IL to Licensed Distributors and Receivers', strType = 'Both MFT- and UST-/EIF-free', strNote = 'TaxType=3', strTransactionType = '', intPositionId = 480, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1208
UNION ALL SELECT intReportingComponentId = 1209, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'DD-1', strScheduleName = 'Tax-Free Sales of Dyed Diesel to Other Than a Distributor or Supplier in IL', strType = '', strNote = '', strTransactionType = '', intPositionId = 490, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1209
UNION ALL SELECT intReportingComponentId = 1210, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'E', strScheduleName = 'MFT, UST, and EIF Tax- and Fee-Paid Purchases', strType = 'Gasoline, MFT-paid Only', strNote = 'TaxType=1', strTransactionType = '', intPositionId = 500, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1210
UNION ALL SELECT intReportingComponentId = 1211, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'E', strScheduleName = 'MFT, UST, and EIF Tax- and Fee-Paid Purchases', strType = 'Gasoline, UST-/EIF-paid Only', strNote = 'TaxType=2', strTransactionType = '', intPositionId = 510, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1211
UNION ALL SELECT intReportingComponentId = 1212, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'E', strScheduleName = 'MFT, UST, and EIF Tax- and Fee-Paid Purchases', strType = 'Gasoline, Both MFT- and UST-/EIF-paid', strNote = 'TaxType=3', strTransactionType = '', intPositionId = 520, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1212
UNION ALL SELECT intReportingComponentId = 1213, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'E', strScheduleName = 'MFT, UST, and EIF Tax- and Fee-Paid Purchases', strType = 'Combustible Gases, MFT-paid Only', strNote = 'TaxType=1', strTransactionType = '', intPositionId = 530, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1213
UNION ALL SELECT intReportingComponentId = 1214, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'E', strScheduleName = 'MFT, UST, and EIF Tax- and Fee-Paid Purchases', strType = 'Combustible Gases, UST-/EIF-paid Only', strNote = 'TaxType=2', strTransactionType = '', intPositionId = 540, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1214
UNION ALL SELECT intReportingComponentId = 1215, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'E', strScheduleName = 'MFT, UST, and EIF Tax- and Fee-Paid Purchases', strType = 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', strNote = 'TaxType=3', strTransactionType = '', intPositionId = 550, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1215
UNION ALL SELECT intReportingComponentId = 1216, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'E', strScheduleName = 'MFT, UST, and EIF Tax- and Fee-Paid Purchases', strType = 'Alcohol, MFT-paid Only', strNote = 'TaxType=1', strTransactionType = '', intPositionId = 560, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1216
UNION ALL SELECT intReportingComponentId = 1217, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'E', strScheduleName = 'MFT, UST, and EIF Tax- and Fee-Paid Purchases', strType = 'Alcohol, UST-/EIF-paid Only', strNote = 'TaxType=2', strTransactionType = '', intPositionId = 570, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1217
UNION ALL SELECT intReportingComponentId = 1218, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'E', strScheduleName = 'MFT, UST, and EIF Tax- and Fee-Paid Purchases', strType = 'Alcohol, Both MFT- and UST-/EIF-paid', strNote = 'TaxType=3', strTransactionType = '', intPositionId = 580, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1218
UNION ALL SELECT intReportingComponentId = 1219, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LE', strScheduleName = 'Tax- and Fee-Paid Purchases of Fuel Types Subject Only to UST/EIF', strType = 'Aviation Fuel', strNote = '', strTransactionType = '', intPositionId = 590, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1219
UNION ALL SELECT intReportingComponentId = 1220, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LE', strScheduleName = 'Tax- and Fee-Paid Purchases of Fuel Types Subject Only to UST/EIF', strType = '1-K Kerosene', strNote = '', strTransactionType = '', intPositionId = 600, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1220
UNION ALL SELECT intReportingComponentId = 1221, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LE', strScheduleName = 'Tax- and Fee-Paid Purchases of Fuel Types Subject Only to UST/EIF', strType = 'Dyed Diesel', strNote = '', strTransactionType = '', intPositionId = 610, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1221
UNION ALL SELECT intReportingComponentId = 1222, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'LE', strScheduleName = 'Tax- and Fee-Paid Purchases of Fuel Types Subject Only to UST/EIF', strType = 'Other', strNote = '', strTransactionType = '', intPositionId = 620, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1222
UNION ALL SELECT intReportingComponentId = 1223, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SE', strScheduleName = 'Tax- and Fee-Paid Purchases of Special Fuel (Excluding Dyed Diesel)', strType = 'Special Fuel (Excluding Dyed Diesel), MFT-paid Only', strNote = 'TaxType=1', strTransactionType = '', intPositionId = 630, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1223
UNION ALL SELECT intReportingComponentId = 1224, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SE', strScheduleName = 'Tax- and Fee-Paid Purchases of Special Fuel (Excluding Dyed Diesel)', strType = 'Special Fuel (Excluding Dyed Diesel), UST-/EIF-paid Only', strNote = 'TaxType=2', strTransactionType = '', intPositionId = 640, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1224
UNION ALL SELECT intReportingComponentId = 1225, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SE', strScheduleName = 'Tax- and Fee-Paid Purchases of Special Fuel (Excluding Dyed Diesel)', strType = 'Special Fuel (Excluding Dyed Diesel), Both MFT- and UST-/EIF-paid', strNote = 'TaxType=3', strTransactionType = '', intPositionId = 650, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1225
UNION ALL SELECT intReportingComponentId = 1226, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SE', strScheduleName = 'Tax- and Fee-Paid Purchases of Special Fuel (Excluding Dyed Diesel)', strType = '1-K Kerosene, MFT-paid Only', strNote = 'TaxType=1', strTransactionType = '', intPositionId = 660, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1226
UNION ALL SELECT intReportingComponentId = 1227, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SE', strScheduleName = 'Tax- and Fee-Paid Purchases of Special Fuel (Excluding Dyed Diesel)', strType = '1-K Kerosene, UST-/EIF-paid Only', strNote = 'TaxType=2', strTransactionType = '', intPositionId = 670, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1227
UNION ALL SELECT intReportingComponentId = 1228, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SE', strScheduleName = 'Tax- and Fee-Paid Purchases of Special Fuel (Excluding Dyed Diesel)', strType = '1-K Kerosene, Both MFT- and UST-/EIF-paid', strNote = 'TaxType=3', strTransactionType = '', intPositionId = 680, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1228
UNION ALL SELECT intReportingComponentId = 1229, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SE', strScheduleName = 'Tax- and Fee-Paid Purchases of Special Fuel (Excluding Dyed Diesel)', strType = 'Other, MFT-paid Only', strNote = 'TaxType=1', strTransactionType = '', intPositionId = 690, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1229
UNION ALL SELECT intReportingComponentId = 1230, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SE', strScheduleName = 'Tax- and Fee-Paid Purchases of Special Fuel (Excluding Dyed Diesel)', strType = 'Other, UST-/EIF-paid Only', strNote = 'TaxType=2', strTransactionType = '', intPositionId = 700, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1230
UNION ALL SELECT intReportingComponentId = 1231, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'SE', strScheduleName = 'Tax- and Fee-Paid Purchases of Special Fuel (Excluding Dyed Diesel)', strType = 'Other, Both MFT- and UST-/EIF-paid', strNote = 'TaxType=3', strTransactionType = '', intPositionId = 710, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1231
UNION ALL SELECT intReportingComponentId = 1232, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'GA-1', strScheduleName = 'Alcohol, Compressed Gases, or 1-K Kerosene Sold in IL as Motor Fuel', strType = 'LP Gas', strNote = '', strTransactionType = '', intPositionId = 720, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1232
UNION ALL SELECT intReportingComponentId = 1233, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'GA-1', strScheduleName = 'Alcohol, Compressed Gases, or 1-K Kerosene Sold in IL as Motor Fuel', strType = 'Alcohol', strNote = '', strTransactionType = '', intPositionId = 720, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1233
UNION ALL SELECT intReportingComponentId = 1234, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'GA-1', strScheduleName = 'Alcohol, Compressed Gases, or 1-K Kerosene Sold in IL as Motor Fuel', strType = '1-K Kerosene', strNote = '', strTransactionType = '', intPositionId = 730, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1234
UNION ALL SELECT intReportingComponentId = 1235, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'GA-1', strScheduleName = 'Alcohol, Compressed Gases, or 1-K Kerosene Sold in IL as Motor Fuel', strType = 'Other', strNote = '', strTransactionType = '', intPositionId = 740, strSPInventory = '', strSPInvoice = '', strSPRunReport = '', intMasterId = 1235
UNION ALL SELECT intReportingComponentId = 1236, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'M', strScheduleName = 'MFT, UST, and EIF Products Used for Blending', strType = 'Gasoline', strNote = '', strTransactionType = NULL, intPositionId = 750, strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL, intMasterId = 1236
UNION ALL SELECT intReportingComponentId = 1237, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'M', strScheduleName = 'MFT, UST, and EIF Products Used for Blending', strType = 'Special Fuels', strNote = '', strTransactionType = NULL, intPositionId = 760, strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL, intMasterId = 1237
UNION ALL SELECT intReportingComponentId = 2157, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = 'RMFT-5-US', strScheduleName = 'Form RMFT-5-US', strType = NULL, strNote = '', strTransactionType = NULL, intPositionId = 770, strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL, intMasterId = 2157
UNION ALL SELECT intReportingComponentId = 2158, strFormCode = 'RMFT-5', strFormName = 'Motor Fuel Distributor/Supplier Tax Return', strScheduleCode = '', strScheduleName = 'Form RMFT-5', strType = NULL, strNote = 'Form RMFT-5', strTransactionType = NULL, intPositionId = 770, strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL, intMasterId = 2158
UNION ALL SELECT intReportingComponentId = 2248, strFormCode = 'E-file', strFormName = 'IL Electronic (Text) File', strScheduleCode = '', strScheduleName = 'IL Electronic (Text) File', strType = 'Text File', strNote = NULL, strTransactionType = NULL, intPositionId = 780, strSPInventory = NULL, strSPInvoice = NULL, strSPRunReport = NULL, intMasterId = 2248

EXEC uspTFUpgradeReportingComponents @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponent = @ReportingComponent


-- Tax Criteria
/* Generate script for Tax Criteria. Specify Tax Authority Id to filter out specific Tax Criteria only.
select 'UNION ALL SELECT intTaxCriteriaId = ' + CAST(intReportingComponentCriteriaId AS NVARCHAR(10))
	+ CASE WHEN TaxCat.strTaxCategory IS NULL THEN ', strTaxCategory = NULL' ELSE ', strTaxCategory = ''' + TaxCat.strTaxCategory + ''''  END
	+ CASE WHEN TaxCat.strState IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + TaxCat.strState + ''''  END
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strCriteria IS NULL THEN ', strCriteria = NULL' ELSE ', strCriteria = ''' + strCriteria + '''' END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(TaxCrit.intMasterId, '') = '' THEN intReportingComponentCriteriaId ELSE TaxCrit.intMasterId END) AS NVARCHAR(20))
from tblTFReportingComponentCriteria TaxCrit
left join tblTFTaxCategory TaxCat ON TaxCat.intTaxCategoryId = TaxCrit.intTaxCategoryId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = TaxCrit.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId and TaxCat.intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @TaxCriteria AS TFTaxCriteria

INSERT INTO @TaxCriteria(
	intTaxCriteriaId
	, strTaxCategory
	, strState
	, strFormCode
	, strScheduleCode
	, strType
	, strCriteria
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTaxCriteriaId = 139, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, MFT-free Only', strCriteria = '= 0', intMasterId = 139
UNION ALL SELECT intTaxCriteriaId = 140, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 140
UNION ALL SELECT intTaxCriteriaId = 141, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 141
UNION ALL SELECT intTaxCriteriaId = 142, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 142
UNION ALL SELECT intTaxCriteriaId = 143, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 143
UNION ALL SELECT intTaxCriteriaId = 144, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 144
UNION ALL SELECT intTaxCriteriaId = 145, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, MFT-free Only', strCriteria = '= 0', intMasterId = 145
UNION ALL SELECT intTaxCriteriaId = 146, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 146
UNION ALL SELECT intTaxCriteriaId = 147, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 147
UNION ALL SELECT intTaxCriteriaId = 148, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 148
UNION ALL SELECT intTaxCriteriaId = 149, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 149
UNION ALL SELECT intTaxCriteriaId = 150, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 150
UNION ALL SELECT intTaxCriteriaId = 151, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 151
UNION ALL SELECT intTaxCriteriaId = 152, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 152
UNION ALL SELECT intTaxCriteriaId = 153, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 153
UNION ALL SELECT intTaxCriteriaId = 154, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 154
UNION ALL SELECT intTaxCriteriaId = 155, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 155
UNION ALL SELECT intTaxCriteriaId = 156, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 156
UNION ALL SELECT intTaxCriteriaId = 157, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 157
UNION ALL SELECT intTaxCriteriaId = 158, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 158
UNION ALL SELECT intTaxCriteriaId = 159, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, MFT-free Only', strCriteria = '= 0', intMasterId = 159
UNION ALL SELECT intTaxCriteriaId = 160, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 160
UNION ALL SELECT intTaxCriteriaId = 161, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 161
UNION ALL SELECT intTaxCriteriaId = 162, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 162
UNION ALL SELECT intTaxCriteriaId = 163, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 163
UNION ALL SELECT intTaxCriteriaId = 164, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 164
UNION ALL SELECT intTaxCriteriaId = 165, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, MFT-free Only', strCriteria = '= 0', intMasterId = 165
UNION ALL SELECT intTaxCriteriaId = 166, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 166
UNION ALL SELECT intTaxCriteriaId = 167, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 167
UNION ALL SELECT intTaxCriteriaId = 168, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 168
UNION ALL SELECT intTaxCriteriaId = 169, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 169
UNION ALL SELECT intTaxCriteriaId = 170, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Railroads', strCriteria = '= 0', intMasterId = 170
UNION ALL SELECT intTaxCriteriaId = 171, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Railroads', strCriteria = '= 0', intMasterId = 171
UNION ALL SELECT intTaxCriteriaId = 172, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Ships etc', strCriteria = '= 0', intMasterId = 172
UNION ALL SELECT intTaxCriteriaId = 173, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Ships etc', strCriteria = '= 0', intMasterId = 173
UNION ALL SELECT intTaxCriteriaId = 174, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Kerosene Sold to Air Carriers', strCriteria = '= 0', intMasterId = 174
UNION ALL SELECT intTaxCriteriaId = 175, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Kerosene Sold to Air Carriers', strCriteria = '= 0', intMasterId = 175
UNION ALL SELECT intTaxCriteriaId = 176, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Aviation Fuel Sold to Air Carriers', strCriteria = '= 0', intMasterId = 176
UNION ALL SELECT intTaxCriteriaId = 177, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Aviation Fuel Sold to Air Carriers', strCriteria = '= 0', intMasterId = 177
UNION ALL SELECT intTaxCriteriaId = 178, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = '1-k Kerosene Sold to Air Carriers', strCriteria = '= 0', intMasterId = 178
UNION ALL SELECT intTaxCriteriaId = 179, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = '1-k Kerosene Sold to Air Carriers', strCriteria = '= 0', intMasterId = 179
UNION ALL SELECT intTaxCriteriaId = 180, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'MFT-free Only', strCriteria = '= 0', intMasterId = 180
UNION ALL SELECT intTaxCriteriaId = 181, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 181
UNION ALL SELECT intTaxCriteriaId = 182, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 182
UNION ALL SELECT intTaxCriteriaId = 183, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 183
UNION ALL SELECT intTaxCriteriaId = 184, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 184
UNION ALL SELECT intTaxCriteriaId = 185, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 185
UNION ALL SELECT intTaxCriteriaId = 186, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 186
UNION ALL SELECT intTaxCriteriaId = 187, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 187
UNION ALL SELECT intTaxCriteriaId = 188, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 188
UNION ALL SELECT intTaxCriteriaId = 189, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 189
UNION ALL SELECT intTaxCriteriaId = 190, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', strCriteria = '= 0', intMasterId = 190
UNION ALL SELECT intTaxCriteriaId = 191, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', strCriteria = '= 0', intMasterId = 191
UNION ALL SELECT intTaxCriteriaId = 192, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', strCriteria = '= 0', intMasterId = 192
UNION ALL SELECT intTaxCriteriaId = 193, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', strCriteria = '= 0', intMasterId = 193
UNION ALL SELECT intTaxCriteriaId = 194, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', strCriteria = '= 0', intMasterId = 194
UNION ALL SELECT intTaxCriteriaId = 195, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', strCriteria = '= 0', intMasterId = 195
UNION ALL SELECT intTaxCriteriaId = 196, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', strCriteria = '= 0', intMasterId = 196
UNION ALL SELECT intTaxCriteriaId = 197, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', strCriteria = '= 0', intMasterId = 197
UNION ALL SELECT intTaxCriteriaId = 198, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', strCriteria = '= 0', intMasterId = 198
UNION ALL SELECT intTaxCriteriaId = 199, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'MFT-free Only', strCriteria = '= 0', intMasterId = 199
UNION ALL SELECT intTaxCriteriaId = 200, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 200
UNION ALL SELECT intTaxCriteriaId = 201, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'UST-/EIF-free Only', strCriteria = '= 0', intMasterId = 201
UNION ALL SELECT intTaxCriteriaId = 202, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 202
UNION ALL SELECT intTaxCriteriaId = 203, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 203
UNION ALL SELECT intTaxCriteriaId = 204, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 204
UNION ALL SELECT intTaxCriteriaId = 205, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, MFT-paid Only', strCriteria = '<> 0', intMasterId = 205
UNION ALL SELECT intTaxCriteriaId = 206, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 206
UNION ALL SELECT intTaxCriteriaId = 207, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 207
UNION ALL SELECT intTaxCriteriaId = 208, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 208
UNION ALL SELECT intTaxCriteriaId = 209, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 209
UNION ALL SELECT intTaxCriteriaId = 210, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 210
UNION ALL SELECT intTaxCriteriaId = 211, strTaxCategory = 'IL Excise Tax Combustible Gases', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, MFT-paid Only', strCriteria = '<> 0', intMasterId = 211
UNION ALL SELECT intTaxCriteriaId = 212, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 212
UNION ALL SELECT intTaxCriteriaId = 213, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 213
UNION ALL SELECT intTaxCriteriaId = 214, strTaxCategory = 'IL Excise Tax Combustible Gases', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 214
UNION ALL SELECT intTaxCriteriaId = 215, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 215
UNION ALL SELECT intTaxCriteriaId = 216, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 216
UNION ALL SELECT intTaxCriteriaId = 217, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, MFT-paid Only', strCriteria = '<> 0', intMasterId = 217
UNION ALL SELECT intTaxCriteriaId = 218, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 218
UNION ALL SELECT intTaxCriteriaId = 219, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 219
UNION ALL SELECT intTaxCriteriaId = 220, strTaxCategory = 'IL Excise Tax Gasoline/Gasohol', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 220
UNION ALL SELECT intTaxCriteriaId = 221, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 221
UNION ALL SELECT intTaxCriteriaId = 222, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 222
UNION ALL SELECT intTaxCriteriaId = 223, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Aviation Fuel', strCriteria = '<> 0', intMasterId = 223
UNION ALL SELECT intTaxCriteriaId = 224, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Aviation Fuel', strCriteria = '<> 0', intMasterId = 224
UNION ALL SELECT intTaxCriteriaId = 225, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = '1-K Kerosene', strCriteria = '<> 0', intMasterId = 225
UNION ALL SELECT intTaxCriteriaId = 226, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = '1-K Kerosene', strCriteria = '<> 0', intMasterId = 226
UNION ALL SELECT intTaxCriteriaId = 227, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Dyed Diesel', strCriteria = '<> 0', intMasterId = 227
UNION ALL SELECT intTaxCriteriaId = 228, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Dyed Diesel', strCriteria = '<> 0', intMasterId = 228
UNION ALL SELECT intTaxCriteriaId = 229, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Other', strCriteria = '<> 0', intMasterId = 229
UNION ALL SELECT intTaxCriteriaId = 230, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Other', strCriteria = '<> 0', intMasterId = 230
UNION ALL SELECT intTaxCriteriaId = 231, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), MFT-paid Only', strCriteria = '<> 0', intMasterId = 231
UNION ALL SELECT intTaxCriteriaId = 232, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 232
UNION ALL SELECT intTaxCriteriaId = 233, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 233
UNION ALL SELECT intTaxCriteriaId = 234, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 234
UNION ALL SELECT intTaxCriteriaId = 235, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 235
UNION ALL SELECT intTaxCriteriaId = 236, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 236
UNION ALL SELECT intTaxCriteriaId = 237, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, MFT-paid Only', strCriteria = '<> 0', intMasterId = 237
UNION ALL SELECT intTaxCriteriaId = 238, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 238
UNION ALL SELECT intTaxCriteriaId = 239, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 239
UNION ALL SELECT intTaxCriteriaId = 240, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 240
UNION ALL SELECT intTaxCriteriaId = 241, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 241
UNION ALL SELECT intTaxCriteriaId = 242, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 242
UNION ALL SELECT intTaxCriteriaId = 243, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, MFT-paid Only', strCriteria = '<> 0', intMasterId = 243
UNION ALL SELECT intTaxCriteriaId = 244, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 244
UNION ALL SELECT intTaxCriteriaId = 245, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, UST-/EIF-paid Only', strCriteria = '<> 0', intMasterId = 245
UNION ALL SELECT intTaxCriteriaId = 246, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 246
UNION ALL SELECT intTaxCriteriaId = 247, strTaxCategory = 'IL Underground Storage Tank (UST)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 247
UNION ALL SELECT intTaxCriteriaId = 248, strTaxCategory = 'IL Environment Impact Fee (EIF)', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, Both MFT- and UST-/EIF-paid', strCriteria = '<> 0', intMasterId = 248
UNION ALL SELECT intTaxCriteriaId = 249, strTaxCategory = 'IL Excise Tax Diesel Clear', strState = 'IL', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, Both MFT- and UST-/EIF-free', strCriteria = '= 0', intMasterId = 249

EXEC uspTFUpgradeTaxCriteria @TaxAuthorityCode = @TaxAuthorityCode, @TaxCriteria = @TaxCriteria


-- Reporting Component - Base
/* Generate script for Valid Product Codes. Specify Tax Authority Id to filter out specific Valid Product Codes only.
select 'UNION ALL SELECT intValidProductCodeId = ' + CAST(intReportingComponentProductCodeId AS NVARCHAR(10))
	+ CASE WHEN PC.strProductCode IS NULL THEN ', strProductCode = NULL' ELSE ', strProductCode = ''' + PC.strProductCode + ''''  END
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = ''''' ELSE ', strType = ''' + RC.strType + '''' END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(RCPC.intMasterId, '') = '' THEN intReportingComponentProductCodeId ELSE RCPC.intMasterId END) AS NVARCHAR(20))
from tblTFReportingComponentProductCode RCPC
left join tblTFProductCode PC ON PC.intProductCodeId= RCPC.intProductCodeId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCPC.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
/* Generate script for Valid Origin States. Specify Tax Authority Id to filter out specific Valid Origin States only.
select 'UNION ALL SELECT intValidOriginStateId = ' + CAST(intReportingComponentOriginStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN RCOS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCOS.strType + ''''  END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(RCOS.intMasterId, '') = '' THEN intReportingComponentOriginStateId ELSE RCOS.intMasterId END) AS NVARCHAR(20))
from tblTFReportingComponentOriginState RCOS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCOS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCOS.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
/* Generate script for Valid Destination States. Specify Tax Authority Id to filter out specific Valid Destination States only.
select 'UNION ALL SELECT intValidDestinationStateId = ' + CAST(intReportingComponentDestinationStateId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS IS NULL THEN ', strState = NULL' ELSE ', strState = ''' + ODS.strOriginDestinationState COLLATE Latin1_General_CI_AS + ''''  END
	+ CASE WHEN RCDS.strType IS NULL THEN ', strStatus = NULL' ELSE ', strStatus = ''' + RCDS.strType + ''''  END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(RCDS.intMasterId, '') = '' THEN intReportingComponentDestinationStateId ELSE RCDS.intMasterId END) AS NVARCHAR(20))
from tblTFReportingComponentDestinationState RCDS
left join tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId= RCDS.intOriginDestinationStateId
left join tblTFReportingComponent RC ON RC.intReportingComponentId = RCDS.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @ValidProductCodes AS TFValidProductCodes
DECLARE @ValidOriginStates AS TFValidOriginStates
DECLARE @ValidDestinationStates AS TFValidDestinationStates

INSERT INTO @ValidProductCodes(
	intValidProductCodeId
	, strProductCode
	, strFormCode
	, strScheduleCode
	, strType
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intValidProductCodeId = 1422, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, MFT-free Only', intMasterId = 1422
UNION ALL SELECT intValidProductCodeId = 1423, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, MFT-free Only', intMasterId = 1423
UNION ALL SELECT intValidProductCodeId = 1424, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, MFT-free Only', intMasterId = 1424
UNION ALL SELECT intValidProductCodeId = 1425, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, UST-/EIF-free Only', intMasterId = 1425
UNION ALL SELECT intValidProductCodeId = 1426, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, UST-/EIF-free Only', intMasterId = 1426
UNION ALL SELECT intValidProductCodeId = 1427, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, UST-/EIF-free Only', intMasterId = 1427
UNION ALL SELECT intValidProductCodeId = 1428, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, Both MFT- and UST-/EIF-free', intMasterId = 1428
UNION ALL SELECT intValidProductCodeId = 1429, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, Both MFT- and UST-/EIF-free', intMasterId = 1429
UNION ALL SELECT intValidProductCodeId = 1430, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, Both MFT- and UST-/EIF-free', intMasterId = 1430
UNION ALL SELECT intValidProductCodeId = 1431, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, MFT-free Only', intMasterId = 1431
UNION ALL SELECT intValidProductCodeId = 1432, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, MFT-free Only', intMasterId = 1432
UNION ALL SELECT intValidProductCodeId = 1433, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, MFT-free Only', intMasterId = 1433
UNION ALL SELECT intValidProductCodeId = 1434, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, UST-/EIF-free Only', intMasterId = 1434
UNION ALL SELECT intValidProductCodeId = 1435, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, UST-/EIF-free Only', intMasterId = 1435
UNION ALL SELECT intValidProductCodeId = 1436, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, UST-/EIF-free Only', intMasterId = 1436
UNION ALL SELECT intValidProductCodeId = 1437, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, Both MFT- and UST-/EIF-free', intMasterId = 1437
UNION ALL SELECT intValidProductCodeId = 1438, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, Both MFT- and UST-/EIF-free', intMasterId = 1438
UNION ALL SELECT intValidProductCodeId = 1439, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, Both MFT- and UST-/EIF-free', intMasterId = 1439
UNION ALL SELECT intValidProductCodeId = 1440, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, MFT-free Only', intMasterId = 1440
UNION ALL SELECT intValidProductCodeId = 1441, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, MFT-free Only', intMasterId = 1441
UNION ALL SELECT intValidProductCodeId = 1442, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, MFT-free Only', intMasterId = 1442
UNION ALL SELECT intValidProductCodeId = 1446, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, UST-/EIF-free Only', intMasterId = 1446
UNION ALL SELECT intValidProductCodeId = 1447, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, UST-/EIF-free Only', intMasterId = 1447
UNION ALL SELECT intValidProductCodeId = 1448, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, UST-/EIF-free Only', intMasterId = 1448
UNION ALL SELECT intValidProductCodeId = 1449, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, Both MFT- and UST-/EIF-free', intMasterId = 1449
UNION ALL SELECT intValidProductCodeId = 1450, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, Both MFT- and UST-/EIF-free', intMasterId = 1450
UNION ALL SELECT intValidProductCodeId = 1451, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, Both MFT- and UST-/EIF-free', intMasterId = 1451
UNION ALL SELECT intValidProductCodeId = 1452, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, MFT-free Only', intMasterId = 1452
UNION ALL SELECT intValidProductCodeId = 1453, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, MFT-free Only', intMasterId = 1453
UNION ALL SELECT intValidProductCodeId = 1454, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, MFT-free Only', intMasterId = 1454
UNION ALL SELECT intValidProductCodeId = 1455, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, UST-/EIF-free Only', intMasterId = 1455
UNION ALL SELECT intValidProductCodeId = 1456, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, UST-/EIF-free Only', intMasterId = 1456
UNION ALL SELECT intValidProductCodeId = 1457, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, UST-/EIF-free Only', intMasterId = 1457
UNION ALL SELECT intValidProductCodeId = 1458, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, Both MFT- and UST-/EIF-free', intMasterId = 1458
UNION ALL SELECT intValidProductCodeId = 1459, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, Both MFT- and UST-/EIF-free', intMasterId = 1459
UNION ALL SELECT intValidProductCodeId = 1460, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, Both MFT- and UST-/EIF-free', intMasterId = 1460
UNION ALL SELECT intValidProductCodeId = 1461, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Received', intMasterId = 1461
UNION ALL SELECT intValidProductCodeId = 1462, strProductCode = '125', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Received', intMasterId = 1462
UNION ALL SELECT intValidProductCodeId = 1463, strProductCode = '130', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Received', intMasterId = 1463
UNION ALL SELECT intValidProductCodeId = 1464, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Received', intMasterId = 1464
UNION ALL SELECT intValidProductCodeId = 1465, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Received', intMasterId = 1465
UNION ALL SELECT intValidProductCodeId = 1466, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Imported', intMasterId = 1466
UNION ALL SELECT intValidProductCodeId = 1467, strProductCode = '125', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Imported', intMasterId = 1467
UNION ALL SELECT intValidProductCodeId = 1468, strProductCode = '130', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Imported', intMasterId = 1468
UNION ALL SELECT intValidProductCodeId = 1469, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Imported', intMasterId = 1469
UNION ALL SELECT intValidProductCodeId = 1470, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Imported', intMasterId = 1470
UNION ALL SELECT intValidProductCodeId = 1471, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, MFT-free Only', intMasterId = 1471
UNION ALL SELECT intValidProductCodeId = 1472, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, MFT-free Only', intMasterId = 1472
UNION ALL SELECT intValidProductCodeId = 1473, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, MFT-free Only', intMasterId = 1473
UNION ALL SELECT intValidProductCodeId = 1474, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, UST-/EIF-free Only', intMasterId = 1474
UNION ALL SELECT intValidProductCodeId = 1475, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, UST-/EIF-free Only', intMasterId = 1475
UNION ALL SELECT intValidProductCodeId = 1476, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, UST-/EIF-free Only', intMasterId = 1476
UNION ALL SELECT intValidProductCodeId = 1477, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, Both MFT- and UST-/EIF-free', intMasterId = 1477
UNION ALL SELECT intValidProductCodeId = 1478, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, Both MFT- and UST-/EIF-free', intMasterId = 1478
UNION ALL SELECT intValidProductCodeId = 1479, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, Both MFT- and UST-/EIF-free', intMasterId = 1479
UNION ALL SELECT intValidProductCodeId = 1480, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, MFT-free Only', intMasterId = 1480
UNION ALL SELECT intValidProductCodeId = 1481, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, MFT-free Only', intMasterId = 1481
UNION ALL SELECT intValidProductCodeId = 1482, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, MFT-free Only', intMasterId = 1482
UNION ALL SELECT intValidProductCodeId = 1483, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, UST-/EIF-free Only', intMasterId = 1483
UNION ALL SELECT intValidProductCodeId = 1484, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, UST-/EIF-free Only', intMasterId = 1484
UNION ALL SELECT intValidProductCodeId = 1485, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, UST-/EIF-free Only', intMasterId = 1485
UNION ALL SELECT intValidProductCodeId = 1486, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, Both MFT- and UST-/EIF-free', intMasterId = 1486
UNION ALL SELECT intValidProductCodeId = 1491, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, Both MFT- and UST-/EIF-free', intMasterId = 1491
UNION ALL SELECT intValidProductCodeId = 1492, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, Both MFT- and UST-/EIF-free', intMasterId = 1492
UNION ALL SELECT intValidProductCodeId = 1493, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'B', strType = '', intMasterId = 1493
UNION ALL SELECT intValidProductCodeId = 1494, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'B', strType = '', intMasterId = 1494
UNION ALL SELECT intValidProductCodeId = 1496, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'B', strType = '', intMasterId = 1496
UNION ALL SELECT intValidProductCodeId = 1497, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DB', strType = '', intMasterId = 1497
UNION ALL SELECT intValidProductCodeId = 1498, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DB', strType = '', intMasterId = 1498
UNION ALL SELECT intValidProductCodeId = 1499, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DB', strType = '', intMasterId = 1499
UNION ALL SELECT intValidProductCodeId = 1501, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Railroads', intMasterId = 1501
UNION ALL SELECT intValidProductCodeId = 1503, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Railroads', intMasterId = 1503
UNION ALL SELECT intValidProductCodeId = 1509, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Ships etc', intMasterId = 1509
UNION ALL SELECT intValidProductCodeId = 1511, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Ships etc', intMasterId = 1511
UNION ALL SELECT intValidProductCodeId = 1516, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Kerosene Sold to Air Carriers', intMasterId = 1516
UNION ALL SELECT intValidProductCodeId = 1518, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Kerosene Sold to Air Carriers', intMasterId = 1518
UNION ALL SELECT intValidProductCodeId = 1529, strProductCode = '125', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Aviation Fuel Sold to Air Carriers', intMasterId = 1529
UNION ALL SELECT intValidProductCodeId = 1530, strProductCode = '130', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Aviation Fuel Sold to Air Carriers', intMasterId = 1530
UNION ALL SELECT intValidProductCodeId = 1532, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = '1-k Kerosene Sold to Air Carriers', intMasterId = 1532
UNION ALL SELECT intValidProductCodeId = 1533, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = '1-k Kerosene Sold to Air Carriers', intMasterId = 1533
UNION ALL SELECT intValidProductCodeId = 1534, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SB', strType = '', intMasterId = 1534
UNION ALL SELECT intValidProductCodeId = 1535, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SB', strType = '', intMasterId = 1535
UNION ALL SELECT intValidProductCodeId = 1538, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SB', strType = '', intMasterId = 1538
UNION ALL SELECT intValidProductCodeId = 1536, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'C', strType = '', intMasterId = 1536
UNION ALL SELECT intValidProductCodeId = 1537, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'C', strType = '', intMasterId = 1537
UNION ALL SELECT intValidProductCodeId = 1539, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'C', strType = '', intMasterId = 1539
UNION ALL SELECT intValidProductCodeId = 1540, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DC', strType = '', intMasterId = 1540
UNION ALL SELECT intValidProductCodeId = 1541, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DC', strType = '', intMasterId = 1541
UNION ALL SELECT intValidProductCodeId = 1542, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DC', strType = '', intMasterId = 1542
UNION ALL SELECT intValidProductCodeId = 1543, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'LC', strType = '', intMasterId = 1543
UNION ALL SELECT intValidProductCodeId = 1544, strProductCode = '125', strFormCode = 'RMFT-5', strScheduleCode = 'LC', strType = '', intMasterId = 1544
UNION ALL SELECT intValidProductCodeId = 1545, strProductCode = '130', strFormCode = 'RMFT-5', strScheduleCode = 'LC', strType = '', intMasterId = 1545
UNION ALL SELECT intValidProductCodeId = 1546, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'LC', strType = '', intMasterId = 1546
UNION ALL SELECT intValidProductCodeId = 1547, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'LC', strType = '', intMasterId = 1547
UNION ALL SELECT intValidProductCodeId = 1548, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SC', strType = '', intMasterId = 1548
UNION ALL SELECT intValidProductCodeId = 1549, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SC', strType = '', intMasterId = 1549
UNION ALL SELECT intValidProductCodeId = 1550, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'MFT-free Only', intMasterId = 1550
UNION ALL SELECT intValidProductCodeId = 1551, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'MFT-free Only', intMasterId = 1551
UNION ALL SELECT intValidProductCodeId = 1558, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'MFT-free Only', intMasterId = 1558
UNION ALL SELECT intValidProductCodeId = 1552, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'UST-/EIF-free Only', intMasterId = 1552
UNION ALL SELECT intValidProductCodeId = 1553, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'UST-/EIF-free Only', intMasterId = 1553
UNION ALL SELECT intValidProductCodeId = 1557, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'UST-/EIF-free Only', intMasterId = 1557
UNION ALL SELECT intValidProductCodeId = 1554, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'Both MFT- and UST-/EIF-free', intMasterId = 1554
UNION ALL SELECT intValidProductCodeId = 1555, strProductCode = '124', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'Both MFT- and UST-/EIF-free', intMasterId = 1555
UNION ALL SELECT intValidProductCodeId = 1556, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'Both MFT- and UST-/EIF-free', intMasterId = 1556
UNION ALL SELECT intValidProductCodeId = 1559, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'MFT-free Only', intMasterId = 1559
UNION ALL SELECT intValidProductCodeId = 1560, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'MFT-free Only', intMasterId = 1560
UNION ALL SELECT intValidProductCodeId = 1561, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'MFT-free Only', intMasterId = 1561
UNION ALL SELECT intValidProductCodeId = 1562, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'UST-/EIF-free Only', intMasterId = 1562
UNION ALL SELECT intValidProductCodeId = 1563, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'UST-/EIF-free Only', intMasterId = 1563
UNION ALL SELECT intValidProductCodeId = 1564, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'UST-/EIF-free Only', intMasterId = 1564
UNION ALL SELECT intValidProductCodeId = 1565, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'Both MFT- and UST-/EIF-free', intMasterId = 1565
UNION ALL SELECT intValidProductCodeId = 1566, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'Both MFT- and UST-/EIF-free', intMasterId = 1566
UNION ALL SELECT intValidProductCodeId = 1567, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'Both MFT- and UST-/EIF-free', intMasterId = 1567
UNION ALL SELECT intValidProductCodeId = 1568, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', intMasterId = 1568
UNION ALL SELECT intValidProductCodeId = 1569, strProductCode = '125', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', intMasterId = 1569
UNION ALL SELECT intValidProductCodeId = 1570, strProductCode = '130', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', intMasterId = 1570
UNION ALL SELECT intValidProductCodeId = 1571, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', intMasterId = 1571
UNION ALL SELECT intValidProductCodeId = 1572, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', intMasterId = 1572
UNION ALL SELECT intValidProductCodeId = 1573, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', intMasterId = 1573
UNION ALL SELECT intValidProductCodeId = 1574, strProductCode = '125', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', intMasterId = 1574
UNION ALL SELECT intValidProductCodeId = 1575, strProductCode = '130', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', intMasterId = 1575
UNION ALL SELECT intValidProductCodeId = 1576, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', intMasterId = 1576
UNION ALL SELECT intValidProductCodeId = 1577, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', intMasterId = 1577
UNION ALL SELECT intValidProductCodeId = 1580, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', intMasterId = 1580
UNION ALL SELECT intValidProductCodeId = 1578, strProductCode = '125', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', intMasterId = 1578
UNION ALL SELECT intValidProductCodeId = 1581, strProductCode = '130', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', intMasterId = 1581
UNION ALL SELECT intValidProductCodeId = 1582, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', intMasterId = 1582
UNION ALL SELECT intValidProductCodeId = 1583, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', intMasterId = 1583
UNION ALL SELECT intValidProductCodeId = 1584, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'MFT-free Only', intMasterId = 1584
UNION ALL SELECT intValidProductCodeId = 1585, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'MFT-free Only', intMasterId = 1585
UNION ALL SELECT intValidProductCodeId = 1592, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'MFT-free Only', intMasterId = 1592
UNION ALL SELECT intValidProductCodeId = 1586, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'UST-/EIF-free Only', intMasterId = 1586
UNION ALL SELECT intValidProductCodeId = 1587, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'UST-/EIF-free Only', intMasterId = 1587
UNION ALL SELECT intValidProductCodeId = 1591, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'UST-/EIF-free Only', intMasterId = 1591
UNION ALL SELECT intValidProductCodeId = 1588, strProductCode = '142', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'Both MFT- and UST-/EIF-free', intMasterId = 1588
UNION ALL SELECT intValidProductCodeId = 1589, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'Both MFT- and UST-/EIF-free', intMasterId = 1589
UNION ALL SELECT intValidProductCodeId = 1590, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'Both MFT- and UST-/EIF-free', intMasterId = 1590
UNION ALL SELECT intValidProductCodeId = 1593, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'DD-1', strType = '', intMasterId = 1593
UNION ALL SELECT intValidProductCodeId = 1594, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'DD-1', strType = '', intMasterId = 1594
UNION ALL SELECT intValidProductCodeId = 1595, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'DD-1', strType = '', intMasterId = 1595
UNION ALL SELECT intValidProductCodeId = 1596, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, MFT-paid Only', intMasterId = 1596
UNION ALL SELECT intValidProductCodeId = 1599, strProductCode = 'E00', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, MFT-paid Only', intMasterId = 1599
UNION ALL SELECT intValidProductCodeId = 1597, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, UST-/EIF-paid Only', intMasterId = 1597
UNION ALL SELECT intValidProductCodeId = 1600, strProductCode = 'E00', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, UST-/EIF-paid Only', intMasterId = 1600
UNION ALL SELECT intValidProductCodeId = 1598, strProductCode = '065', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, Both MFT- and UST-/EIF-paid', intMasterId = 1598
UNION ALL SELECT intValidProductCodeId = 1601, strProductCode = 'E00', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, Both MFT- and UST-/EIF-paid', intMasterId = 1601
UNION ALL SELECT intValidProductCodeId = 1614, strProductCode = '054', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, MFT-paid Only', intMasterId = 1614
UNION ALL SELECT intValidProductCodeId = 1602, strProductCode = '224', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, MFT-paid Only', intMasterId = 1602
UNION ALL SELECT intValidProductCodeId = 1604, strProductCode = '998', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, MFT-paid Only', intMasterId = 1604
UNION ALL SELECT intValidProductCodeId = 1605, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, MFT-paid Only', intMasterId = 1605
UNION ALL SELECT intValidProductCodeId = 1616, strProductCode = '054', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, UST-/EIF-paid Only', intMasterId = 1616
UNION ALL SELECT intValidProductCodeId = 1606, strProductCode = '224', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, UST-/EIF-paid Only', intMasterId = 1606
UNION ALL SELECT intValidProductCodeId = 1608, strProductCode = '998', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, UST-/EIF-paid Only', intMasterId = 1608
UNION ALL SELECT intValidProductCodeId = 1609, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, UST-/EIF-paid Only', intMasterId = 1609
UNION ALL SELECT intValidProductCodeId = 1617, strProductCode = '054', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', intMasterId = 1617
UNION ALL SELECT intValidProductCodeId = 1610, strProductCode = '224', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', intMasterId = 1610
UNION ALL SELECT intValidProductCodeId = 1612, strProductCode = '998', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', intMasterId = 1612
UNION ALL SELECT intValidProductCodeId = 1613, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', intMasterId = 1613
UNION ALL SELECT intValidProductCodeId = 1618, strProductCode = '123', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, MFT-paid Only', intMasterId = 1618
UNION ALL SELECT intValidProductCodeId = 1619, strProductCode = '123', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, UST-/EIF-paid Only', intMasterId = 1619
UNION ALL SELECT intValidProductCodeId = 1620, strProductCode = '123', strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, Both MFT- and UST-/EIF-paid', intMasterId = 1620
UNION ALL SELECT intValidProductCodeId = 1621, strProductCode = '125', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Aviation Fuel', intMasterId = 1621
UNION ALL SELECT intValidProductCodeId = 1622, strProductCode = '130', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Aviation Fuel', intMasterId = 1622
UNION ALL SELECT intValidProductCodeId = 1623, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = '1-K Kerosene', intMasterId = 1623
UNION ALL SELECT intValidProductCodeId = 1624, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = '1-K Kerosene', intMasterId = 1624
UNION ALL SELECT intValidProductCodeId = 1625, strProductCode = '072', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Dyed Diesel', intMasterId = 1625
UNION ALL SELECT intValidProductCodeId = 1626, strProductCode = '228', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Dyed Diesel', intMasterId = 1626
UNION ALL SELECT intValidProductCodeId = 1627, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Other', intMasterId = 1627
UNION ALL SELECT intValidProductCodeId = 1628, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), MFT-paid Only', intMasterId = 1628
UNION ALL SELECT intValidProductCodeId = 1629, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), UST-/EIF-paid Only', intMasterId = 1629
UNION ALL SELECT intValidProductCodeId = 1630, strProductCode = '160', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), Both MFT- and UST-/EIF-paid', intMasterId = 1630
UNION ALL SELECT intValidProductCodeId = 1631, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, MFT-paid Only', intMasterId = 1631
UNION ALL SELECT intValidProductCodeId = 1632, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, MFT-paid Only', intMasterId = 1632
UNION ALL SELECT intValidProductCodeId = 1633, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, UST-/EIF-paid Only', intMasterId = 1633
UNION ALL SELECT intValidProductCodeId = 1634, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, UST-/EIF-paid Only', intMasterId = 1634
UNION ALL SELECT intValidProductCodeId = 1635, strProductCode = '073', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, Both MFT- and UST-/EIF-paid', intMasterId = 1635
UNION ALL SELECT intValidProductCodeId = 1636, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, Both MFT- and UST-/EIF-paid', intMasterId = 1636
UNION ALL SELECT intValidProductCodeId = 1637, strProductCode = '998', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, MFT-paid Only', intMasterId = 1637
UNION ALL SELECT intValidProductCodeId = 1638, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, MFT-paid Only', intMasterId = 1638
UNION ALL SELECT intValidProductCodeId = 1639, strProductCode = '998', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, UST-/EIF-paid Only', intMasterId = 1639
UNION ALL SELECT intValidProductCodeId = 1640, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, UST-/EIF-paid Only', intMasterId = 1640
UNION ALL SELECT intValidProductCodeId = 1641, strProductCode = '998', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, Both MFT- and UST-/EIF-paid', intMasterId = 1641
UNION ALL SELECT intValidProductCodeId = 1642, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, Both MFT- and UST-/EIF-paid', intMasterId = 1642
UNION ALL SELECT intValidProductCodeId = 1650, strProductCode = '054', strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'LP Gas', intMasterId = 1650
UNION ALL SELECT intValidProductCodeId = 1651, strProductCode = '224', strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'LP Gas', intMasterId = 1651
UNION ALL SELECT intValidProductCodeId = 1652, strProductCode = '225', strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'LP Gas', intMasterId = 1652
UNION ALL SELECT intValidProductCodeId = 1653, strProductCode = '123', strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'Alcohol', intMasterId = 1653
UNION ALL SELECT intValidProductCodeId = 1654, strProductCode = 'E00', strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'Alcohol', intMasterId = 1654
UNION ALL SELECT intValidProductCodeId = 1645, strProductCode = '145', strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = '1-K Kerosene', intMasterId = 1645
UNION ALL SELECT intValidProductCodeId = 1649, strProductCode = '285', strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'Other', intMasterId = 1649
UNION ALL SELECT intValidProductCodeId = 1643, strProductCode = '998', strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'Other', intMasterId = 1643
UNION ALL SELECT intValidProductCodeId = 1644, strProductCode = '999', strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'Other', intMasterId = 1644

INSERT INTO @ValidOriginStates(
	intValidOriginStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
	, intMasterId
)
SELECT intValidOriginStateId = 213, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 213
UNION ALL SELECT intValidOriginStateId = 214, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 214
UNION ALL SELECT intValidOriginStateId = 215, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 215
UNION ALL SELECT intValidOriginStateId = 234, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, MFT-free Only', strState = 'IL', strStatus = 'Exclude', intMasterId = 234
UNION ALL SELECT intValidOriginStateId = 217, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, UST-/EIF-free Only', strState = 'IL', strStatus = 'Exclude', intMasterId = 217
UNION ALL SELECT intValidOriginStateId = 218, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Exclude', intMasterId = 218
UNION ALL SELECT intValidOriginStateId = 233, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 233
UNION ALL SELECT intValidOriginStateId = 220, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 220
UNION ALL SELECT intValidOriginStateId = 221, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 221
UNION ALL SELECT intValidOriginStateId = 222, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, MFT-free Only', strState = 'IL', strStatus = 'Exclude', intMasterId = 222
UNION ALL SELECT intValidOriginStateId = 223, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, UST-/EIF-free Only', strState = 'IL', strStatus = 'Exclude', intMasterId = 223
UNION ALL SELECT intValidOriginStateId = 224, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Exclude', intMasterId = 224
UNION ALL SELECT intValidOriginStateId = 225, strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Received', strState = 'IL', strStatus = 'Include', intMasterId = 225
UNION ALL SELECT intValidOriginStateId = 226, strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Imported', strState = 'IL', strStatus = 'Exclude', intMasterId = 226
UNION ALL SELECT intValidOriginStateId = 227, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 227
UNION ALL SELECT intValidOriginStateId = 228, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 228
UNION ALL SELECT intValidOriginStateId = 229, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 229
UNION ALL SELECT intValidOriginStateId = 235, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, MFT-free Only', strState = 'IL', strStatus = 'Exclude', intMasterId = 235
UNION ALL SELECT intValidOriginStateId = 231, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, UST-/EIF-free Only', strState = 'IL', strStatus = 'Exclude', intMasterId = 231
UNION ALL SELECT intValidOriginStateId = 232, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Exclude', intMasterId = 232

INSERT INTO @ValidDestinationStates(
	intValidDestinationStateId
	, strFormCode
	, strScheduleCode
	, strType
	, strState
	, strStatus
	, intMasterId
)
SELECT intValidDestinationStateId = 215, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 215
UNION ALL SELECT intValidDestinationStateId = 216, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 216
UNION ALL SELECT intValidDestinationStateId = 217, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 217
UNION ALL SELECT intValidDestinationStateId = 218, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 218
UNION ALL SELECT intValidDestinationStateId = 219, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 219
UNION ALL SELECT intValidDestinationStateId = 220, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 220
UNION ALL SELECT intValidDestinationStateId = 221, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 221
UNION ALL SELECT intValidDestinationStateId = 222, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 222
UNION ALL SELECT intValidDestinationStateId = 223, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 223
UNION ALL SELECT intValidDestinationStateId = 224, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 224
UNION ALL SELECT intValidDestinationStateId = 225, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 225
UNION ALL SELECT intValidDestinationStateId = 226, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 226
UNION ALL SELECT intValidDestinationStateId = 227, strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Received', strState = 'IL', strStatus = 'Include', intMasterId = 227
UNION ALL SELECT intValidDestinationStateId = 228, strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Imported', strState = 'IL', strStatus = 'Include', intMasterId = 228
UNION ALL SELECT intValidDestinationStateId = 229, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 229
UNION ALL SELECT intValidDestinationStateId = 230, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 230
UNION ALL SELECT intValidDestinationStateId = 231, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 231
UNION ALL SELECT intValidDestinationStateId = 232, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 232
UNION ALL SELECT intValidDestinationStateId = 233, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 233
UNION ALL SELECT intValidDestinationStateId = 234, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 234
UNION ALL SELECT intValidDestinationStateId = 235, strFormCode = 'RMFT-5', strScheduleCode = 'C', strType = '', strState = 'IL', strStatus = 'Exclude', intMasterId = 235
UNION ALL SELECT intValidDestinationStateId = 236, strFormCode = 'RMFT-5', strScheduleCode = 'DC', strType = '', strState = 'IL', strStatus = 'Exclude', intMasterId = 236
UNION ALL SELECT intValidDestinationStateId = 237, strFormCode = 'RMFT-5', strScheduleCode = 'LC', strType = '', strState = 'IL', strStatus = 'Exclude', intMasterId = 237
UNION ALL SELECT intValidDestinationStateId = 238, strFormCode = 'RMFT-5', strScheduleCode = 'SC', strType = '', strState = 'IL', strStatus = 'Exclude', intMasterId = 238
UNION ALL SELECT intValidDestinationStateId = 239, strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 239
UNION ALL SELECT intValidDestinationStateId = 240, strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 240
UNION ALL SELECT intValidDestinationStateId = 241, strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 241
UNION ALL SELECT intValidDestinationStateId = 242, strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 242
UNION ALL SELECT intValidDestinationStateId = 243, strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 243
UNION ALL SELECT intValidDestinationStateId = 244, strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 244
UNION ALL SELECT intValidDestinationStateId = 245, strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', strState = 'IL', strStatus = 'Include', intMasterId = 245
UNION ALL SELECT intValidDestinationStateId = 246, strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', strState = 'IL', strStatus = 'Include', intMasterId = 246
UNION ALL SELECT intValidDestinationStateId = 247, strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', strState = 'IL', strStatus = 'Include', intMasterId = 247
UNION ALL SELECT intValidDestinationStateId = 248, strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'MFT-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 248
UNION ALL SELECT intValidDestinationStateId = 249, strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'UST-/EIF-free Only', strState = 'IL', strStatus = 'Include', intMasterId = 249
UNION ALL SELECT intValidDestinationStateId = 250, strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'Both MFT- and UST-/EIF-free', strState = 'IL', strStatus = 'Include', intMasterId = 250
UNION ALL SELECT intValidDestinationStateId = 251, strFormCode = 'RMFT-5', strScheduleCode = 'DD-1', strType = '', strState = 'IL', strStatus = 'Include', intMasterId = 251
UNION ALL SELECT intValidDestinationStateId = 253, strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'LP Gas', strState = 'IL', strStatus = 'Include', intMasterId = 253
UNION ALL SELECT intValidDestinationStateId = 254, strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'Alcohol', strState = 'IL', strStatus = 'Include', intMasterId = 254
UNION ALL SELECT intValidDestinationStateId = 255, strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = '1-K Kerosene', strState = 'IL', strStatus = 'Include', intMasterId = 255
UNION ALL SELECT intValidDestinationStateId = 256, strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'Other', strState = 'IL', strStatus = 'Include', intMasterId = 256

EXEC uspTFUpgradeValidProductCodes @TaxAuthorityCode = @TaxAuthorityCode, @ValidProductCodes = @ValidProductCodes
EXEC uspTFUpgradeValidOriginStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidOriginStates = @ValidOriginStates
EXEC uspTFUpgradeValidDestinationStates @TaxAuthorityCode = @TaxAuthorityCode, @ValidDestinationStates = @ValidDestinationStates


-- Reporting Component - Configuration
/* Generate script for Reporting Component - Configurations. Specify Tax Authority Id to filter out specific Reporting Component - Configurations only.
select 'UNION ALL SELECT intReportTemplateId = ' + CAST(intReportingComponentConfigurationId AS NVARCHAR(10))
	+ CASE WHEN RC.strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + RC.strFormCode + ''''  END
	+ CASE WHEN RC.strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + RC.strScheduleCode + ''''  END
	+ CASE WHEN RC.strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + RC.strType + '''' END
	+ CASE WHEN strTemplateItemId IS NULL THEN ', strTemplateItemId = NULL' ELSE ', strTemplateItemId = ''' + strTemplateItemId + ''''  END
	+ CASE WHEN strReportSection IS NULL THEN ', strReportSection = NULL' ELSE ', strReportSection = ''' + strReportSection + ''''  END
	+ CASE WHEN intReportItemSequence IS NULL THEN ', intReportItemSequence = NULL' ELSE ', intReportItemSequence = ''' + CAST(intReportItemSequence AS NVARCHAR(10)) + ''''  END
	+ CASE WHEN intTemplateItemNumber IS NULL THEN ', intTemplateItemNumber = NULL' ELSE ', intTemplateItemNumber = ''' + CAST(intTemplateItemNumber AS NVARCHAR(10)) + ''''  END
	+ CASE WHEN strDescription IS NULL THEN ', strDescription = NULL' ELSE ', strDescription = ''' + REPLACE(strDescription, '''', '''''') + ''''  END
	+ CASE WHEN Config.strScheduleCode IS NULL THEN ', strScheduleList = NULL' ELSE ', strScheduleList = ''' + Config.strScheduleCode + ''''  END
	+ CASE WHEN strConfiguration IS NULL THEN ', strConfiguration = NULL' ELSE ', strConfiguration = ''' + strConfiguration + ''''  END
	+ CASE WHEN ysnConfiguration IS NULL THEN ', ysnConfiguration = NULL' ELSE ', ysnConfiguration = ''' + CAST(ysnConfiguration AS NVARCHAR(5)) + ''''  END
	+ CASE WHEN ysnDynamicConfiguration IS NULL THEN ', ysnDynamicConfiguration = NULL' ELSE ', ysnDynamicConfiguration = ''' + CAST(ysnDynamicConfiguration AS NVARCHAR(5)) + ''''  END
	+ CASE WHEN strLastIndexOf IS NULL THEN ', strLastIndexOf = NULL' ELSE ', strLastIndexOf = ''' + strLastIndexOf + ''''  END
	+ CASE WHEN strSegment IS NULL THEN ', strSegment = NULL' ELSE ', strSegment = ''' + strSegment + ''''  END
	+ CASE WHEN intConfigurationSequence IS NULL THEN ', intConfigurationSequence = NULL' ELSE ', intConfigurationSequence = ''' + CAST(intConfigurationSequence AS NVARCHAR(10)) + ''''  END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(Config.intMasterId, '') = '' THEN intReportingComponentConfigurationId ELSE Config.intMasterId END) AS NVARCHAR(20))
from tblTFReportingComponentConfiguration Config
left join tblTFReportingComponent RC ON RC.intReportingComponentId = Config.intReportingComponentId
WHERE RC.intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @ReportingComponentConfigurations AS TFReportingComponentConfigurations

INSERT INTO @ReportingComponentConfigurations(
	intReportTemplateId
	, strFormCode
	, strScheduleCode
	, strType
	, strTemplateItemId
	, strReportSection
	, intReportItemSequence
	, intTemplateItemNumber
	, strDescription
	, strScheduleList
	, strConfiguration
	, ysnConfiguration
	, ysnDynamicConfiguration
	, strLastIndexOf
	, strSegment
	, intSort
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intReportTemplateId = 254, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-RecLicense', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Receiver License', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 254
UNION ALL SELECT intReportTemplateId = 255, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-Line1Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Line 1 Col 1 Beginning Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 255
UNION ALL SELECT intReportTemplateId = 256, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-Line1Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Line 1 Col 2 Beginning Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 256
UNION ALL SELECT intReportTemplateId = 257, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-Line4Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Line 4 Col 1 Ending Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 257
UNION ALL SELECT intReportTemplateId = 258, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-Line4Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Line 4 Col 2 Ending Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 258
UNION ALL SELECT intReportTemplateId = 259, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-Line9Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Line 9 Col 1 Gallons Lost due to Fire, Leakage, etc', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 259
UNION ALL SELECT intReportTemplateId = 260, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-Line9Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Line 9 Col 2 Gallons Lost due to Fire, Leakage, etc', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 260
UNION ALL SELECT intReportTemplateId = 261, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-USTRate', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'UST Rate in decimal', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 261
UNION ALL SELECT intReportTemplateId = 262, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-EIFRate', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'EIF Rate in decimal', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 262
UNION ALL SELECT intReportTemplateId = 263, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-ColDisc', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'Collection Discount in decimal', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 263
UNION ALL SELECT intReportTemplateId = 264, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, strTemplateItemId = 'RMFT-5-US-Line18', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'Line 18 Creidt', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 264
UNION ALL SELECT intReportTemplateId = 228, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-DistLicense', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '1', strDescription = 'Distributor License Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = 'Header', intConfigurationSequence = NULL, intMasterId = 228
UNION ALL SELECT intReportTemplateId = 229, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-SupplierLicense', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '2', strDescription = 'Supplier License Number', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 229
UNION ALL SELECT intReportTemplateId = 230, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line1Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '3', strDescription = 'Line 1 Col 1 Beginning Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 230
UNION ALL SELECT intReportTemplateId = 231, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line1Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '4', strDescription = 'Line 1 Col 2 Beginning Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 231
UNION ALL SELECT intReportTemplateId = 232, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line1Col3', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '5', strDescription = 'Line 1 Col 3 Beginning Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 232
UNION ALL SELECT intReportTemplateId = 233, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line4Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '6', strDescription = 'Line 4 Col 1 Ending Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 233
UNION ALL SELECT intReportTemplateId = 234, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line4Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '7', strDescription = 'Line 4 Col 2 Ending Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 234
UNION ALL SELECT intReportTemplateId = 235, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line4Col3', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '8', strDescription = 'Line 4 Col 3 Ending Inventory', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 235
UNION ALL SELECT intReportTemplateId = 236, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line8C', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '9', strDescription = 'Line 8.c Dyed Diesel for nonhighway purposes', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 236
UNION ALL SELECT intReportTemplateId = 237, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line9Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '10', strDescription = 'Line 9 Col 1 Gallons Lost due to Fire, Leakage, etc', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 237
UNION ALL SELECT intReportTemplateId = 238, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line9Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '11', strDescription = 'Line 9 Col 2 Gallons Lost due to Fire, Leakage, etc', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 238
UNION ALL SELECT intReportTemplateId = 239, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line9Col3', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '12', strDescription = 'Line 9 Col 3 Gallons Lost due to Fire, Leakage, etc', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 239
UNION ALL SELECT intReportTemplateId = 240, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line10Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '13', strDescription = 'Line 10.a or 10.b Col 1 Gallons Lost or Gained', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 240
UNION ALL SELECT intReportTemplateId = 241, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line10Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '14', strDescription = 'Line 10.a or 10.b Col 2 Gallons Lost or Gained', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 241
UNION ALL SELECT intReportTemplateId = 242, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line10Col3', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '15', strDescription = 'Line 10.a or 10.b Col 3 Gallons Lost or Gained', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 242
UNION ALL SELECT intReportTemplateId = 243, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line13Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '16', strDescription = 'Line 13 Col 1 Gallons Sold and Distributed for All Other Purposes', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 243
UNION ALL SELECT intReportTemplateId = 244, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line13Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '17', strDescription = 'Line 13 Col 2 Gallons Sold and Distributed for All Other Purposes', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 244
UNION ALL SELECT intReportTemplateId = 245, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line14Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '18', strDescription = 'Line 14 Col 1 Gallons used for Vehicles', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 245
UNION ALL SELECT intReportTemplateId = 246, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line14Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '19', strDescription = 'Line 14 Col 2 Gallons used for Vehicles', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 246
UNION ALL SELECT intReportTemplateId = 247, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line15Col1', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '20', strDescription = 'Line 15 Col 1 Gallons for Nontaxable Purposes', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 247
UNION ALL SELECT intReportTemplateId = 248, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line15Col2', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '21', strDescription = 'Line 15 Col 2 Gallons for Nontaxable Purposes', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 248
UNION ALL SELECT intReportTemplateId = 249, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-TaxRateGas', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '22', strDescription = 'Tax Rate in Decimal -- Gasoline', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 249
UNION ALL SELECT intReportTemplateId = 250, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-TaxRateSpecialFuel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '23', strDescription = 'Tax Rate in Decimal -- Special Fuel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 250
UNION ALL SELECT intReportTemplateId = 251, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-ColDiscGas', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '24', strDescription = 'Collection Discount in Decimal -- Gasoline', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 251
UNION ALL SELECT intReportTemplateId = 252, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-ColDiscSpecialFuel', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '25', strDescription = 'Collection Discount in Decimal -- Special Fuel', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 252
UNION ALL SELECT intReportTemplateId = 253, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, strTemplateItemId = 'RMFT-5-Line23', strReportSection = 'Header', intReportItemSequence = '0', intTemplateItemNumber = '26', strDescription = 'Line 23 Creidt', strScheduleList = NULL, strConfiguration = NULL, ysnConfiguration = '1', ysnDynamicConfiguration = '0', strLastIndexOf = NULL, strSegment = NULL, intConfigurationSequence = NULL, intMasterId = 253

EXEC uspTFUpgradeReportingComponentConfigurations @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentConfigurations = @ReportingComponentConfigurations


-- Reporting Component - Output Designer
/* Generate script for Reporting Component - Output Designer. Specify Tax Authority Id to filter out specific Reporting Component - Output Designer only.
select 'UNION ALL SELECT intScheduleColumnId = ' + CAST(intReportingComponentFieldId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN strColumn IS NULL THEN ', strColumn = NULL' ELSE ', strColumn = ''' + strColumn + '''' END
	+ CASE WHEN strCaption IS NULL THEN ', strCaption = NULL' ELSE ', strCaption = ''' + strCaption + '''' END
	+ CASE WHEN strFormat IS NULL THEN ', strFormat = NULL' ELSE ', strFormat = ''' + strFormat + '''' END
	+ CASE WHEN strFooter IS NULL THEN ', strFooter = NULL' ELSE ', strFooter = ''' + strFooter + '''' END
	+ CASE WHEN intWidth IS NULL THEN ', intWidth = NULL' ELSE ', intWidth = ' + CAST(intWidth AS NVARCHAR(10)) END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(RCF.intMasterId, '') = '' THEN intReportingComponentFieldId ELSE RCF.intMasterId END) AS NVARCHAR(20))
from tblTFReportingComponentField RCF
left join tblTFReportingComponent RC on RC.intReportingComponentId = RCF.intReportingComponentId
where RC.intTaxAuthorityId = @TaxAuthorityId
*/

--DECLARE @ReportingComponentOutputDesigners AS TFReportingComponentOutputDesigners

--INSERT INTO @ReportingComponentOutputDesigners(
--	intScheduleColumnId
--	, strFormCode
--	, strScheduleCode
--	, strType
--	, strColumn
--	, strCaption
--	, strFormat
--	, strFooter
--	, intWidth
--	, intMasterId
--)
---- Insert generated script here. Remove first instance of "UNION ALL "


--EXEC uspTFUpgradeReportingComponentOutputDesigners @TaxAuthorityCode = @TaxAuthorityCode, @ReportingComponentOutputDesigners = @ReportingComponentOutputDesigners


-- Filing Packet
/* Generate script for Filing Packets. Specify Tax Authority Id to filter out specific Filing Packets only.
select 'UNION ALL SELECT intFilingPacketId = ' + CAST(intFilingPacketId AS NVARCHAR(10))
	+ CASE WHEN strFormCode IS NULL THEN ', strFormCode = NULL' ELSE ', strFormCode = ''' + strFormCode + ''''  END
	+ CASE WHEN strScheduleCode IS NULL THEN ', strScheduleCode = NULL' ELSE ', strScheduleCode = ''' + strScheduleCode + ''''  END
	+ CASE WHEN strType IS NULL THEN ', strType = NULL' ELSE ', strType = ''' + strType + '''' END
	+ CASE WHEN ysnStatus IS NULL THEN ', ysnStatus = NULL' ELSE ', ysnStatus = ' + CAST(ysnStatus AS NVARCHAR) END
	+ CASE WHEN intFrequency IS NULL THEN ', intFrequency = NULL' ELSE ', intFrequency = ' + CAST(intFrequency AS NVARCHAR(10)) END
	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(FP.intMasterId, '') = '' THEN intFilingPacketId ELSE FP.intMasterId END) AS NVARCHAR(20))
from tblTFFilingPacket FP
left join tblTFReportingComponent RC on RC.intReportingComponentId = FP.intReportingComponentId
where FP.intTaxAuthorityId = @TaxAuthorityId
*/
DECLARE @FilingPackets AS TFFilingPackets

INSERT INTO @FilingPackets(
	intFilingPacketId
	, strFormCode
	, strScheduleCode
	, strType
	, ysnStatus
	, intFrequency
	, intMasterId
)
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intFilingPacketId = 2288, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, MFT-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2288
UNION ALL SELECT intFilingPacketId = 2289, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, UST-/EIF-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2289
UNION ALL SELECT intFilingPacketId = 2290, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Received, Both MFT- and UST-/EIF-free', ysnStatus = 1, intFrequency = 1, intMasterId = 2290
UNION ALL SELECT intFilingPacketId = 2291, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, MFT-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2291
UNION ALL SELECT intFilingPacketId = 2292, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, UST-/EIF-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2292
UNION ALL SELECT intFilingPacketId = 2293, strFormCode = 'RMFT-5', strScheduleCode = 'A', strType = 'Imported, Both MFT- and UST-/EIF-free', ysnStatus = 1, intFrequency = 1, intMasterId = 2293
UNION ALL SELECT intFilingPacketId = 2294, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, MFT-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2294
UNION ALL SELECT intFilingPacketId = 2295, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, UST-/EIF-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2295
UNION ALL SELECT intFilingPacketId = 2296, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Received, Both MFT- and UST-/EIF-free', ysnStatus = 1, intFrequency = 1, intMasterId = 2296
UNION ALL SELECT intFilingPacketId = 2297, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, MFT-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2297
UNION ALL SELECT intFilingPacketId = 2298, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, UST-/EIF-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2298
UNION ALL SELECT intFilingPacketId = 2299, strFormCode = 'RMFT-5', strScheduleCode = 'DA', strType = 'Imported, Both MFT- and UST-/EIF-free', ysnStatus = 1, intFrequency = 1, intMasterId = 2299
UNION ALL SELECT intFilingPacketId = 2300, strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Received', ysnStatus = 1, intFrequency = 1, intMasterId = 2300
UNION ALL SELECT intFilingPacketId = 2301, strFormCode = 'RMFT-5', strScheduleCode = 'LA', strType = 'Imported', ysnStatus = 1, intFrequency = 1, intMasterId = 2301
UNION ALL SELECT intFilingPacketId = 2302, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, MFT-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2302
UNION ALL SELECT intFilingPacketId = 2303, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, UST-/EIF-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2303
UNION ALL SELECT intFilingPacketId = 2304, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Received, Both MFT- and UST-/EIF-free', ysnStatus = 1, intFrequency = 1, intMasterId = 2304
UNION ALL SELECT intFilingPacketId = 2305, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, MFT-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2305
UNION ALL SELECT intFilingPacketId = 2306, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, UST-/EIF-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2306
UNION ALL SELECT intFilingPacketId = 2307, strFormCode = 'RMFT-5', strScheduleCode = 'SA', strType = 'Imported, Both MFT- and UST-/EIF-free', ysnStatus = 1, intFrequency = 1, intMasterId = 2307
UNION ALL SELECT intFilingPacketId = 2308, strFormCode = 'RMFT-5', strScheduleCode = 'B', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 2308
UNION ALL SELECT intFilingPacketId = 2309, strFormCode = 'RMFT-5', strScheduleCode = 'DB', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 2309
UNION ALL SELECT intFilingPacketId = 2310, strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Railroads', ysnStatus = 1, intFrequency = 1, intMasterId = 2310
UNION ALL SELECT intFilingPacketId = 2311, strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Diesel Sold to Ships etc', ysnStatus = 1, intFrequency = 1, intMasterId = 2311
UNION ALL SELECT intFilingPacketId = 2312, strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Kerosene Sold to Air Carriers', ysnStatus = 1, intFrequency = 1, intMasterId = 2312
UNION ALL SELECT intFilingPacketId = 2313, strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = 'Aviation Fuel Sold to Air Carriers', ysnStatus = 1, intFrequency = 1, intMasterId = 2313
UNION ALL SELECT intFilingPacketId = 2314, strFormCode = 'RMFT-5', strScheduleCode = 'LB', strType = '1-k Kerosene Sold to Air Carriers', ysnStatus = 1, intFrequency = 1, intMasterId = 2314
UNION ALL SELECT intFilingPacketId = 2315, strFormCode = 'RMFT-5', strScheduleCode = 'SB', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 2315
UNION ALL SELECT intFilingPacketId = 2316, strFormCode = 'RMFT-5', strScheduleCode = 'C', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 2316
UNION ALL SELECT intFilingPacketId = 2317, strFormCode = 'RMFT-5', strScheduleCode = 'DC', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 2317
UNION ALL SELECT intFilingPacketId = 2318, strFormCode = 'RMFT-5', strScheduleCode = 'LC', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 2318
UNION ALL SELECT intFilingPacketId = 2319, strFormCode = 'RMFT-5', strScheduleCode = 'SC', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 2319
UNION ALL SELECT intFilingPacketId = 2320, strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'MFT-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2320
UNION ALL SELECT intFilingPacketId = 2321, strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'UST-/EIF-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2321
UNION ALL SELECT intFilingPacketId = 2322, strFormCode = 'RMFT-5', strScheduleCode = 'D', strType = 'Both MFT- and UST-/EIF-free', ysnStatus = 1, intFrequency = 1, intMasterId = 2322
UNION ALL SELECT intFilingPacketId = 2323, strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'MFT-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2323
UNION ALL SELECT intFilingPacketId = 2324, strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'UST-/EIF-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2324
UNION ALL SELECT intFilingPacketId = 2325, strFormCode = 'RMFT-5', strScheduleCode = 'DD', strType = 'Both MFT- and UST-/EIF-free', ysnStatus = 1, intFrequency = 1, intMasterId = 2325
UNION ALL SELECT intFilingPacketId = 2326, strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Aviation Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 2326
UNION ALL SELECT intFilingPacketId = 2327, strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = '1-k Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 2327
UNION ALL SELECT intFilingPacketId = 2328, strFormCode = 'RMFT-5', strScheduleCode = 'LD', strType = 'Other', ysnStatus = 1, intFrequency = 1, intMasterId = 2328
UNION ALL SELECT intFilingPacketId = 2329, strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'MFT-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2329
UNION ALL SELECT intFilingPacketId = 2330, strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'UST-/EIF-free Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2330
UNION ALL SELECT intFilingPacketId = 2331, strFormCode = 'RMFT-5', strScheduleCode = 'SD', strType = 'Both MFT- and UST-/EIF-free', ysnStatus = 1, intFrequency = 1, intMasterId = 2331
UNION ALL SELECT intFilingPacketId = 2332, strFormCode = 'RMFT-5', strScheduleCode = 'DD-1', strType = '', ysnStatus = 1, intFrequency = 1, intMasterId = 2332
UNION ALL SELECT intFilingPacketId = 2333, strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, MFT-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2333
UNION ALL SELECT intFilingPacketId = 2334, strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, UST-/EIF-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2334
UNION ALL SELECT intFilingPacketId = 2335, strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Gasoline, Both MFT- and UST-/EIF-paid', ysnStatus = 1, intFrequency = 1, intMasterId = 2335
UNION ALL SELECT intFilingPacketId = 2336, strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, MFT-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2336
UNION ALL SELECT intFilingPacketId = 2337, strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, UST-/EIF-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2337
UNION ALL SELECT intFilingPacketId = 2338, strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Combustible Gases, Both MFT- and UST-/EIF-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2338
UNION ALL SELECT intFilingPacketId = 2339, strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, MFT-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2339
UNION ALL SELECT intFilingPacketId = 2340, strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, UST-/EIF-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2340
UNION ALL SELECT intFilingPacketId = 2341, strFormCode = 'RMFT-5', strScheduleCode = 'E', strType = 'Alcohol, Both MFT- and UST-/EIF-paid', ysnStatus = 1, intFrequency = 1, intMasterId = 2341
UNION ALL SELECT intFilingPacketId = 2342, strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Aviation Fuel', ysnStatus = 1, intFrequency = 1, intMasterId = 2342
UNION ALL SELECT intFilingPacketId = 2343, strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = '1-K Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 2343
UNION ALL SELECT intFilingPacketId = 2344, strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Dyed Diesel', ysnStatus = 1, intFrequency = 1, intMasterId = 2344
UNION ALL SELECT intFilingPacketId = 2345, strFormCode = 'RMFT-5', strScheduleCode = 'LE', strType = 'Other', ysnStatus = 1, intFrequency = 1, intMasterId = 2345
UNION ALL SELECT intFilingPacketId = 2346, strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), MFT-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2346
UNION ALL SELECT intFilingPacketId = 2347, strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), UST-/EIF-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2347
UNION ALL SELECT intFilingPacketId = 2348, strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Special Fuel (Excluding Dyed Diesel), Both MFT- and UST-/EIF-paid', ysnStatus = 1, intFrequency = 1, intMasterId = 2348
UNION ALL SELECT intFilingPacketId = 2349, strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, MFT-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2349
UNION ALL SELECT intFilingPacketId = 2350, strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, UST-/EIF-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2350
UNION ALL SELECT intFilingPacketId = 2351, strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = '1-K Kerosene, Both MFT- and UST-/EIF-paid', ysnStatus = 1, intFrequency = 1, intMasterId = 2351
UNION ALL SELECT intFilingPacketId = 2352, strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, MFT-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2352
UNION ALL SELECT intFilingPacketId = 2353, strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, UST-/EIF-paid Only', ysnStatus = 1, intFrequency = 1, intMasterId = 2353
UNION ALL SELECT intFilingPacketId = 2354, strFormCode = 'RMFT-5', strScheduleCode = 'SE', strType = 'Other, Both MFT- and UST-/EIF-paid', ysnStatus = 1, intFrequency = 1, intMasterId = 2354
UNION ALL SELECT intFilingPacketId = 2355, strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'LP Gas', ysnStatus = 1, intFrequency = 1, intMasterId = 2355
UNION ALL SELECT intFilingPacketId = 2356, strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'Alcohol', ysnStatus = 1, intFrequency = 1, intMasterId = 2356
UNION ALL SELECT intFilingPacketId = 2357, strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = '1-K Kerosene', ysnStatus = 1, intFrequency = 1, intMasterId = 2357
UNION ALL SELECT intFilingPacketId = 2358, strFormCode = 'RMFT-5', strScheduleCode = 'GA-1', strType = 'Other', ysnStatus = 1, intFrequency = 1, intMasterId = 2358
UNION ALL SELECT intFilingPacketId = 2359, strFormCode = 'RMFT-5', strScheduleCode = 'M', strType = 'Gasoline', ysnStatus = 1, intFrequency = 1, intMasterId = 2359
UNION ALL SELECT intFilingPacketId = 2360, strFormCode = 'RMFT-5', strScheduleCode = 'M', strType = 'Special Fuels', ysnStatus = 1, intFrequency = 1, intMasterId = 2360
UNION ALL SELECT intFilingPacketId = 2361, strFormCode = 'RMFT-5', strScheduleCode = 'RMFT-5-US', strType = NULL, ysnStatus = 1, intFrequency = 1, intMasterId = 2361
UNION ALL SELECT intFilingPacketId = 2362, strFormCode = 'RMFT-5', strScheduleCode = '', strType = NULL, ysnStatus = 1, intFrequency = 1, intMasterId = 2362
UNION ALL SELECT intFilingPacketId = 2590, strFormCode = 'E-file', strScheduleCode = '', strType = 'Text File', ysnStatus = 1, intFrequency = 1, intMasterId = 2590

EXEC uspTFUpgradeFilingPackets @TaxAuthorityCode = @TaxAuthorityCode, @FilingPackets = @FilingPackets

GO